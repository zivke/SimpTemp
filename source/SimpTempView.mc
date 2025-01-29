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

    drawCurrentTime(dc);
    drawTemperatureValues(dc, temperatureIterator);
    drawTemperatureChart(dc, temperatureIterator);
  }

  function drawCurrentTime(dc as Graphics.Dc) {
    var currentTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var timeFormat = "$1$:$2$"; // Time format (HH:MM)

    // Set text color to black
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);

    // Draw the current time
    dc.drawText(
      dc.getWidth() / 2 - 6,
      10,
      Graphics.FONT_XTINY,
      Lang.format(timeFormat, [
        currentTime.hour.format("%02d"),
        currentTime.min.format("%02d"),
      ]),
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
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
      22,
      Graphics.FONT_XTINY,
      "min: " + minimumTemperature.format("%.1f") + "°",
      Graphics.TEXT_JUSTIFY_LEFT
    );

    // Get and draw the maximum temperature value
    maximumTemperature = iter.getMax();
    dc.drawText(
      20,
      42,
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
    var chartHeight = 80; // Chart height
    var chartX = (dc.getWidth() - chartWidth) / 2; // X position of the chart
    var chartY = dc.getHeight() - chartHeight - 20; // Y position of the chart
    var historySize = 120; // 120 data points (4 hours, every 2 minutes)
    var temperatureHistory = new Lang.Array<
      Number or Float or Null
    >[historySize]; // Initialize temperature history array

    // Adjust min and max to ensure a visible range
    var chartMinimum = Math.floor(minimumTemperature).toNumber() - 4;
    var chartMaximum = Math.ceil(maximumTemperature).toNumber() + 4;

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

    // Draw chart frame (FOR DEBUGGING PURPOSES)
    // dc.drawRectangle(chartX, chartY, chartWidth, chartHeight);

    // Draw chart
    var xStep = chartWidth.toFloat() / historySize;
    var yScale = chartHeight.toFloat() / (chartMaximum - chartMinimum);
    for (var i = 1; i < historySize; i++) {
      if (temperatureHistory[i] != null) {
        var x = Math.ceil(chartX + i * xStep);
        var y = Math.ceil(
          chartY + chartHeight - (temperatureHistory[i] - chartMinimum) * yScale
        );
        dc.drawLine(chartX + i, chartY + chartHeight, x, y);
      }
    }

    dc.drawText(
      dc.getWidth() / 2,
      chartY + chartHeight + 8,
      Graphics.FONT_XTINY,
      "Last 4 hours",
      Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );

    // Display min and max temperature values on the chart (triangles)
    for (var i = 0; i < historySize; i++) {
      if (temperatureHistory[i] == minimumTemperature) {
        var x = chartX + i * xStep;
        var y = chartY + chartHeight - 9;
        drawMinTriangle(dc, x, y);
      }
      if (temperatureHistory[i] == maximumTemperature) {
        var x = chartX + i * xStep;
        var y = chartY + 8;
        drawMaxTriangle(dc, x, y);
      }
    }
  }

  // Draw the triangle to indicate the minimum temperature value
  function drawMinTriangle(
    dc as Graphics.Dc,
    pointX as Numeric,
    pointY as Numeric
  ) {
    // Create the polygon points array
    var points = [
      [pointX, pointY],
      [pointX + 4, pointY + 7],
      [pointX - 4, pointY + 7],
    ];

    // Draw the triangle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon(points);

    // Draw the triangle outline (so it is visible if it goes outside of the chart)
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(pointX, pointY - 1, pointX + 5, pointY + 8);
    dc.drawLine(pointX + 5, pointY + 8, pointX - 5, pointY + 8);
    dc.drawLine(pointX - 5, pointY + 8, pointX, pointY - 1);
  }

  // Draw the triangle to indicate the minimum temperature value
  function drawMaxTriangle(
    dc as Graphics.Dc,
    pointX as Numeric,
    pointY as Numeric
  ) {
    // Create the polygon points array
    var points = [
      [pointX, pointY],
      [pointX + 4, pointY - 7],
      [pointX - 4, pointY - 7],
    ];

    // Draw the triangle
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon(points);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
