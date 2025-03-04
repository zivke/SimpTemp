import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class SimpTempInfoView extends WatchUi.View {
  private var _simpTempState as SimpTempState;

  function initialize(simpTempState as SimpTempState) {
    self._simpTempState = simpTempState;

    View.initialize();
  }

  function onLayout(dc as Dc) as Void {}

  function onShow() as Void {}

  function onUpdate(dc as Dc) as Void {
    if (_simpTempState.getStatus().getCode() == Status.DONE) {
      WatchUi.switchToView(
        new SimpTempView(_simpTempState as SimpTempState),
        new SimpTempDelegate(),
        WatchUi.SLIDE_IMMEDIATE
      );
    } else {
      drawInfoMessage(dc, _simpTempState.getStatus().getMessage());
    }
  }

  function onHide() as Void {}

  private function drawInfoMessage(
    dc as Graphics.Dc,
    message as String?
  ) as Void {
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
    dc.clear();

    var infoMessage = new WatchUi.TextArea({
      :text => message != null ? message : "Unknown error",
      :backgroundColor => Graphics.COLOR_BLACK,
      :color => Graphics.COLOR_WHITE,
      :font => Graphics.FONT_TINY,
      :justification => Graphics.TEXT_JUSTIFY_CENTER |
      Graphics.TEXT_JUSTIFY_VCENTER,
      :locX => WatchUi.LAYOUT_HALIGN_CENTER,
      :locY => WatchUi.LAYOUT_VALIGN_CENTER,
      :width => dc.getWidth() * 0.8,
      :height => dc.getHeight() * 0.8,
    });
    infoMessage.draw(dc);
  }
}
