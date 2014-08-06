part of tweenengine;
/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Cubic extends TweenEquation {
  
  static num _computeIN(num time)=>  time * time * time;
  
  static num _computeOUT(num t) => (t-=1)*t*t + 1;

  static num _computeINOUT(num t){
    if ((t*=2) < 1) return 0.5 * t * t * t;
    return 0.5 * ( (t-=2) * t * t + 2);
  }
  static final Cubic IN = new Cubic._()
    ..name = "Cubic.IN"
    ..compute = _computeIN;
  
  static final Cubic OUT = new Cubic._()
  ..name = "Cubic.OUT"
  ..compute = _computeOUT;
  
  static final Cubic INOUT = new Cubic._()
  ..name = "Cubic.INOUT"
  ..compute = _computeINOUT;
                
  Cubic._();
}