part of Phaser;

typedef double doubleFunc();

class SinCosTable {
  DoubleLinkedQueue<num> sin, cos;
  int length;
}

class Math {
  Math._() {
  }

  static const double SQRT1_2 = DMath.SQRT1_2;
  static const double SQRT2 = DMath.SQRT2;
  static const double PI = DMath.PI;
  static const double PI2 = DMath.PI * 2;
  static final doubleFunc random = new DMath.Random().nextDouble;
  static final double _degreeToRadiansFactor = DMath.PI / 180;
  static final double _radianToDegreesFactor = 180 / DMath.PI;

  static num pow(num th, num exp) => DMath.pow(th, exp);

  static num cos(num th) => DMath.cos(th);

  static num sin(num th) => DMath.sin(th);

  static num abs(num val) => val.abs();

  static num sqrt(num val) => DMath.sqrt(val);

  static num atan2(num a, num b) => DMath.atan2(a, b);

  static num round(num val) => val.round();

  static bool fuzzyEqual(num a, num b, [num epsilon = 0.0001]) {
    return (a - b).abs() < epsilon;
  }

  static bool fuzzyLessThan(num a, num b, [num epsilon = 0.0001]) {
    return a < b + epsilon;
  }

  static bool fuzzyGreaterThan(num a, num b, [num epsilon = 0.0001]) {
    return a > b - epsilon;
  }

  static int fuzzyCeil(num val, [num epsilon = 0.0001]) {
    return (val - epsilon).ceil();
  }

  static int fuzzyFloor(num val, [num epsilon = 0.0001]) {
    return (val + epsilon).floor();
  }

  static double average(List<num> args) {
    num sum = args.fold(0, (a, b) => a + b);
    return sum / args.length;
  }

  static int truncate(num n) {
    return (n > 0) ? n.floor() : n.ceil();
  }

  static int shear(int n) {
    return n % 1;
  }

  static int snapTo(num input, num gap, [num start = 0]) {

    if (gap == 0) {
      return input;
    }

    input -= start;
    input = gap * (input / gap).round();

    return start + input;

  }

  static int snapToFloor(num input, num gap, [num start = 0]) {

    if (gap == 0) {
      return input;
    }

    input -= start;
    input = gap * (input / gap).floor();

    return start + input;

  }

  static int snapToCeil(num input, num gap, [num start = 0]) {

    if (gap == 0) {
      return input;
    }

    input -= start;
    input = gap * (input / gap).ceil();

    return start + input;

  }

  static num snapToInArray(num input, List<num> arr, [sort = true]) {

    if (sort) {
      arr.sort();
    }

    if (input < arr[0]) {
      return arr[0];
    }

    var i = 1;

    while (arr[i] < input) {
      i++;
    }

    num low = arr[i - 1];
    num high = (i < arr.length) ? arr[i] : double.INFINITY;

    return ((high - input) <= (input - low)) ? high : low;
  }

  static int roundTo(num value, [int place = 0, int base = 10]) {
    var p = DMath.pow(base, -place);
    return ((value * p) / p).round();
  }

  static int floorTo(num value, [int place = 0, int base = 10]) {
    var p = DMath.pow(base, -place);
    return ((value * p) / p).floor();
  }

  static int ceilTo(num value, [int place = 0, int base = 10]) {
    var p = DMath.pow(base, -place);
    return ((value * p) / p).floor();
  }

  static num interpolateFloat(num a, num b, num weight) {
    return (b - a) * weight + a;
  }

  static num angleBetween(num x1, num y1, num x2, num y2) {
    return DMath.atan2(y2 - y1, x2 - x1);
  }

  /**
      * Find the angle of a segment from (x1, y1) -> (x2, y2).
      * Note that the difference between this method and Math.angleBetween is that this assumes the y coordinate travels
      * down the screen.
      * 
      * @method Phaser.Math#angleBetweenY
      * @param {number} x1
      * @param {number} y1
      * @param {number} x2
      * @param {number} y2
      * @return {number}
      */
  static num angleBetweenY(num x1, num y1, num x2, num y2) {
    return Math.atan2(x2 - x1, y2 - y1);
  }

