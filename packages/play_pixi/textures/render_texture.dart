part of PIXI;

typedef void Render(DisplayObject displayObject, Point position, [bool clear]);

class RenderTexture extends Texture {
  Renderer renderer;
  num width, height;
  Rectangle frame;
  scaleModes scaleMode;

  BaseTexture baseTexture = new BaseTexture();

  var textureBuffer;
  Point projection;

  Render render;

  static Matrix tempMatrix = new Matrix();

  RenderTexture([num this.width=100, num this.height=100, this.renderer, scaleModes this.scaleMode=scaleModes.DEFAULT]):super._() {
    if (renderer == null) {
      renderer = defaultRenderer;
    }
    frame = new Rectangle(0, 0, this.width, this.height);
    baseTexture.width = width;
    baseTexture.height = height;
    baseTexture.scaleMode = scaleMode;
    baseTexture.hasLoaded = true;
    //print(this.renderer.type);
    if (this.renderer.type == WEBGL_RENDERER) {
      var gl = this.renderer.gl;

      this.textureBuffer = new FilterTexture(gl, this.width, this.height, this.baseTexture.scaleMode);
      this.baseTexture._glTextures[gl] = this.textureBuffer.texture;

      this.render = this.renderWebGL;
      this.projection = new Point(this.width / 2, -this.height / 2);
    }
    else {
      this.render = this.renderCanvas;
      this.textureBuffer = new CanvasBuffer(this.width, this.height);
      this.baseTexture.source = this.textureBuffer.canvas;
    }

    Texture.frameUpdates.add(this);


  }

  resize(num width, num height) {
    this.width = width;
    this.height = height;

    this.frame.width = this.width;
    this.frame.height = this.height;

    if (this.renderer.type == WEBGL_RENDERER) {
      this.projection.x = this.width / 2;
      this.projection.y = -this.height / 2;

      var gl = this.renderer.gl;
      gl.bindTexture(TEXTURE_2D, this.baseTexture._glTextures[gl]);
      gl.texImage2D(TEXTURE_2D, 0, RGBA, this.width, this.height, 0, RGBA, UNSIGNED_BYTE, null);
    }
    else {
      this.textureBuffer.resize(this.width, this.height);
    }

    Texture.frameUpdates.add(this);
  }

  renderWebGL(DisplayObjectContainer displayObject, Point position, bool clear) {
    //TOOD replace position with matrix..
    var gl = this.renderer.gl;

    gl.colorMask(true, true, true, true);

    gl.viewport(0, 0, this.width, this.height);

    gl.bindFramebuffer(FRAMEBUFFER, this.textureBuffer.frameBuffer);

    if (clear) this.textureBuffer.clear();

    // THIS WILL MESS WITH HIT TESTING!
    var children = displayObject.children;

    //TODO -? create a new one??? dont think so!
    var originalWorldTransform = displayObject.worldTransform;
    displayObject.worldTransform = RenderTexture.tempMatrix;
    // modify to flip...
    displayObject.worldTransform.d = -1;
    displayObject.worldTransform.ty = this.projection.y * -2;

    if (position != null) {
      displayObject.worldTransform.tx = position.x;
      displayObject.worldTransform.ty -= position.y;
    }

    for (int i = 0, j = children.length; i < j; i++) {
      children[i].updateTransform();
    }

    // update the textures!
    WebGLRenderer.updateTextures(gl);

    //
    this.renderer.renderDisplayObject(displayObject, this.projection, this.textureBuffer.frameBuffer);

    displayObject.worldTransform = originalWorldTransform;
  }

  void renderCanvas(DisplayObjectContainer displayObject, Point position, bool clear) {
    var children = displayObject.children;

    var originalWorldTransform = displayObject.worldTransform;

    displayObject.worldTransform = RenderTexture.tempMatrix;

    if (position != null) {
      displayObject.worldTransform.tx = position.x;
      displayObject.worldTransform.ty = position.y;
    }

    for (var i = 0, j = children.length; i < j; i++) {
      children[i].updateTransform();
    }

    if (clear)this.textureBuffer.clear();

    var context = this.textureBuffer.context;

    this.renderer.renderDisplayObject(displayObject, context);

    context.setTransform(1, 0, 0, 1, 0, 0);

    displayObject.worldTransform = originalWorldTransform;
  }

}
