part of PIXI;

class StripShader extends Shader {
  StripShader(this.gl) {
  }

  Program program = null;
  RenderingContext gl;
  List<String> fragmentSrc = [
      'precision mediump float;',
      'varying vec2 vTextureCoord;',
      'varying float vColor;',
      'uniform float alpha;',
      'uniform sampler2D uSampler;',

      'void main(void) {',
      '   gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.x, vTextureCoord.y));',
      '   gl_FragColor = gl_FragColor * alpha;',
      '}'
  ];

  List<String> vertexSrc = [
      'attribute vec2 aVertexPosition;',
      'attribute vec2 aTextureCoord;',
      'attribute float aColor;',
      'uniform mat3 translationMatrix;',
      'uniform vec2 projectionVector;',
      'varying vec2 vTextureCoord;',
      'uniform vec2 offsetVector;',
      'varying float vColor;',

      'void main(void) {',
      '   vec3 v = translationMatrix * vec3(aVertexPosition, 1.0);',
      '   v -= offsetVector.xyx;',
      '   gl_Position = vec4( v.x / projectionVector.x -1.0, v.y / projectionVector.y + 1.0 , 0.0, 1.0);',
      '   vTextureCoord = aTextureCoord;',
      '   vColor = aColor;',
      '}'
  ];

  UniformLocation uSampler;
  UniformLocation projectionVector;
  UniformLocation offsetVector;
  UniformLocation dimensions;
  UniformLocation uMatrix;
  UniformLocation translationMatrix;
  UniformLocation alpha;

  int aVertexPosition;
  int aPositionCoord;
  int aScale;
  int aRotation;
  int aTextureCoord;
  int colorAttribute;

  List attributes;

  init ()
  {

    //var gl = gl;

    Program program = compileProgram(gl, this.vertexSrc, this.fragmentSrc);
    gl.useProgram(program);

    // get and store the uniforms for the shader
    this.uSampler = gl.getUniformLocation(program, 'uSampler');
    this.projectionVector = gl.getUniformLocation(program, 'projectionVector');
    this.offsetVector = gl.getUniformLocation(program, 'offsetVector');
    this.colorAttribute = gl.getAttribLocation(program, 'aColor');
    //this.dimensions = gl.getUniformLocation(this.program, 'dimensions');

    // get and store the attributes
    this.aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
    this.aTextureCoord = gl.getAttribLocation(program, 'aTextureCoord');

    this.translationMatrix = gl.getUniformLocation(program, 'translationMatrix');
    this.alpha = gl.getUniformLocation(program, 'alpha');

    this.program = program;
  }

  destroy(){

  }
}
