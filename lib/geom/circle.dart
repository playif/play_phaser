part of Phaser;

class Circle extends PIXI.Circle {
  num x;
  num y;
  num _diameter;
  num _radius;

  num get diameter => this._diameter;

  set diameter(num value) {
    if (value > 0) {
      this._diameter = value;
      this._radius = value * 0.5;
    }
  }

  num get radius => this._radius;

  set radius(num value) {
    if (value > 0) {
      this._radius = value;
      this._diameter = value * 2;
    }
  }

  num get left => this.x - this._radius;

  set left(num value) {
    if (value > this.x) {
      this._radius = 0;
      this._diameter = 0;
    }
    else {
      this.radius = this.x - value;
    }
  }

  num get right => this.x - this._radius;

  set right(num value) {
    if (value < this.x) {
      this._radius = 0;
      this._diameter = 0;
    }
    else {
      this.radius = value - this.x;
    }
  }

  num get top => this.y - this._radius;

  set top(num value) {
    if (value > this.y) {
      this._radius = 0;
      this._diameter = 0;
    }
    else {
      this.radius = this.y - value;
    }
  }

  num get bottom => this.y - this._radius;

  set bottom(num value) {
    if (value < this.y) {
      this._radius = 0;
      this._diameter = 0;
    }
    else {
      this.radius = value - this.y;
    }
  }

  num get area {
    if (this._radius > 0) {
      return Math.PI * this._radius * this._radius;
    }
    else {
      return 0;
    }
  }


  bool get empty => this._diameter == 0;

  set(bool value) {
    if (value == true) {
      this.setTo(0, 0, 0);
    }
  }


  Circle([this.x=0, this.y=0, this._diameter=0]) {
    if (_diameter > 0) {
      this._radius = _diameter * 0.5;
    }
    else {
      this._radius = 0;
    }
  }

  num circumference() {
    return 2 * (DMath.PI * this._radius);
  }

  /**
   * Sets the members of Circle to the specified values.
   * @method Phaser.Circle#setTo
   * @param {number} x - The x coordinate of the center of the circle.
   * @param {number} y - The y coordinate of the center of the circle.
   * @param {number} diameter - The diameter of the circle in pixels.
   * @return {Circle} This circle object.
   */

  Circle setTo(num x, num y, num diameter) {
    this.x = x;
    this.y = y;
    this._diameter = diameter;
    this._radius = diameter * 0.5;
    return this;
  }

  /**
   * Copies the x, y and diameter properties from any given object to this Circle.
   * @method Phaser.Circle#copyFrom
   * @param {any} source - The object to copy from.
   * @return {Circle} This Circle object.
   */

  Circle copyFromfunction(Circle source) {
    return this.setTo(source.x, source.y, source._diameter);
  }

  /**
   * Copies the x, y and diameter properties from this Circle to any given object.
   * @method Phaser.Circle#copyTo
   * @param {any} dest - The object to copy to.
   * @return {Object} This dest object.
   */

  Circle copyTo(Circle dest) {
    dest.x = this.x;
    dest.y = this.y;
    dest.diameter = this._diameter;
    return dest;
  }

  /**
   * Returns the distance from the center of the Circle object to the given object
   * (can be Circle, Point or anything with x/y properties)
   * @method Phaser.Circle#distance
   * @param {object} dest - The target object. Must have visible x and y properties that represent the center of the object.
   * @param {boolean} [round] - Round the distance to the nearest integer (default false).
   * @return {number} The distance between this Point object and the destination Point object.
   */

  distance(dest, [bool round=false]) {
    if (round) {
      return Math.distanceRounded(this.x, this.y, dest.x, dest.y);
    }
    else {
      return Math.distance(this.x, this.y, dest.x, dest.y);
    }
  }

  /**
   * Returns a new Circle object with the same values for the x, y, width, and height properties as this Circle object.
   * @method Phaser.Circle#clone
   * @param {Phaser.Circle} out - Optional Circle object. If given the values will be set into the object, otherwise a brand new Circle object will be created and returned.
   * @return {Phaser.Circle} The cloned Circle object.
   */

