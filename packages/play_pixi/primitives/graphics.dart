part of PIXI;

class GraphicsData {
  List<num> points = [];
  num fillAlpha = 1;
  num fillColor = 0x0;

  bool fill;
  num lineWidth = 1;
  num lineAlpha = 1;
  num lineColor = 0x0;
  int type = Graphics.POLY;
}

class Graphics extends DisplayObjectContainer {
  static int POLY = 0;
  static int RECT = 1;
  static int CIRC = 2;
  static int ELIP = 3;

  num fillAlpha = 1;
  num fillColor = 0x0;
  bool filling = false;
  num lineWidth = 1;
  num lineAlpha = 1;
  num lineColor = 0x0;
  List<GraphicsData> graphicsData = [];

  int tint = 0xFFFFFF;
  blendModes blendMode;

  GraphicsData currentPath = new GraphicsData();

  Map _webGL = {};

  bool isMask = false;

  Rectangle bounds = null;

  int boundsPadding = 10;
  bool dirty = false;
  bool clearDirty = false;


  Graphics() {
    renderable = true;
    blendMode = blendModes.NORMAL;
  }


  set cacheAsBitmap(bool value) {
    if (this._cacheAsBitmap == value)return;

    if (value) {
      this._generateCachedSprite();
    }
    else {
      this._destroyCachedSprite();
    }

    this._cacheAsBitmap = value;
  }

  lineStyle([int lineWidth=0, num color=0, num alpha=1]) {
    if (this.currentPath.points.length == 0) {
      if (this.graphicsData.length > 0) {
        this.graphicsData.removeLast();
      }
    }

    this.lineWidth = lineWidth;
    this.lineColor = color;
    this.lineAlpha = alpha;

    this.currentPath = new GraphicsData()
      ..lineWidth = this.lineWidth
      ..lineColor = this.lineColor
      ..lineAlpha = this.lineAlpha
      ..fillColor = this.fillColor
      ..fillAlpha = this.fillAlpha
      ..fill = this.filling
      ..points = []
      ..type = POLY;

    this.graphicsData.add(this.currentPath);

    return this;
  }

  moveTo(num x, num y) {
    if (this.currentPath.points.length == 0) {
      if (this.graphicsData.length > 0) {
        this.graphicsData.removeLast();
      }
    }

    this.currentPath = new GraphicsData()
      ..lineWidth = this.lineWidth
      ..lineColor = this.lineColor
      ..lineAlpha = this.lineAlpha
      ..fillColor = this.fillColor
      ..fillAlpha = this.fillAlpha
      ..fill = this.filling
      ..points = []
      ..type = POLY;

    this.currentPath.points.addAll([x, y]);

    this.graphicsData.add(this.currentPath);

    return this;
  }

  lineTo(x, y) {
    this.currentPath.points.addAll([x, y]);
    this.dirty = true;

    return this;
  }

  beginFill([num color, num alpha=1]) {

    this.filling = true;
    this.fillColor = color;
    this.fillAlpha = alpha;

    return this;
  }

  endFill() {
    this.filling = false;
    this.fillColor = null;
    this.fillAlpha = 1;

    return this;
  }

  drawRect(x, y, width, height) {
    if (this.currentPath.points.length == 0) {
      if (this.graphicsData.length > 0) {
        this.graphicsData.removeLast();
      }
    }

    this.currentPath = new GraphicsData()
      ..lineWidth = this.lineWidth
      ..lineColor = this.lineColor
      ..lineAlpha = this.lineAlpha
      ..fillColor = this.fillColor
      ..fillAlpha = this.fillAlpha
      ..fill = this.filling
      ..points = [x, y, width, height]
      ..type = RECT;


    this.graphicsData.add(this.currentPath);
    this.dirty = true;

    return this;
  }

  drawCircle(x, y, radius) {
    if (this.currentPath.points.length == 0) {
      if (this.graphicsData.length > 0) {
        this.graphicsData.removeLast();
      }
    }

    this.currentPath = new GraphicsData()
      ..lineWidth = this.lineWidth
      ..lineColor = this.lineColor
      ..lineAlpha = this.lineAlpha
      ..fillColor = this.fillColor
      ..fillAlpha = this.fillAlpha
      ..fill = this.filling
      ..points = [x, y, radius, radius]
      ..type = CIRC;

    this.graphicsData.add(this.currentPath);
    this.dirty = true;

    return this;
  }

