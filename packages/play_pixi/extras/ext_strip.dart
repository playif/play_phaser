part of PIXI;

class Strip extends DisplayObjectContainer{

  Texture texture;
  num width;
  num height;
  blendModes blendMode = blendModes.NORMAL;
  Float32List uvs;
  Float32List verticies;
  Float32List colors;
  Uint16List indices;

  bool updateFrame = false;

  Strip(this.texture, this.width, this.height) {
    this.uvs = new Float32List.fromList([0, 1,
    1, 1,
    1, 0, 0, 1]);

    this.verticies = new Float32List.fromList([0, 0,
    0, 0,
    0, 0, 0,
    0, 0]);

    this.colors = new Float32List.fromList([1, 1, 1, 1]);

    this.indices = new Uint16List.fromList([0, 1, 2, 3]);


    // load the texture!
    if (texture.baseTexture.hasLoaded) {
      this.width = this.texture.frame.width;
      this.height = this.texture.frame.height;
      this.updateFrame = true;
    }
    else {
      //this.onTextureUpdateBind = this.onTextureUpdate.bind(this);
      this.texture.addEventListener('update', onTextureUpdate);
    }

    this.renderable = true;
  }

  setTexture(Texture texture) {
    //TODO SET THE TEXTURES
    //TODO VISIBILITY

    // stop current texture
    this.texture = texture;
    this.width = texture.frame.width;
    this.height = texture.frame.height;
    this.updateFrame = true;
  }

  onTextureUpdate(e) {
    this.updateFrame = true;
  }
}
