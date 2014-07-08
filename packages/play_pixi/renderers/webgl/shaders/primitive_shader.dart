part of PIXI;

class PrimitiveShader extends Shader {
  PrimitiveShader(this.gl) {
    this.init();
  }


  RenderingContext gl;
  var program = null;
  List<String> fragmentSrc = [
      'precision mediump float;',
      'varying vec4 vColor;',

      'void main(void) {',
      '   gl_FragColor = vColor;',
      '}'
  ];

  List<String> vertexSrc = [
      'attribute vec2 aVertexPosition;',
      'attribute vec4 aColor;',
      'uniform mat3 translationMatrix;',
      'uniform vec2 projectionVector;',
      'uniform vec2 offsetVector;',
      'uniform float alpha;',
      'uniform vec3 tint;',
      'varying vec4 vColor;',

      'void main(void) {',
      '   vec3 v = translationMatrix * vec3(aVertexPosition , 1.0);',
      '   v -= offsetVector.xyx;',
      '   gl_Position = vec4( v.x / projectionVector.x -1.0, v.y / -projectionVector.y + 1.0 , 0.0, 1.0);',
      '   vColor = aColor * vec4(tint * alpha, alpha);',
      '}'
  ];


  //int textureCount = 0;

  UniformLocation projectionVector;
  UniformLocation offsetVector;
  UniformLocation tintColor;
  UniformLocation translationMatrix;
  UniformLocation alpha;

  int aVertexPosition;
  int colorAttribute;

//  int aPositionCoord;
//  int aScale;
//  int aRotation;
//  int aTextureCoord;


  List<int> attributes;





  var uniforms;

  init() {

    var gl = this.gl;

    Program program = compileProgram(gl, this.vertexSrc, this.fragmentSrc);
    gl.useProgram(program);

    // get and store the uniforms for the shader
    this.projectionVector = gl.getUniformLocation(program, 'projectionVector');
    this.offsetVector = gl.getUniformLocation(program, 'offsetVector');
    this.tintColor = gl.getUniformLocation(program, 'tint');


    // get and store the attributes
    this.aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
    this.colorAttribute = gl.getAttribLocation(program, 'aColor');


    this.attributes = [this.aVertexPosition, this.colorAttribute];
    // End worst hack eva //
    this.translationMatrix = gl.getUniformLocation(program, 'translationMatrix');
    this.alpha = gl.getUniformLocation(program, 'alpha');

    this.program = program;
  }

  destroy() {
    this.gl.deleteProgram(this.program);
    this.uniforms = null;
    this.gl = null;

    this.attributes = null;
  }
}