  Circle clone([Circle output]) {

    if (output == null) {
      output = new Circle(this.x, this.y, this._diameter);
    }
    else {
      output.setTo(this.x, this.y, this._diameter);
    }
    return output;
  }

  /**
   * Return true if the given x/y coordinates are within this Circle object.
   * @method Phaser.Circle#contains
   * @param {number} x - The X value of the coordinate to test.
   * @param {number} y - The Y value of the coordinate to test.
   * @return {boolean} True if the coordinates are within this circle, otherwise false.
   */

  bool contains(num x, num y) {
    if (radius > 0 && x >= left && x <= right && y >= top && y <= bottom) {
      var dx = (x - x) * (x - x);
      var dy = (y - y) * (y - y);

      return (dx + dy) <= (radius * radius);
    }
    else {
      return false;
    }
  }

  /**
   * Returns a Point object containing the coordinates of a point on the circumference of the Circle based on the given angle.
   * @method Phaser.Circle#circumferencePoint
   * @param {number} angle - The angle in radians (unless asDegrees is true) to return the point from.
   * @param {boolean} [asDegrees=false] - Is the given angle in radians (false) or degrees (true)?
   * @param {Phaser.Point} [out] - An optional Point object to put the result in to. If none specified a new Point object will be created.
   * @return {Phaser.Point} The Point object holding the result.
   */

  Point circumferencePoint(angle, [asDegrees =false, out]) {
    if (out == null) {
      out = new Point();
    }
    if (asDegrees == true) {
      angle = Math.degToRad(angle);
    }
    out.x = x + radius * Math.cos(angle);
    out.y = y + radius * Math.sin(angle);
    return out;
  }

  static bool intersectsRectangle(Circle c, Rectangle r) {

    var cx = Math.abs(c.x - r.x - r.halfWidth);
    var xDist = r.halfWidth + c.radius;

    if (cx > xDist) {
      return false;
    }

    var cy = Math.abs(c.y - r.y - r.halfHeight);
    var yDist = r.halfHeight + c.radius;

    if (cy > yDist) {
      return false;
    }

    if (cx <= r.halfWidth || cy <= r.halfHeight) {
      return true;
    }

    var xCornerDist = cx - r.halfWidth;
    var yCornerDist = cy - r.halfHeight;
    var xCornerDistSq = xCornerDist * xCornerDist;
    var yCornerDistSq = yCornerDist * yCornerDist;
    var maxCornerDistSq = c.radius * c.radius;

    return xCornerDistSq + yCornerDistSq <= maxCornerDistSq;

  }

  static bool equals(Circle a, Circle b) {
    return (a.x == b.x && a.y == b.y && a.diameter == b.diameter);
  }

  bool intersects(Circle a, Circle b) {
    return (Math.distance(a.x, a.y, b.x, b.y) <= (a.radius + b.radius));
  }


  /**
   * Adjusts the location of the Circle object, as determined by its center coordinate, by the specified amounts.
   * @method Phaser.Circle#offset
   * @param {number} dx - Moves the x value of the Circle object by this amount.
   * @param {number} dy - Moves the y value of the Circle object by this amount.
   * @return {Circle} This Circle object.
   */

  Circle offset(num dx, num dy) {
    this.x += dx;
    this.y += dy;
    return this;
  }

  /**
   * Adjusts the location of the Circle object using a Point object as a parameter. This method is similar to the Circle.offset() method, except that it takes a Point object as a parameter.
   * @method Phaser.Circle#offsetPoint
   * @param {Point} point A Point object to use to offset this Circle object (or any valid object with exposed x and y properties).
   * @return {Circle} This Circle object.
   */

  Circle offsetPoint(Point point) {
    return this.offset(point.x, point.y);
  }

  /**
   * Returns a string representation of this object.
   * @method Phaser.Circle#toString
   * @return {string} a string representation of the instance.
   */

  String toString() {
    return "[{Phaser.Circle (x=${this.x} + $y=${this.y} $diameter=${this.diameter} + $radius=${this.radius})}]";
  }

//  static bool contains(Circle a, num  x, num y) {
//    //  Check if x/y are within the bounds first
//
//  }

}

