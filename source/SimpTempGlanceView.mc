import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class SimpTempGlanceView extends WatchUi.GlanceView {
  var simpTempState as SimpTempState?;

  function initialize(simpTempState as SimpTempState) {
    GlanceView.initialize();

    self.simpTempState = simpTempState;
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Call the parent onUpdate function to redraw the layout
    GlanceView.onUpdate(dc);

    dc.clear();

    // TODO: Select system theme colors?
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.drawText(
      0,
      0,
      Graphics.FONT_GLANCE,
      Application.loadResource(Rez.Strings.AppName) +
        "\n" +
        simpTempState.temperature.format("%.1f") +
        "°",
      Graphics.TEXT_JUSTIFY_LEFT
    );
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}
}
