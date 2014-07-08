part of PIXI;

class FilterTexture {
  RenderingContext gl;
  Framebuffer frameBuffer;
  Renderbuffer renderBuffer;
  var texture;
  int width, height;

  FilterTexture(this.gl, int width, int height, [scaleMode =scaleModes.DEFAULT]) {
    this.frameBuffer = gl.createFramebuffer();
    this.texture = gl.createTexture();

    gl.bindTexture(TEXTURE_2D, this.texture);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, scaleMode == scaleModes.LINEAR ? LINEAR : NEAREST);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, scaleMode == scaleModes.LINEAR ? LINEAR : NEAREST);
    gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE);
    gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
    gl.bindFramebuffer(FRAMEBUFFER, this.frameBuffer);

    //this.frameBuffer.width=width;

    //gl.bindFramebuffer(FRAMEBUFFER, this.frameBuffer);

    gl.framebufferTexture2D(FRAMEBUFFER, COLOR_ATTACHMENT0, TEXTURE_2D, this.texture, 0);


    // required for masking a mask??
    this.renderBuffer = gl.createRenderbuffer();
    gl.bindRenderbuffer(RENDERBUFFER, this.renderBuffer);
    gl.framebufferRenderbuffer(FRAMEBUFFER, DEPTH_STENCIL_ATTACHMENT, RENDERBUFFER, this.renderBuffer);

    this.resize(width, height);
  }

  clear() {
    var gl = this.gl;

    gl.clearColor(0, 0, 0, 0);

    gl.clear(COLOR_BUFFER_BIT);
  }

  resize(int width, int height) {
    if (this.width == width && this.height == height) return;

    this.width = width;
    this.height = height;

    var gl = this.gl;

    gl.bindTexture(TEXTURE_2D, this.texture);

    ImageElement image=new ImageElement();
    //int border=0;
    gl.texImage2D(TEXTURE_2D, 0, RGBA, width, height, 0, RGBA, UNSIGNED_BYTE, null);

    // update the stencil buffer width and height
    gl.bindRenderbuffer(RENDERBUFFER, this.renderBuffer);

    gl.renderbufferStorage(RENDERBUFFER, DEPTH_STENCIL, width, height);

    //print(gl.checkFramebufferStatus(FRAMEBUFFER));
  }

  destroy() {
    var gl = this.gl;
    gl.deleteFramebuffer(this.frameBuffer);
    gl.deleteTexture(this.texture);

    this.frameBuffer = null;
    this.texture = null;
  }
}
