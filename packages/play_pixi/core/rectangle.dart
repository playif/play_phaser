//import "../PIXI.dart";

part of PIXI;

Rectangle EmptyRectangle = new Rectangle(0, 0, 0, 0);

class Rectangle {
  num x, y, width, height;

  bool isMask = false;

  Rectangle([this.x=0, this.y=0, this.width=0, this.height=0]);

  Rectangle clone() {
    return new Rectangle(this.x, this.y, this.width, this.height);
  }

  bool contains(num x, num y) {
    if (this.width <= 0 || this.height <= 0)
      return false;

    var x1 = this.x;
    if (x >= x1 && x <= x1 + this.width) {
      var y1 = this.y;

      if (y >= y1 && y <= y1 + this.height) {
        return true;
      }
    }
    return false;
  }


}
