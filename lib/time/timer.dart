part of Phaser;

typedef void TimerFunc(Timer timer);

class Timer {
  Game game;
  bool autoDestroy=true;
  bool running = false;
  bool expired = false;
  num elapsed = 0.0;
  List<TimerEvent> events = [];

  Signal<TimerFunc> onComplete = new Signal();

  num nextTick = 0.0;
  int timeCap = 1000;

  bool paused = false;
  bool _codePaused = false;

  num _started = 0.0;
  num _pauseStarted = 0.0;
  num _pauseTotal = 0.0;
  num _now = new DateTime.now().millisecondsSinceEpoch;

  int _len = 0;

  int _marked = 0;

  int _i = 0;
  int _diff = 0;
  num _newTick = 0.0;

  static const double MINUTE = 60000.0;
  static const double SECOND = 1000.0;
  static const double HALF = 500.0;
  static const double QUARTER = 250.0;

  Timer(this.game, [bool autoDestroy=true]) {
  }

  num get next => nextTick;

  num get duration {
    if (this.running && this.nextTick > this._now) {
      return this.nextTick - this._now;
    }
    else {
      return 0.0;
    }
  }

  int get length => events.length;

  num get ms {
    if (this.running) {
      return this._now - this._started - this._pauseTotal;
    }
    else {
      return 0.0;
    }
  }

  num get second {
    if (this.running) {
      return this.ms * 0.001;
    }
    else {
      return 0;
    }
  }

  /**
   * Creates a new TimerEvent on this Timer. Use the methods add, repeat or loop instead of this.
   * @method Phaser.Timer#create
   * @private
   * @param {number} delay - The number of milliseconds that should elapse before the Timer will call the given callback.
   * @param {boolean} loop - Should the event loop or not?
   * @param {number} repeatCount - The number of times the event will repeat.
   * @param {function} callback - The callback that will be called when the Timer event occurs.
   * @param {object} callbackContext - The context in which the callback will be called.
   * @param {array} arguments - The values to be sent to your callback function when it is called.
   * @return {Phaser.TimerEvent} The Phaser.TimerEvent object that was created.
   */

  TimerEvent create(num delay, bool loop, int repeatCount, Function callback, args) {

    num tick = Math.round(delay);

    if (this._now == 0) {
      tick += this.game.time.now;
    }
    else {
      tick += this._now;
    }

    TimerEvent event = new TimerEvent(this, delay, tick, repeatCount, loop, callback, args);

    this.events.add(event);

    this.order();

    this.expired = false;

    return event;

  }

  /**
   * Adds a new Event to this Timer. The event will fire after the given amount of 'delay' in milliseconds has passed, once the Timer has started running.
   * Call Timer.start() once you have added all of the Events you require for this Timer. The delay is in relation to when the Timer starts, not the time it was added.
   * If the Timer is already running the delay will be calculated based on the timers current time.
   *
   * @method Phaser.Timer#add
   * @param {number} delay - The number of milliseconds that should elapse before the Timer will call the given callback.
   * @param {function} callback - The callback that will be called when the Timer event occurs.
   * @param {object} callbackContext - The context in which the callback will be called.
   * @param {...*} arguments - The values to be sent to your callback function when it is called.
   * @return {Phaser.TimerEvent} The Phaser.TimerEvent object that was created.
   */

  TimerEvent add(num delay, Function callback, [List args]) {
    return this.create(delay, false, 0, callback, args);
  }

  /**
   * Adds a new TimerEvent that will always play through once and then repeat for the given number of iterations.
   * The event will fire after the given amount of 'delay' milliseconds has passed once the Timer has started running.
   * Call Timer.start() once you have added all of the Events you require for this Timer. The delay is in relation to when the Timer starts, not the time it was added.
   * If the Timer is already running the delay will be calculated based on the timers current time.
   *
   * @method Phaser.Timer#repeat
   * @param {number} delay - The number of milliseconds that should elapse before the Timer will call the given callback.
   * @param {number} repeatCount - The number of times the event will repeat once is has finished playback. A repeatCount of 1 means it will repeat itself once, playing the event twice in total.
   * @param {function} callback - The callback that will be called when the Timer event occurs.
   * @param {object} callbackContext - The context in which the callback will be called.
   * @param {...*} arguments - The values to be sent to your callback function when it is called.
   * @return {Phaser.TimerEvent} The Phaser.TimerEvent object that was created.
   */

