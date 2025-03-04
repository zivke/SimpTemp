import Toybox.Application;
import Toybox.Lang;
import Toybox.SensorHistory;
import Toybox.System;
import Toybox.WatchUi;

(:glance)
class SimpTempApp extends Application.AppBase {
  private var _glanceTemperatureString as String?;
  private var _simpTempState as SimpTempState?;

  function initialize() {
    AppBase.initialize();

    if (
      Toybox has :SensorHistory &&
      Toybox.SensorHistory has :getTemperatureHistory
    ) {
      // Get the temperature history iterator
      var temperatureIterator = Toybox.SensorHistory.getTemperatureHistory({
        :period => 1,
        :order => SensorHistory.ORDER_NEWEST_FIRST,
      });

      // Get the current temperature first
      var sensorSample = temperatureIterator.next();
      if (sensorSample != null) {
        self._glanceTemperatureString = getTemperatureString(sensorSample.data);
      }
    }
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {
    self._simpTempState = new SimpTempState();
  }

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
    return [new SimpTempGlanceView(_glanceTemperatureString)];
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

  private function getTemperatureString(
    temperature as Number or Float or Null
  ) as String? {
    if (temperature == null) {
      return null;
    }

    if (System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE) {
      return (temperature * 1.8 + 32).format("%.1f").toString() + "°F";
    }

    return temperature.format("%.1f").toString() + "°C";
  }
}

function getApp() as SimpTempApp {
  return Application.getApp() as SimpTempApp;
}
