part of tweenengine;
 
/**
 * Core class of the Tween Engine. A Tween is basically an interpolation
 * between two values of an object attribute. However, the main interest of a
 * Tween is that you can apply an easing formula on this interpolation, in
 * order to smooth the transitions or to achieve cool effects like springs or
 * bounces.
 *
 * The Universal Tween Engine is called "universal" because it is able to apply
 * interpolations on every attribute from every possible object. Therefore,
 * every object in your application can be animated with cool effects: it does
 * not matter if your application is a game, a desktop interface or even a
 * console program! If it makes sense to animate something, then it can be
 * animated through this engine.
 *
 * This class contains many static factory methods to create and instantiate
 * new interpolations easily. The common way to create a Tween is by using one
 * of these factories:
 *
 * * Tween.to(...)
 * * Tween.from(...)
 * * Tween.set(...)
 * * Tween.callBack(...)
 *
 * ## Example - firing a Tween
 *
 * The following example will move the target horizontal position from its
 * current value to x=200 and y=300, during 500ms, but only after a delay of
 * 1000ms. The animation will also be repeated 2 times (the starting position
 * is registered at the end of the delay, so the animation will automatically
 * restart from this registered position).
 *
 *     Tween.to(myObject, POSITION_XY, 0.5f)
 *       ..targetValues = [200, 300]
 *       ..easing = Quad.INOUT
 *       ..delay = 1
 *       ..repeat(2, 0.2)
 *       ..start(myManager);
 *
 * Tween life-cycles can be automatically managed for you, thanks to the
 * [TweenManager] class. If you choose to manage your tween when you start
 * it, then you don't need to care about it anymore. **Tweens are
 * _fire-and-forget_: don't think about them anymore once you started
 * them (if they are managed of course).**
 *
 * You need to periodicaly update the tween engine, in order to compute the new
 * values. If your tweens are managed, only update the manager; else you need
 * to call [:update():] on your tweens periodically.
 *
 * ## Example - setting up the engine
 *
 * The engine cannot directly change your objects attributes, since it doesn't
 * know them. Therefore, you need to tell him how to get and set the different
 * attributes of your objects: **you need to implement the [TweenAccessor]
 * interface for each object class you will animate**. Once
 * done, don't forget to register these implementations, using the static method
 * [registerAccessor], when you start your application.
 *
 * see [TweenAccessor]
 * see [TweenManager]
 * see [TweenEquation]
 * see [Timeline]
 * author
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Tween extends BaseTween<Tween> {
  // -------------------------------------------------------------------------
  // Static -- misc
  // -------------------------------------------------------------------------

  ///Used as parameter in [repeat] and [repeatYoyo] methods.
  static const int INFINITY = -1;

//  static int _combinedAttrsLimit = 3;
//  static int _waypointsLimit = 0;

  ///Changes the [limit] for combined attributes. Defaults to 3 to reduce memory footprint.
//  static void set combinedAttributesLimit(int limit){ 
//    Tween._combinedAttrsLimit = limit; 
//  }

  ///Changes the [limit] of allowed waypoints for each tween. Defaults to 0 to reduce memory footprint.
//  static void set waypointsLimit(int limit){ 
//    Tween._waypointsLimit = limit; 
//  }

  ///Gets the version number of the library.

  static String get version => "0.10.0";

  // -------------------------------------------------------------------------
  // Static -- pool
  // -------------------------------------------------------------------------

  static final PoolCallback<Tween> _poolCallback = new PoolCallback<Tween>()
    ..onPool = (Tween obj) {
    obj.reset();
  }
    ..onUnPool = (Tween obj) {
    obj.reset();
  };


  static final Pool<Tween> _pool = new Pool<Tween>(_poolCallback)
    ..create = () => new Tween._();


  /// Used for debug purpose. Gets the current number of objects that are waiting in the Tween pool.

  int getPoolSize() => _pool.size();

  //Increases the minimum capacity of the pool. Capacity defaults to 20.
  //static void ensurePoolCapacity(int minCapacity) => _pool.ensureCapacity(minCapacity);

  // -------------------------------------------------------------------------
  // Static -- tween accessors
  // -------------------------------------------------------------------------

  static TweenAccessor _registeredAccessors;

  /**
   * Registers an accessor with the class of an object. This accessor will be
   * used by tweens applied to every objects implementing the registered
   * class, or inheriting from it.
   *
   * [someType] An object type.
   * [defaultAccessor] Th e accessor that will be used to tween any object of class "someClass".
   */

  static void registerAccessor(TweenAccessor defaultAccessor) {
    _registeredAccessors = defaultAccessor;
  }

  /**
   * Gets the registered TweenAccessor associated with the given object class.
   *
   * [someType] An object type.
   */

  static TweenAccessor getRegisteredAccessor() {
    return _registeredAccessors;
  }

  // -------------------------------------------------------------------------
  // Static -- factories
  // -------------------------------------------------------------------------

  /**
   * Factory creating a new standard interpolation. This is the most common
   * type of interpolation. The starting values are retrieved automatically
   * after the delay (if any).
   *
   * **You need to set the target values of the interpolation by using
   * of the targetValues setter**. The interpolation will run from the
   * starting values to these target values.
   *
   * The common use of Tweens is "fire-and-forget": you do not need to care
   * for tweens once you added them to a TweenManager, they will be updated
   * automatically, and cleaned once finished. Common call:
   *
   *     Tween.to(myObject, POSITION, 1.0f)
   *       ..targetValues = [50, 70]
   *       ..easing = Quad.INOUT
   *       ..start(myManager);
   *
   * Several options such as delay, repetitions and callbacks can be added to
   * the tween.
   *
   * [target] The target object of the interpolation.
   * [tweenType] The desired type of interpolation.
   * [duration] The duration of the interpolation, in milliseconds.
   *
   * Returns The generated Tween.
   */

  static Tween to(Object target, String tweenType, num duration) {
    Tween tween = _pool.get()
      ..easing = Quad.INOUT
      .._setup(target, tweenType, duration)
      ..path = TweenPaths.catmullRom;
    return tween;
  }

  /**
   * Factory creating a new reversed interpolation. The ending values are
   * retrieved automatically after the delay (if any).
   *
   * **You need to set the starting values of the interpolation by using
   * of the [targetValue] setter**. The interpolation will run from the
   * starting values to these target values.
   *
   * The common use of Tweens is "fire-and-forget": you do not need to care
   * for tweens once you added them to a TweenManager, they will be updated
   * automatically, and cleaned once finished. Common call:
   *
   *     Tween.from(myObject, POSITION, 1.0)
   *      ..targetValues = [0, 0]
   *      ..easing = Quad.INOUT
   *      .start(myManager);
   *
   * Several options such as delay, repetitions and callbacks can be added to
   * the tween.
   *
   * [target] The target object of the interpolation.
   * [tweenType] The desired type of interpolation.
   * [duration] The duration of the interpolation, in milliseconds.
   *
   * Returns The generated Tween.
   */

  static Tween from(Object target, String tweenType, num duration) {
    Tween tween = _pool.get()
      .._setup(target, tweenType, duration)
      ..easing = Quad.INOUT
      ..path = TweenPaths.catmullRom
      .._isFrom = true;
    return tween;
  }

  /**
   * Factory creating a new instantaneous interpolation (thus this is not
   * really an interpolation).
   *
   * **You need to set the target values of the interpolation by using one
   * of the [targetValue] setter**. The interpolation will set the target
   * attribute to these values after the delay (if any).
   *
   * The common use of Tweens is "fire-and-forget": you do not need to care
   * for tweens once you added them to a TweenManager, they will be updated
   * automatically, and cleaned once finished. Common call:
   *
   *     Tween.set(myObject, POSITION)
   *      ..target = [50, 70]
   *      ..delay = 1
   *      ..start(myManager);
   *
   * Several options such as delay, repetitions and callbacks can be added to
   * the tween.
   *
   * [target] The target object of the interpolation.
   * [tweenType] The desired type of interpolation.
   *
   * Returns The generated Tween.
   */

  static Tween set(Object target, String tweenType) {
    Tween tween = _pool.get()
      .._setup(target, tweenType, 0)
      ..easing = TweenEquations.easeInQuad;
    return tween;
  }

  /**
   * Factory creating a new timer. The given callback will be triggered on
   * each iteration start, after the delay.
   *
   * The common use of Tweens is "fire-and-forget": you do not need to care
   * for tweens once you added them to a TweenManager, they will be updated
   * automatically, and cleaned once finished. Common call:
   *
   *     Tween.call(myCallback)
   *      ..delay = 1
   *      ..repeat(10, 1000)
   *      ..start(myManager);
   *
   * see [TweenCallback]
   *
   * [callback] The callback that will be triggered on each iteration start.
   *
   * Returns The generated Tween.
   */

  static Tween callBack(TweenCallback callback) {
    Tween tween = _pool.get()
      .._setup(null, '', 0)
      ..setCallback(callback)
      ..setCallbackTriggers(TweenCallback.START);
    return tween;
  }

  /**
   * Convenience method to create an empty tween. Such object is only useful
   * when placed inside animation sequences (see [Timeline]), in which
   * it may act as a beacon, so you can set a callback on it in order to
   * trigger some action at the right moment.
   *
   * Returns The generated Tween.
   */

  static Tween mark() {
    Tween tween = _pool.get()
      .._setup(null, '', 0);
    return tween;
  }

  // -------------------------------------------------------------------------
  // Attributes
  // -------------------------------------------------------------------------

  // Main
  Object _target;

  //Type _targetClass;
  TweenAccessor<Object> _accessor;
  String _type;
  TweenEquation _equation;
  TweenPath _path;

  // General
  bool _isFrom;
  bool _isRelative;

  //int _combinedAttrsCnt;
  //int _waypointsCnt;

  // Values
  num _startValue ;

  //new List<num>(_combinedAttrsLimit);
  num _targetValue ;

  //= new List<num>(_combinedAttrsLimit);
  //final List<num> _waypoints = new List<num>(_waypointsLimit * _combinedAttrsLimit);

  // Buffers
  num _currentValue;

  //new List<num>(_combinedAttrsLimit);
