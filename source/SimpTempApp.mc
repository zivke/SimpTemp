import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class SimpTempApp extends Application.AppBase {
  private var _simpTempState as SimpTempState?;

  function initialize() {
    AppBase.initialize();

    try {
      self._simpTempState = new SimpTempState();
    } catch (exception) {
      WatchUi.switchToView(
        new SimpTempErrorView(exception.getErrorMessage()),
        null,
        WatchUi.SLIDE_IMMEDIATE
      );
    }
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {}

  (:glance)
  function getGlanceView() as Array<GlanceView>? {
    return (
      [new SimpTempGlanceView(_simpTempState as SimpTempState)] as
      Array<GlanceView>
    );
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    return (
      [new SimpTempView(_simpTempState as SimpTempState)] as
      Array<Views or InputDelegates>
    );
  }
}

function getApp() as SimpTempApp {
  return Application.getApp() as SimpTempApp;
}
