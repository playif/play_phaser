part of Phaser;

class Frame extends Rectangle {
  int index;
  num x;
  num y;
  num width;
  num height;
  String name;
  String uuid;

  num centerX;

  num centerY;

  num distance;

  bool rotate = false;

  String rotationDirection = 'cw';

  bool trimmed = false;

  num sourceSizeW;
  num sourceSizeH;

  num spriteSourceSizeX = 0;
  num spriteSourceSizeY = 0;
  num spriteSourceSizeW = 0;
  num spriteSourceSizeH = 0;

  Frame(this.index, this.x, this.y, this.width, this.height, this.name, this.uuid) {
    centerX = Math.floor(width / 2);
    centerY = Math.floor(height / 2);

    sourceSizeW = width;
    sourceSizeH = height;

    /**
      * @property {number} distance - The distance from the top left to the bottom-right of this Frame.
      */
    this.distance = Math.distance(0, 0, width, height);

//    /**
//      * @property {number} right - The right of the Frame (x + width).
//      */
//    this.right = this.x + this.width;
//
//    /**
//      * @property {number} bottom - The bottom of the frame (y + height).
//      */
//    this.bottom = this.y + this.height;
  }


  setTrim(bool trimmed, num actualWidth, num actualHeight, num destX, num destY, num destWidth, num destHeight) {
    this.trimmed = trimmed;

    if (trimmed) {
      //this.width = actualWidth;
      //this.height = actualHeight;
      this.sourceSizeW = actualWidth;
      this.sourceSizeH = actualHeight;
      this.centerX = Math.floor(actualWidth / 2);
      this.centerY = Math.floor(actualHeight / 2);
      this.spriteSourceSizeX = destX;
      this.spriteSourceSizeY = destY;
      this.spriteSourceSizeW = destWidth;
      this.spriteSourceSizeH = destHeight;
    }

  }

  Rectangle getRect([Rectangle out]) {

    if (out == null) {
      out = new Rectangle(this.x, this.y, this.width, this.height);
    } else {
      out.setTo(this.x, this.y, this.width, this.height);
    }

    return out;
  }

  /**
   * Clones this Frame into a new Phaser.Frame object and returns it.
   * Note that all properties are cloned, including the name, index and UUID.
   */
  Frame clone([Frame output]) {
    if (output != null) {
      output
          ..index = this.index
          ..x = x
          ..y = y
          ..width = width
          ..height = height
          ..name = name
          ..uuid = uuid;
      return output;
    }
    return new Frame(this.index, this.x, this.y, this.width, this.height, this.name, this.uuid);
//
//    Frame output = new Frame(this.index, this.x, this.y, this.width, this.height, this.name, this.uuid);

//      output
//          ..index = this.index
//          ..x = x
//          ..y = y
//          ..width = width
//          ..height = height
//          ..name = name
//          ..uuid = uuid;

//    return output;

  }
}
