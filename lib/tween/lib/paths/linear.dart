part of tweenengine;

/**
 * @author Aurelien Ribon | http://www.aurelienribon.com/
 */
class LinearPath extends TweenPath {
  
  LinearPath(){
    this.compute = _compute;
  }

  num _compute(num t, List<num> points, int pointsCnt) {
    int segment = ((pointsCnt-1) * t).floor();
    segment = Math.max(segment, 0);
    segment = Math.min(segment, pointsCnt-2);

    t = t * (pointsCnt-1) - segment;

    return points[segment] + t * (points[segment+1] - points[segment]);
  }
}