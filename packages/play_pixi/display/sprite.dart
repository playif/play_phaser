part of PIXI;

class Sprite extends DisplayObjectContainer {
  Point anchor = new Point();
  Texture texture;
  bool updateFrame = false;
  bool textureChange = false;
  num _width = 0, _height = 0;
  TextureUvs _uvs = null;
  CanvasImageSource tintedTexture;
  CanvasBuffer buffer = null;

  num get width => scale.x * texture.frame.width;

  set width(num value) {
    this.scale.x = value / this.texture.frame.width;
    this._width = value;
  }

  num get height => scale.y * texture.frame.height;

  set height(num value) {
    this.scale.y = value / this.texture.frame.height;
    this._height = value;
  }

  int tint = 0xFFFFFF;
  int cachedTint;

//  bool renderable = true;

  blendModes blendMode = blendModes.NORMAL;


  Sprite._(){
    renderable = true;
  }

  Sprite(this.texture) {
    _setupTexture();
  }

  void _setupTexture() {
    if (texture.baseTexture.hasLoaded) {
      this.onTextureUpdate(null);
    }
    else {
      this.texture.addEventListener('update', this.onTextureUpdate);
    }
  }

  void setTexture(Texture texture) {
    // stop current texture;
    if (this.texture.baseTexture != texture.baseTexture) {
      this.textureChange = true;
      this.texture = texture;
    }
    else {
      this.texture = texture;
    }

    this.cachedTint = 0xFFFFFF;
    this.updateFrame = true;
  }

  onTextureUpdate(PixiEvent e) {
    //print('update');
    // so if _width is 0 then width was not set..
    if (this._width != 0) this.scale.x = this._width / this.texture.frame.width;
    if (this._height != 0) this.scale.y = this._height / this.texture.frame.height;


    this.updateFrame = true;
  }

  Rectangle getBounds([Matrix matrix]) {

    num width = this.texture.frame.width;
    num height = this.texture.frame.height;

    num w0 = width * (1 - this.anchor.x);
    num w1 = width * -this.anchor.x;

    num h0 = height * (1 - this.anchor.y);
    num h1 = height * -this.anchor.y;

    Matrix worldTransform = (matrix == null) ? this.worldTransform : matrix ;

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

    // store a reference so that if this function gets called again in the render cycle we do not have to recalculate
    this._currentBounds = bounds;

    return bounds;
  }


  void _renderWebGL(RenderSession renderSession) {

    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (!this.visible || this.alpha <= 0)return;

    int i, j;

    // do a quick check to see if this element has a mask or a filter.
    if (this._mask != null || this._filters != null) {
      WebGLSpriteBatch spriteBatch = renderSession.spriteBatch;

      if (this._mask != null) {
        spriteBatch.stop();
        renderSession.maskManager.pushMask(this.mask, renderSession);
        spriteBatch.start();
      }


      if (this._filters != null) {
        print("cool");
        spriteBatch.flush();
        renderSession.filterManager.pushFilter(this._filterBlock);
      }

      // add this sprite to the batch
      spriteBatch.render(this);

      // now loop through the children and make sure they get rendered
      for (int i = 0, j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }

      // time to stop the sprite batch as either a mask element or a filter draw will happen next
      spriteBatch.stop();

      if (this._filters != null)renderSession.filterManager.popFilter();
      if (this._mask != null)renderSession.maskManager.popMask(renderSession);

      spriteBatch.start();
    }
    else {
      renderSession.spriteBatch.render(this);

      // simple render children!
      for (int i = 0, j = this.children.length; i < j; i++) {
        this.children[i]._renderWebGL(renderSession);
      }
    }


    //TODO check culling
  }


  void _renderCanvas(RenderSession renderSession) {
    // if the sprite is not visible or the alpha is 0 then no need to render this element
    if (this.visible == false || this.alpha == 0)return;


    Rectangle frame = this.texture.frame;
    CanvasRenderingContext2D context = renderSession.context;
    Texture texture = this.texture;

    if (this.blendMode != renderSession.currentBlendMode) {
      renderSession.currentBlendMode = this.blendMode;
      context.globalCompositeOperation = blendModesCanvas[renderSession.currentBlendMode];
    }

    if (this._mask != null) {
      renderSession.maskManager.pushMask(this._mask, renderSession.context);
    }


    //ignore null sources
    if (frame != null && frame.width != 0 && frame.height != 0 && texture.baseTexture.source != null) {
      context.globalAlpha = this.worldAlpha;

      Matrix transform = this.worldTransform;

      // allow for trimming
      if (renderSession.roundPixels != null) {
        context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx.floor(), transform.ty.floor());
      }
      else {
        context.setTransform(transform.a, transform.c, transform.b, transform.d, transform.tx, transform.ty);
      }


      //if smoothingEnabled is supported and we need to change the smoothing property for this texture
      if (renderSession.scaleMode != this.texture.baseTexture.scaleMode) {
        renderSession.scaleMode = this.texture.baseTexture.scaleMode;
        context.imageSmoothingEnabled = (renderSession.scaleMode == scaleModes.LINEAR);
      }

      if (this.tint != 0xFFFFFF) {

        if (this.cachedTint != this.tint) {
          // no point tinting an image that has not loaded yet!
          if (!texture.baseTexture.hasLoaded)return;

          this.cachedTint = this.tint;

          //TODO clean up caching - how to clean up the caches?
          this.tintedTexture = CanvasTinter.getTintedTexture(this, this.tint);

        }

        context.drawImageScaledFromSource(this.tintedTexture,
        0,
        0,
        frame.width,
        frame.height,
        (this.anchor.x) * -frame.width,
        (this.anchor.y) * -frame.height,
        frame.width,
        frame.height);
      }
      else {


        if (texture.trim != null) {
          Rectangle trim = texture.trim;

          context.drawImageScaledFromSource(this.texture.baseTexture.source,
          frame.x,
          frame.y,
          frame.width,
          frame.height,
          trim.x - this.anchor.x * trim.width,
          trim.y - this.anchor.y * trim.height,
          frame.width,
          frame.height);
        }
        else {
          //window.console.log(this.texture.baseTexture.source);
          context.drawImageScaledFromSource(this.texture.baseTexture.source,
          frame.x,
          frame.y,
          frame.width,
          frame.height,
          (this.anchor.x) * -frame.width,
          (this.anchor.y) * -frame.height,
          frame.width,
          frame.height);
        }

      }
    }

    // OVERWRITE
    for (int i = 0, j = this.children.length; i < j; i++) {
      DisplayObject child = this.children[i];
      child._renderCanvas(renderSession);
    }

    if (this._mask != null) {
      renderSession.maskManager.popMask(renderSession.context);
    }
  }


  static Sprite fromFrame(String frameId) {
    var texture = TextureCache[frameId];
    if (texture == null) throw new Exception('The frameId "$frameId" does not exist in the texture cache.');
    return new Sprite(texture);
  }

  static Sprite fromImage(String imageId, [bool crossorigin, scaleModes scaleMode]) {
    var texture = Texture.fromImage(imageId, crossorigin, scaleMode);
    return new Sprite(texture);
  }

}
