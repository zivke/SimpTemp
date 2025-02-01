import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

(:glance)
class SimpTempApp extends Application.AppBase {
  var simpTempState as SimpTempState;

  function initialize() {
    AppBase.initialize();

    simpTempState = new SimpTempState();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {}

  (:glance)
  function getGlanceView() as Array<GlanceView>? {
    return (
      [new SimpTempGlanceView(simpTempState as SimpTempState)] as
      Array<GlanceView>
    );
  }

  // Return the initial view of your application here
  function getInitialView() as Array<Views or InputDelegates>? {
    return (
      [new SimpTempView(simpTempState as SimpTempState)] as
      Array<Views or InputDelegates>
    );
  }
}

function getApp() as SimpTempApp {
  return Application.getApp() as SimpTempApp;
}
