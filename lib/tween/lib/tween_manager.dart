part of tweenengine;

/**
 * A TweenManager updates all your tweens and timelines at once.
 * Its main interest is that it handles the tween/timeline life-cycles for you,
 * as well as the pooling constraints (if object pooling is enabled).
 *
 * Just give it a bunch of tweens or timelines and call [update] periodically,
 * you don't need to care for anything else! Relax and enjoy your animations.
 *
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class TweenManager {
  // -------------------------------------------------------------------------
  // Static API
  // -------------------------------------------------------------------------

  /**
   * Disables or enables the "auto remove" mode of any tween manager for a
   * particular tween or timeline. This mode is activated by default. The
   * interest of desactivating it is to prevent some tweens or timelines from
   * being automatically removed from a manager once they are finished.
   * Therefore, if you update a manager backwards, the tweens or timelines
   * will be played again, even if they were finished.
   */
  static void setAutoRemove(BaseTween object, bool value) {
          object._isAutoRemoveEnabled = value;
  }

  /**
   * Disables or enables the "auto start" mode of any tween manager for a
   * particular tween or timeline. This mode is activated by default. If it
   * is not enabled, add a tween or timeline to any manager won't start it
   * automatically, and you'll need to call .start() manually on your object.
   */
  static void setAutoStart(BaseTween object, bool value) {
    object._isAutoStartEnabled = value;
  }

  // -------------------------------------------------------------------------
  // API
  // -------------------------------------------------------------------------

  final List<BaseTween> _objects = new List<BaseTween>();
  bool _isPaused = false;

  ///Adds a tween or timeline to the manager and starts or restarts it.
  void add(BaseTween object) {
    if (!_objects.contains(object)) _objects.add(object);
    if (object._isAutoStartEnabled) object.start();
  }

  ///Returns true if the manager contains any valid interpolation associated to the given target object and to the given tween type.
  bool containsTarget(Object target, int tweenType) => _objects.any( (BaseTween obj) => obj.containsTarget(target));

  ///Kills every managed tweens and timelines.
  void killAll() {
    _objects.forEach( (BaseTween obj) => obj.kill() );
  }

  /**
   * Kills every tweens associated to the given target and tween type. Will also kill every timelines containing 
   * a tween associated to the given target and tween type.
   */
  void killTarget(Object target, [int tweenType]) {
    _objects.forEach( (BaseTween obj) => obj.killTarget(target, tweenType) );
  }

  ///Pauses the manager. Further update calls won't have any effect.
  void pause() { _isPaused = true; }

  /// Resumes the manager, if paused.
  void resume() { _isPaused = false; }

  /**
   * Updates all tweens with a [delta] time and handles the tweens life-cycles
   * automatically. If a tween is finished, it will be removed from the
   * manager. **The delta time represents the elapsed time between now and the
   * last update call**. Each tween or timeline manages its local time, and adds
   * this delta to its local time to update itself.
   *
   * Slow motion, fast motion and backward play can be easily achieved by
   * tweaking this delta time. Multiply it by -1 to play the animation
   * backward, or by 0.5 to play it twice slower than its normal speed.
   */
  void update(num delta) {
    _objects.removeWhere((BaseTween obj) {
      if (obj.isFinished && obj._isAutoRemoveEnabled) {
        obj.free();
        return true;
      }
      return false;
    });

    if (!_isPaused) {
      if (delta >= 0) {
        for ( int i =0; i < _objects.length; i++)
          _objects[i].update(delta);
      } else {
        for ( int i = _objects.length - 1; i >= 0; i--)
          _objects[i].update(delta);
      }
    }
  }

//  removeTween(BaseTween tween){
//    tween.kill();
//  }

  /**
   * Gets the number of managed objects. An object may be a tween or a timeline. Note that a timeline 
   * only counts for 1 object, since it manages its children itself.
   * 
   * To get the count of running tweens, see [runningTweensCount]}.
   */
  int get length => _objects.length;

  /**
   * Gets the number of running tweens. This number includes the tweens located inside timelines (and nested timelines).
   * 
   * **Provided for debug purpose only**
   */
  int get runningTweensCount => _getTweensCount(_objects);

  /**
   * Gets the number of running timelines. This number includes the timelines nested inside other timelines.
   * 
   * **Provided for debug purpose only.**
   */
  int get runningTimelinesCount => _getTimelinesCount(_objects);

  /**
   * Gets an immutable list of every managed object.
   * 
   * **Provided for debug purpose only.**
   */
  List<BaseTween> get objects => new List<BaseTween>.from(_objects, growable: false);

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  static int _getTweensCount(List<BaseTween> objs) {
    int cnt = 0;
    objs.forEach( (BaseTween obj) {
      if (obj is Tween) cnt += 1;
      else cnt += _getTweensCount((obj as Timeline).getChildren());
    });
    return cnt;
  }

  static int _getTimelinesCount(List<BaseTween> objs) {
    int cnt = 0;
    objs.forEach( (BaseTween obj) {
      if (obj is Timeline) 
        cnt += 1 + _getTimelinesCount(obj.getChildren());
    });
    return cnt;
  }
}