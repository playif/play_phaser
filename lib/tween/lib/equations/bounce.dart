part of tweenengine;

/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Bounce extends TweenEquation {
  
  static num _computeIN(num time)=> 1 - _computeOUT(1-time);
  
  static num _computeOUT(num t){
    if (t < (1 / 2.75)) {
      return 7.5625 *t *t;
    } else if (t < (2/2.75)) {
      return 7.5625 *(t-= (1.5 /2.75))*t + .75;
    } else if (t < (2.5/2.75)) {
      return 7.5625 * (t-=(2.25 / 2.75)) * t + .9375;
    } else {
      return 7.5625 * (t-=(2.625 /2.75)) * t + .984375;
    }
  }

  static num _computeINOUT(num t){
    if (t < 0.5) return _computeIN(t*2) * 0.5;
    else return _computeOUT(t*2-1) * 0.5 + 0.5;
  }
  
  static final Bounce IN = new Bounce._()
    ..name = "Bounce.IN"
    ..compute = _computeIN;

  static final Bounce OUT = new Bounce._()
    ..name = "Bounce.OUT"
    ..compute = _computeOUT;

  static final Bounce INOUT = new Bounce._()
    ..name = "Bounce.INOUT"
    ..compute = _computeINOUT;
  
  Bounce._();
}