  TimerEvent repeat(num delay, int repeatCount, Function callback, List args) {
    return this.create(delay, false, repeatCount, callback, args);
  }

  /**
   * Adds a new looped Event to this Timer that will repeat forever or until the Timer is stopped.
   * The event will fire after the given amount of 'delay' milliseconds has passed once the Timer has started running.
   * Call Timer.start() once you have added all of the Events you require for this Timer. The delay is in relation to when the Timer starts, not the time it was added.
   * If the Timer is already running the delay will be calculated based on the timers current time.
   *
   * @method Phaser.Timer#loop
   * @param {number} delay - The number of milliseconds that should elapse before the Timer will call the given callback.
   * @param {function} callback - The callback that will be called when the Timer event occurs.
   * @param {object} callbackContext - The context in which the callback will be called.
   * @param {...*} arguments - The values to be sent to your callback function when it is called.
   * @return {Phaser.TimerEvent} The Phaser.TimerEvent object that was created.
   */

  TimerEvent loop(num delay, Function callback, List args) {
    return this.create(delay, true, 0, callback, args);
  }

  /**
   * Starts this Timer running.
   * @method Phaser.Timer#start
   * @param {number} [delay=0] - The number of milliseconds that should elapse before the Timer will start.
   */

  start([int delay=0]) {

    if (this.running) {
      return;
    }

    this._started = this.game.time.now + delay;

    this.running = true;

    for (var i = 0; i < this.events.length; i++) {
      this.events[i].tick = this.events[i].delay + this._started;
    }

  }

  /**
   * Stops this Timer from running. Does not cause it to be destroyed if autoDestroy is set to true.
   * @method Phaser.Timer#stop
   * @param {boolean} [clearEvents=true] - If true all the events in Timer will be cleared, otherwise they will remain.
   */

  stop([bool clearEvents=true]) {

    this.running = false;


    if (clearEvents) {
      this.events.length = 0;
    }

  }

  /**
   * Removes a pending TimerEvent from the queue.
   * @param {Phaser.TimerEvent} event - The event to remove from the queue.
   * @method Phaser.Timer#remove
   */

  remove(TimerEvent event) {

    for (var i = 0; i < this.events.length; i++) {
      if (this.events[i] == event) {
        this.events[i].pendingDelete = true;
        return true;
      }
    }

    return false;

  }

  /**
   * Orders the events on this Timer so they are in tick order. This is called automatically when new events are created.
   * @method Phaser.Timer#order
   */

  order() {

    if (this.events.length > 0) {
      //  Sort the events so the one with the lowest tick is first
      this.events.sort(this.sortHandler);

      this.nextTick = this.events[0].tick;
    }

  }

  /**
   * Sort handler used by Phaser.Timer.order.
   * @method Phaser.Timer#sortHandler
   * @protected
   */

  sortHandler(a, b) {

    if (a.tick < b.tick) {
      return -1;
    }
    else if (a.tick > b.tick) {
      return 1;
    }

    return 0;

  }

  /**
   * Clears any events from the Timer which have pendingDelete set to true and then resets the private _len and _i values.
   *
   * @method Phaser.Timer#clearPendingEvents
   */

  clearPendingEvents() {

    this._i = this.events.length;

    while (this._i-- > 0) {
      if (this.events[this._i].pendingDelete) {
        this.events.removeAt(this._i);
      }
    }

    this._len = this.events.length;
    this._i = 0;

  }

  callback(TimerEvent events) {
    if (events.args == null) {
      events.callback();
    }
    else {
      events.callback(this.events[this._i].args);
    }
  }

  /**
   * The main Timer update event, called automatically by Phaser.Time.update.
   *
   * @method Phaser.Timer#update
   * @protected
   * @param {number} time - The time from the core game clock.
   * @return {boolean} True if there are still events waiting to be dispatched, otherwise false if this Timer can be destroyed.
   */

