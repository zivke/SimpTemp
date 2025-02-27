import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class SimpTempMenu2Delegate extends WatchUi.Menu2InputDelegate {
  function initialize() {
    Menu2InputDelegate.initialize();
  }

  function onSelect(item as MenuItem) {
    if (item instanceof ToggleMenuItem && item.getId() == :ShowMinMaxLines) {
      Application.Properties.setValue(
        item.getId().toString(),
        item.isEnabled()
      );
    }
  }
}
