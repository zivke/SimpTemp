import Toybox.Lang;

class UnsupportedException extends Exception {
  function initialize(message as String) {
    Exception.initialize();
    self.mMessage = "Unsupported: " + message;
  }
}
