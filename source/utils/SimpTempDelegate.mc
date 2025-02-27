import Toybox.Lang;
import Toybox.WatchUi;

class SimpTempDelegate extends WatchUi.BehaviorDelegate {
  function initialize() {
    BehaviorDelegate.initialize();
  }

  function onMenu() as Boolean {
    var menu = new Rez.Menus.OptionsMenu() as Menu2;
    var showMinMax =
      Application.Properties.getValue("ShowMinMaxLines") as Boolean?;
    if (showMinMax != null) {
      var index = menu.findItemById(:ShowMinMaxLines);
      if (index >= 0) {
        var item = menu.getItem(index);
        if (item != null && item instanceof ToggleMenuItem) {
          (item as ToggleMenuItem).setEnabled(showMinMax);
        }
      }
    }

    WatchUi.pushView(
      menu,
      new SimpTempMenu2Delegate(),
      WatchUi.SLIDE_IMMEDIATE
    );
    return true;
  }
}
