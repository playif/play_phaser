part of PIXI;

abstract class Shader {

  UniformLocation uSampler;
  UniformLocation projectionVector;
  UniformLocation offsetVector;
  UniformLocation dimensions;
  UniformLocation uMatrix;

  int aVertexPosition;
  int aPositionCoord;
  int aScale;
  int aRotation;
  int aTextureCoord;
  int colorAttribute;

  List attributes;


  init();
  destroy();
}
