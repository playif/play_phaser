part of tweenengine;

/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Sine extends TweenEquation {
  //private static final float PI = 3.14159265f;

  static final Sine IN = new Sine._()
    ..name = "Sine.IN"
  ..compute = (num t) => -Math.cos(t * (Math.PI/2)) + 1;

  static final Sine OUT = new Sine._()
    ..name = "Sine.OUT"
    ..compute = (num t) => Math.sin(t * (Math.PI/2));

  static final Sine INOUT = new Sine._()
    ..name = "Sine.INOUT"
    ..compute = (num t) => -0.5 * (Math.cos(Math.PI*t) - 1);

  Sine._();
}
