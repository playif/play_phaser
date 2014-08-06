part of tweenengine;

/**
 * Easing equation based on Robert Penner's work:
 * http://robertpenner.com/easing/
 * author 
 *    Aurelien Ribon | http://www.aurelienribon.com/ (Original java code)
 *    Xavier Guzman (dart port)
 */
class Elastic extends TweenEquation {
  //static final num PI = 3.14159265f;
  
  num param_a = 0 ;
  num param_p = 0;
  bool setA = false;
  bool setP = false;

  Elastic._();
  
  void a(num a) {
    param_a = a;
    this.setA = true;
  }

  void p(num p) {
    param_p = p;
    this.setP = true;
  }

  static num _computeIN(num t) {  
    //num a = param_a;
    //num p = param_p;
    if (t==0) return 0;  
    if (t==1) return 1; 
    //if (!setP) 
      num p=0.3;
    num s;
    //if (!setA || a < 1) { 
      num a=1; 
      s=p/4; 
//    }else 
//      s = p / (2* Math.PI) * Math.asin(1/a);
    
    return -(a * Math.pow(2, 10 * (t-=1) ) * Math.sin( (t-s) * ( 2 * Math.PI)/p ));
  }
  
  static num _computeOUT(num t) {
//    num a = param_a;
//    num p = param_p;
    if (t==0) return 0;  
    if (t==1) return 1; 
//    if (!setP) 
      num p=0.3;
    num s;
//    if (!setA || a < 1) { 
      num a=1; 
      s=p/4; 
//    }else 
//      s = p/(2*Math.PI) * Math.asin(1/a);
    return a*Math.pow(2,-10*t) * Math.sin( (t-s) * (2*Math.PI) / p ) + 1;
  }

  static num _computeINOUT(num t){
//    num a = param_a;
//    num p = param_p;
    if (t==0) return 0;  
    if ((t*=2)==2) return 1; 
    
//    if (!setP) 
      num p=0.3 * 1.5;
    num s;
//    if (!setA || a < 1) { 
      num a=1; 
      s=p/4; 
//    }
//    else s = p/(2*Math.PI) * Math.asin(1/a);
    if (t < 1) return - 0.5 * (a * Math.pow(2,10 * (t-=1) ) * Math.sin( (t-s)*(2*Math.PI) / p ));
    return a * Math.pow(2,-10 * (t-=1)) * Math.sin( (t-s)*(2*Math.PI) / p ) * 0.5 + 1;
  }
  
  static final Elastic IN = new Elastic._()
    ..name = "Elastic.IN"
    ..compute = _computeIN;
  
  static final Elastic OUT = new Elastic._()
  ..name = "Elastic.OUT"
  ..compute = _computeOUT;
  
  static final Elastic INOUT = new Elastic._()
  ..name = "Elastic.INOUT"
  ..compute = _computeINOUT;
                        
}
