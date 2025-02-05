import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;

(:glance)
class SimpTempState {
  var historySize as Number = 120; // 120 data points (4 hours, every 2 minutes)
  var temperatureHistory as Lang.Array<Number or Float or Null> =
    new Lang.Array<Number or Float or Null>[historySize];
  var temperature as Number or Float or Null; // Current temperature value
  var minimumTemperature as Number or Float or Null; // Minimum temperature value
  var maximumTemperature as Number or Float or Null; // Maximum temperature value

  var timer as Timer.Timer = new Timer.Timer();

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

    timer.start(method(:load), 60000, true); // Load the temperature data every 2 minutes
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
    self.temperature = sensorSample.data;

    while (sensorSample != null) {
      var timeDiff = sensorSample.when.subtract(startTime);
      //   System.print("Time diff: " + timeDiff.value() + "\t");
      var index = Math.floor(timeDiff.value() / 120); // Every 2 minutes
      temperatureHistory[index] = sensorSample.data;

      sensorSample = temperatureIterator.next();
    }

    self.minimumTemperature = temperatureIterator.getMin();
    self.maximumTemperature = temperatureIterator.getMax();

    WatchUi.requestUpdate();
  }

  function reset() as Void {
    temperatureHistory = new Lang.Array<Number or Float or Null>[historySize];
    temperature = null;
    minimumTemperature = null;
    maximumTemperature = null;
  }
}
