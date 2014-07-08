
part of PIXI;


class Circle {
  num x,y,radius;

  Circle([this.x=0, this.y=0, this.radius=0]) {

  }

  Circle clone ()
  {
    return new Circle(x, y, radius);
  }

  bool contains(num x, num y)
  {
    if(this.radius <= 0)
      return false;

    var dx = (this.x - x),
    dy = (this.y - y),
    r2 = this.radius * this.radius;

    dx *= dx;
    dy *= dy;

    return (dx + dy <= r2);
  }
}
