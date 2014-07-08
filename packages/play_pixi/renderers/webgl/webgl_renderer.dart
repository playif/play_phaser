part of PIXI;

Set glContexts = new Set();

class WebGLRenderer extends Renderer {
//  static int glContextId = 0;

  //num width, height;
//  bool transparent=false;
//  bool antialias=false;

  WebGLRenderer([int width=800, int height=600, CanvasElement view, bool transparent=false, bool antialias=false]) {
    if (defaultRenderer == null) defaultRenderer = this;
    type = WEBGL_RENDERER;
    this.width = width;
    this.height = height;
    this.transparent = transparent;
    this.antialias = antialias;

    if (view == null) {
      view = new CanvasElement();
    }
    //print(view);

    this.view = view;
    this.view.width = this.width;
    this.view.height = this.height;


    // deal with losing context..
    //this.contextLost = this.handleContextLost.bind(this);
    //this.contextRestoredLost = this.handleContextRestored.bind(this);

    this.view.addEventListener('webglcontextlost', this.handleContextLost, false);
    this.view.addEventListener('webglcontextrestored', this.handleContextRestored, false);

    this.options = {
        'alpha': this.transparent,
        'antialias':this.antialias, // SPEED UP??
        'premultipliedAlpha':transparent,
        'stencil':true
    };

    //try 'experimental-webgl'
    try {
      this.gl = this.view.getContext('experimental-webgl', this.options);
      //window.console.log(this.view.getContext('experimental-webgl', this.options));
    } catch (e) {
      //try 'webgl'
      try {
        this.gl = this.view.getContext('webgl', this.options);
      } catch (e2) {
        // fail, not able to get a context
        throw new Exception(' This browser does not support webGL. Try using the canvas renderer $this');
      }
    }

    var gl = this.gl;
    //this.glId = WebGLRenderer.glContextId ++;

    glContexts.add(gl);
    //window.console.log(gl);

    if (blendModesWebGL == null) {

      //TODO improve the performance
      blendModesWebGL = {
      };

      blendModesWebGL[blendModes.NORMAL] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.ADD] = [SRC_ALPHA, DST_ALPHA];
      blendModesWebGL[blendModes.MULTIPLY] = [DST_COLOR, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.SCREEN] = [SRC_ALPHA, ONE];
      blendModesWebGL[blendModes.OVERLAY] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.DARKEN] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.LIGHTEN] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.COLOR_DODGE] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.COLOR_BURN] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.HARD_LIGHT] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.SOFT_LIGHT] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.DIFFERENCE] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.EXCLUSION] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.HUE] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.SATURATION] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.COLOR] = [ONE, ONE_MINUS_SRC_ALPHA];
      blendModesWebGL[blendModes.LUMINOSITY] = [ONE, ONE_MINUS_SRC_ALPHA];
    }


    this.projection = new Point();
    this.projection.x = this.width / 2;
    this.projection.y = -this.height / 2;

    this.offset = new Point(0, 0);

    this.resize(this.width, this.height);
    this.contextLost = false;

    // time to create the render managers! each one focuses on managine a state in webGL
    this.shaderManager = new WebGLShaderManager(gl); // deals with managing the shader programs and their attribs
    this.spriteBatch = new WebGLSpriteBatch(gl); // manages the rendering of sprites
    this.maskManager = new WebGLMaskManager(gl); // manages the masks using the stencil buffer
    this.filterManager = new WebGLFilterManager(gl, this.transparent); // manages the filters

    this.renderSession = new RenderSession();
    this.renderSession.gl = this.gl;
    this.renderSession.drawCount = 0;
    this.renderSession.shaderManager = this.shaderManager;
    this.renderSession.maskManager = this.maskManager;
    this.renderSession.filterManager = this.filterManager;
    this.renderSession.spriteBatch = this.spriteBatch;
    this.renderSession.renderer = this;

    gl.useProgram(this.shaderManager.defaultShader.program);

    gl.disable(RenderingContext.DEPTH_TEST);
    gl.disable(RenderingContext.CULL_FACE);

    gl.enable(RenderingContext.BLEND);
    gl.colorMask(true, true, true, this.transparent);
  }

  render(Stage stage) {
    if (this.contextLost) return;
    //window.console.log(stage.children[0]);

    // if rendering a new stage clear the batches..
    if (this.__stage != stage) {
      if (stage.interactive)stage.interactionManager.removeEvents();

      // TODO make this work
      // dont think this is needed any more?
      this.__stage = stage;
    }

    // update any textures this includes uvs and uploading them to the gpu
    WebGLRenderer.updateTextures(gl);

    // update the scene graph
    stage.updateTransform();


    // interaction
    if (stage._interactive) {
      //need to add some events!
      if (!stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = true;
        stage.interactionManager.setTarget(this);
      }
    }


    // -- Does this need to be set every frame? -- //
    //gl.colorMask(true, true, true, this.transparent);

    gl.viewport(0, 0, this.width, this.height);

    // make sure we are bound to the main frame buffer
    gl.bindFramebuffer(FRAMEBUFFER, null);

    if (this.transparent == true) {
      gl.clearColor(0, 0, 0, 0);
    }
    else {
      gl.clearColor(stage.backgroundColorSplit[0], stage.backgroundColorSplit[1], stage.backgroundColorSplit[2], 1);
    }


    gl.clear(COLOR_BUFFER_BIT);

    this.renderDisplayObject(stage, this.projection);

    // interaction
    if (stage.interactive) {
      //need to add some events!
      if (!stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = true;
        stage.interactionManager.setTarget(this);
      }
    }
    else {
      if (stage._interactiveEventsAdded) {
        stage._interactiveEventsAdded = false;
        stage.interactionManager.setTarget(this);
      }
    }

    /*
    //can simulate context loss in Chrome like so:
     this.view.onmousedown = function(ev) {
     console.dir(this.gl.getSupportedExtensions());
        var ext = (
            gl.getExtension("WEBGL_scompressed_texture_s3tc")
       // gl.getExtension("WEBGL_compressed_texture_s3tc") ||
       // gl.getExtension("MOZ_WEBGL_compressed_texture_s3tc") ||
       // gl.getExtension("WEBKIT_WEBGL_compressed_texture_s3tc")
     );
     console.dir(ext);
     var loseCtx = this.gl.getExtension("WEBGL_lose_context");
      console.log("killing context");
      loseCtx.loseContext();
     setTimeout(function() {
          console.log("restoring context...");
          loseCtx.restoreContext();
      }.bind(this), 1000);
     }.bind(this);
     */
  }


  renderDisplayObject(DisplayObject displayObject, [Point projection, buffer]) {
    // reset the render session data..
    this.renderSession.drawCount = 0;
    this.renderSession.currentBlendMode = blendModes.NONE;

    this.renderSession.projection = projection;
    this.renderSession.offset = this.offset;


    // start the sprite batch
    this.spriteBatch.begin(this.renderSession);

    // start the filter manager
    this.filterManager.begin(this.renderSession, buffer);

    // render the scene!
    displayObject._renderWebGL(this.renderSession);

    // finish the sprite batch
    this.spriteBatch.end();
  }


  static void updateTextures(RenderingContext gl) {
    var i = 0;

    //TODO break this out into a texture manager...
    //for (i = 0; i < PIXI.texturesToUpdate.length; i++)
    //    PIXI.WebGLRenderer.updateTexture(PIXI.texturesToUpdate[i]);

    //print(Texture.frameUpdates);
    for (i = 0; i < Texture.frameUpdates.length; i++)
      WebGLRenderer.updateTextureFrame(Texture.frameUpdates[i]);

    for (i = 0; i < texturesToDestroy.length; i++)
      WebGLRenderer.destroyTexture(texturesToDestroy[i], gl);

    texturesToUpdate.length = 0;
    texturesToDestroy.length = 0;
    Texture.frameUpdates.length = 0;
  }


  static destroyTexture(Texture texture, RenderingContext gl) {
    //TODO break this out into a texture manager...
    for (var t in texture._glTextures.values) {
      gl.deleteTexture(t);
    }
    texture._glTextures.clear();
//    for (int i = texture._glTextures.length - 1; i >= 0; i--) {
//      var glTexture = texture._glTextures[i];
//      var gl = glContexts[i];
//
//      if (gl && glTexture) {
//        gl.deleteTexture(glTexture);
//      }
//    }
//
//    texture._glTextures.length = 0;
  }

  static updateTextureFrame(Texture texture) {

    texture.updateFrame = false;

    // now set the uvs. Figured that the uv data sits with a texture rather than a sprite.
    // so uv data is stored on the texture itself
    texture._updateWebGLuvs();
  }

  resize(width, height) {
    this.width = width;
    this.height = height;

    this.view.width = width;
    this.view.height = height;

    this.gl.viewport(0, 0, this.width, this.height);

    this.projection.x = this.width / 2;
    this.projection.y = -this.height / 2;
  }

  handleContextLost(event) {
    event.preventDefault();
    this.contextLost = true;
  }

  handleContextRestored(event) {

    //try 'experimental-webgl'
    try {
      this.gl = this.view.getContext('experimental-webgl', this.options);
    } catch (e) {
      //try 'webgl'
      try {
        this.gl = this.view.getContext('webgl', this.options);
      } catch (e2) {
        // fail, not able to get a context
        throw new Exception(' This browser does not support webGL. Try using the canvas renderer this');
      }
    }

    var gl = this.gl;
    //this.glId = WebGLRenderer.glContextId ++;


    // need to set the context...
    this.shaderManager.setContext(gl);
    this.spriteBatch.setContext(gl);
    this.maskManager.setContext(gl);
    this.filterManager.setContext(gl);


    this.renderSession.gl = this.gl;

    gl.disable(gl.DEPTH_TEST);
    gl.disable(gl.CULL_FACE);

    gl.enable(gl.BLEND);
    gl.colorMask(true, true, true, this.transparent);

    this.gl.viewport(0, 0, this.width, this.height);

    for (var key in TextureCache) {
      var texture = TextureCache[key].baseTexture;
      texture._glTextures = [];
    }

    /**
     * Whether the context was lost
     * @property contextLost
     * @type Boolean
     */
    this.contextLost = false;

  }

  void destroy() {

    // deal with losing context..

    // remove listeners
    this.view.removeEventListener('webglcontextlost', this.handleContextLost);
    this.view.removeEventListener('webglcontextrestored', this.handleContextRestored);

    glContexts.remove(this.gl);

    this.projection = null;
    this.offset = null;

    // time to create the render managers! each one focuses on managine a state in webGL
    this.shaderManager.destroy();
    this.spriteBatch.destroy();
    this.maskManager.destroy();
    this.filterManager.destroy();

    this.shaderManager = null;
    this.spriteBatch = null;
    this.maskManager = null;
    this.filterManager = null;

    this.gl = null;
    //
    this.renderSession = null;
  }

}