  bool update(num time) {

    if (this.paused) {
      return true;
    }

    this.elapsed = time - this._now;
    this._now = time;

    //  spike-dislike
    if (this.elapsed > this.timeCap) {
      //  For some reason the time between now and the last time the game was updated was larger than our timeCap.
      //  This can happen if the Stage.disableVisibilityChange is true and you swap tabs, which makes the raf pause.
      //  In this case we need to adjust the TimerEvents and nextTick.
      this.adjustEvents(time - this.elapsed);
    }

    this._marked = 0;

    //  Clears events marked for deletion and resets _len and _i to 0.
    this.clearPendingEvents();

    if (this.running && this._now >= this.nextTick && this._len > 0) {
      while (this._i < this._len && this.running) {
        if (this._now >= this.events[this._i].tick) {
          //  (now + delay) - (time difference from last tick to now)
          this._newTick = (this._now + this.events[this._i].delay) - (this._now - this.events[this._i].tick);

          if (this._newTick < 0) {
            this._newTick = this._now + this.events[this._i].delay;
          }


          if (this.events[this._i].loop == true) {
            this.events[this._i].tick = this._newTick;
            callback(events[this._i]);

          }
          else if (this.events[this._i].repeatCount > 0) {
            this.events[this._i].repeatCount--;
            this.events[this._i].tick = this._newTick;
            callback(events[this._i]);
          }
          else {
            this._marked++;
            this.events[this._i].pendingDelete = true;
            callback(events[this._i]);
          }

          this._i++;
        }
        else {
          break;
        }
      }

      //  Are there any events left?
      if (this.events.length > this._marked) {
        this.order();
      }
      else {
        this.expired = true;
        this.onComplete.dispatch(this);
      }
    }

    if (this.expired && this.autoDestroy) {
      return false;
    }
    else {
      return true;
    }

  }

  /**
   * Pauses the Timer and all events in the queue.
   * @method Phaser.Timer#pause
   */

  pause() {

    if (!this.running) {
      return;
    }

    this._codePaused = true;

    if (this.paused) {
      return;
    }

    this._pauseStarted = this.game.time.now;

    this.paused = true;

  }

  /**
   * This is called by the core Game loop. Do not call it directly, instead use Timer.pause.
   * @method Phaser.Timer#_pause
   * @private
   */

  _pause() {

    if (this.paused || !this.running) {
      return;
    }

    this._pauseStarted = this.game.time.now;

    this.paused = true;

  }

  /**
   * Adjusts the time of all pending events and the nextTick by the given baseTime.
   *
   * @method Phaser.Timer#adjustEvents
   */

  adjustEvents(num baseTime) {

    for (var i = 0; i < this.events.length; i++) {
      if (!this.events[i].pendingDelete) {
        //  Work out how long there would have been from when the game paused until the events next tick
        var t = this.events[i].tick - baseTime;

        if (t < 0) {
          t = 0;
        }

        //  Add the difference on to the time now
        this.events[i].tick = this._now + t;
      }
    }

    var d = this.nextTick - baseTime;

    if (d < 0) {
      this.nextTick = this._now;
    }
    else {
      this.nextTick = this._now + d;
    }

  }

  /**
   * Resumes the Timer and updates all pending events.
   *
   * @method Phaser.Timer#resume
   */

  resume() {

    if (!this.paused) {
      return;
    }

    var now = this.game.time.now;
    this._pauseTotal += now - this._now;
    this._now = now;

    this.adjustEvents(this._pauseStarted);

    this.paused = false;
    this._codePaused = false;

  }

  /**
   * This is called by the core Game loop. Do not call it directly, instead use Timer.pause.
   * @method Phaser.Timer#_resume
   * @private
   */

  _resume() {

    if (this._codePaused) {
      return;
    }
    else {
      this.resume();
    }

  }

  /**
   * Removes all Events from this Timer and all callbacks linked to onComplete, but leaves the Timer running.
   * The onComplete callbacks won't be called.
   *
   * @method Phaser.Timer#removeAll
   */

  removeAll() {

    this.onComplete.removeAll();
    this.events.length = 0;
    this._len = 0;
    this._i = 0;

  }

  /**
   * Destroys this Timer. Any pending Events are not dispatched.
   * The onComplete callbacks won't be called.
   *
   * @method Phaser.Timer#destroy
   */

  destroy() {

    this.onComplete.removeAll();
    this.running = false;
    this.events = [];
    this._len = 0;
    this._i = 0;

  }


}
