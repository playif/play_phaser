part of Phaser;

class Point extends PIXI.Point {
//  num x;
//  num y;

//  num getTweenableValue(String tweenType) {
//      dynamic me=this as dynamic;
//      switch (tweenType) {
//        case 'x':
//          return me.x;
//
//      }
//      return null;
//    }
//
//    void setTweenableValue(String tweenType, num newValue) {
//      dynamic me=this as dynamic;
//      switch (tweenType) {
//        case 'x':
//          me.x = newValue;
//          break;
//      }
//    }


  Point([num x = 0, num y = 0])
      : super(x, y) {

  }

  Point copyFrom(source) {
    return this.setTo(source.x, source.y);
  }

  /**
   * Inverts the x and y values of this Point
   *
   * @method Phaser.Point#invert
   * @return {Phaser.Point} This Point object.
   */

  Point invert() {
    return this.setTo(this.y, this.x);
  }

  /**
   * Sets the `x` and `y` values of this Point object to the given values.
   * If you omit the `y` value then the `x` value will be applied to both, for example:
   * `Point.setTo(2)` is the same as `Point.setTo(2, 2)`
   *
   * @method Phaser.Point#setTo
   * @param {number} x - The horizontal value of this point.
   * @param {number} [y] - The vertical value of this point. If not given the x value will be used in its place.
   * @return {Phaser.Point} This Point object. Useful for chaining method calls.
   */

  Point setTo([num x = 0, num y]) {
    this.x = x;
    this.y = y == null ? this.x : y;
    return this;
  }

  /**
   * Sets the `x` and `y` values of this Point object to the given values.
   * If you omit the `y` value then the `x` value will be applied to both, for example:
   * `Point.setTo(2)` is the same as `Point.setTo(2, 2)`
   *
   * @method Phaser.Point#set
   * @param {number} x - The horizontal value of this point.
   * @param {number} [y] - The vertical value of this point. If not given the x value will be used in its place.
   * @return {Phaser.Point} This Point object. Useful for chaining method calls.
   */

  Point set([num x = 0, num y]) {
    this.x = x;
    this.y = y == null ? this.x : y;
    return this;
  }

  /**
   * Adds the given x and y values to this Point.
   *
   * @method Phaser.Point#add
   * @param {number} x - The value to add to Point.x.
   * @param {number} y - The value to add to Point.y.
   * @return {Phaser.Point} This Point object. Useful for chaining method calls.
   */

  Point add(num x, num y) {
    this.x += x;
    this.y += y;
    return this;
  }

  /**
   * Subtracts the given x and y values from this Point.
   *
   * @method Phaser.Point#subtract
   * @param {number} x - The value to subtract from Point.x.
   * @param {number} y - The value to subtract from Point.y.
   * @return {Phaser.Point} This Point object. Useful for chaining method calls.
   */

  Point subtract(num x, num y) {
    this.x -= x;
    this.y -= y;
    return this;
  }

  /**
   * Multiplies Point.x and Point.y by the given x and y values. Sometimes known as `Scale`.
   *
   * @method Phaser.Point#multiply
   * @param {number} x - The value to multiply Point.x by.
   * @param {number} y - The value to multiply Point.x by.
   * @return {Phaser.Point} This Point object. Useful for chaining method calls.
   */

  Point multiply(num x, num y) {
    this.x *= x;
    this.y *= y;
    return this;
  }

  /**
   * Divides Point.x and Point.y by the given x and y values.
   *
   * @method Phaser.Point#divide
   * @param {number} x - The value to divide Point.x by.
   * @param {number} y - The value to divide Point.x by.
   * @return {Phaser.Point} This Point object. Useful for chaining method calls.
   */

  Point divide(num x, num y) {
    this.x /= x;
    this.y /= y;
    return this;
  }

  /**
   * Clamps the x value of this Point to be between the given min and max.
   *
   * @method Phaser.Point#clampX
   * @param {number} min - The minimum value to clamp this Point to.
   * @param {number} max - The maximum value to clamp this Point to.
   * @return {Phaser.Point} This Point object.
   */

