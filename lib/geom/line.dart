part of Phaser;

class Line {
  num x1, x2, y1, y2;
  Point start, end;

  Line([this.x1 = 0, this.y1 = 0, this.x2 = 0, this.y2 = 0]) {
    /**
     * @property {Phaser.Point} start - The start point of the line.
     */
    this.start = new Point(x1, y1);

    /**
     * @property {Phaser.Point} end - The end point of the line.
     */
    this.end = new Point(x2, y2);
  }

  /**
   * Sets the components of the Line to the specified values.
   * @method Phaser.Line#setTo
   * @param {number} [x1=0] - The x coordinate of the start of the line.
   * @param {number} [y1=0] - The y coordinate of the start of the line.
   * @param {number} [x2=0] - The x coordinate of the end of the line.
   * @param {number} [y2=0] - The y coordinate of the end of the line.
   * @return {Phaser.Line} This line object
   */

  setTo([int x1 = 0, int y1 = 0, int x2 = 0, int y2 = 0]) {
    this.start.setTo(x1, y1);
    this.end.setTo(x2, y2);
    return this;
  }

  /**
   * Sets the line to match the x/y coordinates of the two given sprites.
   * Can optionally be calculated from their center coordinates.
   * @method Phaser.Line#fromSprite
   * @param {Phaser.Sprite} startSprite - The coordinates of this Sprite will be set to the Line.start point.
   * @param {Phaser.Sprite} endSprite - The coordinates of this Sprite will be set to the Line.start point.
   * @param {boolean} [useCenter=false] - If true it will use startSprite.center.x, if false startSprite.x. Note that Sprites don't have a center property by default, so only enable if you've over-ridden your Sprite with a custom class.
   * @return {Phaser.Line} This line object
   */

  Line fromSprite(Sprite startSprite, Sprite endSprite, [bool useCenter = false]) {

//    if (typeof useCenter == 'undefined') { useCenter = false; }

    if (useCenter) {
      return this.setTo(startSprite.center.x, startSprite.center.y, endSprite.center.x, endSprite.center.y);
    }
    return this.setTo(startSprite.x, startSprite.y, endSprite.x, endSprite.y);

  }

  /**
      * Returns a new Line object with the same values for the start and end properties as this Line object.
      * @method Phaser.Line#clone
      * @param {Phaser.Line} output - Optional Line object. If given the values will be set into the object, otherwise a brand new Line object will be created and returned.
      * @return {Phaser.Line} The cloned Line object.
      */
  Line clone(Line output) {

    if (output == null) {
      output = new Line(this.start.x, this.start.y, this.end.x, this.end.y);
    } else {
      output.setTo(this.start.x, this.start.y, this.end.x, this.end.y);
    }

    return output;
  }
  /**
   * Checks for intersection between this line and another Line.
   * If asSegment is true it will check for segment intersection. If asSegment is false it will check for line intersection.
   * Returns the intersection segment of AB and EF as a Point, or null if there is no intersection.
   *
   * @method Phaser.Line#intersects
   * @param {Phaser.Line} line - The line to check against this one.
   * @param {boolean} [asSegment=true] - If true it will check for segment intersection, otherwise full line intersection.
   * @param {Phaser.Point} [result] - A Point object to store the result in, if not given a new one will be created.
   * @return {Phaser.Point} The intersection segment of the two lines as a Point, or null if there is no intersection.
   */

  Point intersects(Line line, [bool asSegment, Point result]) {
    return Line.intersectsPoints(this.start, this.end, line.start, line.end, asSegment, result);
  }

  /**
   * Tests if the given coordinates fall on this line. See pointOnSegment to test against just the line segment.
   * @method Phaser.Line#pointOnLine
   * @param {number} x - The line to check against this one.
   * @param {number} y - The line to check against this one.
   * @return {boolean} True if the point is on the line, false if not.
   */

  pointOnLine(int x, int y) {

    return ((x - this.start.x) * (this.end.y - this.start.y) == (this.end.x - this.start.x) * (y - this.start.y));

  }

  /**
   * Tests if the given coordinates fall on this line and within the segment. See pointOnLine to test against just the line.
   * @method Phaser.Line#pointOnSegment
   * @param {number} x - The line to check against this one.
   * @param {number} y - The line to check against this one.
   * @return {boolean} True if the point is on the line and segment, false if not.
   */

  pointOnSegment(int x, int y) {

    var xMin = Math.min(this.start.x, this.end.x);
    var xMax = Math.max(this.start.x, this.end.x);
    var yMin = Math.min(this.start.y, this.end.y);
    var yMax = Math.max(this.start.y, this.end.y);

    return (this.pointOnLine(x, y) && (x >= xMin && x <= xMax) && (y >= yMin && y <= yMax));

  }

  /**
   * Using Bresenham's line algorithm this will return an array of all coordinates on this line.
   * The start and end points are rounded before this runs as the algorithm works on integers.
   *
   * @method Phaser.Line#coordinatesOnLine
   * @param {number} [stepRate=1] - How many steps will we return? 1 = every coordinate on the line, 2 = every other coordinate, etc.
   * @param {array} [results] - The array to store the results in. If not provided a new one will be generated.
   * @return {array} An array of coordinates.
   */

