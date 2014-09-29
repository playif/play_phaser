part of P2;

class body_debug {
  Phaser.Game game;
  Body body;

  Phaser.Graphics canvas;
  body_debug(Phaser.Game game, Body body, {num pixelsPerLengthUnit:20,bool debugPolygons:false,num lineWidth:1,num alpha:0.5}) {
    this.game=game;
    this.body=body;

    /**
     * @property {Phaser.Graphics} canvas - The canvas to render the debug info to.
     */
    this.canvas = new Phaser.Graphics(game);

    this.canvas.alpha = this.settings.alpha;

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

    this.position.x = this.body.position[0] * this.ppu;
    this.position.y = this.body.position[1] * this.ppu;

    return this.rotation = this.body.angle;

  }

  /**
   * Draws the P2 shapes to the Graphics object.
   *
   * @method Phaser.Physics.P2.BodyDebug#draw
   */
  draw() {

    var angle, child, color, i, j, lineColor, lw, obj, offset, sprite, v, verts, vrot, _j, _ref1;
    obj = this.body;
    sprite = this.canvas;
    sprite.clear();
    color = int.parse(this.randomPastelHex(), radix:16);
    lineColor = 0xff0000;
    lw = this.lineWidth;

    if (obj is p2.Body && obj.shapes.length)
    {
      var l = obj.shapes.length;

      i = 0;

      while (i != l)
      {
        child = obj.shapes[i];
        offset = obj.shapeOffsets[i];
        angle = obj.shapeAngles[i];
        offset = offset || 0;
        angle = angle || 0;

        if (child is p2.Circle)
        {
          this.drawCircle(sprite, offset[0] * this.ppu, offset[1] * this.ppu, angle, child.radius * this.ppu, color, lw);
        }
        else if (child is p2.Convex)
        {
          verts = [];
          vrot = p2.vec2.create();

          for (num j = _j = 0, _ref1 = child.vertices.length; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; j = 0 <= _ref1 ? ++_j : --_j)
          {
            v = child.vertices[j];
            p2.vec2.rotate(vrot, v, angle);
            verts.push([(vrot[0] + offset[0]) * this.ppu, -(vrot[1] + offset[1]) * this.ppu]);
          }

          this.drawConvex(sprite, verts, child.triangles, lineColor, color, lw, this.settings.debugPolygons, [offset[0] * this.ppu, -offset[1] * this.ppu]);
        }
        else if (child is p2.Plane)
          {
            this.drawPlane(sprite, offset[0] * this.ppu, -offset[1] * this.ppu, color, lineColor, lw * 5, lw * 10, lw * 10, this.ppu * 100, angle);
          }
          else if (child is p2.Line)
            {
              this.drawLine(sprite, child.length * this.ppu, lineColor, lw);
            }
            else if (child is p2.Rectangle)
              {
                this.drawRectangle(sprite, offset[0] * this.ppu, -offset[1] * this.ppu, angle, child.width * this.ppu, child.height * this.ppu, lineColor, color, lw);
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

    if (lineWidth == null) { lineWidth = 1; }
    if (color == null) { color = 0x000000; }

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

    if (lineWidth == null) { lineWidth = 1; }
    if (color == null) { color = 0xffffff; }
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

    if (lineWidth == null) { lineWidth = 1; }
    if (color == null) { color = 0x000000; }

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

    if (lineWidth == null) { lineWidth = 1; }
    if (color == null) { color = 0x000000; }

    if (!debug)
    {
      g.lineStyle(lineWidth, color, 1);
      g.beginFill(fillColor);
      i = 0;

      while (i != verts.length)
      {
        v = verts[i];
        x = v[0];
        y = v[1];

        if (i == 0)
        {
          g.moveTo(x, -y);
        }
        else
        {
          g.lineTo(x, -y);
        }

        i++;
      }

      g.endFill();

      if (verts.length > 2)
      {
        g.moveTo(verts[verts.length - 1][0], -verts[verts.length - 1][1]);
        return g.lineTo(verts[0][0], -verts[0][1]);
      }
    }
    else
    {
      colors = [0xff0000, 0x00ff00, 0x0000ff];
      i = 0;

      while (i != verts.length + 1)
      {
        v0 = verts[i % verts.length];
        v1 = verts[(i + 1) % verts.length];
        x0 = v0[0];
        y0 = v0[1];
        x1 = v1[0];
        y1 = v1[1];
        g.lineStyle(lineWidth, colors[i % colors.length], 1);
        g.moveTo(x0, -y0);
        g.lineTo(x1, -y1);
        g.drawCircle(x0, -y0, lineWidth * 2);
        i++;
      }

      g.lineStyle(lineWidth, 0x000000, 1);
      return g.drawCircle(offset[0], offset[1], lineWidth * 2);
    }

  }

  /**
   * Draws a P2 Path.
   *
   * @method Phaser.Physics.P2.BodyDebug#drawPath
   */
  drawPath(Phaser.Graphics g, path, color, fillColor, lineWidth) {

    var area, i, lastx, lasty, p1x, p1y, p2x, p2y, p3x, p3y, v, x, y;
    if ( lineWidth == null) { lineWidth = 1; }
    if ( color == null) { color = 0x000000; }

    g.lineStyle(lineWidth, color, 1);

    if ( fillColor is num)
    {
      g.beginFill(fillColor);
    }

    lastx = null;
    lasty = null;
    i = 0;

    while (i < path.length)
    {
      v = path[i];
      x = v[0];
      y = v[1];

      if (x != lastx || y != lasty)
      {
        if (i == 0)
        {
          g.moveTo(x, y);
        }
        else
        {
          p1x = lastx;
          p1y = lasty;
          p2x = x;
          p2y = y;
          p3x = path[(i + 1) % path.length][0];
          p3y = path[(i + 1) % path.length][1];
          area = ((p2x - p1x) * (p3y - p1y)) - ((p3x - p1x) * (p2y - p1y));

          if (area != 0)
          {
            g.lineTo(x, y);
          }
        }
        lastx = x;
        lasty = y;
      }

      i++;

    }

    if (fillColor is num)
    {
      g.endFill();
    }

    if (path.length > 2 && fillColor is num)
    {
      g.moveTo(path[path.length - 1][0], path[path.length - 1][1]);
      g.lineTo(path[0][0], path[0][1]);
    }

  }

  /**
   * Draws a P2 Plane shape.
   *
   * @method Phaser.Physics.P2.BodyDebug#drawPlane
   */
  drawPlane(g, x0, x1, color, lineColor, lineWidth, diagMargin, diagSize, maxLength, angle) {

    var max, xd, yd;
    if ( lineWidth == null) { lineWidth = 1; }
    if ( color == null) { color = 0xffffff; }

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

    var blue, green, mix, red;
    mix = [255, 255, 255];

    red = Math.floor(Math.random() * 256);
    green = Math.floor(Math.random() * 256);
    blue = Math.floor(Math.random() * 256);

    red = Math.floor((red + 3 * mix[0]) / 4);
    green = Math.floor((green + 3 * mix[1]) / 4);
    blue = Math.floor((blue + 3 * mix[2]) / 4);

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
  componentToHex(c) {

    var hex;
    hex = c.toString(16);

    if (hex.len == 2)
    {
      return hex;
    }
    else
    {
      return hex + '0';
    }

  }

}