  Point clampX(num min, num max) {
    this.x = Math.clamp(this.x, min, max);
    return this;
  }

  /**
   * Clamps the y value of this Point to be between the given min and max
   *
   * @method Phaser.Point#clampY
   * @param {number} min - The minimum value to clamp this Point to.
   * @param {number} max - The maximum value to clamp this Point to.
   * @return {Phaser.Point} This Point object.
   */

  Point clampY(num min, num max) {
    this.y = Math.clamp(this.y, min, max);
    return this;
  }

  /**
   * Clamps this Point object values to be between the given min and max.
   *
   * @method Phaser.Point#clamp
   * @param {number} min - The minimum value to clamp this Point to.
   * @param {number} max - The maximum value to clamp this Point to.
   * @return {Phaser.Point} This Point object.
   */

  Point clamp(num min, num max) {
    this.x = Math.clamp(this.x, min, max);
    this.y = Math.clamp(this.y, min, max);
    return this;
  }

  /**
   * Creates a copy of the given Point.
   *
   * @method Phaser.Point#clone
   * @param {Phaser.Point} [output] Optional Point object. If given the values will be set into this object, otherwise a brand new Point object will be created and returned.
   * @return {Phaser.Point} The new Point object.
   */

  Point clone([Point output]) {

    if (output == null) {
      output = new Point(this.x, this.y);
    } else {
      output.setTo(this.x, this.y);
    }
    return output;
  }

  /**
   * Copies the x and y properties from this Point to any given object.
   *
   * @method Phaser.Point#copyTo
   * @param {any} dest - The object to copy to.
   * @return {Object} The dest object.
   */

  copyTo(dest) {
    dest.x = this.x;
    dest.y = this.y;
    return dest;
  }

  /**
   * Returns the distance of this Point object to the given object (can be a Circle, Point or anything with x/y properties)
   *
   * @method Phaser.Point#distance
   * @param {object} dest - The target object. Must have visible x and y properties that represent the center of the object.
   * @param {boolean} [round] - Round the distance to the nearest integer (default false).
   * @return {number} The distance between this Point object and the destination Point object.
   */

  num distance(Point b, [bool round = false]) {
    if (round) {
      return Math.distanceRounded(x, y, b.x, b.y);
    } else {
      return Math.distance(x, y, b.x, b.y);
    }
  }

  /**
   * Determines whether the given objects x/y values are equal to this Point object.
   *
   * @method Phaser.Point#equals
   * @param {Phaser.Point|any} a - The object to compare with this Point.
   * @return {boolean} A value of true if the x and y points are equal, otherwise false.
   */

  bool equals(Point a) {

    return (a.x == this.x && a.y == this.y);

  }

  /**
   * Returns the angle between this Point object and another object with public x and y properties.
   *
   * @method Phaser.Point#angle
   * @param {Phaser.Point|any} a - The object to get the angle from this Point to.
   * @param {boolean} [asDegrees=false] - Is the given angle in radians (false) or degrees (true)?
   * @return {number} The angle between the two objects.
   */

  num angle(Point a, [asDegrees = false]) {
    if (asDegrees) {
      return Math.radToDeg(Math.atan2(a.y - this.y, a.x - this.x));
    } else {
      return Math.atan2(a.y - this.y, a.x - this.x);
    }
  }

  /**
   * Returns the angle squared between this Point object and another object with public x and y properties.
   *
   * @method Phaser.Point#angleSq
   * @param {Phaser.Point|any} a - The object to get the angleSq from this Point to.
   * @return {number} The angleSq between the two objects.
   */

  num angleSq(Point a) {
    return (this - a).angle(a - this);
  }

  /**
   * Rotates this Point around the x/y coordinates given to the desired angle.
   *
   * @method Phaser.Point#rotate
   * @param {number} x - The x coordinate of the anchor point.
   * @param {number} y - The y coordinate of the anchor point.
   * @param {number} angle - The angle in radians (unless asDegrees is true) to rotate the Point to.
   * @param {boolean} asDegrees - Is the given rotation in radians (false) or degrees (true)?
   * @param {number} [distance] - An optional distance constraint between the Point and the anchor.
   * @return {Phaser.Point} The modified point object.
   */