  static num angleBetweenPoints(Point point1, Point point2) {
    return DMath.atan2(point2.y - point1.y, point2.x - point1.x);
  }

  /**
      * Find the angle of a segment from (point1.x, point1.y) -> (point2.x, point2.y).
      * @method Phaser.Math#angleBetweenPointsY
      * @param {Phaser.Point} point1
      * @param {Phaser.Point} point2
      * @return {number}
      */
  static num angleBetweenPointsY(Point point1, Point point2) {
    return Math.atan2(point2.x - point1.x, point2.y - point1.y);
  }

  static num reverseAngle(num angleRad) {
    return normalizeAngle(angleRad + DMath.PI);
  }

  static num normalizeAngle(num angleRad) {
    angleRad = angleRad % (2 * DMath.PI);
    return angleRad >= 0 ? angleRad : angleRad + 2 * DMath.PI;
  }

  static num normalizeLatitude(num lat) {
    return DMath.max(-90, DMath.min(90, lat));
  }

  static num normalizeLongitude(num lng) {
    if (lng % 360 == 180) {
      return 180;
    }
    lng = lng % 360;
    return lng < -180 ? lng + 360 : lng > 180 ? lng - 360 : lng;
  }


  static bool chanceRoll([num chance = 50]) {
    if (chance <= 0) {
      return false;
    } else if (chance >= 100) {
      return true;
    } else {
      if (random() * 100 >= chance) {
        return false;
      } else {
        return true;
      }
    }
  }

  static List<int> numberArray(int min, int max) {

    List<int> result = [];

    for (int i = min; i <= max; i++) {
      result.add(i);
    }

    return result;

  }

  /**
       * Creates an array of numbers (positive and/or negative) progressing from
       * `start` up to but not including `end`. If `start` is less than `stop` a
       * zero-length range is created unless a negative `step` is specified.
       *
       * @static
       * @method Phaser.Math#numberArrayStep
       * @param {number} [start=0] - The start of the range.
       * @param {number} end - The end of the range.
       * @param {number} [step=1] - The value to increment or decrement by.
       * @returns {Array} Returns the new array of numbers.
       * @example
       *
       * Phaser.Math.numberArrayStep(4);
       * // => [0, 1, 2, 3]
       *
       * Phaser.Math.numberArrayStep(1, 5);
       * // => [1, 2, 3, 4]
       *
       * Phaser.Math.numberArrayStep(0, 20, 5);
       * // => [0, 5, 10, 15]
       *
       * Phaser.Math.numberArrayStep(0, -4, -1);
       * // => [0, -1, -2, -3]
       *
       * Phaser.Math.numberArrayStep(1, 4, 0);
       * // => [1, 1, 1]
       *
       * Phaser.Math.numberArrayStep(0);
       * // => []
       */
  List numberArrayStep([num start = 0, num end, num step = 1]) {

    //start = +start || 0;

    // enables use as a callback for functions like `_.map`
    //var type = typeof end;

//          if ((end is num || end == String) && step && step[end] == start)
//          {
//              end = step = null;
//          }

    //step = step == null ? 1 : (step || 0);

    if (end == null) {
      end = start;
      start = 0;
    }

    // use `Array(length)` so engines like Chakra and V8 avoid slower modes
    // http://youtu.be/XAqIpGU8ZZk#t=17m25s
    var index = -1;
    var length = Math.max(Math.ceil((end - start) / step), 0);
    var result = new List(length);

    while (++index < length) {
      result[index] = start;
      start += step;
    }

    return result;

  }

  static num maxAdd(num value, num amount, num max) {
    value += amount;
    if (value > max) {
      value = max;
    }
    return value;
  }

  static num minSub(num value, num amount, num min) {
    value -= amount;
    if (value < min) {
      value = min;
    }
    return value;
  }

  static num wrap(num value, num min, num max) {

    num range = max - min;

    if (range <= 0) {
      return 0;
    }

    num result = (value - min) % range;

    if (result < 0) {
      result += range;
    }

    return result + min;

  }

