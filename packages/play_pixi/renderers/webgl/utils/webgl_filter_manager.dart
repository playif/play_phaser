part of PIXI;

class WebGLFilterManager {
  RenderingContext gl;
  bool transparent;

  List<FilterBlock> filterStack = [];
  num offsetX = 0;
  num offsetY = 0;

  List<FilterTexture> texturePool;

  RenderSession renderSession;
  int width, height;

  PixiShader defaultShader;



  Float32List vertexArray;



  Float32List uvArray;

  Buffer colorBuffer;
  Buffer indexBuffer;
  Buffer vertexBuffer;
  Buffer uvBuffer;

  Framebuffer buffer;

  Float32List colorArray;

  WebGLFilterManager(RenderingContext gl, this.transparent) {
    setContext(gl);
  }

  setContext(gl) {
    this.gl = gl;
    this.texturePool = [];

    this.initShaderBuffers();
  }

  begin(RenderSession renderSession, Framebuffer buffer) {
    this.renderSession = renderSession;
    this.defaultShader = renderSession.shaderManager.defaultShader;

    var projection = this.renderSession.projection;
    // console.log(this.width)
    this.width = (projection.x * 2).toInt();
    this.height = (-projection.y * 2).toInt();
    this.buffer = buffer;
  }

  pushFilter(FilterBlock filterBlock) {
    var gl = this.gl;

    var projection = this.renderSession.projection;
    var offset = this.renderSession.offset;

    filterBlock._filterArea = (filterBlock.target.filterArea == null) ? filterBlock.target.getBounds() : filterBlock.target.filterArea;


    // filter program
    // OPTIMISATION - the first filter is free if its a simple color change?
    this.filterStack.add(filterBlock);

    var filter = filterBlock.filterPasses[0];

    this.offsetX += filterBlock._filterArea.x;
    this.offsetY += filterBlock._filterArea.y;

    FilterTexture texture = null;

    if (this.texturePool.length > 0) {
      texture = this.texturePool.removeLast();
    }

    if (texture == null) {
      texture = new FilterTexture(this.gl, this.width, this.height);
    }
    else {
//      print(this.width);
//      print(texture.width);
//      print(this.height);
//      print(texture.height);
      texture.resize(this.width, this.height);
    }


    gl.bindTexture(TEXTURE_2D, texture.texture);

    Rectangle filterArea = filterBlock._filterArea;// filterBlock.target.getBounds();///filterBlock.target.filterArea;

    var padding = filter.padding;
    filterArea.x -= padding;
    filterArea.y -= padding;
    filterArea.width += padding * 2;
    filterArea.height += padding * 2;


    // cap filter to screen size..
    if (filterArea.x < 0)filterArea.x = 0;
    if (filterArea.width > this.width)filterArea.width = this.width;
    if (filterArea.y < 0)filterArea.y = 0;
    if (filterArea.height > this.height)filterArea.height = this.height;


    //gl.texImage2D(TEXTURE_2D, 0, RGBA,  filterArea.width.toInt(), filterArea.height.toInt(), 0, RGBA, UNSIGNED_BYTE, null);
    gl.bindFramebuffer(FRAMEBUFFER, texture.frameBuffer);
    //print(filterArea.width.toInt());
    // set view port


    gl.viewport(0, 0, filterArea.width.toInt(), filterArea.height.toInt());

    projection.x = filterArea.width / 2;
    projection.y = -filterArea.height / 2;

    offset.x = -filterArea.x;
    offset.y = -filterArea.y;

    //print(filterArea.width / 2.0);
    // update projection
    gl.uniform2f(this.defaultShader.projectionVector, filterArea.width / 2.0, -filterArea.height / 2.0);
    gl.uniform2f(this.defaultShader.offsetVector, -filterArea.x.toDouble(), -filterArea.y.toDouble());

    gl.colorMask(true, true, true, true);
    gl.clearColor(0.0, 0.0, 0.0, 0.0);
    //print(COLOR_BUFFER_BIT);


    gl.clear(COLOR_BUFFER_BIT);
    //print("here");

    filterBlock._glFilterTexture = texture;
  }


