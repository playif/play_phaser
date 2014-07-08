part of PIXI;

class WebGLShaderManager {
  RenderingContext gl;
  int maxAttibs = 10;
  Map<int, bool> attribState = {
  };
  Map<int, bool> tempAttribState = {
  };

  PrimitiveShader primitiveShader;
  PixiShader defaultShader;
  PixiFastShader fastShader;
  PixiShader currentShader;

  WebGLShaderManager(gl) {
    for (var i = 0; i < this.maxAttibs; i++) {
      this.attribState[i] = false;
    }

    this.setContext(gl);
  }

  setContext(gl) {
    this.gl = gl;

    // the next one is used for rendering primatives
    this.primitiveShader = new PrimitiveShader(gl);

    // this shader is used for the default sprite rendering
    this.defaultShader = new PixiShader(gl);

    // this shader is used for the fast sprite rendering
    this.fastShader = new PixiFastShader(gl);


    this.activateShader(this.defaultShader);
  }

  setAttribs(List<int> attribs) {
    // reset temp state

    var i;

    for (i = 0; i < this.tempAttribState.length; i++) {
      this.tempAttribState[i] = false;
    }

    // set the new attribs
    for (i = 0; i < attribs.length; i++) {
      var attribId = attribs[i];
      this.tempAttribState[attribId] = true;
    }

    var gl = this.gl;

    for (i = 0; i < this.attribState.length; i++) {

      if (this.attribState[i] != this.tempAttribState[i]) {
        this.attribState[i] = this.tempAttribState[i];

        if (this.tempAttribState[i] == true) {
          gl.enableVertexAttribArray(i);
        }
        else {
          gl.disableVertexAttribArray(i);
        }
      }
    }
  }

  activateShader(shader) {
    //if(this.currentShader == shader)return;

    this.currentShader = shader;

    this.gl.useProgram(shader.program);
    this.setAttribs(shader.attributes);

  }

  activatePrimitiveShader() {
    var gl = this.gl;

    gl.useProgram(this.primitiveShader.program);

    this.setAttribs(this.primitiveShader.attributes);

  }


  deactivatePrimitiveShader() {
    var gl = this.gl;

    gl.useProgram(this.defaultShader.program);

    this.setAttribs(this.defaultShader.attributes);
  }

  destroy() {
    this.attribState = null;

    this.tempAttribState = null;

    this.primitiveShader.destroy();

    this.defaultShader.destroy();

    this.fastShader.destroy();

    this.gl = null;
  }
}
