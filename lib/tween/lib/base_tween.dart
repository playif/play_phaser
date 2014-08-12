part of tweenengine;

/**
 * BaseTween is the base class of Tween and Timeline. It defines the
 * iteration engine used to play animations for any number of times, and in
 * any direction, at any speed.
 *
 * It is responsible for calling the different callbacks at the right moments,
 * and for making sure that every callbacks are triggered, even if the update
 * engine gets a big delta time at once.
 *
 * see [Tween]
 * see [Timeline]
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
abstract class BaseTween<T> {
  // General
  int _step;
  int _repeatCnt;
  bool _isIterationStep;
  bool _isYoyo;

  // Timings
  num _delay;
  num _duration;
  num _repeatDelay;
  num _currentTime;
  num _deltaTime;
  bool _isStarted; // true when the object is started
  bool _isInitialized; // true after the delay
  bool _isFinished; // true when all repetitions are done
  bool _isKilled; // true if kill() was called
  bool _isPaused; // true if pause() was called

  // Misc
  TweenCallback _callback;
  int _callbackTriggers;
  Object _userData;

  // Package access
  bool _isAutoRemoveEnabled;
  bool _isAutoStartEnabled;

  // -------------------------------------------------------------------------

  void reset() {
    _step = -2;
    _repeatCnt = 0;
    _isIterationStep = _isYoyo = false;

    _delay = _duration = _repeatDelay = _currentTime = _deltaTime = 0;
    _isStarted = _isInitialized = _isFinished = _isKilled = _isPaused = false;

    _callback = null;
    _callbackTriggers = TweenCallback.COMPLETE;
    _userData = null;

    _isAutoRemoveEnabled = _isAutoStartEnabled = true;
  }
  


  // -------------------------------------------------------------------------
  // API
  // -------------------------------------------------------------------------
  void build(){
  }
  

  /**
   * Starts or restarts the object unmanaged. If no [manager] is passed, you will need to take care of
   * its life-cycle. 
   * 
   * If you want the tween to be managed for you, use a [TweenManager] 
   * so the life cycle is handled for you, then you can relax and enjoy the animation.
   */
  void start([TweenManager manager]) {
    if (manager == null){
      build();
      _currentTime = 0;
      _isStarted = true;
    }else{
      manager.add(this);  
    }
  }

  /**
   * Adds a delay to the tween or timeline.
   *
   * [delay] A num representing the duration.
   */
  void set delay(num delay) {  _delay += delay; }

  ///Kills the tween or timeline. If you are using a [TweenManager], this object will be removed automatically.
  void kill() {
    _isKilled = true;
  }

  /**
   * Stops and resets the tween or timeline, and sends it to its pool, for
   * later reuse. Note that if you use a [TweenManager], this method
   * is automatically called once the animation is finished.
  */
  void free() {
  }

  ///Pauses the tween or timeline. Further update calls won't have any effect.
  void pause() {
    _isPaused = true;
  }

  ///Resumes the tween or timeline. Has no effect is it was no already paused.
  void resume() {
    _isPaused = false;
  }

  /**
   * Repeats the tween or timeline [count] times.
   * 
   * [count] The number of repetitions. For infinite repetition, use [Tween.INFINITY], or a negative number.
   * [delay] A delay between each iteration.
   */
  void repeat(int count, num delay) {
    if (_isStarted) throw new Exception("You can't change the repetitions of a tween or timeline once it is started");
    _repeatCnt = count;
    _repeatDelay = delay >= 0 ? delay : 0;
    _isYoyo = false;
  }

  /**
   * Repeats the tween or timeline [count] times.
   * Every two iterations, it will be played backwards.
   *
   * [count] The number of repetitions. For infinite repetition,  use [Tween.INFINITY], or `-1`.
   * [delay] A delay before each repetition.
   */
  void repeatYoyo(int count, num delay) {
          if (_isStarted) throw new Exception("You can't change the repetitions of a tween or timeline once it is started");
          _repeatCnt = count;
          _repeatDelay = delay >= 0 ? delay : 0;
          _isYoyo = true;
  }

  /**
   * Sets the [TweenCallback]. By default, it will be fired at the completion of the tween or timeline (event COMPLETE). 
   * If you want to change this behavior and add more triggers, use the [setCallbackTriggers] method.
   */
  void setCallback(TweenCallback callback) {
    _callback = callback;
  }

  /**
   * Changes the triggers of the callback. The available triggers, listed as
   * members of the [TweenCallback] interface, are:
   *
   * * [TweenCallback.BEGIN]: right after the delay (if any)
   * * [TweenCallback.START]: at each iteration beginning
   * * [TweenCallback.END]: at each iteration ending, before the repeat delay
   * * [TweenCallback.COMPLETE]: at last END event
   * * [TweenCallback.BACK_BEGIN]: at the beginning of the first backward iteration
   * * [TweenCallback.BACK_START]: at each backward iteration beginning, after the repeat delay
   * * [TweenCallback.BACK_END]: at each backward iteration ending
   * * [TweenCallback.BACK_COMPLETE]: at last BACK_END event
   * 
   * forward :      BEGIN                                   COMPLETE
   * forward :      START    END      START    END      START    END
   * |--------------[XXXXXXXXXX]------[XXXXXXXXXX]------[XXXXXXXXXX]
   * backward:      bEND  bSTART      bEND  bSTART      bEND  bSTART
   * backward:      bCOMPLETE                                 bBEGIN
   * 
   *
   * @param flags one or more triggers, separated by the '|' operator.
   */
  void setCallbackTriggers(int flags) {
    _callbackTriggers = flags;
  }

  /**
   * Attaches an object to this tween or timeline. It can be useful in order
   * to retrieve some data from a TweenCallback.
   *
   * [data] Any kind of object.
   */
  void setUserData(Object data) {
    _userData = data;
  }
  

  // -------------------------------------------------------------------------
  // Getters
  // -------------------------------------------------------------------------

  ///Gets the delay of the tween or timeline. Nothing will happen before
  num get delay => _delay;

  ///Gets the duration of a single iteration.
  num get duration => _duration;

  ///Gets the number of iterations that will be played.
  int get repeatCount => _repeatCnt;

  ///Gets the delay occuring between two iterations.
  num get repeatDelay => _repeatDelay;

  /**
   * Returns the complete duration, including initial delay and repetitions.
   * 
   * The formula is as follows:
   * 
   *    fullDuration = delay + duration + (repeatDelay + duration) * repeatCnt
   */
  num get fullDuration => _repeatCnt < 0 ? -1 : _delay + _duration + (_repeatDelay + _duration) * _repeatCnt;

  ///Gets the attached data, or null if none.
  Object get userData => _userData;

  /**
   * Gets the id of the current step. Values are as follows:
   * 
   * * even numbers mean that an iteration is playing
   * * odd numbers mean that we are between two iterations
   * * -2 means that the initial [delay] has not ended
   * * -1 means that we are before the first iteration
   * * [repeatCount]*2 + 1 means that we are after the last iteration
   */
  int get step => _step;

  ///Gets the local time.
  num get currentTime=> _currentTime;

  ///Returns true if the tween or timeline has been started.
  bool get isStarted => _isStarted;

  /**
   * Returns true if the tween or timeline has been initialized. Starting
   * values for tweens are stored at initialization time. This initialization
   * takes place right after the initial delay, if any.
   */
  bool get isInitialized => _isInitialized;

  /**
   * Returns true if the tween is finished (i.e. if the tween has reached
   * its end or has been killed). If you don't use a [TweenManager], you may
   * want to call [free] to reuse the object later.
   */
  bool get isFinished => _isFinished || _isKilled;

  ///Returns true if the iterations are played as yoyo. Yoyo means that every two iterations, the animation will be played backwards.
  bool get isYoyo => _isYoyo;

  ///Returns true if the tween or timeline is currently paused.
  bool get isPaused => _isPaused;
  
  bool get isKilled => _isKilled;

  // -------------------------------------------------------------------------
  // Abstract API
  // -------------------------------------------------------------------------

  void forceStartValues();
  void forceEndValues();

  bool containsTarget(Object target, [int tweenType]);

  // -------------------------------------------------------------------------
  // API
  // -------------------------------------------------------------------------

  void initializeOverride() {
  }

  void updateOverride(int step, int lastStep, bool isIterationStep, num delta) {
  }

  void forceToStart() {
    _currentTime = -delay;
    _step = -1;
    _isIterationStep = false;
    if (isReverse(0)) forceEndValues();
    else forceStartValues();
  }

  void forceToEnd(num time) {
    _currentTime = time - fullDuration;
    _step = _repeatCnt*2 + 1;
    _isIterationStep = false;
    if (isReverse(_repeatCnt*2)) forceStartValues();
    else forceEndValues();
  }

  void callCallback(int type) {
    if (_callback != null && (_callbackTriggers & type) > 0) _callback.onEvent(type, this);
  }

  bool isReverse(int step) {
    return isYoyo && (step%4).abs() == 2;
  }

  bool isValid(int step) {
    return (step >= 0 && step <= _repeatCnt*2) || _repeatCnt < 0;
  }

  void killTarget(Object target, [int tweenType]) {
      if (containsTarget(target, tweenType)) kill();
  }

  // -------------------------------------------------------------------------
  // Update engine
  // -------------------------------------------------------------------------

  /**
   * Updates the tween or timeline state. <b>You may want to use a
   * TweenManager to update objects for you.</b>
   *
   * Slow motion, fast motion and backward play can be easily achieved by
   * tweaking this delta time. Multiply it by -1 to play the animation
   * backward, or by 0.5 to play it twice slower than its normal speed.
   *
   * @param delta A delta time between now and the last call.
   */
  void update(num delta) {
    if (!_isStarted || _isPaused || _isKilled) return;

    _deltaTime = delta;

    if (!isInitialized) {
      initialize();
    }

    if (isInitialized) {
      testRelaunch();
      updateStep();
      testCompletion();
    }

    _currentTime += _deltaTime;
    _deltaTime = 0;
  }

  void initialize() {
    if (currentTime + _deltaTime >= delay) {
      initializeOverride();
      _isInitialized = true;
      _isIterationStep = true;
      _step = 0;
      _deltaTime -= delay-currentTime;
      _currentTime = 0;
      callCallback(TweenCallback.BEGIN);
      callCallback(TweenCallback.START);
    }
  }

  void testRelaunch() {
    if (!_isIterationStep && _repeatCnt >= 0 && step < 0 && currentTime + _deltaTime >= 0) {
      assert( step == -1 );
      _isIterationStep = true;
      _step = 0;
      num delta = 0 - currentTime;
      _deltaTime -= delta;
      _currentTime = 0;
      callCallback(TweenCallback.BEGIN);
      callCallback(TweenCallback.START);
      updateOverride(step, step-1, _isIterationStep, delta);
    }else if (!_isIterationStep && _repeatCnt >= 0 && _step > _repeatCnt*2 && currentTime + _deltaTime < 0) {
      assert (step == repeatCount * 2 + 1 );
      _isIterationStep = true;
      _step = repeatCount * 2;
      num delta = 0-currentTime;
      _deltaTime -= delta;
      _currentTime = duration;
      callCallback(TweenCallback.BACK_BEGIN);
      callCallback(TweenCallback.BACK_START);
      updateOverride(step, step+1, _isIterationStep, delta);
    }
  }

  void updateStep() {
    while (isValid(_step)) {
      if (!_isIterationStep && currentTime + _deltaTime <= 0) {
        _isIterationStep = true;
        _step -= 1;

        num delta = 0 - currentTime;
        _deltaTime -= delta;
        _currentTime = duration;

        if (isReverse(step)) 
          forceStartValues(); 
        else 
          forceEndValues();
        callCallback(TweenCallback.BACK_START);
        updateOverride(step, step+1, _isIterationStep, delta);

      }else if (!_isIterationStep && currentTime + _deltaTime >= repeatDelay) {
        _isIterationStep = true;
        _step += 1;

        num delta = repeatDelay-currentTime;
        _deltaTime -= delta;
        _currentTime = 0;

        if (isReverse(step)) 
          forceEndValues(); 
        else 
          forceStartValues();
        callCallback(TweenCallback.START);
        updateOverride(step, step-1, _isIterationStep, delta);

      }else if (_isIterationStep && currentTime + _deltaTime <= 0) {
        _isIterationStep = false;
        _step -= 1;

        num delta = 0-currentTime;
        _deltaTime -= delta;
        _currentTime = 0;

        updateOverride(step, step+1, _isIterationStep, delta);
        callCallback(TweenCallback.BACK_END);

        if (step < 0 && repeatCount >= 0) 
          callCallback(TweenCallback.BACK_COMPLETE);
        else 
          _currentTime = repeatDelay;

      }else if (_isIterationStep && currentTime + _deltaTime >= duration) {
        _isIterationStep = false;
        _step += 1;

        num delta = duration-currentTime;
        _deltaTime -= delta;
        _currentTime = duration;

        updateOverride(step, step-1, _isIterationStep, delta);
        callCallback(TweenCallback.END);

        if (step > repeatCount*2 && repeatCount >= 0) 
          callCallback(TweenCallback.COMPLETE);
        _currentTime = 0;

      }else if (_isIterationStep) {
        num delta = _deltaTime;
        _deltaTime -= delta;
        _currentTime += delta;
        updateOverride(step, step, _isIterationStep, delta);
        break;

      }else {
        num delta = _deltaTime;
        _deltaTime -= delta;
        _currentTime += delta;
        break;
      }
    }
  }

  void testCompletion() {
          _isFinished = repeatCount >= 0 && (step > repeatCount*2 || step < 0);
  }
}
