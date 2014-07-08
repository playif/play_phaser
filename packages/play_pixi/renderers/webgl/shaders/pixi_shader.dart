part of PIXI;

class PixiShader extends Shader {
  PixiShader(this.gl) {
    this.init();
  }

  RenderingContext gl;
  Program program = null;
  List<String> fragmentSrc = [
      'precision lowp float;',
      'varying vec2 vTextureCoord;',
      'varying vec4 vColor;',
      'uniform sampler2D uSampler;',
      'void main(void) {',
      '   gl_FragColor = texture2D(uSampler, vTextureCoord) * vColor ;',
      '}'
  ];


  List<String> vertexSrc = null;

  //[
//      'attribute vec2 aVertexPosition;',
//      'attribute vec2 aPositionCoord;',
//      'attribute vec2 aScale;',
//      'attribute float aRotation;',
//      'attribute vec2 aTextureCoord;',
//      'attribute float aColor;',
//
//      'uniform vec2 projectionVector;',
//      'uniform vec2 offsetVector;',
//      'uniform mat3 uMatrix;',
//
//      'varying vec2 vTextureCoord;',
//      'varying float vColor;',
//
//      'const vec2 center = vec2(-1.0, 1.0);',
//
//      'void main(void) {',
//      '   vec2 v;',
//      '   vec2 sv = aVertexPosition * aScale;',
//      '   v.x = (sv.x) * cos(aRotation) - (sv.y) * sin(aRotation);',
//      '   v.y = (sv.x) * sin(aRotation) + (sv.y) * cos(aRotation);',
//      '   v = ( uMatrix * vec3(v + aPositionCoord , 1.0) ).xy ;',
//      '   gl_Position = vec4( ( v / projectionVector) + center , 0.0, 1.0);',
//      '   vTextureCoord = aTextureCoord;',
//      //  '   vec3 color = mod(vec3(aColor.y/65536.0, aColor.y/256.0, aColor.y), 256.0) / 256.0;',
//      '   vColor = aColor;',
//      '}'
//  ];

  static List<String> defaultVertexSrc = [
      'attribute vec2 aVertexPosition;',
      'attribute vec2 aTextureCoord;',
      'attribute vec2 aColor;',

      'uniform vec2 projectionVector;',
      'uniform vec2 offsetVector;',

      'varying vec2 vTextureCoord;',
      'varying vec4 vColor;',

      'const vec2 center = vec2(-1.0, 1.0);',

      'void main(void) {',
      '   gl_Position = vec4( ((aVertexPosition + offsetVector) / projectionVector) + center , 0.0, 1.0);',
      '   vTextureCoord = aTextureCoord;',
      '   vec3 color = mod(vec3(aColor.y/65536.0, aColor.y/256.0, aColor.y), 256.0) / 256.0;',
      '   vColor = vec4(color * aColor.x, aColor.x);',
      '}'
  ];

  int textureCount = 0;

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

  Map uniforms = {
  };


  init() {

    var gl = this.gl;

    Program program = compileProgram(gl, (this.vertexSrc == null) ? PixiShader.defaultVertexSrc : this.vertexSrc, this.fragmentSrc);

    //window.console.log(1);
    gl.useProgram(program);

    //window.console.log(2);

    // get and store the uniforms for the shader
    this.uSampler = gl.getUniformLocation(program, 'uSampler');
    this.projectionVector = gl.getUniformLocation(program, 'projectionVector');
    this.offsetVector = gl.getUniformLocation(program, 'offsetVector');
    this.dimensions = gl.getUniformLocation(program, 'dimensions');

    // get and store the attributes
    this.aVertexPosition = gl.getAttribLocation(program, 'aVertexPosition');
    this.aTextureCoord = gl.getAttribLocation(program, 'aTextureCoord');
    this.colorAttribute = gl.getAttribLocation(program, 'aColor');


    // Begin worst hack eva //

    // WHY??? ONLY on my chrome pixel the line above returns -1 when using filters?
    // maybe its something to do with the current state of the gl context.
    // Im convinced this is a bug in the chrome browser as there is NO reason why this should be returning -1 especially as it only manifests on my chrome pixel
    // If theres any webGL people that know why could happen please help :)
    if (this.colorAttribute == -1) {
      this.colorAttribute = 2;
    }

    this.attributes = [this.aVertexPosition, this.aTextureCoord, this.colorAttribute];

    // End worst hack eva //

    // add those custom shaders!
    for (var key in this.uniforms.keys) {

      // get the uniform locations..
      this.uniforms[key]['uniformLocation'] = gl.getUniformLocation(program, key);
    }

    this.initUniforms();

    this.program = program;
  }

