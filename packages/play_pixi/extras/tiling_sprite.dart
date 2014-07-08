part of PIXI;

class TilingSprite extends Sprite {
  num _width, _height;
  Point tileScale;
  Point tilePosition;
  CanvasPattern __tilePattern = null;

  Texture tilingTexture;
  bool refreshTexture = false;

  Point tileScaleOffset = new Point();

  TilingSprite(Texture texture, [num width=100, num height=100]):super(texture) {
    this.width = width;
    this.height = height;

    texture.baseTexture._powerOf2 = true;
    tileScale = new Point(1, 1);
    tilePosition = new Point(0, 0);


    this.renderable = true;
    this.tint = 0xFFFFFF;
    this.blendMode = blendModes.NORMAL;
  }

  num get width => this._width;

  set width(value) {
    this._width = value;
  }

  num get height => this._height;

  set height(value) {
    this._height = value;
  }

  onTextureUpdate(e) {
    // so if _width is 0 then width was not set..
    //if(this._width)this.scale.x = this._width / this.texture.frame.width;
    //if(this._height)this.scale.y = this._height / this.texture.frame.height;
    // alert(this._width)
    this.updateFrame = true;
  }

  _renderWebGL(RenderSession renderSession) {

    if (this.visible == false || this.alpha == 0)return;

    int i, j;

    if (this.mask != null) {
      renderSession.spriteBatch.stop();
      renderSession.maskManager.pushMask(this.mask, renderSession);
      renderSession.spriteBatch.start();
    }

    if (this.filters != null) {
      renderSession.spriteBatch.flush();
      renderSession.filterManager.pushFilter(this._filterBlock);
    }


    if (this.tilingTexture == null || this.refreshTexture) {

      this.generateTilingTexture(true);
      if (this.tilingTexture != null && this.tilingTexture.needsUpdate) {
        //TODO - tweaking

        updateWebGLTexture(this.tilingTexture.baseTexture, renderSession.gl);
        this.tilingTexture.needsUpdate = false;
        // this.tilingTexture._uvs = null;
      }
    }
    else renderSession.spriteBatch.renderTilingSprite(this);


    // simple render children!
    for (int i = 0, j = this.children.length; i < j; i++) {
      this.children[i]._renderWebGL(renderSession);
    }

    renderSession.spriteBatch.stop();

    if (this.filters != null)renderSession.filterManager.popFilter();
    if (this.mask != null)renderSession.maskManager.popMask(renderSession);

    renderSession.spriteBatch.start();
  }

  _renderCanvas(renderSession) {
    if (this.visible == false || this.alpha == 0)return;

    CanvasRenderingContext2D context = renderSession.context;

    if (this._mask != null) {
      renderSession.maskManager.pushMask(this._mask, context);
    }

    context.globalAlpha = this.worldAlpha;


    var transform = this.worldTransform;

    // allow for trimming
//(this.anchor.x) * -frame.width,
//                               (this.anchor.y) * -frame.height,


    context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);


    if (this.__tilePattern == null || this.refreshTexture) {
      this.generateTilingTexture(false);

      if (this.tilingTexture != null) {
        var source = this.tilingTexture.baseTexture.source;

        if (source is CanvasElement) {
          this.__tilePattern = context.createPattern(this.tilingTexture.baseTexture.source as CanvasElement, 'repeat');
        }
        else if (source is ImageElement) {
          this.__tilePattern = context.createPatternFromImage(this.tilingTexture.baseTexture.source, 'repeat');
        }
        else {
          throw new Exception("null source");
        }
      }
      else {
        return;
      }
    }

    // check blend mode
    if (this.blendMode != renderSession.currentBlendMode) {
      renderSession.currentBlendMode = this.blendMode;
      context.globalCompositeOperation = blendModesCanvas[renderSession.currentBlendMode];
    }

    context.beginPath();

    Point tilePosition = this.tilePosition;
    Point tileScale = this.tileScale;

    tilePosition.x %= this.tilingTexture.baseTexture.width;
    tilePosition.y %= this.tilingTexture.baseTexture.height;

    // offset
    context.scale(tileScale.x, tileScale.y);
    context.translate(tilePosition.x, tilePosition.y);

    context.fillStyle = this.__tilePattern;

    // make sure to account for the anchor point..
    context.fillRect(-tilePosition.x + (this.anchor.x * -this._width), -tilePosition.y + (this.anchor.y * -this._height),
    this._width / tileScale.x, this._height / tileScale.y);

    context.scale(1 / tileScale.x, 1 / tileScale.y);
    context.translate(-tilePosition.x, -tilePosition.y);

    context.closePath();

