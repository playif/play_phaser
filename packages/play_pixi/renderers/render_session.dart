part of PIXI;

class RenderSession {

//  RenderingContext glID;
  RenderingContext gl;
  Point projection;
  Point offset;
  int drawCount = 0;
  WebGLShaderManager shaderManager;
  MaskManager maskManager;
  WebGLFilterManager filterManager;
  WebGLSpriteBatch spriteBatch;
  Renderer renderer;

  blendModes currentBlendMode;
  scaleModes scaleMode;
  //String smoothProperty;

  CanvasRenderingContext2D context;

  var roundPixels = null;
}
