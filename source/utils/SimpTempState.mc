import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;

(:glance)
class Status {
  enum Code {
    UNKNOWN_ERROR = -5,
    UNSUPPORTED = -4,
    NO_MIN_MAX_TEMPERATURE = -3,
    NO_CURRENT_TEMPERATURE = -2,
    INVALID_DATA = -1,
    INITIALIZING = 0,
    LOADING = 1,
    DONE = 2,
  }

  private var _code as Code = INITIALIZING;

  function getCode() as Code {
    return _code;
  }

  function setCode(code as Code) {
    self._code = code;
    WatchUi.requestUpdate();
  }

  function hasError() {
    return _code < 0;
  }

  function getMessage() as String {
    var message = "";
    if (_code < 0) {
      message = "Error: ";
    }

    switch (self._code) {
      case UNKNOWN_ERROR:
        message += "Unknown";
        break;
      case UNSUPPORTED:
        message += "Sensors not supported";
        break;
      case NO_MIN_MAX_TEMPERATURE:
        message += "No minimum or maximum temperature";
        break;
      case NO_CURRENT_TEMPERATURE:
        message += "No current temperature";
        break;
      case INVALID_DATA:
        message += "Invalid data";
        break;
      case INITIALIZING:
        message += "Initializing...";
        break;
      case LOADING:
        message += "Loading...";
        break;
      case DONE:
        message += "Done";
        break;
      default: {
        message += "Status unknown";
        break;
      }
    }

    return message;
  }
}

(:glance)
class SimpTempState {
  // Fetch the system units
  private var _systemUnits as System.UnitsSystem =
    System.getDeviceSettings().temperatureUnits;

  // Used for various adjustments depending on the screen resolution
  private var _sizeFactor as Number = Math.floor(
    System.getDeviceSettings().screenWidth / 100
  ).toNumber();

  // Determine the best size of the sensor history depending on the screen size and resolution
  private var _historyHours as Number = Math.floor(
    System.getDeviceSettings().screenWidth / 30 - _sizeFactor
  ).toNumber();
  private var _historySize as Number = _historyHours * 30; // 30 data points per hour, every 2 minutes
  private var _temperatureHistory as Lang.Array<Number or Float or Null> =
    new Lang.Array<Number or Float or Null>[_historySize];
  private var _temperature as Number or Float or Null; // Current temperature value
  private var _minimumTemperature as Number or Float or Null; // Minimum temperature value
  private var _maximumTemperature as Number or Float or Null; // Maximum temperature value

  private var _timer as Timer.Timer;

  private var _status as Status;

  // Time to wait before retrying to load the temperature data
  private var _retryDelay as Number = 2000;
  private var _retryCount as Number = 0;

  function initialize() {
    self._status = new Status();
    _timer = new Timer.Timer();

    // Check device for SensorHistory compatibility
    if (
      !(Toybox has :SensorHistory) ||
      !(Toybox.SensorHistory has :getTemperatureHistory)
    ) {
      _status.setCode(Status.UNSUPPORTED);
      return;
    }

    load();
  }

  function load() as Void {
    if (_status.getCode() == Status.INITIALIZING) {
      _status.setCode(Status.LOADING);
    } else if (_status.getCode() == Status.LOADING) {
      return;
    } else if (_status.getCode() == Status.DONE) {
      _retryCount = 0;
      _status.setCode(Status.LOADING);
    } else {
      _retryCount += 1;
      if (_retryCount >= 4) {
        // Fatal error - stop everything and keep the last error
        _timer.stop();
        WatchUi.requestUpdate();
        return;
      }
    }

    reset();

    // Get the temperature history iterator
    var temperatureIterator = Toybox.SensorHistory.getTemperatureHistory({
      :period => new Time.Duration(Gregorian.SECONDS_PER_HOUR * _historyHours),
      :order => SensorHistory.ORDER_NEWEST_FIRST,
    });

    // Get the temperature indexes for the temperature history array
    var startTime = temperatureIterator.getOldestSampleTime();
    var endTime = temperatureIterator.getNewestSampleTime();
    if (startTime == null || endTime == null) {
      _status.setCode(Status.INVALID_DATA);
      _timer.stop();
      _timer.start(method(:load), _retryDelay, true); // Try to reload every 5 seconds
      return;
    }

    // It has happened sometimes that the time difference between the first and last sample
    // is more than the expected history size. In this case, we need to adjust the index.
    var totalTimeDiff = endTime.subtract(startTime);
    var index_correction =
      _historySize - 1 - Math.floor(totalTimeDiff.value() / 120).toNumber();

    var sensorSample = temperatureIterator.next();
    if (sensorSample == null || sensorSample.data == null) {
      _status.setCode(Status.NO_CURRENT_TEMPERATURE);
      _timer.stop();
      _timer.start(method(:load), _retryDelay, true); // Try to reload every 5 seconds
      return;
    }
    self._temperature = convertTemperature(sensorSample.data);

    while (sensorSample != null) {
      if (sensorSample.data != null) {
        var timeDiff = sensorSample.when.subtract(startTime);
        var index =
          Math.floor(timeDiff.value() / 120).toNumber() + index_correction; // Every 2 minutes
        if (index >= 0 && index < _historySize) {
          _temperatureHistory[index] = convertTemperature(sensorSample.data);
        } else {
          System.println(
            "Error: Temperature reading time out of range (index: " +
              index +
              ")"
          );
        }
      }

      sensorSample = temperatureIterator.next();
    }

    self._minimumTemperature = convertTemperature(temperatureIterator.getMin());
    self._maximumTemperature = convertTemperature(temperatureIterator.getMax());

    if (_minimumTemperature == null || _maximumTemperature == null) {
      _status.setCode(Status.INVALID_DATA);
      _timer.stop();
      _timer.start(method(:load), _retryDelay, true); // Try to reload every 5 seconds
      return;
    }

    _status.setCode(Status.DONE);
    _timer.stop();
    _timer.start(method(:load), 60000, true); // Load the temperature data every minute

    // WatchUi.requestUpdate(); gets called by _status.setCode()
  }

  private function reset() as Void {
    _temperatureHistory = new Lang.Array<Number or Float or Null>[_historySize];
    _temperature = null;
    _minimumTemperature = null;
    _maximumTemperature = null;
  }

  private function convertTemperature(
    temperature as Number or Float or Null
  ) as Number or Float or Null {
    if (temperature == null) {
      return null;
    }

    if (_systemUnits == System.UNIT_STATUTE) {
      return temperature * 1.8 + 32;
    }

    return temperature;
  }

  function destroy() as Void {
    _timer.stop();
  }

  function getSystemUnits() as System.UnitsSystem {
    return _systemUnits;
  }

  function getSizeFactor() as Number {
    return _sizeFactor;
  }

  function getHistoryHours() as Number {
    return _historyHours;
  }

  function getHistorySize() as Number {
    return _historySize;
  }

  function getTemperatureHistory() as Lang.Array<Number or Float or Null> {
    return _temperatureHistory;
  }

  function getTemperature() as Number or Float or Null {
    return _temperature;
  }

  function getMinimumTemperature() as Number or Float or Null {
    return _minimumTemperature;
  }

  function getMaximumTemperature() as Number or Float or Null {
    return _maximumTemperature;
  }

  function getStatus() as Status {
    return _status;
  }
}
