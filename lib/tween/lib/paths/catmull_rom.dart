part of tweenengine;

/**
 * @author Aurelien Ribon | http://www.aurelienribon.com/
 */
class CatmullRom extends TweenPath {
   
  CatmullRom(){
    this.compute = _compute;
  }
  
  num _compute(num t, List<num> points, int pointsCnt) {
    num segment = ((pointsCnt-1)* t ).floor();
    segment = Math.max(segment, 0);
    segment = Math.min(segment, pointsCnt-2);

    t = t * (pointsCnt-1) - segment;

    if (segment == 0) {
      return _catmullRomSpline(points[0], points[0], points[1], points[2], t);
    }

    if (segment == pointsCnt-2) {
      return _catmullRomSpline(points[pointsCnt-3], points[pointsCnt-2], points[pointsCnt-1], points[pointsCnt-1], t);
    }

    return _catmullRomSpline(points[segment-1], points[segment], points[segment+1], points[segment+2], t);
  }

  num _catmullRomSpline(num a, num b, num c, num d, num t) {
    num t1 = (c - a) * 0.5;
    num t2 = (d - b) * 0.5;

    num h1 = 2 * t * t * t - 3 * t * t + 1;
    num h2 = -2 * t * t * t + 3 * t * t;
    num h3 = t * t * t - 2 * t * t + t;
    num h4 = t * t * t - t * t;

    return b * h1 + c * h2 + t1 * h3 + t2 * h4;
  }
}