  static num wrapValue(num value, num amount, num max) {

    num diff;
    value = value.abs();
    amount = amount.abs();
    max = max.abs();
    diff = (value + amount) % max;

    return diff;

  }

  static num limitValue(num value, num min, num max) {
    return (value < min) ? min : ((value > max) ? max : value);
  }

  static int randomSign() {
    return (Math.random() > 0.5) ? 1 : -1;
  }

  static bool isOdd(int n) {
    return (n % 2) == 1;
  }

  static bool isEven(int n) {
    return (n % 2) == 0;
  }

  static num min(num a, num b) {
    return DMath.min(a, b);
  }

  static num max(num a, num b) {
    return DMath.max(a, b);
  }

  static num minList(Iterable<num> args) {
    return args.fold(double.MAX_FINITE, (i, n) => i < n ? i : n);
  }

  static num maxList(Iterable<num> args) {
    return args.fold(-double.MAX_FINITE, (i, n) => i > n ? i : n);
  }

  static num minProperty(Iterable args, prop(e)) {
    return args.map(prop).fold(double.MAX_FINITE, (i, n) => i < n ? i : n);
  }

  static num maxProperty(Iterable args, prop(e)) {
    return args.map(prop).fold(-double.MAX_FINITE, (i, n) => i > n ? i : n);
  }


  static num wrapAngle(num angle, [bool radians = false]) {
    num radianFactor = (radians) ? DMath.PI / 180 : 1;
    return wrap(angle, -180 * radianFactor, 180 * radianFactor);
  }

  static num angleLimit(num angle, num min, num max) {
    num result = angle;
    if (angle > max) {
      result = max;
    } else if (angle < min) {
      result = min;
    }
    return result;
  }

  static num linearInterpolation(List<num> v, num k) {
    num m = v.length - 1;
    num f = m * k;
    num i = f.floor();
    if (k < 0) {
      return linear(v[0], v[1], f);
    }
    if (k > 1) {
      return linear(v[m], v[m - 1], m - f);
    }
    return linear(v[i], v[i + 1 > m ? m : i + 1], f - i);
  }

  static num bezierInterpolation(List<num> v, num k) {
    num b = 0;
    num n = v.length - 1;

    for (int i = 0; i <= n; i++) {
      b += DMath.pow(1 - k, n - i) * DMath.pow(k, i) * v[i] * bernstein(n, i);
    }
    return b;
  }

  static num catmullRomInterpolation(List<num> v, num k) {

    var m = v.length - 1;
    var f = m * k;
    var i = f.floor();

    if (v[0] == v[m]) {
      if (k < 0) {
        i = (f = m * (1 + k)).floor();
      }

      return catmullRom(v[(i - 1 + m) % m], v[i], v[(i + 1) % m], v[(i + 2) % m], f - i);

    } else {
      if (k < 0) {
        return v[0] - (catmullRom(v[0], v[0], v[1], v[1], -f) - v[0]);
      }

      if (k > 1) {
        return v[m] - (catmullRom(v[m], v[m], v[m - 1], v[m - 1], f - m) - v[m]);
      }

      return catmullRom(v[i ? i - 1 : 0], v[i], v[m < i + 1 ? m : i + 1], v[m < i + 2 ? m : i + 2], f - i);
    }

  }

  static num linear(num p0, num p1, num t) {
    return (p1 - p0) * t + p0;
  }


  static num bernstein(num n, num i) {
    return factorial(n) / factorial(i) / factorial(n - i);
  }

  static num factorial(num value) {
    if (value == 0) {
      return 1;
    }
    num res = value;
    while (--value >= 0) {
      res *= value;
    }
    return res;
  }

  static num catmullRom(num p0, num p1, num p2, num p3, num t) {

    num v0 = (p2 - p0) * 0.5,
        v1 = (p3 - p1) * 0.5,
        t2 = t * t,
        t3 = t * t2;

    return (2 * p1 - 2 * p2 + v0 + v1) * t3 + (-3 * p1 + 3 * p2 - 2 * v0 - v1) * t2 + v0 * t + p1;

  }

