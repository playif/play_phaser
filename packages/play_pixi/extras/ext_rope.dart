part of PIXI;

class Rope extends Strip {
  List<Point> points;
  num count = 0;

  Rope(Texture texture, this.points, [num width, num height])
  :super(texture, width, height) {
    this.verticies = new Float32List(points.length * 4);
    this.uvs = new Float32List(points.length * 4);
    this.colors = new Float32List(points.length * 2);
    this.indices = new Uint16List(points.length * 2);

    this.refresh();
  }

  refresh() {
    List<Point> points = this.points;
    if (points.length < 1) return;

    var uvs = this.uvs;

    var lastPoint = points[0];
    var indices = this.indices;
    var colors = this.colors;

    this.count -= 0.2;


    uvs[0] = 0.0;
    uvs[1] = 1.0;
    uvs[2] = 0.0;
    uvs[3] = 1.0;

    colors[0] = 1.0;
    colors[1] = 1.0;

    indices[0] = 0;
    indices[1] = 1;

    int total = points.length;
    int index;
    num amount;

    Point point= new Point(0,0);

    for (int i = 1; i < total; i++) {

      point = points[i];
      index = i * 4;
      // time to do some smart drawing!
      amount = i / (total - 1);

      if (i % 2 != 0) {
        uvs[index] = amount;
        uvs[index + 1] = 0.0;

        uvs[index + 2] = amount;
        uvs[index + 3] = 1.0;

      }
      else {
        uvs[index] = amount;
        uvs[index + 1] = 0.0;

        uvs[index + 2] = amount;
        uvs[index + 3] = 1.0;
      }

      index = i * 2;
      colors[index] = 1.0;
      colors[index + 1] = 1.0;

      index = i * 2;
      indices[index] = index;
      indices[index + 1] = index + 1;

      lastPoint = point;
    }
  }

  updateTransform() {

    List<Point> points = this.points;
    if (points.length < 1) return;

    Point lastPoint = points[0];
    Point nextPoint;
    Point perp = new Point(0, 0);

    this.count -= 0.2;

    var verticies = this.verticies;
    verticies[0] = lastPoint.x + perp.x.toDouble();
    verticies[1] = lastPoint.y + perp.y.toDouble(); //+ 200
    verticies[2] = lastPoint.x - perp.x.toDouble();
    verticies[3] = lastPoint.y - perp.y.toDouble();//+200
    // time to do some smart drawing!

    int total = points.length, index;
    num ratio, perpLength, n;

    Point point = new Point(0,0);

    for (int i = 1; i < total; i++) {
      point = points[i];
      index = i * 4;

      if (i < points.length - 1) {
        nextPoint = points[i + 1];
      }
      else {
        nextPoint = point;
      }

      perp.y = -(nextPoint.x - lastPoint.x);
      perp.x = nextPoint.y - lastPoint.y;

      ratio = (1 - (i / (total - 1))) * 10;

      if (ratio > 1) ratio = 1;

      perpLength = sqrt(perp.x * perp.x + perp.y * perp.y);
      n = this.texture.height / 2; //(20 + Math.abs(Math.sin((i + this.count) * 0.3) * 50) )* ratio;
      perp.x /= perpLength;
      perp.y /= perpLength;

      perp.x *= n;
      perp.y *= n;

      verticies[index] = point.x + perp.x.toDouble();
      verticies[index + 1] = point.y + perp.y.toDouble();
      verticies[index + 2] = point.x - perp.x.toDouble();
      verticies[index + 3] = point.y - perp.y.toDouble();

      lastPoint = point;
    }

    super.updateTransform();
  }

  setTexture(Texture texture) {
    // stop current texture
    this.texture = texture;
    this.updateFrame = true;
  }

}
