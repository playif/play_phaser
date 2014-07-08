part of PIXI;

class WebGLShaderUtils {
  WebGLShaderUtils() {
  }
}

CompileVertexShader(RenderingContext gl, List<String> shaderSrc) {
  return _CompileShader(gl, shaderSrc, RenderingContext.VERTEX_SHADER);
}

CompileFragmentShader(RenderingContext gl, List<String> shaderSrc) {
  return _CompileShader(gl, shaderSrc, RenderingContext.FRAGMENT_SHADER);
}

_CompileShader(RenderingContext gl, List<String> shaderSrc, int shaderType) {
  var src = shaderSrc.join("\n");
  //window.console.log(src);
  var shader = gl.createShader(shaderType);
  gl.shaderSource(shader, src);
  gl.compileShader(shader);

  if (gl.getShaderParameter(shader, RenderingContext.COMPILE_STATUS) == null) {
    window.console.log(gl.getShaderInfoLog(shader));
    return null;
  }

  return shader;
}

compileProgram(RenderingContext gl, List<String> vertexSrc, List<String> fragmentSrc) {
  var fragmentShader = CompileFragmentShader(gl, fragmentSrc);
  var vertexShader = CompileVertexShader(gl, vertexSrc);

  Program shaderProgram = gl.createProgram();

  gl.attachShader(shaderProgram, vertexShader);
  gl.attachShader(shaderProgram, fragmentShader);
  gl.linkProgram(shaderProgram);

  if (gl.getProgramParameter(shaderProgram, RenderingContext.LINK_STATUS) == null) {
    window.console.log("Could not initialise shaders");
  }

  return shaderProgram;
}