    if (this._mask != null) {
      renderSession.maskManager.popMask(renderSession.context);
    }
  }


  Rectangle getBounds([Matrix matrix]) {

    var width = this._width;
    var height = this._height;

    var w0 = width * (1 - this.anchor.x);
    var w1 = width * -this.anchor.x;

    var h0 = height * (1 - this.anchor.y);
    var h1 = height * -this.anchor.y;

    var worldTransform = this.worldTransform;

    var a = worldTransform[0];
    var b = worldTransform[3];
    var c = worldTransform[1];
    var d = worldTransform[4];
    var tx = worldTransform[2];
    var ty = worldTransform[5];

    var x1 = a * w1 + c * h1 + tx;
    var y1 = d * h1 + b * w1 + ty;

    var x2 = a * w0 + c * h1 + tx;
    var y2 = d * h1 + b * w0 + ty;

    var x3 = a * w0 + c * h0 + tx;
    var y3 = d * h0 + b * w0 + ty;

    var x4 = a * w1 + c * h0 + tx;
    var y4 = d * h0 + b * w1 + ty;

    var maxX = double.NEGATIVE_INFINITY;
    var maxY = double.NEGATIVE_INFINITY;

    var minX = double.INFINITY;
    var minY = double.INFINITY;

    minX = x1 < minX ? x1 : minX;
    minX = x2 < minX ? x2 : minX;
    minX = x3 < minX ? x3 : minX;
    minX = x4 < minX ? x4 : minX;

    minY = y1 < minY ? y1 : minY;
    minY = y2 < minY ? y2 : minY;
    minY = y3 < minY ? y3 : minY;
    minY = y4 < minY ? y4 : minY;

    maxX = x1 > maxX ? x1 : maxX;
    maxX = x2 > maxX ? x2 : maxX;
    maxX = x3 > maxX ? x3 : maxX;
    maxX = x4 > maxX ? x4 : maxX;

    maxY = y1 > maxY ? y1 : maxY;
    maxY = y2 > maxY ? y2 : maxY;
    maxY = y3 > maxY ? y3 : maxY;
    maxY = y4 > maxY ? y4 : maxY;

    var bounds = this._bounds;

    bounds.x = minX;
    bounds.width = maxX - minX;

    bounds.y = minY;
    bounds.height = maxY - minY;

    // store a refferance so that if this function gets called again in the render cycle we do not have to recacalculate
    this._currentBounds = bounds;

    return bounds;
  }


  generateTilingTexture(bool forcePowerOfTwo) {

    Texture texture = this.texture;

    if (!texture.baseTexture.hasLoaded) return;

    Texture baseTexture = texture.baseTexture;
    Rectangle frame = texture.frame;

    num targetWidth, targetHeight;

    // check that the frame is the same size as the base texture.
    var isFrame = frame.width != baseTexture.width || frame.height != baseTexture.height;

    bool newTextureRequired = false;

    if (!forcePowerOfTwo) {
      if (isFrame) {
        targetWidth = frame.width;
        targetHeight = frame.height;

        newTextureRequired = true;

      }
    }
    else {
      targetWidth = getNextPowerOfTwo(frame.width);
      targetHeight = getNextPowerOfTwo(frame.height);
      if (frame.width != targetWidth && frame.height != targetHeight)newTextureRequired = true;
    }


    if (newTextureRequired) {

      CanvasBuffer canvasBuffer;

      if (this.tilingTexture != null && this.tilingTexture.isTiling) {
        canvasBuffer = this.tilingTexture.canvasBuffer;
        canvasBuffer.resize(targetWidth, targetHeight);
        this.tilingTexture.baseTexture.width = targetWidth;
        this.tilingTexture.baseTexture.height = targetHeight;
        this.tilingTexture.needsUpdate = true;
      }
      else {
        canvasBuffer = new CanvasBuffer(targetWidth, targetHeight);

        this.tilingTexture = Texture.fromCanvas(canvasBuffer.canvas);
        this.tilingTexture.canvasBuffer = canvasBuffer;
        this.tilingTexture.isTiling = true;

      }

      canvasBuffer.context.drawImageScaledFromSource(texture.baseTexture.source,
      frame.x,
      frame.y,
      frame.width,
      frame.height,
      0,
      0,
      targetWidth,
      targetHeight);

      this.tileScaleOffset.x = frame.width / targetWidth;
      this.tileScaleOffset.y = frame.height / targetHeight;

    }
    else {
      //TODO - switching?
      if (this.tilingTexture != null && this.tilingTexture.isTiling) {
        // destroy the tiling texture!
        // TODO could store this somewhere?
        this.tilingTexture.destroy(true);
      }

      this.tileScaleOffset.x = 1;
      this.tileScaleOffset.y = 1;
      this.tilingTexture = texture;
    }
    this.refreshTexture = false;
    this.tilingTexture.baseTexture._powerOf2 = true;
  }
}
