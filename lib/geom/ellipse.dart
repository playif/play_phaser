part of Phaser;

class Ellipse extends PIXI.Ellipse {
  int type;
  num x, y, width, height;


  /**
   * The left coordinate of the Ellipse. The same as the X coordinate.
   * @name Phaser.Ellipse#left
   * @propety {number} left - Gets or sets the value of the leftmost point of the ellipse.
   */
  //Object.defineProperty(Phaser.Ellipse.prototype, "left", {

  num get left {
    return this.x;
  }

  set left(num value) {
    this.x = value;
  }

  //});

  /**
   * The x coordinate of the rightmost point of the Ellipse. Changing the right property of an Ellipse object has no effect on the x property, but does adjust the width.
   * @name Phaser.Ellipse#right
   * @property {number} right - Gets or sets the value of the rightmost point of the ellipse.
   */
  //Object.defineProperty(Phaser.Ellipse.prototype, "right", {

  num get right {
    return this.x + this.width;
  }

  set right(num value) {
    if (value < this.x) {
      this.width = 0;
    }
    else {
      this.width = this.x + value;
    }
  }

  //});

  /**
   * The top of the Ellipse. The same as its y property.
   * @name Phaser.Ellipse#top
   * @property {number} top - Gets or sets the top of the ellipse.
   */
  //Object.defineProperty(Phaser.Ellipse.prototype, "top", {

  num get top {
    return this.y;
  }

  set top(num value) {
    this.y = value;
  }

  //});

  /**
   * The sum of the y and height properties. Changing the bottom property of an Ellipse doesn't adjust the y property, but does change the height.
   * @name Phaser.Ellipse#bottom
   * @property {number} bottom - Gets or sets the bottom of the ellipse.
   */
  //Object.defineProperty(Phaser.Ellipse.prototype, "bottom", {

  num get bottom {
    return this.y + this.height;
  }

  set bottom(num value) {
    if (value < this.y) {
      this.height = 0;
    }
    else {
      this.height = this.y + value;
    }
  }

  //});

  /**
   * Determines whether or not this Ellipse object is empty. Will return a value of true if the Ellipse objects dimensions are less than or equal to 0; otherwise false.
   * If set to true it will reset all of the Ellipse objects properties to 0. An Ellipse object is empty if its width or height is less than or equal to 0.
   * @name Phaser.Ellipse#empty
   * @property {boolean} empty - Gets or sets the empty state of the ellipse.
   */
  //Object.defineProperty(Phaser.Ellipse.prototype, "empty", {

  bool get empty {
    return (this.width == 0 || this.height == 0);
  }

  set(bool value) {
    if (value == true) {
      this.setTo(0, 0, 0, 0);
    }
  }

  //});

  Ellipse(num x, num y, num width, num height) {
    this.type = ELLIPSE;

    /**
     * @property {number} x - The X coordinate of the upper-left corner of the framing rectangle of this ellipse.
     */
    this.x = x;

    /**
     * @property {number} y - The Y coordinate of the upper-left corner of the framing rectangle of this ellipse.
     */
    this.y = y;

    /**
     * @property {number} width - The overall width of this ellipse.
     */
    this.width = width;

    /**
     * @property {number} height - The overall height of this ellipse.
     */
    this.height = height;

  }


  /**
   * Sets the members of the Ellipse to the specified values.
   * @method Phaser.Ellipse#setTo
   * @param {number} x - The X coordinate of the upper-left corner of the framing rectangle of this ellipse.
   * @param {number} y - The Y coordinate of the upper-left corner of the framing rectangle of this ellipse.
   * @param {number} width - The overall width of this ellipse.
   * @param {number} height - The overall height of this ellipse.
   * @return {Phaser.Ellipse} This Ellipse object.
   */

  Ellipse setTo(num x, num y, num width, num height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    return this;
  }

  /**
   * Copies the x, y, width and height properties from any given object to this Ellipse.
   * @method Phaser.Ellipse#copyFrom
   * @param {any} source - The object to copy from.
   * @return {Phaser.Ellipse} This Ellipse object.
   */

  Ellipse copyFrom(Ellipse source) {
    return this.setTo(source.x, source.y, source.width, source.height);
  }

  /**
   * Copies the x, y and diameter properties from this Circle to any given object.
   * @method Phaser.Ellipse#copyTo
   * @param {any} dest - The object to copy to.
   * @return {Object} This dest object.
   */

  copyTo(dest) {
    dest.x = this.x;
    dest.y = this.y;
    dest.width = this.width;
    dest.height = this.height;
    return dest;
  }

  /**
   * Returns a new Ellipse object with the same values for the x, y, width, and height properties as this Ellipse object.
   * @method Phaser.Ellipse#clone
   * @param {Phaser.Ellipse} out - Optional Ellipse object. If given the values will be set into the object, otherwise a brand new Ellipse object will be created and returned.
   * @return {Phaser.Ellipse} The cloned Ellipse object.
   */

  Ellipse clone([Ellipse output]) {

    if (output == null) {
      output = new Ellipse(this.x, this.y, this.width, this.height);
    }
    else {
      output.setTo(this.x, this.y, this.width, this.height);
    }

    return output;

  }

  /**
   * Return true if the given x/y coordinates are within this Ellipse object.
   * @method Phaser.Ellipse#contains
   * @param {number} x - The X value of the coordinate to test.
   * @param {number} y - The Y value of the coordinate to test.
   * @return {boolean} True if the coordinates are within this ellipse, otherwise false.
   */

  bool contains(num x, num y) {
    if (this.width <= 0 || this.height <= 0) {
      return false;
    }

    //  Normalize the coords to an ellipse with center 0,0 and a radius of 0.5
    double normx = ((x - this.x) / this.width) - 0.5;
    double normy = ((y - this.y) / this.height) - 0.5;

    normx *= normx;
    normy *= normy;

    return (normx + normy < 0.25);
    //return Ellipse.contains(this, x, y);
  }

  /**
   * Returns a string representation of this object.
   * @method Phaser.Ellipse#toString
   * @return {string} A string representation of the instance.
   */

  String toString() {
    return "[{Phaser.Ellipse (x=${this.x} y=${this.y} width=${this.width} height=${this.height})}]";
  }

  /**
   * Return true if the given x/y coordinates are within the Ellipse object.
   * @method Phaser.Ellipse.contains
   * @param {Phaser.Ellipse} a - The Ellipse to be checked.
   * @param {number} x - The X value of the coordinate to test.
   * @param {number} y - The Y value of the coordinate to test.
   * @return {boolean} True if the coordinates are within this ellipse, otherwise false.
   */
//  Phaser.Ellipse.contains = function (a, x, y) {
//
//
//
//  }

  /**
   * Returns the framing rectangle of the ellipse as a Phaser.Rectangle object.
   *
   * @method Phaser.Ellipse.getBounds
   * @return {Phaser.Rectangle} The framing rectangle
   */

  Rectangle getBounds() {
    return new Rectangle(this.x, this.y, this.width, this.height);
  }
}
