part of Phaser;

class Rectangle extends PIXI.Rectangle {
  num x;
  num y;
  num width;
  num height;

  num get halfWidth => Math.round(this.width / 2);

  num get halfHeight => Math.round(this.height / 2);

  num get bottom {
    return this.y + this.height;
  }

  set bottom(num value) {
    if (value <= this.y) {
      this.height = 0;
    } else {
      this.height = (value - this.y);
    }
  }

  Point get bottomRight {
    return new Point(this.right, this.bottom);
  }

  set bottomRight(Point value) {
    this.right = value.x;
    this.bottom = value.y;
  }

  num get left {
    return this.x;
  }

  set left(num value) {
    if (value >= this.right) {
      this.width = 0;
    } else {
      this.width = this.right - value;
    }
    this.x = value;
  }

  num get right {
    return this.x + this.width;
  }

  set right(num value) {
    if (value <= this.x) {
      this.width = 0;
    } else {
      this.width = this.x + value;
    }
  }

  num get volume => this.width * this.height;

  num get perimeter => (this.width * 2) + (this.height * 2);

  num get centerX => this.x + this.halfWidth;

  set centerX(num value) {
    this.x = value - this.halfWidth;
  }

  num get centerY => this.y + this.halfHeight;

  set centerY(num value) {
    this.y = value - this.halfHeight;
  }

  num get top {
    return this.y;
  }

  set top(num value) {
    if (value >= this.bottom) {
      this.height = 0;
      this.y = value;
    } else {
      this.height = (this.bottom - value);
    }
  }

  Point get topLeft {
    return new Point(this.x, this.y);
  }

  set topLeft(Point value) {
    this.x = value.x;
    this.y = value.y;
  }


  bool get empty => (this.width == 0 || this.height == 0);

  set empty(bool value) {
    if (value == true) {
      this.setTo(0, 0, 0, 0);
    }
  }

  /**
   * The location of the Rectangles top right corner as a Point object.
   * @name Phaser.Rectangle#topRight
   * @property {Phaser.Point} topRight - The location of the Rectangles top left corner as a Point object.
   */
  //Object.defineProperty(Phaser.Rectangle.prototype, "topRight", {

  Point get topRight {
    return new Point(this.x + this.width, this.y);
  }

  set topRight(value) {
    this.right = value.x;
    this.y = value.y;
  }

  Point get bottomLeft {
    return new Point(this.x, this.y + this.height);
  }

  set bottomLeft(Point value) {
    this.x = value.x;
    this.bottom = value.y;
  }

  //});

  Rectangle([this.x = 0, this.y = 0, this.width = 0, this.height = 0]) {
  }

  /**
   * Adjusts the location of the Rectangle object, as determined by its top-left corner, by the specified amounts.
   * @method Phaser.Rectangle#offset
   * @param {number} dx - Moves the x value of the Rectangle object by this amount.
   * @param {number} dy - Moves the y value of the Rectangle object by this amount.
   * @return {Phaser.Rectangle} This Rectangle object.
   */

  Rectangle offsetRect(num dx, num dy) {
    this.x += dx;
    this.y += dy;
    return this;
  }


  /**
   * Adjusts the location of the Rectangle object using a Point object as a parameter. This method is similar to the Rectangle.offset() method, except that it takes a Point object as a parameter.
   * @method Phaser.Rectangle#offsetPoint
   * @param {Phaser.Point} point - A Point object to use to offset this Rectangle object.
   * @return {Phaser.Rectangle} This Rectangle object.
   */

  Rectangle offsetPoint(Point point) {
    return this.offsetRect(point.x, point.y);
  }

  /**
   * Sets the members of Rectangle to the specified values.
   * @method Phaser.Rectangle#setTo
   * @param {number} x - The x coordinate of the top-left corner of the Rectangle.
   * @param {number} y - The y coordinate of the top-left corner of the Rectangle.
   * @param {number} width - The width of the Rectangle in pixels.
   * @param {number} height - The height of the Rectangle in pixels.
   * @return {Phaser.Rectangle} This Rectangle object
   */

  Rectangle setTo(num x, num y, num width, num height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    return this;
  }

  /**
   * Runs Math.floor() on both the x and y values of this Rectangle.
   * @method Phaser.Rectangle#floor
   */

  floor() {
    this.x = Math.floor(this.x);
    this.y = Math.floor(this.y);
  }

  /**
   * Runs Math.floor() on the x, y, width and height values of this Rectangle.
   * @method Phaser.Rectangle#floorAll
   */

  floorAll() {
    this.x = Math.floor(this.x);
    this.y = Math.floor(this.y);
    this.width = Math.floor(this.width);
    this.height = Math.floor(this.height);
  }


