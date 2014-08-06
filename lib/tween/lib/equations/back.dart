part of tweenengine;
/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Back extends TweenEquation {
  
  static num _param_s = 1.70158;
  
  static num _computeIN(num time){
    num s = _param_s;
    return time * time *((s+1)* time - s);
  }
  
  static num _computeOUT(num time){
    num s = _param_s;
    return (time-=1)*time*((s+1)*time + s) + 1;
  }
  
  static num _computeINOUT(num time){
    num s = _param_s;
    if ((time*=2) < 1) 
      return 0.5 * (time* time* ( ( ( s *= (1.525) ) + 1)  * time - s));
    return 0.5 * ((time-=2)*time*( ( ( s *= (1.525 ) ) + 1) * time + s) + 2);
  }
  
  
  static final Back IN = new Back._()
    ..compute = _computeIN
    ..name = "BACK.IN";

  static final Back OUT = new Back._()
    ..compute = _computeOUT
    ..name = "BACK.OUT";
  
  static final Back INOUT = new Back._()
    ..compute = _computeINOUT
    ..name = "BACK.INOUT";
  
  Back._();
}