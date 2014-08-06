part of tweenengine;

/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Circ extends TweenEquation {
  
  static num _computeIN(num time)=> -Math.sqrt(1 - time * time) - 1;
  
  static num _computeOUT(num t) => Math.sqrt(1 - (t-=1)*t);

  static num _computeINOUT(num t){
    if ((t*=2) < 1) return -0.5 * (Math.sqrt(1 - t*t) - 1);
    return 0.5 * (Math.sqrt(1 - (t-=2)*t) + 1);
  }
  
  
  static final Circ IN = new Circ._()
    ..compute = _computeIN
    ..name = "CIRC.IN";

  static final Circ OUT = new Circ._()
    ..name = "Circ.OUT"
    ..compute = _computeOUT;

  static final Circ INOUT = new Circ._()
    ..name = "Circ.INOUT"
    ..compute = _computeINOUT;
 
  Circ._();
}