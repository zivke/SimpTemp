import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

(:glance)
class SimpTempView extends WatchUi.View {
  var simpTempState as SimpTempState?;

  function initialize(simpTempState as SimpTempState) {
    self.simpTempState = simpTempState;
    View.initialize();
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

    drawCurrentTime(dc);
    drawTemperatureValues(dc);
    drawTemperatureChart(dc);
  }

  function drawCurrentTime(dc as Graphics.Dc) {
    var currentTime = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var timeFormat = "$1$:$2$"; // Time format (HH:MM)
    var clockLabel = View.findDrawableById("clockValue") as Text?;
    if (clockLabel != null) {
      clockLabel.setText(
        Lang.format(timeFormat, [
          currentTime.hour.format("%02d"),
          currentTime.min.format("%02d"),
        ])
      );
    }
  }

  // Draw the temperature values
  function drawTemperatureValues(dc as Graphics.Dc) {
    // Set the temperature label value
    var temperatureLabel = View.findDrawableById("temperatureValue") as Text?;
    if (temperatureLabel != null) {
      temperatureLabel.setText(simpTempState.temperature.format("%.1f") + "°");
    }

    // Set the minimum temperature label value
    var minimumTemperatureLabel =
      View.findDrawableById("minimumTemperatureValue") as Text?;
    if (minimumTemperatureLabel != null) {
      minimumTemperatureLabel.setText(
        "min: " + simpTempState.minimumTemperature.format("%.1f") + "°"
      );
    }

    // Set the maximum temperature label value
    var maximumTemperatureLabel =
      View.findDrawableById("maximumTemperatureValue") as Text?;
    if (maximumTemperatureLabel != null) {
      maximumTemperatureLabel.setText(
        "max: " + simpTempState.maximumTemperature.format("%.1f") + "°"
      );
    }
  }

  // Draw the temperature chart
  function drawTemperatureChart(dc as Graphics.Dc) {
    // If no valid data, skip drawing the chart
    if (
      simpTempState.minimumTemperature == null ||
      simpTempState.maximumTemperature == null
    ) {
      // Missing data - skip drawing the chart
      return;
    }

    var chartWidth = 120; // Chart width
    var chartHeight = 80; // Chart height
    var chartX = (dc.getWidth() - chartWidth) / 2; // X position of the chart
    var chartY = dc.getHeight() - chartHeight - 20; // Y position of the chart

    // Adjust min and max to ensure a visible range
    var chartMinimum =
      Math.floor(simpTempState.minimumTemperature).toNumber() - 5;
    var chartMaximum =
      Math.ceil(simpTempState.maximumTemperature).toNumber() + 5;

    // Draw chart frame (FOR DEBUGGING PURPOSES)
    // dc.drawRectangle(chartX, chartY, chartWidth, chartHeight);

    // Draw chart
    var yScale = chartHeight.toFloat() / (chartMaximum - chartMinimum);
    for (var i = 0; i < simpTempState.historySize; i++) {
      var temp = simpTempState.temperatureHistory[i];
      if (temp != null) {
        var x = chartX + i;
        var y = Math.ceil(
          chartY + chartHeight - (temp - chartMinimum) * yScale
        );
        dc.drawLine(x, chartY + chartHeight - 1, x, y);
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
    for (var i = 0; i < simpTempState.historySize; i++) {
      if (
        simpTempState.temperatureHistory[i] == simpTempState.minimumTemperature
      ) {
        var x = chartX + i;
        var y = chartY + chartHeight - 7;
        drawMinTriangle(dc, x, y);
        break;
      }
    }

    for (var i = 0; i < simpTempState.historySize; i++) {
      if (
        simpTempState.temperatureHistory[i] == simpTempState.maximumTemperature
      ) {
        var x = chartX + i;
        var y = chartY + 6;
        drawMaxTriangle(dc, x, y);
        break;
      }
    }
  }

  // Draw the triangle to indicate the minimum temperature value
  function drawMinTriangle(
    dc as Graphics.Dc,
    pointX as Number,
    pointY as Number
  ) {
    // Create the polygon points array
    var points = [
      [pointX, pointY],
      [pointX + 4, pointY + 4],
      [pointX - 4, pointY + 4],
    ];

    // Draw the triangle
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
    dc.fillPolygon(points);

    // Draw the triangle outline (so it is visible if it goes outside of the chart)
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
    dc.drawLine(pointX, pointY - 1, pointX + 5, pointY + 4);
    dc.drawLine(pointX, pointY - 1, pointX - 5, pointY + 4);
    dc.drawLine(pointX + 5, pointY + 4, pointX - 5, pointY + 4);
  }

  // Draw the triangle to indicate the minimum temperature value
  function drawMaxTriangle(
    dc as Graphics.Dc,
    pointX as Number,
    pointY as Number
  ) {
    // Create the polygon points array
    var points = [
      [pointX, pointY],
      [pointX + 4, pointY - 4],
      [pointX - 4, pointY - 4],
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
