part of PIXI;

Map TextureCache = {
};
Map FrameCache = {
};

int TextureCacheIdGenerator = 0;

class Texture extends BaseTexture {
  bool noFrame = false;
  bool updateFrame = false;
  Rectangle frame;
  Rectangle trim = null;
  BaseTexture scope;
  TextureUvs _uvs = null;
  static List<Texture> frameUpdates = [];

  BaseTexture baseTexture;



  Map tintCache;

  bool needsUpdate =true;

  bool isTiling;

  CanvasBuffer canvasBuffer;

  Texture._(){
    scope = this;
  }

  Texture(BaseTexture baseTexture, [this.frame]) {

    scope = this;
    //PIXI.EventTarget.call( this );
    if (frame == null) {
      noFrame = true;
      frame = new Rectangle(0, 0, 1, 1);
    }



    if (baseTexture is Texture)
      baseTexture = (baseTexture as Texture).baseTexture;
    this.baseTexture = baseTexture;

    if (baseTexture.hasLoaded) {

      if (this.noFrame)frame = new Rectangle(0, 0, baseTexture.width, baseTexture.height);

      this.setFrame(frame);
    }
    else {
      var scope = this;
      baseTexture.addEventListener('loaded', (e) {
        scope.onBaseTextureLoaded();
      });
    }


  }

  void onBaseTextureLoaded() {
    var baseTexture = this.baseTexture;
    baseTexture.removeEventListener('loaded', this.onBaseTextureLoaded);

    if (this.noFrame)this.frame = new Rectangle(0, 0, baseTexture.width, baseTexture.height);

    this.setFrame(this.frame);

    this.scope.dispatchEvent(new PixiEvent(type:'update', content: this));
  }

  destroy([bool destroyBase=false]) {
    if (destroyBase) this.baseTexture.destroy();
  }

  setFrame(Rectangle frame) {
    this.frame = frame;
    this.width = frame.width;
    this.height = frame.height;

    //print("$width ${frame.x} ${this.baseTexture.width } $height  ${frame.y} ${this.baseTexture.height}");

    if (frame.x + frame.width > this.baseTexture.width || frame.y + frame.height > this.baseTexture.height) {
      throw new Exception('Texture Error: frame does not fit inside the base Texture dimensions');
    }

    this.updateFrame = true;

    Texture.frameUpdates.add(this);


    //this.dispatchEvent( { type: 'update', content: this } );
  }

  void _updateWebGLuvs() {

    if (this._uvs ==null)this._uvs = new TextureUvs();

    Rectangle frame = this.frame;
    num tw = this.baseTexture.width;
    num th = this.baseTexture.height;

    this._uvs.x0 = frame.x / tw;
    this._uvs.y0 = frame.y / th;

    this._uvs.x1 = (frame.x + frame.width) / tw;
    this._uvs.y1 = frame.y / th;

    this._uvs.x2 = (frame.x + frame.width) / tw;
    this._uvs.y2 = (frame.y + frame.height) / th;

    this._uvs.x3 = frame.x / tw;
    this._uvs.y3 = (frame.y + frame.height) / th;
  }

  static Texture fromImage(String imageUrl, [bool crossorigin, scaleModes scaleMode]) {
    var texture = TextureCache[imageUrl];

    if (texture == null) {
      texture = new Texture(BaseTexture.fromImage(imageUrl, crossorigin, scaleMode));
      TextureCache[imageUrl] = texture;
    }

    return texture;
  }

  static Texture fromFrame(String frameId) {
    var texture = TextureCache[frameId];
    if (texture ==null) throw new Exception('The frameId "$frameId" does not exist in the texture cache');
    return texture;
  }

  static Texture fromCanvas(CanvasElement canvas, [ scaleModes scaleMode]) {
    var baseTexture = BaseTexture.fromCanvas(canvas, scaleMode);

    return new Texture(baseTexture);

  }

  static void addTextureToCache(texture, id) {
    TextureCache[id] = texture;
  }

  static Texture removeTextureFromCache(id) {
    var texture = TextureCache[id];
    TextureCache.remove(id);
    BaseTextureCache.remove(id);
    return texture;
  }


//  resize(num width, num height) {
//    throw new Exception();
//  }



}

class TextureUvs {
  num x0 = 0.0, y0 = 0.0, x1 = 0.0, y1 = 0.0, x2 = 0.0, y2 = 0.0, x3 = 0.0, y3 = 0.0;
}