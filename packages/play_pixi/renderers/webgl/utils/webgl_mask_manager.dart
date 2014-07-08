part of PIXI;

class WebGLMaskManager extends MaskManager {
  List maskStack = [];
  int maskPosition = 0;
  RenderingContext gl;

  WebGLMaskManager(gl) {
    this.setContext(gl);
  }

  setContext(gl) {
    this.gl = gl;
  }

  pushMask(maskData, [renderSession]) {
    var gl = this.gl;

    if (this.maskStack.length == 0) {
      gl.enable(STENCIL_TEST);
      gl.stencilFunc(ALWAYS, 1, 1);
    }

    //  maskData.visible = false;

    this.maskStack.add(maskData);

    gl.colorMask(false, false, false, false);
    gl.stencilOp(KEEP, KEEP, INCR);

    WebGLGraphics.renderGraphics(maskData, renderSession);

    gl.colorMask(true, true, true, true);
    gl.stencilFunc(NOTEQUAL, 0, this.maskStack.length);
    gl.stencilOp(KEEP, KEEP, KEEP);
  }


  popMask(RenderSession renderSession) {
    var gl = this.gl;

    var maskData = this.maskStack.removeLast();

    if (maskData != null) {
      gl.colorMask(false, false, false, false);

      //gl.stencilFunc(gl.ALWAYS,1,1);
      gl.stencilOp(KEEP, KEEP, DECR);

      WebGLGraphics.renderGraphics(maskData, renderSession);

      gl.colorMask(true, true, true, true);
      gl.stencilFunc(NOTEQUAL, 0, this.maskStack.length);
      gl.stencilOp(KEEP, KEEP, KEEP);
    }

    if (this.maskStack.length == 0)gl.disable(STENCIL_TEST);
  }

  destroy() {
    this.maskStack = null;
    this.gl = null;
  }
}
