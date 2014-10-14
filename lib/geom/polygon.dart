part of Phaser;

class Polygon {
  List<Point> _points;
  int type;
  /*
* Sets and modifies the points of this polygon.
*
* @name Phaser.Polygon#points
* @property {array<Phaser.Point>|array<number>} points - The array of vertex points
*/
  //Object.defineProperty(Phaser.Polygon.prototype, 'points', {

  List<Point> get points {
    return this._points;
  }

  set points(List<Point> points) {
    this._points = points;
  }

  //});

  /**
   * Returns the area of the polygon.
   *
   * @name Phaser.Circle#right
   * @readonly
   */
  //Object.defineProperty(Phaser.Polygon.prototype, 'area', {

  num get area {

    Point p1;
    Point p2;
    num avgHeight;
    num width;
    num i;
    num y0 = double.INFINITY;
    num area = 0;

    // Find lowest boundary
    for (i = 0; i < this.points.length; i++) {
      if (this.points[i].y < y0) {
        y0 = this.points[i].y;
      }
    }

    for (i = 0; i < this.points.length; i++) {
      p1 = this.points[i];

      if (i == this.points.length - 1) {
        p2 = this.points[0];
      } else {
        p2 = this.points[i + 1];
      }

      avgHeight = ((p1.y - y0) + (p2.y - y0)) / 2;
      width = p1.x - p2.x;
      area += avgHeight * width;
    }

    return area;

  }

  //});


  Polygon(this._points) {
    /**
     * @property {number} type - The base object type.
     */
    this.type = POLYGON;

    //if points isn't an array, use arguments as the array
//    if (!(points is List))
//    {
//      points = Array.prototype.slice.call(arguments);
//    }

    //if this is a flat array of numbers, convert it to points
//    if (typeof points[0] === 'number')
//    {
//      var p = [];
//
//      for (var i = 0, len = points.length; i < len; i += 2)
//      {
//        p.push(new Phaser.Point(points[i], points[i + 1]));
//      }
//
//      points = p;
//    }

    /**
     * @property {array<Phaser.Point>|array<number>} points - The array of vertex Points.
     * @private
     */
    //this._points = points;

  }

  /**
   * Creates a clone of this polygon.
   *
   * @method Phaser.Polygon#clone
   * @return {Phaser.Polygon} A copy of the polygon.
   */

  Polygon clone(Polygon output) {

    var points = [];

    for (var i = 0; i < this.points.length; i++) {
      points.add(this.points[i].clone());
    }

    //return new Polygon(points);
    if (output == null) {
      output = new Polygon(points);
    } else {
      output.setTo(points);
    }
    return output;
  }

  setTo(List<Point> points) {

    this.points = points;

    return this;

  }

  /**
   * Checks whether the x and y coordinates are contained within this polygon.
   *
   * @method Phaser.Polygon#contains
   * @param {number} x - The X value of the coordinate to test.
   * @param {number} y - The Y value of the coordinate to test.
   * @return {boolean} True if the coordinates are within this polygon, otherwise false.
   */

  contains(num x, num y) {

    var inside = false;

    // use some raycasting to test hits https://github.com/substack/point-in-polygon/blob/master/index.js
    for (var i = 0,
        j = this.points.length - 1; i < this.points.length; j = i++) {
      var xi = this.points[i].x;
      var yi = this.points[i].y;
      var xj = this.points[j].x;
      var yj = this.points[j].y;

      var intersect = ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);

      if (intersect) {
        inside = !inside;
      }
    }

    return inside;

  }

}