  drawEllipse(x, y, width, height) {
    if (this.currentPath.points.length == 0) {
      if (this.graphicsData.length > 0) {
        this.graphicsData.removeLast();
      }
    }

    this.currentPath = new GraphicsData()
      ..lineWidth = this.lineWidth
      ..lineColor = this.lineColor
      ..lineAlpha = this.lineAlpha
      ..fillColor = this.fillColor
      ..fillAlpha = this.fillAlpha
      ..fill = this.filling
      ..points = [x, y, width, height]
      ..type = ELIP;


    this.graphicsData.add(this.currentPath);
    this.dirty = true;

    return this;
  }

  clear() {
    this.lineWidth = 0;
    this.filling = false;

    this.dirty = true;
    this.clearDirty = true;
    this.graphicsData = [];

    this.bounds = null; //new PIXI.Rectangle();

    return this;
  }

  RenderTexture generateTexture([Renderer renderer]) {
    Rectangle bounds = this.getBounds();

    CanvasBuffer canvasBuffer = new CanvasBuffer(bounds.width, bounds.height);
    Texture texture = Texture.fromCanvas(canvasBuffer.canvas);

    canvasBuffer.context.translate(-bounds.x, -bounds.y);

    CanvasGraphics.renderGraphics(this, canvasBuffer.context);

    return texture;
  }

  void _renderWebGL(RenderSession renderSession) {
    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (this.visible == false || this.alpha == 0 || this.isMask == true)return;

    if (this._cacheAsBitmap) {

      if (this.dirty) {
        this._generateCachedSprite();
        // we will also need to update the texture on the gpu too!
        updateWebGLTexture(this._cachedSprite.texture.baseTexture, renderSession.gl);

        this.dirty = false;
      }

      this._cachedSprite.alpha = this.alpha;
      _cachedSprite._renderWebGL(renderSession);

      return;
    }
    else {
      renderSession.spriteBatch.stop();

      if (this._mask != null)renderSession.maskManager.pushMask(this.mask, renderSession);
      if (this._filters != null)renderSession.filterManager.pushFilter(this._filterBlock);

      // check blend mode
      if (this.blendMode != renderSession.spriteBatch.currentBlendMode) {
        renderSession.spriteBatch.currentBlendMode = this.blendMode;
        var blendModeWebGL = blendModesWebGL[renderSession.spriteBatch.currentBlendMode];
        renderSession.spriteBatch.gl.blendFunc(blendModeWebGL[0], blendModeWebGL[1]);
      }

      WebGLGraphics.renderGraphics(this, renderSession);

      // only render if it has children!
      if (this.children.length != 0) {
        renderSession.spriteBatch.start();

        // simple render children!
        for (var i = 0, j = this.children.length; i < j; i++) {
          this.children[i]._renderWebGL(renderSession);
        }

        renderSession.spriteBatch.stop();
      }

      if (this._filters != null)renderSession.filterManager.popFilter();
      if (this._mask != null)renderSession.maskManager.popMask(renderSession);

      renderSession.drawCount++;

      renderSession.spriteBatch.start();
    }
  }

  void _renderCanvas(RenderSession renderSession) {
    //print("here");
    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (this.visible == false || this.alpha == 0 || this.isMask == true)return;

    var context = renderSession.context;
    var transform = this.worldTransform;

    if (this.blendMode != renderSession.currentBlendMode) {
      renderSession.currentBlendMode = this.blendMode;
      context.globalCompositeOperation = blendModesCanvas[renderSession.currentBlendMode];
    }

    context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
    CanvasGraphics.renderGraphics(this, context);

    // simple render children!
    for (int i = 0, j = this.children.length; i < j; i++) {
      this.children[i]._renderCanvas(renderSession);
    }
  }


