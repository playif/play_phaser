part of tweenengine;


/**
 * The [Tweenable] interface enables the object to be passed as target to the Tween Engine.
 * When you tween an object, you also provide a [tweenType], which will be passed to these methods.
 * The [tweenType] is our way of telling the engine which properties it should tween.
 * It's a very simple reflection implementation, if you want.
 *
 * Dart, unlike javascript and to provide better minification,
 * has no string accessors such as `myObject['myProperty']`.
 * You can only access a property using `myObject.myProperty`.
 * This will change when `dart:mirrors` are fully operational.
 * Though, as reflection incurs terrible overhead, especially when compiled to javascript,
 * it makes sense to implement these methods when speed is of the essence. (which it often is)
 *
 * This is a less verbose alternative to TweenAccessor for when you have control over the class
 * whose properties you want to interpolate.
 *
 */
abstract class Tweenable {
  /**
   * Gets one or many values from this object associated to the given tween type.
   * It is used by the Tween Engine to determine starting values.
   *
   * [tweenType] An integer representing the tween type.
   * [returnValues] A List that should be modified by this method.
   * 
   * Returns the count of modified slots from the returnValues array.
   */
  num getTweenableValue(String tweenType);
  
  /**
   * This method is called by the Tween Engine each time a running tween
   * associated with this object has been updated.
   *
   * [tweenType] An integer representing the tween type.
   * [newValues] The new values determined by the Tween Engine.
   */
  void setTweenableValue(String tweenType, num newValue);
}
