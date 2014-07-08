part of PIXI;

class WebGLSpriteBatch {
  RenderingContext gl;
//  int glID;
  int vertSize = 6;
  int maxSize = 6000;
  int size;
  int numVerts;
  int numIndices;

  Float32List vertices;
  Uint16List indices;

  Buffer vertexBuffer = null;
  Buffer indexBuffer = null;

  int lastIndexCount = 0;

  bool drawing = false;
  int currentBatchSize = 0;
  BaseTexture currentBaseTexture = null;

  blendModes currentBlendMode = blendModes.NORMAL;
  RenderSession renderSession = null;

  PixiShader shader = null;

  Matrix matrix = null;

  WebGLSpriteBatch(RenderingContext gl) {

    size = maxSize;
    numVerts = size * 4 * vertSize;
    numIndices = maxSize * 6;
    vertices = new Float32List(numVerts);
    indices = new Uint16List(numIndices);

    for (int i = 0, j = 0; i < numIndices; i += 6, j += 4) {
      this.indices[i + 0] = j + 0;
      this.indices[i + 1] = j + 1;
      this.indices[i + 2] = j + 2;
      this.indices[i + 3] = j + 0;
      this.indices[i + 4] = j + 2;
      this.indices[i + 5] = j + 3;
    }

    this.setContext(gl);
  }

  setContext(RenderingContext gl) {
    this.gl = gl;

    // create a couple of buffers
    this.vertexBuffer = gl.createBuffer();
    this.indexBuffer = gl.createBuffer();

    // 65535 is max index, so 65535 / 6 = 10922.

    //upload the index data
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);
    gl.bufferData(ELEMENT_ARRAY_BUFFER, this.indices, STATIC_DRAW);

    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.bufferData(ARRAY_BUFFER, this.vertices, DYNAMIC_DRAW);

