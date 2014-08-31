part of Phaser;

/// Object that represents a binding between a [Signal] and a listener function.
class SignalBinding {
  Function _listener;
  bool _isOnce;

  int _priority;

  Signal _signal;

  /// If binding is active and should be executed.
  bool active = true;

  List params;

  /**
   * This is an internal constructor and shouldn't be created directly.
   * Inspired by Joa Ebert AS3 SignalBinding and Robert Penner's Slot classes.
   */
  SignalBinding._(this._signal, this._listener, [this._isOnce = false, this._priority = 0]) {
    if (this._priority == null) {
      this._priority = 0;
    }
  }

  /// Default parameters passed to listener during `Signal.dispatch` and `SignalBinding.execute` (curried parameters).
  execute(List params) {

    var handlerReturn;
    //List params;

    if (this.active && this._listener != null) {
      if (this.params == null) {
        this.params = params;
      } else {
        this.params.addAll(params);
      }
      if (params != null && params.length != 0) {
        handlerReturn = Function.apply(this._listener, params);
      } else {
        handlerReturn = this._listener();
      }


      if (this._isOnce) {
        this.detach();
      }
    }

    return handlerReturn;

  }

  /// Detach binding from signal.
  detach() {
    return this.isBound() ? this._signal.remove(this._listener) : null;
  }

  /// True if binding is still bound to the signal and has a listener.
  isBound() {
    return (this._signal != null && this._listener != null);
  }

  /// If [SignalBinding] will only be executed once.
  isOnce() {
    return this._isOnce;
  }

  /// Handler function bound to the signal.
  getListener() {
    return this._listener;
  }

  /// Signal that listener is currently bound to.
  getSignal() {
    return this._signal;
  }


  _destroy() {
    this._signal = null;
    this._listener = null;
  }

  /// String representation of the object.
  String toString() {
    return '[Phaser.SignalBinding isOnce: ${this._isOnce}, isBound:${this.isBound()}, active:${this.active}]';
  }

}