  Rectangle getBounds([Matrix matrix]) {
    if(matrix == null){
      matrix= this.worldTransform;
    }

    if (this.bounds == null)this.updateBounds();

    var w0 = this.bounds.x;
    var w1 = this.bounds.width + this.bounds.x;

    var h0 = this.bounds.y;
    var h1 = this.bounds.height + this.bounds.y;

    var worldTransform = matrix;

    var a = worldTransform.a;
    var b = worldTransform.c;
    var c = worldTransform.b;
    var d = worldTransform.d;
    var tx = worldTransform.tx;
    var ty = worldTransform.ty;

    var x1 = a * w1 + c * h1 + tx;
    var y1 = d * h1 + b * w1 + ty;

    var x2 = a * w0 + c * h1 + tx;
    var y2 = d * h1 + b * w0 + ty;

    var x3 = a * w0 + c * h0 + tx;
    var y3 = d * h0 + b * w0 + ty;

    var x4 = a * w1 + c * h0 + tx;
    var y4 = d * h0 + b * w1 + ty;

    var maxX = x1;
    var maxY = y1;

    var minX = x1;
    var minY = y1;

    minX = x2 < minX ? x2 : minX;
    minX = x3 < minX ? x3 : minX;
    minX = x4 < minX ? x4 : minX;

    minY = y2 < minY ? y2 : minY;
    minY = y3 < minY ? y3 : minY;
    minY = y4 < minY ? y4 : minY;

    maxX = x2 > maxX ? x2 : maxX;
    maxX = x3 > maxX ? x3 : maxX;
    maxX = x4 > maxX ? x4 : maxX;

    maxY = y2 > maxY ? y2 : maxY;
    maxY = y3 > maxY ? y3 : maxY;
    maxY = y4 > maxY ? y4 : maxY;

    var bounds = this._bounds;

    bounds.x = minX;
    bounds.width = maxX - minX;

    bounds.y = minY;
    bounds.height = maxY - minY;

    return bounds;
  }

  updateBounds() {

    var minX = double.INFINITY ;
    var maxX = -double.INFINITY;

    var minY = double.INFINITY;
    var maxY = -double.INFINITY;

    var points, x, y, w, h;

    for (var i = 0; i < this.graphicsData.length; i++) {
      var data = this.graphicsData[i];
      var type = data.type;
      var lineWidth = data.lineWidth;

      points = data.points;

      if (type == Graphics.RECT) {
        x = points[0] - lineWidth / 2;
        y = points[1] - lineWidth / 2;
        w = points[2] + lineWidth;
        h = points[3] + lineWidth;

        minX = x < minX ? x : minX;
        maxX = x + w > maxX ? x + w : maxX;

        minY = y < minY ? x : minY;
        maxY = y + h > maxY ? y + h : maxY;
      }
      else if (type == Graphics.CIRC || type == ELIP) {
        x = points[0];
        y = points[1];
        w = points[2] + lineWidth / 2;
        h = points[3] + lineWidth / 2;

        minX = x - w < minX ? x - w : minX;
        maxX = x + w > maxX ? x + w : maxX;

        minY = y - h < minY ? y - h : minY;
        maxY = y + h > maxY ? y + h : maxY;
      }
      else {
        // POLY
        for (var j = 0; j < points.length; j += 2) {

          x = points[j];
          y = points[j + 1];
          minX = x - lineWidth < minX ? x - lineWidth : minX;
          maxX = x + lineWidth > maxX ? x + lineWidth : maxX;

          minY = y - lineWidth < minY ? y - lineWidth : minY;
          maxY = y + lineWidth > maxY ? y + lineWidth : maxY;
        }
      }
    }

    var padding = this.boundsPadding;
    this.bounds = new Rectangle(minX - padding, minY - padding, (maxX - minX) + padding * 2, (maxY - minY) + padding * 2);
  }

  _generateCachedSprite() {
    var bounds = this.getLocalBounds();

    if (this._cachedSprite == null) {
      var canvasBuffer = new CanvasBuffer(bounds.width, bounds.height);
      var texture = Texture.fromCanvas(canvasBuffer.canvas);

      this._cachedSprite = new Sprite(texture);
      this._cachedSprite.buffer = canvasBuffer;

      this._cachedSprite.worldTransform = this.worldTransform;
    }
    else {
      this._cachedSprite.buffer.resize(bounds.width, bounds.height);
    }

    // leverage the anchor to account for the offset of the element
    this._cachedSprite.anchor.x = -( bounds.x / bounds.width );
    this._cachedSprite.anchor.y = -( bounds.y / bounds.height );

    // this._cachedSprite.buffer.context.save();
    this._cachedSprite.buffer.context.translate(-bounds.x, -bounds.y);

    CanvasGraphics.renderGraphics(this, this._cachedSprite.buffer.context);
    this._cachedSprite.alpha = this.alpha;

    // this._cachedSprite.buffer.context.restore();
  }

  destroyCachedSprite() {
    this._cachedSprite.texture.destroy(true);

    // let the gc collect the unused sprite
    // TODO could be object pooled!
    this._cachedSprite = null;
  }


}
