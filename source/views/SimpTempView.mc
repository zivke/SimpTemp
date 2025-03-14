import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

class SimpTempView extends WatchUi.View {
  private var _simpTempState as SimpTempState;

  function initialize(simpTempState as SimpTempState) {
    self._simpTempState = simpTempState;

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
  function onUpdate(dc as Graphics.Dc) as Void {
    if (_simpTempState.getStatus().getCode() != Status.DONE) {
      WatchUi.switchToView(
        new SimpTempInfoView(_simpTempState as SimpTempState),
        null,
        WatchUi.SLIDE_IMMEDIATE
      );
    } else {
      drawCurrentTime(dc);
      drawTemperatureValues(dc);
      drawTemperatureChart(dc);
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);
  }

  private function drawCurrentTime(dc as Graphics.Dc) {
    var clockLabel = View.findDrawableById("clockValue") as Text?;
    if (clockLabel != null) {
      var currentTime = System.getClockTime();
      clockLabel.setText(
        currentTime.hour.format("%02d") + ":" + currentTime.min.format("%02d")
      );
    }
  }

  // Draw the temperature values
  private function drawTemperatureValues(dc as Graphics.Dc) {
    // Set the temperature label value
    var currentTemperature = _simpTempState.getTemperature();
    var temperatureLabel = View.findDrawableById("temperatureValue") as Text?;
    if (temperatureLabel != null && currentTemperature != null) {
      temperatureLabel.setText(currentTemperature.format("%.1f") + "°");
    }

    // Set the minimum temperature label value
    var minimumTemperatureLabel =
      View.findDrawableById("minimumTemperatureValue") as Text?;
    if (minimumTemperatureLabel != null) {
      minimumTemperatureLabel.setText(
        "min: " + _simpTempState.getMinimumTemperature().format("%.1f") + "°"
      );
    }

    // Set the maximum temperature label value
    var maximumTemperatureLabel =
      View.findDrawableById("maximumTemperatureValue") as Text?;
    if (maximumTemperatureLabel != null) {
      maximumTemperatureLabel.setText(
        "max: " + _simpTempState.getMaximumTemperature().format("%.1f") + "°"
      );
    }
  }

  // Draw the temperature chart
  private function drawTemperatureChart(dc as Graphics.Dc) {
    var temperatureChartDrawable =
      View.findDrawableById("TemperatureChart") as TemperatureChartDrawable?;
    if (temperatureChartDrawable != null) {
      temperatureChartDrawable.setSimpTempState(_simpTempState);
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
