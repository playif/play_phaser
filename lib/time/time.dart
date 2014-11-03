part of Phaser;

class Time {
  Game game;
  num time=0.0;
  num now=0.0;
  num elapsed= 0;
  num pausedTime=0.0;
  bool advancedTiming=false;

  num fps=0.0;

  num fpsMin=1000.0;

  num fpsMax=0.0;

  num msMin=1000.0;

  num msMax=0.0;

  num physicsElapsed=0.0;

  /**
   * @property {number} deltaCap - If you need to cap the delta timer, set the value here. For 60fps the delta should be 0.016, so try variances just above this.
   */
  num deltaCap = 0.0;

  /**
   * @property {number} timeCap - If the difference in time between two frame updates exceeds this value, the frame time is reset to avoid huge elapsed counts.
   */
  num timeCap =  1 / 60 * 1000;

  /**
   * @property {number} frames - The number of frames record in the last second. Only calculated if Time.advancedTiming is true.
   */
  int frames = 0;

  /**
   * @property {number} pauseDuration - Records how long the game was paused for in miliseconds.
   */
  num pauseDuration = 0.0;

  /**
   * @property {number} timeToCall - The value that setTimeout needs to work out when to next update
   */
  num timeToCall = 0.0;

  /**
   * @property {number} lastTime - Internal value used by timeToCall as part of the setTimeout loop
   */
  num lastTime = 0.0;

  /**
   * @property {Phaser.Timer} events - This is a Phaser.Timer object bound to the master clock to which you can add timed events.
   */
  Timer events;

  /**
   * @property {number} _started - The time at which the Game instance started.
   * @private
   */
  num _started = 0.0;

  /**
   * @property {number} _timeLastSecond - The time (in ms) that the last second counter ticked over.
   * @private
   */
  num _timeLastSecond = 0.0;

  /**
   * @property {number} _pauseStarted - The time the game started being paused.
   * @private
   */
  num _pauseStarted = 0.0;

  /**
   * @property {boolean} _justResumed - Internal value used to recover from the game pause state.
   * @private
   */
  bool _justResumed = false;

  /**
   * @property {array} _timers - Internal store of Phaser.Timer objects.
   * @private
   */
  List<Timer> _timers = [];

  /**
   * @property {number} _len - Temp. array length variable.
   * @private
   */
  int _len = 0;

  /**
   * @property {number} _i - Temp. array counter variable.
   * @private
   */
  int _i = 0;

  Time(this.game) {
    events = new Timer(this.game, false);
  }


  /**
   * Called automatically by Phaser.Game after boot. Should not be called directly.
   *
   * @method Phaser.Time#boot
   * @protected
   */
  boot () {
    this._started = new DateTime.now().millisecondsSinceEpoch.toDouble();
    this.events.start();

  }

  /**
   * Adds an existing Phaser.Timer object to the Timer pool.
   *
   * @method Phaser.Time#add
   * @param {Phaser.Timer} timer - An existing Phaser.Timer object.
   * @return {Phaser.Timer} The given Phaser.Timer object.
   */
  add (Timer timer) {
    this._timers.add(timer);
    return timer;
  }

  /**
   * Creates a new stand-alone Phaser.Timer object.
   *
   * @method Phaser.Time#create
   * @param {boolean} [autoDestroy=true] - A Timer that is set to automatically destroy itself will do so after all of its events have been dispatched (assuming no looping events).
   * @return {Phaser.Timer} The Timer object that was created.
   */
  Timer create ([bool autoDestroy=true]) {

    var timer = new Timer(this.game, autoDestroy);

    this._timers.add(timer);

    return timer;

  }

  /**
   * Remove all Timer objects, regardless of their state. Also clears all Timers from the Time.events timer.
   *
   * @method Phaser.Time#removeAll
   */
  removeAll () {

    for (var i = 0; i < this._timers.length; i++)
    {
      this._timers[i].destroy();
    }

    this._timers = [];

    this.events.removeAll();

  }

