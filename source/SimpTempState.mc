import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;

(:glance)
class SimpTempState {
  private var _historySize as Number = 120; // 120 data points (4 hours, every 2 minutes)
  private var _temperatureHistory as Lang.Array<Number or Float or Null> =
    new Lang.Array<Number or Float or Null>[_historySize];
  private var _temperature as Number or Float or Null; // Current temperature value
  private var _minimumTemperature as Number or Float or Null; // Minimum temperature value
  private var _maximumTemperature as Number or Float or Null; // Maximum temperature value

  private var _timer as Timer.Timer = new Timer.Timer();

  function initialize() {
    // Check device for SensorHistory compatibility
    if (
      !(Toybox has :SensorHistory) ||
      !(Toybox.SensorHistory has :getTemperatureHistory)
    ) {
      // TODO: Not supported - display a text message
      return; // TODO
    }

    load();

    _timer.start(method(:load), 60000, true); // Load the temperature data every 2 minutes
  }

  function load() as Void {
    reset();

    // Get the temperature history iterator
    var temperatureIterator = Toybox.SensorHistory.getTemperatureHistory({
      :period => new Time.Duration(Gregorian.SECONDS_PER_HOUR * 4),
      :order => SensorHistory.ORDER_NEWEST_FIRST,
    });

    // Get the temperature indexes for the temperature history array
    var startTime = temperatureIterator.getOldestSampleTime();
    var endTime = temperatureIterator.getNewestSampleTime();
    if (startTime == null || endTime == null) {
      // Invalid data - skip drawing the chart
      return;
    }

    var sensorSample = temperatureIterator.next();
    if (sensorSample == null) {
      // No data - skip drawing the chart
      return;
    }
    self._temperature = sensorSample.data;

    while (sensorSample != null) {
      var timeDiff = sensorSample.when.subtract(startTime);
      //   System.print("Time diff: " + timeDiff.value() + "\t");
      var index = Math.floor(timeDiff.value() / 120); // Every 2 minutes
      _temperatureHistory[index] = sensorSample.data;

      sensorSample = temperatureIterator.next();
    }

    self._minimumTemperature = temperatureIterator.getMin();
    self._maximumTemperature = temperatureIterator.getMax();

    WatchUi.requestUpdate();
  }

  function reset() as Void {
    _temperatureHistory = new Lang.Array<Number or Float or Null>[_historySize];
    _temperature = null;
    _minimumTemperature = null;
    _maximumTemperature = null;
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

  function getTemperatureHistory() as Lang.Array<Number or Float or Null> {
    return _temperatureHistory;
  }

  function getHistorySize() as Number {
    return _historySize;
  }
}
