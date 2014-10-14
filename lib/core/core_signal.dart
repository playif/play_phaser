part of Phaser;

class Signal<T extends Function> {
  List<SignalBinding> _bindings = new List<SignalBinding>();
  var _prevParams = null;
//  Signal self;

  /**
   * If [Signal] should keep record of previously dispatched parameters and
   * automatically execute listener during `add()`/`addOnce()` if Signal was
   * already dispatched before.
   */
  bool memorize = false;
  bool _shouldPropagate = true;

  /**
   * If Signal is active and should broadcast events.
   * IMPORTANT: Setting this property during a dispatch will only affect the next dispatch, if you want to stop the propagation of a signal use `halt()` instead.
   */
  bool active = true;


//  Signal() {
//    //self = this;
//  }


  _validateListener(T listener, String fnName) {
    if (listener is! T) {
      throw new Exception('listener is a required param of {fn}() and should be a Function.'.replaceFirst('{fn}', fnName));
    }
  }


  SignalBinding _registerListener(T listener, bool isOnce, [int priority]) {
    int prevIndex = this._indexOfListener(listener);
    SignalBinding binding;
    if (prevIndex != -1) {
      binding = this._bindings[prevIndex];
      if (binding.isOnce() != isOnce) {
        throw new Exception('You cannot add${(isOnce ? '' : 'Once')}() then add${(!isOnce ? '' : 'Once')}() the same listener without removing the relationship first.');
      }
    } else {
      binding = new SignalBinding._(this, listener, isOnce, priority);
      this._addBinding(binding);
    }
    if (this.memorize && this._prevParams) {
      binding.execute(this._prevParams);
    }
    return binding;
  }

  _addBinding(SignalBinding binding) {
    //simplified insertion sort
    int n = this._bindings.length;
    do {
      --n;
    } while (n >= 0 && this._bindings[n] != null && binding._priority <= this._bindings[n]._priority);
    this._bindings.insert(n + 1, binding);
  }


  int _indexOfListener(T listener) {
    int n = this._bindings.length;
    SignalBinding cur;
    while (n-- != 0) {
      cur = this._bindings[n];
      if (cur._listener == listener) {
        return n;
      }
    }
    return -1;
  }

  /// Check if listener was attached to Signal.
  bool has(T listener) {
    return this._indexOfListener(listener) != -1;
  }

  /// Add a listener to the signal.
  SignalBinding add(T listener, [int priority]) {
    this._validateListener(listener, 'add');
    return this._registerListener(listener, false, priority);
  }

  /// Add listener to the signal that should be removed after first execution (will be executed only once).
  SignalBinding addOnce(T listener, [int priority]) {
    this._validateListener(listener, 'addOnce');
    return this._registerListener(listener, true, priority);
  }

  /// Remove a single listener from the dispatch queue.
  T remove(T listener) {
    this._validateListener(listener, 'remove');
    var i = this._indexOfListener(listener);
    if (i != -1) {
      this._bindings[i]._destroy(); //no reason to a Phaser.SignalBinding exist if it isn't attached to a signal
      this._bindings.removeAt(i);
    }
    return listener;
  }

  /// Remove all listeners from the Signal.
  removeAll() {
    int n = this._bindings.length;
    while (n-- > 0) {
      this._bindings[n]._destroy();
    }
    this._bindings.clear();
  }

  /// Gets the total number of listeneres attached to ths Signal.
  int getNumListeners() {
    return this._bindings.length;
  }

  /**
   * Stop propagation of the event, blocking the dispatch to next listeners on the queue.
   * IMPORTANT: should be called only during signal dispatch, calling it before/after dispatch won't affect signal broadcast.
   */
  halt() {
    this._shouldPropagate = false;
  }

  /// The dispatch function is what sends the Signal out.
  dispatch([arguments]) {

    if (!this.active) {
      return;
    }
    List paramsArr;

    if (arguments is List || arguments == null) {
      paramsArr = arguments;
    }
    else {
      paramsArr = [arguments];
    }

    // = new List.from(arguments);
    int n = this._bindings.length;
    List<SignalBinding> bindings;

    if (this.memorize) {
      this._prevParams = paramsArr;
    }

    if (n == 0) {
      //  Should come after memorize
      return;
    }

    bindings = new List.from(this._bindings); //clone array in case add/remove items during dispatch
    this._shouldPropagate = true; //in case `halt` was called before dispatch or during the previous dispatch.

    //execute all callbacks until end of the list or until a callback returns `false` or stops propagation
    //reverse loop since listeners with higher priority will be added at the end of the list
    do {
      n--;
    } while (n >= 0 && bindings[n] != null && this._shouldPropagate && bindings[n].execute(paramsArr) != false);

  }

  /// Forget memorized arguments.
  forget() {
    this._prevParams = null;
  }

  /**
   * Remove all bindings from signal and destroy any reference to external objects (destroy Signal object).
   * IMPORTANT: calling any method on the signal instance after calling dispose will throw errors.
   */
  dispose() {
    this.removeAll();
    this._bindings = null;
    this._prevParams = null;
  }

  /// String representation of the object.
  String toString() {
    return '[Phaser.Signal active:$this.active numListeners:${this.getNumListeners()}]';
  }
}
