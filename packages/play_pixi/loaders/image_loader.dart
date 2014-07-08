part of PIXI;

class ImageLoader extends Loader {
  Texture texture = null;
  List<Rectangle> frames = [];

  ImageLoader(String url, bool crossorigin)
  :super(url, crossorigin) {
    this.texture = Texture.fromImage(url, crossorigin);
  }

  load() {
    if (!this.texture.baseTexture.hasLoaded) {
      this.texture.baseTexture.addEventListener('loaded', (e) {
        onLoaded();
      });
    }
    else {
      this.onLoaded();
    }
  }

  onLoaded() {
    this.dispatchEvent(new PixiEvent()
      ..type = 'loaded'
      ..content = this);
  }

  loadFramedSpriteSheet(frameWidth, frameHeight, textureName) {
    this.frames = [];
    var cols = (this.texture.width / frameWidth).floor();
    var rows = (this.texture.height / frameHeight).floor();

    var i = 0;
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++, i++) {
        var texture = new Texture(this.texture, new Rectangle()
          ..x = x * frameWidth
          ..y = y * frameHeight
          ..width = frameWidth
          ..height = frameHeight
        );

        this.frames.add(texture);
        if (textureName) TextureCache[textureName + '-' + i] = texture;
      }
    }

    if (!this.texture.baseTexture.hasLoaded) {
      var scope = this;
      this.texture.baseTexture.addEventListener('loaded', (e) {
        scope.onLoaded();
      });
    }
    else {
      this.onLoaded();
    }
  }
}
