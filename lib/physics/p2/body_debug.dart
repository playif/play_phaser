part of P2;

class BodyDebug extends Phaser.Group {
  Phaser.Game game;
  p2.Body body;

  /// The canvas to render the debug info to.
  Phaser.Graphics canvas;
  num ppu;

  bool debugPolygons;

  BodyDebug(Phaser.Game game, p2.Body body, {num pixelsPerLengthUnit: 20, bool debugPolygons: false, num lineWidth: 1, num alpha: 0.5})
      : super(game) {
    this.game = game;
    this.body = body;

    this.debugPolygons = debugPolygons;

    this.ppu = pixelsPerLengthUnit;
    this.ppu = -1 * this.ppu;

    this.canvas = new Phaser.Graphics(game);

    this.canvas.alpha = alpha;

    this.add(this.canvas);

    this.draw();

  }

  /**
   * Core update.
   *
   * @method Phaser.Physics.P2.BodyDebug#update
   */

  update() {

    this.updateSpriteTransform();

  }

  /**
   * Core update.
   *
   * @method Phaser.Physics.P2.BodyDebug#updateSpriteTransform
   */

  updateSpriteTransform() {

    this.position.x = this.body.position.x * this.ppu;
    this.position.y = this.body.position.y * this.ppu;

    return this.rotation = this.body.angle;

  }

  /**
   * Draws the P2 shapes to the Graphics object.
   *
   * @method Phaser.Physics.P2.BodyDebug#draw
   */

  draw() {

    num angle;
    p2.Shape child;
    num color, i, j, lineColor, lw;
    p2.Body obj = this.body;
    p2.vec2 offset;
    Phaser.Graphics sprite = this.canvas;
    p2.vec2 v, vrot;
    List verts;
    num _j, _ref1;


    sprite.clear();
    color = int.parse(this.randomPastelHex(), radix: 16);
    lineColor = 0xff0000;
    lw = this.canvas.lineWidth;

    if (obj is p2.Body && obj.shapes.isNotEmpty) {
      int l = obj.shapes.length;

      i = 0;

      while (i != l) {
        child = obj.shapes[i];
        offset = obj.shapeOffsets[i];
        angle = obj.shapeAngles[i];
        offset = offset == null ? 0 : offset;
        angle = angle == null ? 0 : angle;

        if (child is p2.Circle) {
          this.drawCircle(sprite, offset.x * this.ppu, offset.y * this.ppu, angle, (child as p2.Circle).radius * this.ppu, color, lw);
        } else if (child is p2.Convex) {
          verts = [];
          vrot = p2.vec2.create();

          for (num j = _j = 0,
              _ref1 = (child as p2.Convex).vertices.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
            v = (child as p2.Convex).vertices[j];
            p2.vec2.rotate(vrot, v, angle);
            verts.add(new p2.vec2((vrot.x + offset.x) * this.ppu, -(vrot.y + offset.y) * this.ppu));
          }

          this.drawConvex(sprite, verts, (child as p2.Convex).triangles, lineColor, color, lw, debugPolygons, [offset.x * this.ppu, -offset.y * this.ppu]);
        } else if (child is p2.Plane) {
          this.drawPlane(sprite, offset.x * this.ppu, -offset.y * this.ppu, color, lineColor, lw * 5, lw * 10, lw * 10, this.ppu * 100, angle);
        } else if (child is p2.Line) {
          this.drawLine(sprite, (child as p2.Line).length * this.ppu, lineColor, lw);
        } else if (child is p2.Rectangle) {
          this.drawRectangle(sprite, offset.x * this.ppu, -offset.y * this.ppu, angle, (child as p2.Rectangle).width * this.ppu, (child as p2.Rectangle).height * this.ppu, lineColor, color, lw);
        }

        i++;
      }
    }

  }

  /**
   * Draws the P2 shapes to the Graphics object.
   *
   * @method Phaser.Physics.P2.BodyDebug#draw
   */

  drawRectangle(g, x, y, angle, w, h, color, fillColor, lineWidth) {

    if (lineWidth == null) {
      lineWidth = 1;
    }
    if (color == null) {
      color = 0x000000;
    }

    g.lineStyle(lineWidth, color, 1);
    g.beginFill(fillColor);
    g.drawRect(x - w / 2, y - h / 2, w, h);

  }

  /**
   * Draws a P2 Circle shape.
   *
   * @method Phaser.Physics.P2.BodyDebug#drawCircle
   */

  drawCircle(g, x, y, angle, radius, color, lineWidth) {

    if (lineWidth == null) {
      lineWidth = 1;
    }
    if (color == null) {
      color = 0xffffff;
    }
    g.lineStyle(lineWidth, 0x000000, 1);
    g.beginFill(color, 1.0);
    g.drawCircle(x, y, -radius);
    g.endFill();
    g.moveTo(x, y);
    g.lineTo(x + radius * Math.cos(-angle), y + radius * Math.sin(-angle));

  }

  /**
   * Draws a P2 Line shape.
   *
   * @method Phaser.Physics.P2.BodyDebug#drawCircle
   */

  drawLine(Phaser.Graphics g, len, color, lineWidth) {

    if (lineWidth == null) {
      lineWidth = 1;
    }
    if (color == null) {
      color = 0x000000;
    }

    g.lineStyle(lineWidth * 5, color, 1);
    g.moveTo(-len / 2, 0);
    g.lineTo(len / 2, 0);

  }