  initUniforms() {
    this.textureCount = 1;
    var gl = this.gl;
    var uniform;

    for (String key in this.uniforms.keys) {
      uniform = this.uniforms[key];

      var type = uniform['type'];

      if (type == 'sampler2D') {
        uniform['_init'] = false;

        if (uniform['value'] != null) {
          this.initSampler2D(uniform);
        }
      }
      else if (type == 'mat2' || type == 'mat3' || type == 'mat4') {
        //  These require special handling
        uniform['glMatrix'] = true;
        uniform['glValueLength'] = 1;

        if (type == 'mat2') {
          uniform['glFunc'] = gl.uniformMatrix2fv;
        }
        else if (type == 'mat3') {
          uniform['glFunc'] = gl.uniformMatrix3fv;
        }
        else if (type == 'mat4') {
            uniform['glFunc'] = gl.uniformMatrix4fv;
          }
      }
      else {
        //uniform['glValueLength'] = 1;

        switch (type) {
          case '1f':
            uniform['glFunc'] = gl.uniform1f;
            uniform['glValueLength'] = 1;
            break;
          case '1i':
            uniform['glFunc'] = gl.uniform1i;
            uniform['glValueLength'] = 1;
            break;
          case '2f':
            uniform['glFunc'] = gl.uniform2f;
            uniform['glValueLength'] = 2;
            break;
          case '2i':
            uniform['glFunc'] = gl.uniform2i;
            uniform['glValueLength'] = 2;
            break;
          case '2fv':
            uniform['glFunc'] = gl.uniform2fv;
            uniform['glValueLength'] = 1;
            break;
          case '3f':
            uniform['glFunc'] = gl.uniform3f;
            uniform['glValueLength'] = 3;
            break;
          case '3i':
            uniform['glFunc'] = gl.uniform3i;
            uniform['glValueLength'] = 3;
            break;
          case '3fv':
            uniform['glFunc'] = gl.uniform3fv;
            uniform['glValueLength'] = 1;
            break;
          case '4f':
            uniform['glFunc'] = gl.uniform4f;
            uniform['glValueLength'] = 4;
            break;
          case '4i':
            uniform['glFunc'] = gl.uniform4i;
            uniform['glValueLength'] = 4;
            break;
          case '4fv':
            uniform['glFunc'] = gl.uniform4fv;
            uniform['glValueLength'] = 1;
            break;
        }

        if (uniform['glFunc'] == null) {
          print(type);
          throw new Exception("no shuch function!");
        }

//        //  GL function reference
//        uniform['glFunc'] = gl['uniform' + type];
//
//        if (type == '2f' || type == '2i') {
//          uniform['glValueLength'] = 2;
//        }
//        else if (type == '3f' || type == '3i') {
//          uniform['glValueLength'] = 3;
//        }
//        else if (type == '4f' || type == '4i') {
//            uniform['glValueLength'] = 4;
//          }
//          else {
//            uniform['glValueLength'] = 1;
//          }
      }
    }

  }

  //List<int> TextureLayer=[TEXTURE0,TEXTURE1,TEXTURE2];