  /**
   * Copies the x, y, width and height properties from any given object to this Rectangle.
   * @method Phaser.Rectangle#copyFrom
   * @param {any} source - The object to copy from.
   * @return {Phaser.Rectangle} This Rectangle object.
   */

  Rectangle copyFrom(source) {
    return this.setTo(source.x, source.y, source.width, source.height);
  }


  /**
   * Copies the x, y, width and height properties from this Rectangle to any given object.
   * @method Phaser.Rectangle#copyTo
   * @param {any} source - The object to copy to.
   * @return {object} This object.
   */

  copyTo(Rectangle dest) {
    dest.x = this.x;
    dest.y = this.y;
    dest.width = this.width;
    dest.height = this.height;
    return dest;
  }

  /**
   * Increases the size of the Rectangle object by the specified amounts. The center point of the Rectangle object stays the same, and its size increases to the left and right by the dx value, and to the top and the bottom by the dy value.
   * @method Phaser.Rectangle#inflate
   * @param {number} dx - The amount to be added to the left side of the Rectangle.
   * @param {number} dy - The amount to be added to the bottom side of the Rectangle.
   * @return {Phaser.Rectangle} This Rectangle object.
   */

  Rectangle inflate(num dx, num dy) {
    x -= dx;
    width += 2 * dx;
    y -= dy;
    height += 2 * dy;
    return this;
  }


  /**
   * The size of the Rectangle object, expressed as a Point object with the values of the width and height properties.
   * @method Phaser.Rectangle#size
   * @param {Phaser.Point} [output] - Optional Point object. If given the values will be set into the object, otherwise a brand new Point object will be created and returned.
   * @return {Phaser.Point} The size of the Rectangle object.
   */

  Point size([Point output]) {
    if (output == null) {
      output = new Point(width, height);
    } else {
      output.setTo(width, height);
    }
    return output;
  }

  /**
   * Returns a new Rectangle object with the same values for the x, y, width, and height properties as the original Rectangle object.
   * @method Phaser.Rectangle#clone
   * @param {Phaser.Rectangle} [output] - Optional Rectangle object. If given the values will be set into the object, otherwise a brand new Rectangle object will be created and returned.
   * @return {Phaser.Rectangle}
   */

  Rectangle clone([Rectangle output]) {
    if (output == null) {
      output = new Rectangle(x, y, width, height);
    } else {
      output.setTo(x, y, width, height);
    }
    return output;
  }


  /**
   * Determines whether the specified coordinates are contained within the region defined by this Rectangle object.
   * @method Phaser.Rectangle#contains
   * @param {number} x - The x coordinate of the point to test.
   * @param {number} y - The y coordinate of the point to test.
   * @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
   */

  bool contains(x, y) {
    //return super.contains(x, y);
    if (width <= 0 || height <= 0) {
      return false;
    }
    return (x >= this.x && x <= this.right && y >= this.y && y <= this.bottom);
  }

  /**
   * Centers this Rectangle so that the center coordinates match the given x and y values.
   *
   * @method Phaser.Rectangle#centerOn
   * @param {number} x - The x coordinate to place the center of the Rectangle at.
   * @param {number} y - The y coordinate to place the center of the Rectangle at.
   * @return {Phaser.Rectangle} This Rectangle object
   */

  centerOn(num x, num y) {

    this.centerX = x;
    this.centerY = y;

    return this;

  }

  /**
   * Determines whether the first Rectangle object is fully contained within the second Rectangle object.
   * A Rectangle object is said to contain another if the second Rectangle object falls entirely within the boundaries of the first.
   * @method Phaser.Rectangle#containsRect
   * @param {Phaser.Rectangle} b - The second Rectangle object.
   * @return {boolean} A value of true if the Rectangle object contains the specified point; otherwise false.
   */

  bool containsRect(Rectangle b) {
    //  If the given rect has a larger volume than this one then it can never contain it
    if (volume > b.volume) {
      return false;
    }
    return (x >= b.x && y >= b.y && right <= b.right && bottom <= b.bottom);
  }

  /**
   * Determines whether the two Rectangles are equal.
   * This method compares the x, y, width and height properties of each Rectangle.
   * @method Phaser.Rectangle#equals
   * @param {Phaser.Rectangle} b - The second Rectangle object.
   * @return {boolean} A value of true if the two Rectangles have exactly the same values for the x, y, width and height properties; otherwise false.
   */

  bool equals(Rectangle b) {

    return (x == b.x && y == b.y && width == b.width && height == b.height);

  }