  /**
   * Draws a P2 Convex shape.
   *
   * @method Phaser.Physics.P2.BodyDebug#drawConvex
   */

  drawConvex(Phaser.Graphics g, verts, triangles, color, fillColor, lineWidth, debug, offset) {

    var colors, i, v, v0, v1, x, x0, x1, y, y0, y1;

    if (lineWidth == null) {
      lineWidth = 1;
    }
    if (color == null) {
      color = 0x000000;
    }

    if (!debug) {
      g.lineStyle(lineWidth, color, 1);
      g.beginFill(fillColor);
      i = 0;

      while (i != verts.length) {
        v = verts[i];
        x = v.x;
        y = v.y;

        if (i == 0) {
          g.moveTo(x, -y);
        } else {
          g.lineTo(x, -y);
        }

        i++;
      }

      g.endFill();

      if (verts.length > 2) {
        g.moveTo(verts[verts.length - 1].x, -verts[verts.length - 1].y);
        return g.lineTo(verts[0].x, -verts[0].y);
      }
    } else {
      colors = [0xff0000, 0x00ff00, 0x0000ff];
      i = 0;

      while (i != verts.length + 1) {
        v0 = verts[i % verts.length];
        v1 = verts[(i + 1) % verts.length];
        x0 = v0.x;
        y0 = v0.y;
        x1 = v1.x;
        y1 = v1.y;
        g.lineStyle(lineWidth, colors[i % colors.length], 1);
        g.moveTo(x0, -y0);
        g.lineTo(x1, -y1);
        g.drawCircle(x0, -y0, lineWidth * 2);
        i++;
      }

      g.lineStyle(lineWidth, 0x000000, 1);
      return g.drawCircle(offset.x, offset.y, lineWidth * 2);
    }

  }

  /**
   * Draws a P2 Path.
   *
   * @method Phaser.Physics.P2.BodyDebug#drawPath
   */

  drawPath(Phaser.Graphics g, path, color, fillColor, lineWidth) {

    var area, i, lastx, lasty, p1x, p1y, p2x, p2y, p3x, p3y, v, x, y;
    if (lineWidth == null) {
      lineWidth = 1;
    }
    if (color == null) {
      color = 0x000000;
    }

    g.lineStyle(lineWidth, color, 1);

    if (fillColor is num) {
      g.beginFill(fillColor);
    }

    lastx = null;
    lasty = null;
    i = 0;

    while (i < path.length) {
      v = path[i];
      x = v.x;
      y = v.y;

      if (x != lastx || y != lasty) {
        if (i == 0) {
          g.moveTo(x, y);
        } else {
          p1x = lastx;
          p1y = lasty;
          p2x = x;
          p2y = y;
          p3x = path[(i + 1) % path.length].x;
          p3y = path[(i + 1) % path.length].y;
          area = ((p2x - p1x) * (p3y - p1y)) - ((p3x - p1x) * (p2y - p1y));

          if (area != 0) {
            g.lineTo(x, y);
          }
        }
        lastx = x;
        lasty = y;
      }

      i++;

    }

    if (fillColor is num) {
      g.endFill();
    }

    if (path.length > 2 && fillColor is num) {
      g.moveTo(path[path.length - 1].x, path[path.length - 1].y);
      g.lineTo(path[0].x, path[0].y);
    }

  }

  /**
   * Draws a P2 Plane shape.
   *
   * @method Phaser.Physics.P2.BodyDebug#drawPlane
   */

  drawPlane(g, x0, x1, color, lineColor, lineWidth, diagMargin, diagSize, maxLength, angle) {

    var max, xd, yd;
    if (lineWidth == null) {
      lineWidth = 1;
    }
    if (color == null) {
      color = 0xffffff;
    }

    g.lineStyle(lineWidth, lineColor, 11);
    g.beginFill(color);
    max = maxLength;

    g.moveTo(x0, -x1);
    xd = x0 + Math.cos(angle) * this.game.width;
    yd = x1 + Math.sin(angle) * this.game.height;
    g.lineTo(xd, -yd);

    g.moveTo(x0, -x1);
    xd = x0 + Math.cos(angle) * -this.game.width;
    yd = x1 + Math.sin(angle) * -this.game.height;
    g.lineTo(xd, -yd);

  }

  /**
   * Picks a random pastel color.
   *
   * @method Phaser.Physics.P2.BodyDebug#randomPastelHex
   */

  randomPastelHex() {
    Math.Random random = new Math.Random();
    num blue, green, red;
    List mix = const [255, 255, 255];

    red = random.nextInt(256);
    green = random.nextInt(256);
    blue = random.nextInt(256);

    red = ((red + 3 * mix[0]) / 4).floor();
    green = ((green + 3 * mix[1]) / 4).floor();
    blue = ((blue + 3 * mix[2]) / 4).floor();
    return this.rgbToHex(red, green, blue);
  }

  /**
   * Converts from RGB to Hex.
   *
   * @method Phaser.Physics.P2.BodyDebug#rgbToHex
   */

  rgbToHex(r, g, b) {
    return this.componentToHex(r) + this.componentToHex(g) + this.componentToHex(b);
  }

  /**
   * Component to hex conversion.
   *
   * @method Phaser.Physics.P2.BodyDebug#componentToHex
   */

  componentToHex(int c) {
    String hex;
    hex = c.toRadixString(16);
    if (hex.length == 2) {
      return hex;
    } else {
      return hex + '0';
    }
  }

}
