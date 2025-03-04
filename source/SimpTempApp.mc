import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class SimpTempApp extends Application.AppBase {
  private var _simpTempState as SimpTempState?;

  function initialize() {
    AppBase.initialize();

    self._simpTempState = new SimpTempState();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {
    if (_simpTempState != null) {
      _simpTempState.destroy();
    }
  }

  (:glance)
  function getGlanceView() as [GlanceView] or
    [GlanceView, GlanceViewDelegate] or
    Null {
    return [new SimpTempGlanceView(_simpTempState as SimpTempState)];
  }

  // Return the initial view of your application here
  function getInitialView() as [Views] or [Views, InputDelegates] {
    if (_simpTempState.getStatus().getCode() == Status.DONE) {
      return [
        new SimpTempView(_simpTempState as SimpTempState),
        new SimpTempDelegate(),
      ];
    } else {
      return [new SimpTempInfoView(_simpTempState as SimpTempState)];
    }
  }
}

function getApp() as SimpTempApp {
  return Application.getApp() as SimpTempApp;
}
