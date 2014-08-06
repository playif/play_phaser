part of tweenengine;

/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Expo extends TweenEquation {
  
  static num _computeIN(num t)=> (t==0) ? 0 : Math.pow(2, 10 * (t - 1));
  
  static num _computeOUT(num t) => (t==1) ? 1 : -Math.pow(2, -10 * t) + 1;

  static num _computeINOUT(num t){
    if (t==0) return 0;
    if (t==1) return 1;
    if ((t*=2) < 1) 
      return 0.5 * Math.pow(2, 10 * (t - 1));
    return 0.5 * (-Math.pow(2, -10 * --t) + 2);
  }
  
  static final Expo IN = new Expo._()
    ..name = "Expo.IN"
    ..compute = _computeIN;
  
  static final Expo OUT = new Expo._()
  ..name = "Expo.OUT"
  ..compute = _computeOUT;
  
  static final Expo INOUT = new Expo._()
  ..name = "Expo.INOUT"
  ..compute = _computeINOUT;
  
  Expo._();
}