  popFilter() {
    //var gl = this.gl;
    FilterBlock filterBlock = this.filterStack.removeLast();
    Rectangle filterArea = filterBlock._filterArea;
    FilterTexture texture = filterBlock._glFilterTexture;
    Point projection = this.renderSession.projection;
    Point offset = this.renderSession.offset;

    if (filterBlock.filterPasses.length > 1) {
      gl.viewport(0, 0, filterArea.width.toInt(), filterArea.height.toInt());

      gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);

      this.vertexArray[0] = 0.0;
      this.vertexArray[1] = filterArea.height.toDouble();

      this.vertexArray[2] = filterArea.width.toDouble();
      this.vertexArray[3] = filterArea.height.toDouble();

      this.vertexArray[4] = 0.0;
      this.vertexArray[5] = 0.0;

      this.vertexArray[6] = filterArea.width.toDouble();
      this.vertexArray[7] = 0.0;

      gl.bufferSubData(ARRAY_BUFFER, 0, this.vertexArray);

      gl.bindBuffer(ARRAY_BUFFER, this.uvBuffer);
      // now set the uvs..
      this.uvArray[2] = filterArea.width / this.width;
      this.uvArray[5] = filterArea.height / this.height;
      this.uvArray[6] = filterArea.width / this.width;
      this.uvArray[7] = filterArea.height / this.height;

      gl.bufferSubData(ARRAY_BUFFER, 0, this.uvArray);

      FilterTexture inputTexture = texture;
      FilterTexture outputTexture;
      if (this.texturePool.length > 0) {
        outputTexture = this.texturePool.removeLast();
      }

      if (outputTexture == null) outputTexture = new FilterTexture(this.gl, this.width, this.height);
      outputTexture.resize(this.width, this.height);

      // need to clear this FBO as it may have some left over elements from a previous filter.
      gl.bindFramebuffer(FRAMEBUFFER, outputTexture.frameBuffer);
      gl.clear(COLOR_BUFFER_BIT);

      gl.disable(BLEND);

      for (int i = 0; i < filterBlock.filterPasses.length - 1; i++) {
        var filterPass = filterBlock.filterPasses[i];

        gl.bindFramebuffer(FRAMEBUFFER, outputTexture.frameBuffer);

        // set texture
        gl.activeTexture(TEXTURE0);
        gl.bindTexture(TEXTURE_2D, inputTexture.texture);

        // draw texture..
        //filterPass.applyFilterPass(filterArea.width, filterArea.height);
        this.applyFilterPass(filterPass, filterArea, filterArea.width, filterArea.height);

        // swap the textures..
        var temp = inputTexture;
        inputTexture = outputTexture;
        outputTexture = temp;
      }

      gl.enable(BLEND);

      texture = inputTexture;
      this.texturePool.add(outputTexture);
    }

    AbstractFilter filter = filterBlock.filterPasses[filterBlock.filterPasses.length - 1];

    this.offsetX -= filterArea.x;
    this.offsetY -= filterArea.y;


    num sizeX = this.width;
    num sizeY = this.height;

    num offsetX = 0;
    num offsetY = 0;

    Framebuffer buffer = this.buffer;

    // time to render the filters texture to the previous scene
    if (this.filterStack.length == 0) {
      gl.colorMask(true, true, true, true);
      //this.transparent);
    }
    else {
      FilterBlock currentFilter = this.filterStack[this.filterStack.length - 1];
      filterArea = currentFilter._filterArea;

      sizeX = filterArea.width;
      sizeY = filterArea.height;

      offsetX = filterArea.x;
      offsetY = filterArea.y;

      buffer = currentFilter._glFilterTexture.frameBuffer;
    }


    // TODO need toremove thease global elements..
    projection.x = sizeX / 2;
    projection.y = -sizeY / 2;

    offset.x = offsetX;
    offset.y = offsetY;

    filterArea = filterBlock._filterArea;

    num x = filterArea.x - offsetX + 0.0;
    num y = filterArea.y - offsetY + 0.0;

    // update the buffers..
    // make sure to flip the y!
    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    //print(x);
    this.vertexArray[0] = x;
    this.vertexArray[1] = y + filterArea.height;

    this.vertexArray[2] = x + filterArea.width;
    this.vertexArray[3] = y + filterArea.height;

    this.vertexArray[4] = x;
    this.vertexArray[5] = y;

    this.vertexArray[6] = x + filterArea.width;
    this.vertexArray[7] = y;

    gl.bufferSubData(ARRAY_BUFFER, 0, this.vertexArray);

    gl.bindBuffer(ARRAY_BUFFER, this.uvBuffer);

    this.uvArray[2] = filterArea.width / this.width;
    this.uvArray[5] = filterArea.height / this.height;
    this.uvArray[6] = filterArea.width / this.width;
    this.uvArray[7] = filterArea.height / this.height;

    gl.bufferSubData(ARRAY_BUFFER, 0, this.uvArray);

    //console.log(this.vertexArray)
    //console.log(this.uvArray)
    //console.log(sizeX + " : " + sizeY)

    gl.viewport(0, 0, sizeX.toInt(), sizeY.toInt());

    // bind the buffer
    gl.bindFramebuffer(FRAMEBUFFER, buffer);

    // set the blend mode!
    //gl.blendFunc(gl.ONE, gl.ONE_MINUS_SRC_ALPHA)

