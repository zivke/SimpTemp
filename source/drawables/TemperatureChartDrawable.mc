import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TemperatureChartDrawable extends WatchUi.Drawable {
  private var _simpTempState as SimpTempState?;
  private var _foregroundColor as Number;
  private var _backgroundColor as Number;

  function setSimpTempState(simpTempState as SimpTempState) {
    self._simpTempState = simpTempState;
  }

  function initialize(params as Dictionary?) {
    Drawable.initialize(params);

    var foregroundColor = params.get(:color) as Number?;
    self._foregroundColor = foregroundColor
      ? foregroundColor
      : Graphics.COLOR_BLACK;

    var backgroundColor = params.get(:background) as Number?;
    self._backgroundColor = backgroundColor
      ? backgroundColor
      : Graphics.COLOR_WHITE;
  }

  function draw(dc as Dc) {
    // If no valid data, skip drawing the chart
    if (
      _simpTempState.getMinimumTemperature() == null ||
      _simpTempState.getMaximumTemperature() == null
    ) {
      // Missing data - skip drawing the chart
      return;
    }

    // Automatically determine the y location of the drawable if non provided
    if (locY == 0) {
      locY = Math.floor(dc.getHeight() * 0.3).toNumber();
    }

    // Automatically determine the height of the drawable if non provided
    if (height == 0) {
      height = Math.floor(dc.getHeight() * 0.5).toNumber();
    }

    var chartWidth = _simpTempState.getHistorySize(); // Chart width
    var chartHeight = (height - 20) as Number; // Chart height
    var chartX = Math.floor((dc.getWidth() - chartWidth) / 2).toNumber(); // X position of the chart
    var chartY = locY as Number; // Y position of the chart

    // Adjust min and max to ensure a visible range
    var chartMinimum =
      Math.floor(_simpTempState.getMinimumTemperature()).toNumber() - 5;
    var chartMaximum =
      Math.ceil(_simpTempState.getMaximumTemperature()).toNumber() + 5;

    // Draw chart frame (FOR DEBUGGING PURPOSES)
    // dc.drawRectangle(chartX, chartY, chartWidth, chartHeight);

    // Set colors
    dc.setColor(_foregroundColor, _backgroundColor);

    // Draw chart
    var yScale = chartHeight.toFloat() / (chartMaximum - chartMinimum);
    for (var i = 0; i < _simpTempState.getHistorySize(); i++) {
      var temp = _simpTempState.getTemperatureHistory()[i];
      if (temp != null) {
        var x = chartX + i;
        var y = Math.ceil(
          chartY + chartHeight - (temp - chartMinimum) * yScale
        );
        dc.drawLine(x, chartY + chartHeight - 1, x, y);
      }
    }

    // Draw hour marks
    dc.setColor(_backgroundColor, Graphics.COLOR_TRANSPARENT); // Inverted color
    // 30 measurements per hour = one line every 30 values
    for (var i = chartX + 30; i < chartWidth; i += 30) {
      dc.drawLine(i, chartY + chartHeight, i, chartY + chartHeight - 4);
    }

    var totalChartTimeText =
      "Last " + _simpTempState.getHistoryHours() + " hours";

    dc.setColor(_foregroundColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      chartX + chartWidth / 2,
      chartY + chartHeight + _simpTempState.getSizeFactor() - 2,
      Graphics.FONT_XTINY,
      totalChartTimeText,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    // Draw the min and max temperature triangles and dashed lines
    for (var i = 0; i < _simpTempState.getHistorySize(); i++) {
      var temp = _simpTempState.getTemperatureHistory()[i];
      if (temp != null && temp == _simpTempState.getMinimumTemperature()) {
        var x = chartX + i;
        var y = chartY + chartHeight - 7;
        drawMinTriangle(dc, x, y);

        var dashedLineY = Math.ceil(
          chartY + chartHeight - (temp - chartMinimum) * yScale
        ).toNumber();
        drawHorizontalDashedLine(
          dc,
          chartX,
          chartX + chartWidth,
          dashedLineY + 1,
          Graphics.COLOR_WHITE
        );
        break;
      }
    }

    for (var i = 0; i < _simpTempState.getHistorySize(); i++) {
      var temp = _simpTempState.getTemperatureHistory()[i];
      if (temp != null && temp == _simpTempState.getMaximumTemperature()) {
        var x = chartX + i;
        var y = chartY + 6;
        drawMaxTriangle(dc, x, y);

        var dashedLineY = Math.ceil(
          chartY + chartHeight - (temp - chartMinimum) * yScale
        ).toNumber();
        drawHorizontalDashedLine(
          dc,
          chartX,
          chartX + chartWidth,
          dashedLineY - 1,
          Graphics.COLOR_BLACK
        );
        break;
      }
    }
  }

  // Draw the triangle to indicate the minimum temperature value
  private function drawMinTriangle(
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
  private function drawMaxTriangle(
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

  private function drawHorizontalDashedLine(
    dc as Dc,
    startX as Number,
    endX as Number,
    y as Number,
    color as Number
  ) {
    var dashLength = 3;

    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    for (var i = startX; i < endX; i += 2 * dashLength) {
      var dashStartX = i;
      var dashEndX = i + dashLength;
      dashEndX = dashEndX > endX ? endX : dashEndX;
      dc.drawLine(dashStartX, y, dashEndX, y);
    }
  }
}
