import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MainBackgroundDrawable extends WatchUi.Drawable {
  private var _foregroundColor as Number;
  private var _backgroundColor as Number;

  function initialize(params as Dictionary) {
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
    dc.setColor(self._foregroundColor, self._backgroundColor);
    dc.clear();
  }
}
