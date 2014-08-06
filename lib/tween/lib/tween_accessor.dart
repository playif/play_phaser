part of tweenengine;


/**
 * The TweenAccessor interface lets you interpolate any attribute from any
 * object. Just implement it as you want and register it to the engine by
 * calling [Tween.registerAccessor].
 *
 * Example
 *
 * The following code snippet presents an example of implementation for tweening
 * a Particle class. This Particle class is supposed to only define a position
 * with an "x" and an "y" fields, and their associated getters and setters.
 *
 *     class ParticleAccessor implements TweenAccessor<Particle> {
 *        static const int X = 1;
 *        static const int Y = 2;
 *        static const int XY = 3;
 *
 *        int getValues(Particle target, int tweenType, List<num> returnValues) {
 *          switch (tweenType) {
 *            case X: returnValues[0] = target.getX(); return 1;
 *            case Y: returnValues[0] = target.getY(); return 1;
 *            case XY:
 *                 returnValues[0] = target.getX();
 *                 returnValues[1] = target.getY();
 *                 return 2;
 *            default: return 0;
 *          }
 *        }
 *
 *        void setValues(Particle target, int tweenType, List<num> newValues) {
 *          switch (tweenType) {
 *            case X: target.setX(newValues[0]); break;
 *            case Y: target.setY(newValues[1]); break;
 *            case XY:
 *              target.setX(newValues[0]);
 *              target.setY(newValues[1]);
 *              break;
 *          }
 *        }
 *      }
 *
 * Once done, you only need to register this TweenAccessor once to be able to
 * use it for every Particle objects in your application:
 *
 *     Tween.registerAccessor(Particle, new ParticleAccessor());
 *
 * And that's all, the Tween Engine can now work with all your particles!
 *
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
abstract class TweenAccessor<T> {
  /**
   * Gets one or many values from the target object associated to the
   * given tween type. It is used by the Tween Engine to determine starting
   * values.
   *
   * [target] The target object of the tween.
   * [tweenType] An integer representing the tween type.
   * [returnValues] An array which should be modified by this method.
   * 
   * Returns the count of modified slots from the returnValues array.
   */
  num getValue(T target, String tweenType);
  
  /**
   * This method is called by the Tween Engine each time a running tween
   * associated with the current target object has been updated.
   *
   * [target] The target object of the tween.
   * [tweenType] An integer representing the tween type.
   * [newValues] The new values determined by the Tween Engine.
   */
  void setValue(T target, String tweenType, num newValue);
}