createWebGLTexture(BaseTexture texture, RenderingContext gl) {


  if (texture.hasLoaded) {
    texture._glTextures[gl] = gl.createTexture();


    gl.bindTexture(TEXTURE_2D, texture._glTextures[gl]);

    gl.pixelStorei(UNPACK_PREMULTIPLY_ALPHA_WEBGL, 1);

    gl.texImage2D(TEXTURE_2D, 0, RGBA, RGBA, UNSIGNED_BYTE, texture.source);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, texture.scaleMode == scaleModes.LINEAR ? LINEAR : NEAREST);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, texture.scaleMode == scaleModes.LINEAR ? LINEAR : NEAREST);

    // reguler...

    if (!texture._powerOf2) {
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
    }
    else {
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, REPEAT);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, REPEAT);
    }

    gl.bindTexture(TEXTURE_2D, null);
  }

  return texture._glTextures[gl];
}

updateWebGLTexture(Texture texture, RenderingContext gl) {
  if (texture._glTextures[gl] != null) {
    gl.bindTexture(TEXTURE_2D, texture._glTextures[gl]);
    gl.pixelStorei(UNPACK_PREMULTIPLY_ALPHA_WEBGL, true);

    gl.texImage2D(TEXTURE_2D, 0, RGBA, RGBA, UNSIGNED_BYTE, texture.source);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MAG_FILTER, texture.scaleMode == scaleModes.LINEAR ? LINEAR : NEAREST);
    gl.texParameteri(TEXTURE_2D, TEXTURE_MIN_FILTER, texture.scaleMode == scaleModes.LINEAR ? LINEAR : NEAREST);

    // reguler...

    if (!texture._powerOf2) {
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, CLAMP_TO_EDGE);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, CLAMP_TO_EDGE);
    }
    else {
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_S, REPEAT);
      gl.texParameteri(TEXTURE_2D, TEXTURE_WRAP_T, REPEAT);
    }

    gl.bindTexture(TEXTURE_2D, null);
  }

}