//  List<num> _pathBuffer = new List<num>((2+ _waypointsLimit)*_combinedAttrsLimit);

  // -------------------------------------------------------------------------
  // Setup
  // -------------------------------------------------------------------------

  Tween._() {
    reset();
  }

  //@Override

  void reset() {
    super.reset();

    _target = null;
    //_targetClass = null;
    _accessor = null;
    _type = "";
    _equation = null;
    _path = null;

    _isFrom = _isRelative = false;

    _startValue = _targetValue = _currentValue = 0;

    //_combinedAttrsCnt = _waypointsCnt = 0;

//    if (_accessorBuffer.length != _combinedAttrsLimit) {
//            _accessorBuffer = new Float32List(_combinedAttrsLimit);
//    }

//    if (_pathBuffer.length != (2+ _waypointsLimit) * _combinedAttrsLimit) {
//            _pathBuffer = new Float32List((2+ _waypointsLimit) * _combinedAttrsLimit);
//    }
  }

  void _setup(Object target, String tweenType, num duration) {
    if (duration < 0) throw new Exception("Duration can't be negative");

    _target = target;
    //_targetClass = target != null ? _findTargetClass() : null;
    _type = tweenType;
    _duration = duration;
  }

//  Type _findTargetClass() {
//    if (_registeredAccessors.containsKey(_target.runtimeType)) return _target.runtimeType;
//    if (_target is TweenAccessor) return _target.runtimeType;
//    if (_target is Tweenable) return _target.runtimeType;
//
//    //TODO: find out about this
  ////                Type parentClass = _target.runtimeType.getSuperclass();
  ////                while (parentClass != null && !_registeredAccessors.containsKey(parentClass))
  ////                        parentClass = parentClass.getSuperclass();
  ////
  ////                return parentClass;
