part of tweenengine;

/**
 * Computes the next value of the interpolation, based on its waypoints and
 * the current progress.
*
 * [t] The progress of the interpolation, between 0 and 1. May be out
 * of these bounds if the easing equation involves some kind of rebounds.
 * [points] The waypoints of the tween, from start to target values.
 * [pointsCnt] The number of valid points in the array.
 * 
 * Returns the next value of the interpolation.
 */
typedef num PathComputingFunction(num t, List<num> points, int pointsCnt);

/**
 * Base class for every paths. You can create your own paths and directly use
 * them in the Tween engine by inheriting from this class.
 *
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
abstract class TweenPath {

  
  PathComputingFunction compute;
}


/**
 * Collection of built-in paths.
 *
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
abstract class TweenPaths {
  static final LinearPath linear = new LinearPath();
  static final CatmullRom catmullRom = new CatmullRom();
}