  initSampler2D(Map uniform) {

    if (uniform['value'] == null || uniform['value'].baseTexture == null || !uniform['value'].baseTexture.hasLoaded) {
      return;
    }

    var gl = this.gl;

    print(this.textureCount);
    gl.activeTexture(TEXTURE0 + this.textureCount);
    gl.bindTexture(TEXTURE_2D, uniform['value'].baseTexture._glTextures[gl]);

    //  Extended texture data
    if (uniform['textureData'] != null) {
      var data = uniform['textureData'];

      // GLTexture = mag linear, min linear_mipmap_linear, wrap repeat + gl.generateMipmap(gl.TEXTURE_2D);
      // GLTextureLinear = mag/min linear, wrap clamp
      // GLTextureNearestRepeat = mag/min NEAREST, wrap repeat
      // GLTextureNearest = mag/min nearest, wrap clamp
      // AudioTexture = whatever + luminance + width 512, height 2, border 0
      // KeyTexture = whatever + luminance + width 256, height 2, border 0

      //  magFilter can be: gl.LINEAR, gl.LINEAR_MIPMAP_LINEAR or gl.NEAREST
      //  wrapS/T can be: gl.CLAMP_TO_EDGE or gl.REPEAT

      var magFilter = (data.magFilter) ? data.magFilter : LINEAR;
      var minFilter = (data.minFilter) ? data.minFilter : LINEAR;
      var wrapS = (data.wrapS) ? data.wrapS : CLAMP_TO_EDGE;
      var wrapT = (data.wrapT) ? data.wrapT : CLAMP_TO_EDGE;
      var format = (data.luminance) ? LUMINANCE : RGBA;

      if (data['repeat'] != null) {
        wrapS = REPEAT;
        wrapT = REPEAT;
      }

      gl.pixelStorei(UNPACK_FLIP_Y_WEBGL, !!data.flipY);

      if (data.width) {
        var width = (data.width) ? data.width : 512;
        var height = (data.height) ? data.height : 2;
        var border = (data.border) ? data.border : 0;

        // void texImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, ArrayBufferView? pixels);
        gl.texImage2D(TEXTURE_2D, 0, format, width, height, border, format, UNSIGNED_BYTE, null);
      }
      else {
        //  void texImage2D(GLenum target, GLint level, GLenum internalformat, GLenum format, GLenum type, ImageData? pixels);
        gl.texImage2D(TEXTURE_2D, 0, format, RGBA, UNSIGNED_BYTE, uniform['value']['baseTexture'].source);
      }

      gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, magFilter);
      gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, minFilter);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, wrapS);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, wrapT);
    }

    gl.uniform1i(uniform['uniformLocation'], this.textureCount);

    uniform['_init'] = true;

    this.textureCount++;

  }

  syncUniforms() {
    this.textureCount = 1;
    var uniform;
    var gl = this.gl;

    //  This would probably be faster in an array and it would guarantee key order
    for (var key in this.uniforms.keys) {
      uniform = this.uniforms[key];

      if (uniform['glValueLength'] == 1) {
        if (uniform['glMatrix'] == true) {
          //.console.log(uniform);
          UniformLocation location = uniform['uniformLocation'];
          //print(uniform['value']);
          List list = uniform['value'];
          Float32List flist = new Float32List.fromList(list);
          bool transpose = uniform['transpose'] != null ? uniform['transpose'] : false;
          uniform['glFunc'](location, transpose, flist);
        }
        else {
          UniformLocation location = uniform['uniformLocation'];
          //print(uniform['value']);
          if(uniform['value'] is List){
            List list = uniform['value'];
            Float32List flist = new Float32List.fromList(list);
            uniform['glFunc'](location, flist);
          }
          else{
            uniform['glFunc'](location, uniform['value']);
          }

        }
      }
      else if (uniform['glValueLength'] == 2) {
        uniform['glFunc'](uniform['uniformLocation'], uniform['value']['x'], uniform['value']['y']);
      }
      else if (uniform['glValueLength'] == 3) {
          uniform['glFunc'](uniform['uniformLocation'], uniform['value']['x'], uniform['value']['y'], uniform['value']['z']);
        }
        else if (uniform['glValueLength'] == 4) {
            //print(uniform['value']);
            uniform['glFunc'](uniform['uniformLocation'], uniform['value'][0], uniform['value'][1], uniform['value'][2], uniform['value'][3]);
          }
          else if (uniform['type'] == 'sampler2D') {
              if (uniform['_init'] != null) {
                gl.activeTexture(TEXTURE0 + this.textureCount);
                Texture texture = uniform['value'].baseTexture._glTextures[gl];
                if (texture == null) {
                  texture = createWebGLTexture(uniform['value'].baseTexture, gl);
                }
                gl.bindTexture(TEXTURE_2D, texture);
                gl.uniform1i(uniform['uniformLocation'], this.textureCount);
                this.textureCount++;
              }
              else {
                this.initSampler2D(uniform);
              }
            }
    }

  }

  destroy() {
    this.gl.deleteProgram(this.program);
    this.uniforms = null;
    this.gl = null;

    this.attributes = null;
  }
}

