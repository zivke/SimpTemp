import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class SimpTempGlanceView extends WatchUi.GlanceView {
  private var _simpTempState as SimpTempState?;

  function initialize(simpTempState as SimpTempState) {
    self._simpTempState = simpTempState;

    GlanceView.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.GlanceLayout(dc));
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    if (_simpTempState != null) {
      var temperature = _simpTempState.getTemperature();
      if (temperature != null) {
        var glanceLabel = GlanceView.findDrawableById("GlanceLabel") as Text?;
        if (glanceLabel != null) {
          var temperatureUnitsText =
            _simpTempState.getSystemUnits() == System.UNIT_STATUTE
              ? "°F"
              : "°C";
          glanceLabel.setText(
            loadResource(Rez.Strings.AppName) +
              "\n" +
              temperature.format("%.1f") +
              temperatureUnitsText
          );
        }
      }
    }

    // Call the parent onUpdate function to redraw the layout
    GlanceView.onUpdate(dc);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