//    return null;
//  }

  // -------------------------------------------------------------------------
  // API
  // -------------------------------------------------------------------------


  /**
   * Forces the tween to use the TweenAccessor registered with the given target class. Useful if you want to use a specific accessor associated
   * to an interface, for instance.
   *
   * [targetClass] A type registered with an accessor.
   */
//  void cast(Type targetClass) {
//    if (isStarted) throw new Exception("You can't cast the target of a tween once it is started");
//    _targetClass = targetClass;
//  }

  /**
   * Adds a waypoint to the path. The default path runs from the start values
   * to the end values linearly. If you add waypoints, the default path will
   * use a smooth catmull-rom spline to navigate between the waypoints, but
   * you can change this behavior by setting the [path].
   *
   * [num_OR_numList] The targets of this waypoint. Can be either a num, or a List<num>
   */
//  void addWaypoint(num_OR_numList) {
//    if(num_OR_numList is num){
//      if (_waypointsCnt == _waypointsLimit) _throwWaypointsLimitReached();
//      _waypoints[_waypointsCnt] = num_OR_numList;
//      _waypointsCnt += 1;
//    }else if (num_OR_numList is List<num>){
//      if (_waypointsCnt == _waypointsLimit) _throwWaypointsLimitReached();
//      _waypoints.setAll( _waypointsCnt * num_OR_numList.length, num_OR_numList);
//      _waypointsCnt += 1;
//    }
//  }

  // -------------------------------------------------------------------------
  // Getters & Setters
  // -------------------------------------------------------------------------

  ///Gets the target object.

  get target => _target;

  ///Gets the type of the tween.

  String get tweenType => _type;

  /**
   * The easing [equation][TweenEquation] of the tween. Existing equations can be accessed via
   * [TweenEquations] static instances, but you can of course implement your owns, see [TweenEquation].
   * Default equation is Quad.INOUT.
   */

  TweenEquation get easing => _equation;

  void set easing(TweenEquation easeEquation) {
    _equation = easeEquation;
  }

  /**
   * Target value(s) of the interpolation. The interpolation will run from the
   * **value(s) at start time (after the delay, if any)** to these target value(s).
   *
   * To sum-up:
   * * start values: values at start time, after delay
   * * end values: [targetValue]
   */

  num get targetValue => _targetValue;

  void set targetValue(num value) {
    _targetValue = value;
//    if(num_OR_numList is num)
//      _targetValues[0] = num_OR_numList;
//    else if (num_OR_numList is List<num>){
//      if (_targetValues.length > _combinedAttrsLimit) _throwCombinedAttrsLimitReached();
//      _targetValues.setAll(0, num_OR_numList);
//    }
  }

  /**
   * Sets the target values of the interpolation, relatively to the **values
   * at start time (after the delay, if any)**.
   *
   * To sum-up:<br/>
   * - start values: values at start time, after delay<br/>
   * - end values: params + values at start time, after delay
   *
   * targetValues The relative target values of the interpolation. Can be either a num, or a List<num> if
   * multiple target values are needed
   */

  void set targetRelative(num value) {
    //if(num_OR_numList is num)
    _targetValue = isInitialized ? value + _startValue : value;
//    else if (num_OR_numList is List<num>){
//      if (num_OR_numList.length > _combinedAttrsLimit) _throwCombinedAttrsLimitReached();
//      for (int i=0; i< num_OR_numList.length; i++) {
//        _targetValue = isInitialized ? num_OR_numList[i] + _startValue : num_OR_numList[i];
//      }
//    }
    _isRelative = true;
  }


  /**
   * The algorithm that will be used to navigate through the waypoints,
   * from the start values to the end values. Default is a catmull-rom spline,
   * but you can find other paths in the [TweenPaths] class.
   */

  TweenPath get path => _path;

  void set path(TweenPath path) {
    _path = path;
  }

  ///the number of combined animations.
  //int get combinedAttributesCount=> _combinedAttrsCnt;

  ///the TweenAccessor used with the target.

  TweenAccessor get accessor => _accessor;

  ///the class that was used to find the associated TweenAccessor.
  //Type get targetClass => _targetClass;

  // -------------------------------------------------------------------------
  // Overrides
  // -------------------------------------------------------------------------

  void build() {
    if (_target == null) return ;

    _accessor = _registeredAccessors;
    //if (_accessor == null && _target is TweenAccessor) _accessor = _target;
    //if (_accessor != null) { 
    _currentValue = _accessor.getValue(_target, _type) ;
    //if (_combinedAttrsCnt == null) _combinedAttrsCnt = 0;
    //}
    //else if (_target is Tweenable) {
    //  _accessorBuffer = (_target as Tweenable).getTweenableValue(_type) ;
    //if (_combinedAttrsCnt == null) _combinedAttrsCnt = 0;
    //}
    //else throw new Exception("No TweenAccessor was found for the target, and it is not Tweenable either.");

    //if (_combinedAttrsCnt > _combinedAttrsLimit) _throwCombinedAttrsLimitReached();
  }

  void free() {
    _pool.free(this);
  }

  void initializeOverride() {
    if (_target == null) return;

    _startValue = _getTweenedValue();

    //for (int i=0; i<_combinedAttrsCnt; i++) {
    _targetValue += _isRelative ? _startValue : 0;

    //for (int ii=0; ii<_waypointsCnt; ii++) {
    //  _waypoints[ii*_combinedAttrsCnt+i] += _isRelative ? _startValues[i] : 0;
    //}

    if (_isFrom) {
      num tmp = _startValue;
      _startValue = _targetValue;
      _targetValue = tmp;
    }
    //}
  }

  void updateOverride(int step, int lastStep, bool isIterationStep, num delta) {
    if (_target == null || _equation == null) return;

    // Case iteration end has been reached
    if (!isIterationStep && step > lastStep) {
      _setTweenedValue(isReverse(lastStep) ? _startValue : _targetValue);
      return;
    }

    if (!isIterationStep && step < lastStep) {
      _setTweenedValue(isReverse(lastStep) ? _targetValue : _startValue);
      return;
    }

    // Validation
    assert (isIterationStep);
    assert (currentTime >= 0);
    assert (currentTime <= duration);

    // Case duration equals zero
    if (duration < 0.00000000001 && delta > -0.00000000001) {
      _setTweenedValue(isReverse(step) ? _targetValue : _startValue);
      return;
    }

    if (duration < 0.00000000001 && delta < 0.00000000001) {
      _setTweenedValue(isReverse(step) ? _startValue : _targetValue);
      return;
    }

    // Normal behavior
    num time = isReverse(step) ? duration - currentTime : currentTime;
    num t = _equation.compute(time / duration);
    _currentValue = _startValue + t * (_targetValue - _startValue);
//    if (_waypointsCnt == 0 || _path == null) {
//      //for (int i=0; i<_combinedAttrsCnt; i++) {
//        _accessorBuffer = _startValues + t * (_targetValues - _startValues);
//      //}
//
//    } else {
//      //for (int i=0; i<_combinedAttrsCnt; i++) {
//        _pathBuffer[0] = _startValues;
//        _pathBuffer[1+_waypointsCnt] = _targetValues;
    ////        for (int ii=0; ii<_waypointsCnt; ii++) {
    ////          _pathBuffer[ii+1] = _waypoints[ii*_combinedAttrsCnt+i];
    ////        }
//
//        _accessorBuffer = _path.compute(t, _pathBuffer, _waypointsCnt + 2);
//      //}
//    }

    _setTweenedValue(_currentValue);
  }

  // -------------------------------------------------------------------------
  // BaseTween impl.
  // -------------------------------------------------------------------------

  void forceStartValues() {
    if (_target == null) return;
    _setTweenedValue(_startValue);
  }

  void forceEndValues() {
    if (_target == null) return;
    _setTweenedValue(_targetValue);
  }

  bool containsTarget(Object target, [int tweenType = null]) {
    if (tweenType = null)
      return _target == target;
    return _target == target && _type == tweenType;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  num _getTweenedValue() {
    if (_accessor != null) {
      return _accessor.getValue(_target, _type);
    } else if (_target is Tweenable) {
      // _target is Tweenable
      return (_target as Tweenable).getTweenableValue(_type);
    }

    return 0;
  }

  void _setTweenedValue(num value) {
    if (_accessor != null) {
      _accessor.setValue(_target, _type, value);
    } else if (_target is Tweenable) {
      (_target as Tweenable).setTweenableValue(_type, value);
    }
  }

//  void _throwCombinedAttrsLimitReached() {
//          String msg = """You cannot combine more than $_combinedAttrsLimit 
//                  attributes in a tween. You can raise this limit with 
//                  Tween.setCombinedAttributesLimit(), which should be called once
//                  in application initialization code.""";
//          throw new Exception(msg);
//  }

//  void _throwWaypointsLimitReached() {
//          String msg = """You cannot add more than $_waypointsLimit 
//                  waypoints to a tween. You can raise this limit with
//                  Tween.setWaypointsLimit(), which should be called once in
//                  application initialization code.""";
//          throw new Exception(msg);
//  }
}