    // set texture
    gl.activeTexture(TEXTURE0);
    gl.bindTexture(TEXTURE_2D, texture.texture);

    // apply!
    this.applyFilterPass(filter, filterArea, sizeX, sizeY);

    // now restore the regular shader..
    gl.useProgram(this.defaultShader.program);
    gl.uniform2f(this.defaultShader.projectionVector, sizeX / 2, -sizeY / 2);
    gl.uniform2f(this.defaultShader.offsetVector, -offsetX, -offsetY);

    // return the texture to the pool
    this.texturePool.add(texture);
    filterBlock._glFilterTexture = null;
  }

  applyFilterPass(AbstractFilter filter, Rectangle filterArea, num width, num height) {
    // use program
    var shader = filter.shaders[gl];

    if (shader == null) {
      shader = new PixiShader(gl);

      shader.fragmentSrc = filter.fragmentSrc;
      shader.uniforms = filter.uniforms;
      shader.init();

      filter.shaders[gl] = shader;
    }

    // set the shader
    gl.useProgram(shader.program);

    gl.uniform2f(shader.projectionVector, width / 2, -height / 2);
    gl.uniform2f(shader.offsetVector, 0, 0);

    if (filter.uniforms['dimensions'] != null) {
      filter.uniforms['dimensions']['value'][0] = this.width.toDouble();//width;
      filter.uniforms['dimensions']['value'][1] = this.height.toDouble();//height;
      filter.uniforms['dimensions']['value'][2] = this.vertexArray[0].toDouble();
      filter.uniforms['dimensions']['value'][3] = this.vertexArray[5].toDouble();
      //filterArea.height;
    }

    //  console.log(this.uvArray )
    shader.syncUniforms();

    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.vertexAttribPointer(shader.aVertexPosition, 2, FLOAT, false, 0, 0);

    gl.bindBuffer(ARRAY_BUFFER, this.uvBuffer);
    gl.vertexAttribPointer(shader.aTextureCoord, 2, FLOAT, false, 0, 0);

    gl.bindBuffer(ARRAY_BUFFER, this.colorBuffer);
    gl.vertexAttribPointer(shader.colorAttribute, 2, FLOAT, false, 0, 0);

    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);

    // draw the filter...
    gl.drawElements(TRIANGLES, 6, UNSIGNED_SHORT, 0);

    this.renderSession.drawCount++;
  }

  initShaderBuffers() {
    var gl = this.gl;

    // create some buffers
    this.vertexBuffer = gl.createBuffer();
    this.uvBuffer = gl.createBuffer();
    this.colorBuffer = gl.createBuffer();
    this.indexBuffer = gl.createBuffer();


    // bind and upload the vertexs..
    // keep a reference to the vertexFloatData..
    this.vertexArray = new Float32List.fromList([0.0, 0.0,
    1.0, 0.0,
    0.0, 1.0,
    1.0, 1.0]);

    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, this.vertexBuffer);
    gl.bufferData(
        RenderingContext.ARRAY_BUFFER,
        this.vertexArray,
        RenderingContext.STATIC_DRAW);


    // bind and upload the uv buffer
    this.uvArray = new Float32List.fromList([0.0, 0.0,
    1.0, 0.0,
    0.0, 1.0,
    1.0, 1.0]);

    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, this.uvBuffer);
    gl.bufferData(
        RenderingContext.ARRAY_BUFFER,
        this.uvArray,
        RenderingContext.STATIC_DRAW);

    this.colorArray = new Float32List.fromList([1.0, 16777215.0,
    1.0, 16777215.0,
    1.0, 16777215.0,
    1.0, 16777215.0]);

    gl.bindBuffer(RenderingContext.ARRAY_BUFFER, this.colorBuffer);
    gl.bufferData(
        RenderingContext.ARRAY_BUFFER,
        this.colorArray,
        RenderingContext.STATIC_DRAW);

    // bind and upload the index
    gl.bindBuffer(RenderingContext.ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    gl.bufferData(
        RenderingContext.ELEMENT_ARRAY_BUFFER,
        new Uint16List.fromList([0, 1, 2, 1, 3, 2]),
        RenderingContext.STATIC_DRAW);
  }

  destroy() {
    var gl = this.gl;

    this.filterStack = null;

    this.offsetX = 0;
    this.offsetY = 0;

    //TODO report BUG
    // destroy textures
    for (var i = 0; i < this.texturePool.length; i++) {
      this.texturePool[i].destroy();
    }

    this.texturePool = null;

    //destroy buffers..
    gl.deleteBuffer(this.vertexBuffer);
    gl.deleteBuffer(this.uvBuffer);
    gl.deleteBuffer(this.colorBuffer);
    gl.deleteBuffer(this.indexBuffer);
  }
}
