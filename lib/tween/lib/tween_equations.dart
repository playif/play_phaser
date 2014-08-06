part of tweenengine;


/**
 * Computes the next value of the interpolation.
*
 * [time] The current time, between 0 and 1.
 * Returns the current value.
 */
typedef num ComputingFunction(num time);


/**
 * Base class for every easing equation. You can create your own equations
 * and directly use them in the Tween engine by inheriting from this class.
 *
 * see [Tween]
  * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
abstract class TweenEquation {

  
  ///The [ComputingFunction] for this equation
  ComputingFunction compute;
  
  ///String representation of this function
  String name;

  /**
  * Returns true if the given string is the name of this equation (the name
  * is returned in the toString() method, don't forget to override it).
  * This method is usually used to save/load a tween to/from a text file.
  */
  bool isValueOf(String str) {
    return str == toString();
  }
}


/**
 * Collection of built-in easing equations
 *
  * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
abstract class TweenEquations {
        static final Linear easeNone = Linear.INOUT;
        static final Quad easeInQuad = Quad.IN;
        static final Quad easeOutQuad = Quad.OUT;
        static final Quad easeInOutQuad = Quad.INOUT;
        static final Cubic easeInCubic = Cubic.IN;
        static final Cubic easeOutCubic = Cubic.OUT;
        static final Cubic easeInOutCubic = Cubic.INOUT;
        static final Quart easeInQuart = Quart.IN;
        static final Quart easeOutQuart = Quart.OUT;
        static final Quart easeInOutQuart = Quart.INOUT;
        static final Quint easeInQuint = Quint.IN;
        static final Quint easeOutQuint = Quint.OUT;
        static final Quint easeInOutQuint = Quint.INOUT;
        static final Circ easeInCirc = Circ.IN;
        static final Circ easeOutCirc = Circ.OUT;
        static final Circ easeInOutCirc = Circ.INOUT;
        static final Sine easeInSine = Sine.IN;
        static final Sine easeOutSine = Sine.OUT;
        static final Sine easeInOutSine = Sine.INOUT;
        static final Expo easeInExpo = Expo.IN;
        static final Expo easeOutExpo = Expo.OUT;
        static final Expo easeInOutExpo = Expo.INOUT;
        static final Back easeInBack = Back.IN;
        static final Back easeOutBack = Back.OUT;
        static final Back easeInOutBack = Back.INOUT;
        static final Bounce easeInBounce = Bounce.IN;
        static final Bounce easeOutBounce = Bounce.OUT;
        static final Bounce easeInOutBounce = Bounce.INOUT;
        static final Elastic easeInElastic = Elastic.IN;
        static final Elastic easeOutElastic = Elastic.OUT;
        static final Elastic easeInOutElastic = Elastic.INOUT;
}





