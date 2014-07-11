part of Phaser;

class SignalBinding {
  Function _listener;
  bool _isOnce;

  Object context;

  int _priority;

  Signal _signal;

  bool active = true;

  List params;


  SignalBinding(this._signal, this._listener, [this._isOnce=false, this.context, this._priority=0]) {
    if (this._priority == null) {
      this._priority = 0;
    }
  }

  execute(List paramsArr) {

    var handlerReturn, params;

    if (this.active && !!this._listener) {
      if (this.params == null) {
        this.params = paramsArr;
      }
      else {
        this.params.addAll(paramsArr);
      }
      handlerReturn = this._listener(this.context, params);

      if (this._isOnce) {
        this.detach();
      }
    }

    return handlerReturn;

  }


  detach() {
    return this.isBound() ? this._signal.remove(this._listener, this.context) : null;
  }

  isBound() {
    return (this._signal != null && this._listener != null);
  }

  isOnce() {
    return this._isOnce;
  }

  getListener() {
    return this._listener;
  }

  getSignal() {
    return this._signal;
  }


  _destroy() {
    this._signal = null;
    this._listener = null;
    this.context = null;
  }


  toString() {
    return '[Phaser.SignalBinding isOnce: ${this._isOnce}, isBound:${this.isBound()}, active:${this.active}]';
  }

}
