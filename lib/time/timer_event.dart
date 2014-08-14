part of Phaser;

class TimerEvent {
  Timer timer;
  num delay;
  num tick;
  int repeatCount;
  bool loop;
  Function callback;
  //Object callbackContext;
  List args;
  bool pendingDelete;

  TimerEvent(Timer timer, num delay, num tick, int repeatCount, bool loop, Function callback, List args) {
    /**
     * @property {Phaser.Timer} timer - The Timer object that this TimerEvent belongs to.
     */
    this.timer = timer;

    /**
     * @property {number} delay - The delay in ms at which this TimerEvent fires.
     */
    this.delay = delay;

    /**
     * @property {number} tick - The tick is the next game clock time that this event will fire at.
     */
    this.tick = tick;

    /**
     * @property {number} repeatCount - If this TimerEvent repeats it will do so this many times.
     */
    this.repeatCount = repeatCount - 1;

    /**
     * @property {boolean} loop - True if this TimerEvent loops, otherwise false.
     */
    this.loop = loop;

    /**
     * @property {function} callback - The callback that will be called when the TimerEvent occurs.
     */
    this.callback = callback;

    /**
     * @property {object} callbackContext - The context in which the callback will be called.
     */
    //this.callbackContext = callbackContext;

    /**
     * @property {array} arguments - The values to be passed to the callback.
     */
    this.args = args;

    /**
     * @property {boolean} pendingDelete - A flag that controls if the TimerEvent is pending deletion.
     * @protected
     */
    this.pendingDelete = false;
  }
}
