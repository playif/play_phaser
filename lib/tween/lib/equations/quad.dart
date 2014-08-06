part of tweenengine;

/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Quad extends TweenEquation {
   
  static num _computeINOUT(num t){
    if ((t*=2) < 1) return 0.5* t * t;
    return -0.5 * ((--t)*(t-2) - 1);
  }
  
  static final Quad IN = new Quad._()
  ..name = "Quad.IN"
  ..compute = (num t) => t * t;

  static final Quad OUT = new Quad._()
    ..name = "Quad.OUT"
    ..compute = (num t) => -t*(t-2);

  static final Quad INOUT = new Quad._()
    ..name = "Quad.INOUT"
    ..compute = _computeINOUT;
  
  Quad._();
}