  Point rotate(num x, num y, num angle, [bool asDegrees = false, num distance]) {

    if (asDegrees) {
      angle = Math.degToRad(angle);
    }

    //  Get distance from origin (cx/cy) to this point
    if (distance == null) {
      distance = Math.distance(x, y, this.x, this.y);
      //.sqrt(((x - this.x) * (x - this.x)) + ((y - this.y) * (y - this.y)));
    }

    //return this.setTo(x + distance * Math.cos(angle), y + distance * Math.sin(angle));
    num requiredAngle = angle + Math.atan2(this.y - y, this.x - x);

    return this.setTo(x + distance * Math.cos(requiredAngle), y + distance * Math.sin(requiredAngle));
  }

  /**
   * Calculates the length of the Point object.
   *
   * @method Phaser.Point#getMagnitude
   * @return {number} The length of the Point.
   */

  num getMagnitude() {
    return Math.sqrt((this.x * this.x) + (this.y * this.y));
  }

  /**
   * Calculates the length squared of the Point object.
   *
   * @method Phaser.Point#getMagnitudeSq
   * @return {number} The length ^ 2 of the Point.
   */

  num getMagnitudeSq() {

    return (this.x * this.x) + (this.y * this.y);

  }

  /**
   * Alters the length of the Point without changing the direction.
   *
   * @method Phaser.Point#setMagnitude
   * @param {number} magnitude - The desired magnitude of the resulting Point.
   * @return {Phaser.Point} This Point object.
   */

  Point setMagnitude(num magnitude) {

    return this.normalize().multiply(magnitude, magnitude);

  }

  /**
   * Alters the Point object so that its length is 1, but it retains the same direction.
   *
   * @method Phaser.Point#normalize
   * @return {Phaser.Point} This Point object.
   */

  Point normalize() {

    if (!this.isZero()) {
      var m = this.getMagnitude();
      this.x /= m;
      this.y /= m;
    }

    return this;

  }

  /**
   * Determine if this point is at 0,0.
   *
   * @method Phaser.Point#isZero
   * @return {boolean} True if this Point is 0,0, otherwise false.
   */

  bool isZero() {

    return (this.x == 0 && this.y == 0);

  }

  /**
   * The dot product of this and another Point object.
   *
   * @method Phaser.Point#dot
   * @param {Phaser.Point} a - The Point object to get the dot product combined with this Point.
   * @return {number} The result.
   */

  num dot(Point a) {
    return ((this.x * a.x) + (this.y * a.y));
  }

  /**
   * The cross product of this and another Point object.
   *
   * @method Phaser.Point#cross
   * @param {Phaser.Point} a - The Point object to get the cross product combined with this Point.
   * @return {number} The result.
   */

  num cross(Point a) {
    return ((this.x * a.y) - (this.y * a.x));
  }

  /**
   * Make this Point perpendicular (90 degrees rotation)
   *
   * @method Phaser.Point#perp
   * @return {Phaser.Point} This Point object.
   */

  Point perp() {

    return this.setTo(-this.y, this.x);

  }

  /**
   * Make this Point perpendicular (-90 degrees rotation)
   *
   * @method Phaser.Point#rperp
   * @return {Phaser.Point} This Point object.
   */

  Point rperp() {

    return this.setTo(this.y, -this.x);

  }

  /**
   * Right-hand normalize (make unit length) this Point.
   *
   * @method Phaser.Point#normalRightHand
   * @return {Phaser.Point} This Point object.
   */

  Point normalRightHand() {

    return this.setTo(this.y * -1, this.x);

  }

  /**
   * Returns a string representation of this object.
   *
   * @method Phaser.Point#toString
   * @return {string} A string representation of the instance.
   */

  String toString() {

    return '[{Point (x=${this.x} y=${this.y})}]';

  }