  /**
   * If the Rectangle object specified in the toIntersect parameter intersects with this Rectangle object, returns the area of intersection as a Rectangle object. If the Rectangles do not intersect, this method returns an empty Rectangle object with its properties set to 0.
   * @method Phaser.Rectangle#intersection
   * @param {Phaser.Rectangle} b - The second Rectangle object.
   * @param {Phaser.Rectangle} out - Optional Rectangle object. If given the intersection values will be set into this object, otherwise a brand new Rectangle object will be created and returned.
   * @return {Phaser.Rectangle} A Rectangle object that equals the area of intersection. If the Rectangles do not intersect, this method returns an empty Rectangle object; that is, a Rectangle with its x, y, width, and height properties set to 0.
   */

  Rectangle intersection(Rectangle b, [Rectangle output]) {
    if (output == null) {
      output = new Rectangle();
    }
    if (this.intersects(b)) {
      output.x = Math.max(x, b.x);
      output.y = Math.max(y, b.y);
      output.width = Math.min(right, b.right) - output.x;
      output.height = Math.min(bottom, b.bottom) - output.y;
    }
    return output;
  }


  /**
   * Determines whether the two Rectangles intersect with each other.
   * This method checks the x, y, width, and height properties of the Rectangles.
   * @method Phaser.Rectangle#intersects
   * @param {Phaser.Rectangle} b - The second Rectangle object.
   * @param {number} tolerance - A tolerance value to allow for an intersection test with padding, default to 0.
   * @return {boolean} A value of true if the specified object intersects with this Rectangle object; otherwise false.
   */

  bool intersects(Rectangle b, [num tolerance = 0]) {
    if (width <= 0 || height <= 0 || b.width <= 0 || b.height <= 0) {
      return false;
    }

    return !(right < b.x || bottom < b.y || x > b.right || y > b.bottom);
  }


  /**
   * Determines whether the object specified intersects (overlaps) with the given values.
   * @method Phaser.Rectangle#intersectsRaw
   * @param {number} left - Description.
   * @param {number} right - Description.
   * @param {number} top - Description.
   * @param {number} bottomt - Description.
   * @param {number} tolerance - A tolerance value to allow for an intersection test with padding, default to 0
   * @return {boolean} A value of true if the specified object intersects with the Rectangle; otherwise false.
   */

  bool intersectsRaw(num left, num right, num top, num bottom, [num tolerance = 0]) {

    return !(left > right + tolerance || right < left - tolerance || top > bottom + tolerance || bottom < top - tolerance);

  }


  /**
   * Adds two Rectangles together to create a new Rectangle object, by filling in the horizontal and vertical space between the two Rectangles.
   * @method Phaser.Rectangle#union
   * @param {Phaser.Rectangle} b - The second Rectangle object.
   * @param {Phaser.Rectangle} [out] - Optional Rectangle object. If given the new values will be set into this object, otherwise a brand new Rectangle object will be created and returned.
   * @return {Phaser.Rectangle} A Rectangle object that is the union of the two Rectangles.
   */

  Rectangle union(Rectangle b, Rectangle output) {
    if (output == null) {
      output = new Rectangle();
    }
    return output.setTo(Math.min(x, b.x), Math.min(y, b.y), Math.max(right, b.right) - Math.min(left, b.left), Math.max(bottom, b.bottom) - Math.min(top, b.top));
  }


  /**
   * Returns a string representation of this object.
   * @method Phaser.Rectangle#toString
   * @return {string} A string representation of the instance.
   */

//  toString() {
//    return "[{Rectangle (x=${this.x} y=${this.y} width=${this.width} height=${this.height} empty=${this.empty})}]";
//  }

  factory Rectangle.fromRect(source) {
    return new Rectangle(source.x, source.y, source.width, source.height);
  }

  /**
   * Calculates the Axis Aligned Bounding Box (or aabb) from an array of points.
   *
   * @method Phaser.Rectangle#aabb
   * @param {Phaser.Point[]} points - The array of one or more points.
   * @param {Phaser.Rectangle} [out] - Optional Rectangle to store the value in, if not supplied a new Rectangle object will be created.
   * @return {Phaser.Rectangle} The new Rectangle object.
   * @static
   */

  Rectangle AABB(List<Point> points, Rectangle out) {

    if (out == null) {
      out = new Rectangle();
    }

    num xMax = double.MIN_POSITIVE,
    xMin = double.MAX_FINITE,
    yMax = double.MIN_POSITIVE,
    yMin = double.MAX_FINITE;

    points.forEach((Point point) {
      if (point.x > xMax) {
        xMax = point.x;
      }
      if (point.x < xMin) {
        xMin = point.x;
      }

      if (point.y > yMax) {
        yMax = point.y;
      }
      if (point.y < yMin) {
        yMin = point.y;
      }
    });

    out.setTo(xMin, yMin, xMax - xMin, yMax - yMin);

    return out;
  }

}