  /**
   * Updates the game clock and if enabled the advanced timing data. This is called automatically by Phaser.Game.
   *
   * @method Phaser.Time#update
   * @protected
   * @param {number} time - The current timestamp.
   */
  update (num time) {

    this.now = time;

    this.timeToCall = Math.max(0, 16 - (time - this.lastTime)).toDouble();

    this.elapsed = this.now - this.time;

    //  spike-dislike
    if (this.elapsed > this.timeCap)
    {
      //  For some reason the time between now and the last time the game was updated was larger than our timeCap
      //  This can happen if the Stage.disableVisibilityChange is true and you swap tabs, which makes the raf pause.
      //  In this case we'll drop to some default values to stop the game timers going nuts.
      this.elapsed = this.timeCap;
    }

    //  Calculate physics elapsed, ensure it's > 0, use 1/60 as a fallback
    this.physicsElapsed = this.elapsed / 1000 ;
    if(this.physicsElapsed == 0){
      this.physicsElapsed = 1 / 60;
    }

    if (this.deltaCap > 0 && this.physicsElapsed > this.deltaCap)
    {
      this.physicsElapsed = this.deltaCap;
    }

    if (this.advancedTiming)
    {
      this.msMin = Math.min(this.msMin, this.elapsed);
      this.msMax = Math.max(this.msMax, this.elapsed);

      this.frames++;

      if (this.now > this._timeLastSecond + 1000)
      {
        this.fps = Math.round((this.frames * 1000) / (this.now - this._timeLastSecond));
        this.fpsMin = Math.min(this.fpsMin, this.fps);
        this.fpsMax = Math.max(this.fpsMax, this.fps);
        this._timeLastSecond = this.now;
        this.frames = 0;
      }
    }

    this.time = this.now;
    this.lastTime = time + this.timeToCall;

    //  Paused but still running?
    if (!this.game.paused)
    {
      //  Our internal Phaser.Timer
      this.events.update(this.now);

      //  Any game level timers
      this._i = 0;
      this._len = this._timers.length;

      while (this._i < this._len)
      {
        if (this._timers[this._i].update(this.now))
        {
          this._i++;
        }
        else
        {
          this._timers.removeAt(this._i);

          this._len--;
        }
      }
    }

  }

  /**
   * Called when the game enters a paused state.
   *
   * @method Phaser.Time#gamePaused
   * @private
   */
  gamePaused () {

    this._pauseStarted = this.now;

    this.events.pause();

    var i = this._timers.length;

    while (i-- >0)
    {
      this._timers[i]._pause();
    }

  }

  /**
   * Called when the game resumes from a paused state.
   *
   * @method Phaser.Time#gameResumed
   * @private
   */
  gameResumed () {

    //  Level out the elapsed timer to avoid spikes
    this.time = this.now = new DateTime.now().millisecondsSinceEpoch.toDouble();

    this.pauseDuration = this.time - this._pauseStarted;

    this.events.resume();

    var i = this._timers.length;

    while (i-- > 0)
    {
      this._timers[i]._resume();
    }

  }

  /**
   * The number of seconds that have elapsed since the game was started.
   *
   * @method Phaser.Time#totalElapsedSeconds
   * @return {number} The number of seconds that have elapsed since the game was started.
   */
  totalElapsedSeconds() {
    return (this.now - this._started) * 0.001;
  }

  /**
   * How long has passed since the given time.
   *
   * @method Phaser.Time#elapsedSince
   * @param {number} since - The time you want to measure against.
   * @return {number} The difference between the given time and now.
   */
  elapsedSince (since) {
    return this.now - since;
  }

  /**
   * How long has passed since the given time (in seconds).
   *
   * @method Phaser.Time#elapsedSecondsSince
   * @param {number} since - The time you want to measure (in seconds).
   * @return {number} Duration between given time and now (in seconds).
   */
  elapsedSecondsSince (since) {
    return (this.now - since) * 0.001;
  }

  /**
   * Resets the private _started value to now and removes all currently running Timers.
   *
   * @method Phaser.Time#reset
   */
  reset () {

    this._started = this.now;
    this.removeAll();

  }


}