  static num difference(num a, num b) {
    return (a - b).abs();
  }

  static Object getRandom(List objects, [int startIndex = 0, int length = 0]) {
    if (objects != null) {
      int l = length;
      if ((l == 0) || (l > objects.length - startIndex)) {
        l = objects.length - startIndex;
      }
      if (l > 0) {
        return objects[startIndex + (Math.random() * l).floor()];
      }
    }
    return null;
  }

  static Object removeRandom(List objects, [int startIndex = 0, int length = 0]) {
    if (objects != null) {
      var l = length;
      if ((l == 0) || (l > objects.length - startIndex)) {
        l = objects.length - startIndex;
      }
      if (l > 0) {
        int idx = (startIndex + Math.random() * l).toInt();
        List<GameObject> removed = objects.removeAt(idx);
        return removed[0];
      }
    }
    return null;
  }

  static int floor(num value) {
    //int n = value.floor();
    //return (value > 0) ? (n) : ((n != value) ? (n - 1) : (n));
    return value.floor();
  }

  static int ceil(num value) {
    return value.ceil();
  }

  static sinCosGenerator(int length, [num sinAmplitude = 1.0, num cosAmplitude = 1.0, num frequency = 1.0]) {

    num sin = sinAmplitude;
    num cos = cosAmplitude;
    num frq = frequency * DMath.PI / length;

    DoubleLinkedQueue<num> cosTable = new DoubleLinkedQueue<num>();
    DoubleLinkedQueue<num> sinTable = new DoubleLinkedQueue<num>();

    for (int c = 0; c < length; c++) {
      cos -= sin * frq;
      sin += cos * frq;
      cosTable.add(cos);
      sinTable.add(sin);
    }

    return new SinCosTable()
        ..sin = sinTable
        ..cos = cosTable
        ..length = length;
  }

  static Object shift(DoubleLinkedQueue stack) {
    Object s = stack.removeFirst();
    stack.add(s);
    return s;
  }

  static List shuffleArray(List array) {
    return new List.from(array)..shuffle();
  }

  static num distance(num x1, num y1, num x2, num y2) {
    num dx = x1 - x2;
    num dy = y1 - y2;
    return DMath.sqrt(dx * dx + dy * dy);
  }

  static num distancePow(num x1, num y1, num x2, num y2, [num power = 2]) {
    return DMath.sqrt(DMath.pow(x2 - x1, power) + DMath.pow(y2 - y1, power));
  }

  static num distanceRounded(num x1, num y1, num x2, num y2) {
    return (distance(x1, y1, x2, y2)).round();
  }

  static num clamp(num x, num a, num b) {
    return (x < a) ? a : ((x > b) ? b : x);
  }

  static num clampBottom(num x, num a) {
    return x < a ? a : x;
  }

  static bool within(num a, num b, num tolerance) {
    return ((a - b).abs() <= tolerance);
  }

  static num mapLinear(num x, num a1, num a2, num b1, num b2) {
    return b1 + (x - a1) * (b2 - b1) / (a2 - a1);
  }

  static num smoothstep(num x, num min, num max) {
    x = DMath.max(0, DMath.min(1, (x - min) / (max - min)));
    return x * x * (3 - 2 * x);
  }

  static num smootherstep(num x, num min, num max) {
    x = DMath.max(0, DMath.min(1, (x - min) / (max - min)));
    return x * x * x * (x * (x * 6 - 15) + 10);
  }

  static num sign(num x) {
    return x.sign;
  }

  static num percent(num a, num b, [num base = 0]) {

    if (a > b || base > b) {
      return 1;
    } else if (a < base || base > a) {
      return 0;
    } else {
      return (a - base) / b;
    }
  }

  static num degToRad(num degrees) {
    return degrees * _degreeToRadiansFactor;
  }

  static num radToDeg(num radians) {
    return radians * _radianToDegreesFactor;
  }

}