  Point operator +(b) {
    Point out = new Point();
    if (b is Point) {
      out.x = x + b.x;
      out.y = y + b.y;
    } else {
      out.x = x + b;
      out.y = y + b;
    }
    return out;
  }

  Point operator -(b) {
    Point out = new Point();
    if (b is Point) {
      out.x = x - b.x;
      out.y = y - b.y;
    } else {
      out.x = x - b;
      out.y = y - b;
    }
    return out;
  }

  Point operator *(b) {
    Point out = new Point();
    if (b is Point) {
      out.x = x * b.x;
      out.y = y * b.y;
    } else {
      out.x = x * b;
      out.y = y * b;
    }
    return out;
  }

  Point operator /(b) {
    Point out = new Point();
    if (b is Point) {
      out.x = x / b.x;
      out.y = y / b.y;
    } else {
      out.x = x / b;
      out.y = y / b;
    }
    return out;
  }

  bool operator ==(Point b) {
    return (x == b.x && y == b.y);
  }

  int get hashCode {
    int result = 17;
    result = 37 * result + x.hashCode;
    result = 37 * result + y.hashCode;
    return result;
  }

  Point multiplyAdd(Point a, Point b, num s, [Point out]) {
    if (out == null) {
      out = new Point();
    }
    return out.setTo(a.x + b.x * s, a.y + b.y * s);
  }

  static Point interpolate(Point a, Point b, num f, [Point out]) {
    if (out == null) {
      out = new Point();
    }
    return out.setTo(a.x + (b.x - a.x) * f, a.y + (b.y - a.y) * f);
  }

//  static Point rperp (Point a, [Point out]) {
//    if (out == null) {
//      out = new Point();
//    }
//    return out.setTo(a.y, -a.x);
//
//  }

  static Point project(Point a, Point b, [Point out]) {
    if (out == null) {
      out = new Point();
    }
    num amt = a.dot(b) / b.getMagnitudeSq();
    if (amt != 0) {
      out.setTo(amt * b.x, amt * b.y);
    }
    return out;
  }

  static Point projectUnit(Point a, Point b, [Point out]) {
    if (out == null) {
      out = new Point();
    }
    num amt = a.dot(b);
    if (amt != 0) {
      out.setTo(amt * b.x, amt * b.y);
    }
    return out;
  }

//  static Point normalRightHand(Point a, [Point out]) {
//    if (out == null) {
//      out = new Point();
//    }
//    return out.setTo(a.y * -1, a.x);
//  }

  static Point centroid(List<Point> points, [Point out]) {
    if (out == null) {
      out = new Point();
    }
    if (!(points is List<Point>)) {
      throw new Exception("Phaser.Point. Parameter 'points' must be an array");
    }

    int pointslength = points.length;

    if (pointslength < 1) {
      throw new Exception("Phaser.Point. Parameter 'points' array must not be empty");
    }

    if (pointslength == 1) {
      out.copyFrom(points[0]);
      return out;
    }

    for (int i = 0; i < pointslength; i++) {
      out.add(points[i].x, points[i].y);
    }

    out.divide(pointslength, pointslength);

    return out;

  }

  /**
   * Parses an object for x and/or y properties and returns a new Phaser.Point with matching values.
   * If the object doesn't contain those properties a Point with x/y of zero will be returned.
   *
   * @method Phaser.Point.parse
   * @static
   * @param {Object} obj - The object to parse.
   * @param {string} [xProp='x'] - The property used to set the Point.x value.
   * @param {string} [yProp='y'] - The property used to set the Point.y value.
   * @return {Phaser.Point} The new Point object.
   */
  Point parse(obj, [String xProp='x', String yProp='y']) {

    //xProp = xProp || 'x';
    //yProp = yProp || 'y';

    Point point = new Point();

    if (obj[xProp])
    {
      point.x = int.parse(obj[xProp]);
    }

    if (obj[yProp])
    {
      point.y = int.parse(obj[yProp]);
    }

    return point;

  }
}
