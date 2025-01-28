import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class SimpTempView extends WatchUi.View {
  var temperature as Number or Float or Null; // Current temperature value
  var minimumTemperature as Number or Float or Null; // Minimum temperature value
  var maximumTemperature as Number or Float or Null; // Maximum temperature value

  function initialize() {
    View.initialize();

    temperature = null;
    minimumTemperature = null;
    maximumTemperature = null;

    // Check device for SensorHistory compatibility
    if (
      !(Toybox has :SensorHistory) ||
      !(Toybox.SensorHistory has :getTemperatureHistory)
    ) {
      // TODO: Not supported - display a text message
    }
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.MainLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    // Clear the screen
    dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_WHITE);
    dc.clear();

    // Get the temperature history iterator
    var temperatureIterator = Toybox.SensorHistory.getTemperatureHistory({
      :period => new Time.Duration(Gregorian.SECONDS_PER_HOUR * 4),
      :order => SensorHistory.ORDER_NEWEST_FIRST,
    });

    drawTemperatureValues(dc, temperatureIterator);
    drawTemperatureChart(dc, temperatureIterator);
  }

  // Draw the temperature values
  function drawTemperatureValues(
    dc as Graphics.Dc,
    iter as SensorHistoryIterator?
  ) {
    if (iter == null) {
      // Skip drawing new data if there is no valid data
      return;
    }

    // Get and draw the current temperature value
    temperature = iter.next().data;

    // Set text color to black
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      145,
      20,
      Graphics.FONT_SMALL,
      temperature.format("%.1f") + "°",
      Graphics.TEXT_JUSTIFY_CENTER
    );

    // Get and draw the minimum temperature value
    minimumTemperature = iter.getMin();
    dc.drawText(
      20,
      20,
      Graphics.FONT_XTINY,
      "min: " + minimumTemperature.format("%.1f") + "°",
      Graphics.TEXT_JUSTIFY_LEFT
    );

    // Get and draw the maximum temperature value
    maximumTemperature = iter.getMax();
    dc.drawText(
      20,
      40,
      Graphics.FONT_XTINY,
      "max: " + maximumTemperature.format("%.1f") + "°",
      Graphics.TEXT_JUSTIFY_LEFT
    );
  }

  // Draw the temperature chart
  function drawTemperatureChart(
    dc as Graphics.Dc,
    iter as SensorHistoryIterator?
  ) {
    if (iter == null) {
      // Skip drawing new data if there is no valid data
      return;
    }

    // If no valid data, skip drawing the chart
    if (minimumTemperature == null || maximumTemperature == null) {
      // Missing data - skip drawing the chart
      return;
    }

    // Get the temperature indexes for the temperature history array
    var startTime = iter.getOldestSampleTime();
    var endTime = iter.getNewestSampleTime();
    if (startTime == null || endTime == null) {
      // Invalid data - skip drawing the chart
      return;
    }

    var chartWidth = 120; // Chart width with padding
    var chartHeight = 70; // Chart height
    var chartX = (dc.getWidth() - chartWidth) / 2; // X position of the chart
    var chartY = dc.getHeight() - chartHeight - 30; // Y position of the chart
    var historySize = 120; // 120 data points (4 hours, every 2 minutes)
    var temperatureHistory = new Lang.Array<
      Number or Float or Null
    >[historySize]; // Initialize temperature history array

    // Adjust min and max to ensure a visible range
    var chartMinimum = Math.floor(minimumTemperature).toNumber() - 1;
    var chartMaximum = Math.ceil(maximumTemperature).toNumber() + 1;

    // Draw X-axis labels (time)
    var timeFormat = "$1$:$2$"; // Time format (HH:MM)
    var startTimeLabel = Gregorian.info(startTime, Time.FORMAT_SHORT);
    var endTimeLabel = Gregorian.info(endTime, Time.FORMAT_SHORT);

    for (
      var sensorSample = iter.next();
      sensorSample != null;
      sensorSample = iter.next()
    ) {
      var timeDiff = sensorSample.when.subtract(startTime);
      var index = Math.floor(timeDiff.value() / 120); // Every 2 minutes
      temperatureHistory[index] = sensorSample.data;
    }
    // Add the current temperature to the history array
    // (since it has already been read from the iteraror before and cannot
    // be read again from it without reloading the data)
    temperatureHistory[historySize - 1] = temperature;

    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

    // Draw chart
    var xStep = chartWidth.toFloat() / historySize;
    var yScale = chartHeight.toFloat() / (chartMaximum - chartMinimum);
    for (var i = 1; i < historySize; i++) {
      if (temperatureHistory[i] != null) {
        var x = chartX + i * xStep;
        var y =
          chartY +
          chartHeight -
          (temperatureHistory[i] - chartMinimum) * yScale; // minimumTemperature?
        dc.drawLine(chartX + i, chartY + chartHeight, x, y);
      }
    }

    // Draw X-axis labels (start/end time)
    dc.drawText(
      chartX - 5,
      chartY + chartHeight + 7,
      Graphics.FONT_XTINY,
      Lang.format(timeFormat, [
        startTimeLabel.hour.format("%02d"),
        startTimeLabel.min.format("%02d"),
      ]),
      Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      chartX + chartWidth + 5,
      chartY + chartHeight + 7,
      Graphics.FONT_XTINY,
      Lang.format(timeFormat, [
        endTimeLabel.hour.format("%02d"),
        endTimeLabel.min.format("%02d"),
      ]),
      Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // Display min and max temperature values on the chart (white circles)
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    for (var i = 0; i < historySize; i++) {
      if (temperatureHistory[i] == minimumTemperature) {
        var x = chartX + i * xStep;
        var y = chartY + chartHeight - 4;
        dc.fillCircle(x, y, 2);
      }
      if (temperatureHistory[i] == maximumTemperature) {
        var x = chartX + i * xStep;
        var y = chartY + chartHeight - 4;
        dc.fillCircle(x, y, 2);
      }
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
