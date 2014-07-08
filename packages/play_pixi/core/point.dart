part of PIXI;

class Point {
  num x, y;

  Point([this.x=0, this.y=0]) {
  }

  clone() {
    return new Point(x, y);
  }

  set([num x=0, num y])
  {
    this.x = x;
    this.y = y == null ? this.x : y;
  }
}