    this.currentBlendMode = blendModes.NONE;
  }

  begin(RenderSession renderSession) {
    this.renderSession = renderSession;
    this.shader = this.renderSession.shaderManager.defaultShader;

    this.start();
  }

  end() {
    this.flush();
  }

  render(Sprite sprite) {
    Texture texture = sprite.texture;

    // check texture..
    if (texture.baseTexture != this.currentBaseTexture || this.currentBatchSize >= this.size) {
      this.flush();
      this.currentBaseTexture = texture.baseTexture;
    }


    // check blend mode
    if (sprite.blendMode != this.currentBlendMode) {
      this.setBlendMode(sprite.blendMode);
    }

    // get the uvs for the texture
    TextureUvs uvs = (sprite._uvs == null) ? sprite.texture._uvs : sprite._uvs;
    // if the uvs have not updated then no point rendering just yet!
    //print(sprite.texture._uvs);
    if (uvs == null) return;

    // get the sprites current alpha
    num alpha = sprite.worldAlpha;
    num tint = sprite.tint.toDouble();

    var verticies = this.vertices;


    // TODO trim??
    num aX = sprite.anchor.x;
    num aY = sprite.anchor.y;

    num w0, w1, h0, h1;

    if (sprite.texture.trim != null) {
      // if the sprite is trimmed then we need to add the extra space before transforming the sprite coords..
      Rectangle trim = sprite.texture.trim;

      w1 = trim.x - aX * trim.width;
      w0 = w1 + texture.frame.width;

      h1 = trim.y - aY * trim.height;
      h0 = h1 + texture.frame.height;

    }
    else {
      w0 = (texture.frame.width ) * (1 - aX);
      w1 = (texture.frame.width ) * -aX;

      h0 = texture.frame.height * (1 - aY);
      h1 = texture.frame.height * -aY;
    }

    int index = this.currentBatchSize * 4 * this.vertSize;

    Matrix worldTransform = sprite.worldTransform;//.toArray();

    num a = worldTransform.a;//[0];
    num b = worldTransform.c;//[3];
    num c = worldTransform.b;//[1];
    num d = worldTransform.d;//[4];
    num tx = worldTransform.tx;//[2];
    num ty = worldTransform.ty;///[5];

    //print(tint);
    //print("${uvs.x0} ${uvs.y0} ${uvs.x1} ${uvs.y1} ${uvs.x2} ${uvs.y2} ${uvs.x3} ${uvs.y3}");
    //print("$alpha $tint");
    //print("$a * $w1 + $c * $h1 + $tx");
    // xy


    verticies[index++] =  a * w1 + c * h1 + tx;
    verticies[index++] =  d * h1 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x0;
    verticies[index++] = uvs.y0;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // xy
    verticies[index++] = a * w0 + c * h1 + tx;
    verticies[index++] = d * h1 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x1;
    verticies[index++] = uvs.y1;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // xy
    verticies[index++] = a * w0 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x2;
    verticies[index++] = uvs.y2;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // xy
    verticies[index++] = a * w1 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x3;
    verticies[index++] = uvs.y3;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // increment the batchsize
    this.currentBatchSize++;
    //print(this.currentBatchSize);

  }

  renderTilingSprite(TilingSprite tilingSprite) {
    Texture texture = tilingSprite.tilingTexture;

    if (texture.baseTexture != this.currentBaseTexture || this.currentBatchSize >= this.size) {
      this.flush();
      this.currentBaseTexture = texture.baseTexture;
    }

    // check blend mode
    if (tilingSprite.blendMode != this.currentBlendMode) {
      this.setBlendMode(tilingSprite.blendMode);
    }

    // set the textures uvs temporarily
    // TODO create a separate texture so that we can tile part of a texture

    if (tilingSprite._uvs == null)tilingSprite._uvs = new TextureUvs();

    TextureUvs uvs = tilingSprite._uvs;

    tilingSprite.tilePosition.x %= texture.baseTexture.width * tilingSprite.tileScaleOffset.x;
    tilingSprite.tilePosition.y %= texture.baseTexture.height * tilingSprite.tileScaleOffset.y;

    num offsetX = tilingSprite.tilePosition.x / (texture.baseTexture.width * tilingSprite.tileScaleOffset.x);
    num offsetY = tilingSprite.tilePosition.y / (texture.baseTexture.height * tilingSprite.tileScaleOffset.y);

    num scaleX = (tilingSprite.width / texture.baseTexture.width) / (tilingSprite.tileScale.x * tilingSprite.tileScaleOffset.x);
    num scaleY = (tilingSprite.height / texture.baseTexture.height) / (tilingSprite.tileScale.y * tilingSprite.tileScaleOffset.y);

    uvs.x0 = 0 - offsetX;
    uvs.y0 = 0 - offsetY;

    uvs.x1 = (1 * scaleX) - offsetX;
    uvs.y1 = 0 - offsetY;

    uvs.x2 = (1 * scaleX) - offsetX;
    uvs.y2 = (1 * scaleY) - offsetY;

    uvs.x3 = 0 - offsetX;
    uvs.y3 = (1 * scaleY) - offsetY;

    // get the tilingSprites current alpha
    num alpha = tilingSprite.worldAlpha;
    num tint = tilingSprite.tint.toDouble();

    Float32List verticies = this.vertices;

    num width = tilingSprite.width;
    num height = tilingSprite.height;

    // TODO trim??
    num aX = tilingSprite.anchor.x; // - tilingSprite.texture.trim.x
    num aY = tilingSprite.anchor.y; //- tilingSprite.texture.trim.y
    num w0 = width * (1 - aX);
    num w1 = width * -aX;

    num h0 = height * (1 - aY);
    num h1 = height * -aY;

    int index = this.currentBatchSize * 4 * this.vertSize;

    Matrix worldTransform = tilingSprite.worldTransform;

    num a = worldTransform.a;//[0];
    num b = worldTransform.c;//[3];
    num c = worldTransform.b;//[1];
    num d = worldTransform.d;//[4];
    num tx = worldTransform.tx;//[2];
    num ty = worldTransform.ty;///[5];

    // xy
    verticies[index++] = a * w1 + c * h1 + tx;
    verticies[index++] = d * h1 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x0;
    verticies[index++] = uvs.y0;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // xy
    verticies[index++] = a * w0 + c * h1 + tx;
    verticies[index++] = d * h1 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x1;
    verticies[index++] = uvs.y1;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // xy
    verticies[index++] = a * w0 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w0 + ty;
    // uv
    verticies[index++] = uvs.x2;
    verticies[index++] = uvs.y2;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // xy
    verticies[index++] = a * w1 + c * h0 + tx;
    verticies[index++] = d * h0 + b * w1 + ty;
    // uv
    verticies[index++] = uvs.x3;
    verticies[index++] = uvs.y3;
    // color
    verticies[index++] = alpha;
    verticies[index++] = tint;

    // increment the batchs
    this.currentBatchSize++;
  }


  flush() {
    // If the batch is length 0 then return as there is nothing to draw
    if (this.currentBatchSize == 0) return;

    //var gl = this.gl;

    // bind the current texture
    var texture = this.currentBaseTexture._glTextures[gl];

    if (texture == null) {
      texture = createWebGLTexture(this.currentBaseTexture, gl);
    }
    //print(texture);
    gl.bindTexture(TEXTURE_2D, texture);

    // upload the verts to the buffer

    if (this.currentBatchSize > ( this.size * 0.5 )) {
      gl.bufferSubData(ARRAY_BUFFER, 0, this.vertices);
    }
    else {
      var view = this.vertices.sublist(0, this.currentBatchSize * 4 * this.vertSize);

      gl.bufferSubData(ARRAY_BUFFER, 0, view);
    }

    // var view = this.vertices.subarray(0, this.currentBatchSize * 4 * this.vertSize);
    //gl.bufferSubData(gl.ARRAY_BUFFER, 0, view);

    // now draw those suckas!
    //print("here");
    gl.drawElements(TRIANGLES, this.currentBatchSize * 6, UNSIGNED_SHORT, 0);

    // then reset the batch!
    this.currentBatchSize = 0;

    // increment the draw count
    this.renderSession.drawCount++;
  }


  stop() {
    this.flush();
  }

  start() {
    var gl = this.gl;

    // bind the main texture
    gl.activeTexture(TEXTURE0);

    // bind the buffers
    gl.bindBuffer(ARRAY_BUFFER, this.vertexBuffer);
    gl.bindBuffer(ELEMENT_ARRAY_BUFFER, this.indexBuffer);

    // set the projection
    var projection = this.renderSession.projection;
    //print(projection.y);
    gl.uniform2f(this.shader.projectionVector, projection.x, projection.y);

    // set the pointers
    var stride = this.vertSize * 4;
    gl.vertexAttribPointer(this.shader.aVertexPosition, 2, FLOAT, false, stride, 0);
    gl.vertexAttribPointer(this.shader.aTextureCoord, 2, FLOAT, false, stride, 2 * 4);
    gl.vertexAttribPointer(this.shader.colorAttribute, 2, FLOAT, false, stride, 4 * 4);

    // set the blend mode..
    if (this.currentBlendMode != blendModes.NORMAL) {
      this.setBlendMode(blendModes.NORMAL);
    }
  }

  setBlendMode(blendModes blendMode) {
    this.flush();

    this.currentBlendMode = blendMode;

    var blendModeWebGL = blendModesWebGL[this.currentBlendMode];
    this.gl.blendFunc(blendModeWebGL[0], blendModeWebGL[1]);
  }


  destroy() {

    this.vertices = null;
    this.indices = null;

    this.gl.deleteBuffer(this.vertexBuffer);
    this.gl.deleteBuffer(this.indexBuffer);

    this.currentBaseTexture = null;

    this.gl = null;
  }
}