  List<List<num>> coordinatesOnLine([int stepRate = 1, List<List<num>> results]) {

//  if (typeof stepRate === 'undefined') { stepRate = 1; }
    if (results == null) {
      results = [];
    }

    var x1 = Math.round(this.start.x);
    var y1 = Math.round(this.start.y);
    var x2 = Math.round(this.end.x);
    var y2 = Math.round(this.end.y);

    var dx = Math.abs(x2 - x1);
    var dy = Math.abs(y2 - y1);
    var sx = (x1 < x2) ? 1 : -1;
    var sy = (y1 < y2) ? 1 : -1;
    var err = dx - dy;

    results.add([x1, y1]);

    var i = 1;

    while (!((x1 == x2) && (y1 == y2))) {
      var e2 = err << 1;

      if (e2 > -dy) {
        err -= dy;
        x1 += sx;
      }

      if (e2 < dx) {
        err += dx;
        y1 += sy;
      }

      if (i % stepRate == 0) {
        results.add([x1, y1]);
      }

      i++;

    }

    return results;

  }

  int get length {
    return Math.sqrt((this.end.x - this.start.x) * (this.end.x - this.start.x) + (this.end.y - this.start.y) * (this.end.y - this.start.y));
  }

  num get angle {
    return Math.atan2(this.end.y - this.start.y, this.end.x - this.start.x);
  }

  num get slope {
    return (this.end.y - this.start.y) / (this.end.x - this.start.x);
  }

  num get perpSlope {
    return -((this.end.x - this.start.x) / (this.end.y - this.start.y));
  }

  num get x {
    return Math.min(this.start.x, this.end.x);
  }

  num get y {
    return Math.min(this.start.y, this.end.y);
  }

  num get left {
    return Math.min(this.start.x, this.end.x);
  }

  num get right {
    return Math.max(this.start.x, this.end.x);
  }

  num get bottom {
    return Math.max(this.start.y, this.end.y);
  }

  num get width {
    return Math.abs(this.start.x - this.end.x);
  }

  num get height {
    return Math.abs(this.start.y - this.end.y);
  }


  /**
   * Checks for intersection between two lines as defined by the given start and end points.
   * If asSegment is true it will check for line segment intersection. If asSegment is false it will check for line intersection.
   * Returns the intersection segment of AB and EF as a Point, or null if there is no intersection.
   * Adapted from code by Keith Hair
   *
   * @method Phaser.Line.intersectsPoints
   * @param {Phaser.Point} a - The start of the first Line to be checked.
   * @param {Phaser.Point} b - The end of the first line to be checked.
   * @param {Phaser.Point} e - The start of the second Line to be checked.
   * @param {Phaser.Point} f - The end of the second line to be checked.
   * @param {boolean} [asSegment=true] - If true it will check for segment intersection, otherwise full line intersection.
   * @param {Phaser.Point} [result] - A Point object to store the result in, if not given a new one will be created.
   * @return {Phaser.Point} The intersection segment of the two lines as a Point, or null if there is no intersection.
   */

  static Point intersectsPoints(Point a, Point b, Point e, Point f, [bool asSegment = true, Point result]) {

//    if (typeof asSegment === 'undefined') { asSegment = true; }
    if (result == null) {
      result = new Point();
    }

    var a1 = b.y - a.y;
    var a2 = f.y - e.y;
    var b1 = a.x - b.x;
    var b2 = e.x - f.x;
    var c1 = (b.x * a.y) - (a.x * b.y);
    var c2 = (f.x * e.y) - (e.x * f.y);
    var denom = (a1 * b2) - (a2 * b1);

    if (denom == 0) {
      return null;
    }

    result.x = ((b1 * c2) - (b2 * c1)) / denom;
    result.y = ((a2 * c1) - (a1 * c2)) / denom;

    if (asSegment) {
      var uc = ((f.y - e.y) * (b.x - a.x) - (f.x - e.x) * (b.y - a.y));
      var ua = (((f.x - e.x) * (a.y - e.y)) - (f.y - e.y) * (a.x - e.x)) / uc;
      var ub = (((b.x - a.x) * (a.y - e.y)) - ((b.y - a.y) * (a.x - e.x))) / uc;
      if (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1) {
        return result;
      } else {
        return null;
      }
    }

    return result;

  }

  /**
   * Checks for intersection between two lines.
   * If asSegment is true it will check for segment intersection.
   * If asSegment is false it will check for line intersection.
   * Returns the intersection segment of AB and EF as a Point, or null if there is no intersection.
   * Adapted from code by Keith Hair
   *
   * @method Phaser.Line.intersects
   * @param {Phaser.Line} a - The first Line to be checked.
   * @param {Phaser.Line} b - The second Line to be checked.
   * @param {boolean} [asSegment=true] - If true it will check for segment intersection, otherwise full line intersection.
   * @param {Phaser.Point} [result] - A Point object to store the result in, if not given a new one will be created.
   * @return {Phaser.Point} The intersection segment of the two lines as a Point, or null if there is no intersection.
   */

//  static Point intersects(Line a, Line b, [bool asSegment=true, Point result]) {
//    return Line.intersectsPoints(a.start, a.end, b.start, b.end, asSegment, result);
//  }

}
