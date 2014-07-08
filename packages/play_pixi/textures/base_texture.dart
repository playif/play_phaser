part of PIXI;

Map<String, BaseTexture> BaseTextureCache = {
};
List texturesToUpdate = [];
List texturesToDestroy = [];

int BaseTextureCacheIdGenerator = 0;

class BaseTexture extends EventTarget {
  int id = BaseTextureCacheIdGenerator++;
  num width = 100, height = 100;
  scaleModes scaleMode;

  bool _hasLoaded = false;

  bool get hasLoaded => _hasLoaded;

  void set hasLoaded(value) {
    _hasLoaded = value;
  }

  var source;

  Map<RenderingContext, dynamic> _glTextures = new Map<RenderingContext, dynamic>();

  String imageUrl = null;

  bool _powerOf2 = false;

  EventFunc onLoaded;


  BaseTexture([this.source, this.scaleMode=scaleModes.DEFAULT]) {

    if (source == null) return;


    //
    if (( (source is ImageElement && source.complete != null )
          || (source is CanvasElement) )
        && this.source.width != 0 && this.source.height != 0) {

      this._hasLoaded = true;
      this.width = this.source.width;
      this.height = this.source.height;

      texturesToUpdate.add(this);
    }
    else {

      BaseTexture scope = this;
      //window.console.log(source);
      this.source.onLoad.listen((e) {

        scope.hasLoaded = true;
        scope.width = scope.source.width;
        scope.height = scope.source.height;

        // add it to somewhere...
        texturesToUpdate.add(scope);
        scope.dispatchEvent(new PixiEvent(type: 'loaded', content: scope));
      });
    }
  }


  void destroy() {
    if (this.imageUrl != null) {
      BaseTextureCache.remove(this.imageUrl);
      this.imageUrl = null;
      this.source.src = null;
    }
    this.source = null;
    texturesToDestroy.add(this);
  }

  updateSourceImage(String newSrc) {
    this._hasLoaded = false;
    this.source.src = null;
    this.source.src = newSrc;
  }

  static BaseTexture fromImage(String imageUrl, bool crossorigin, scaleModes scaleMode) {
    var baseTexture = BaseTextureCache[imageUrl];

    if (crossorigin == null && imageUrl.indexOf('data:') == -1) crossorigin = true;

    if (baseTexture == null) {
      // new Image() breaks tex loading in some versions of Chrome.
      // See https://code.google.com/p/chromium/issues/detail?id=238071
      var image = new ImageElement();//document.createElement('img');
      if (crossorigin) {
        image.crossOrigin = '';
      }
      image.src = imageUrl;
      //print("here");
      baseTexture = new BaseTexture(image, scaleMode);
      baseTexture.imageUrl = imageUrl;
      BaseTextureCache[imageUrl] = baseTexture;
    }

    return baseTexture;
  }

  static BaseTexture fromCanvas(CanvasElement canvas, scaleModes scaleMode) {
    if (canvas.dataset['_pixiId'] == null) {
      canvas.dataset['_pixiId'] = "canvas_${TextureCacheIdGenerator++}";
    }

    var baseTexture = BaseTextureCache[canvas.dataset['_pixiId']];

    if (baseTexture == null) {
      baseTexture = new BaseTexture(canvas, scaleMode);
      BaseTextureCache[canvas.dataset['_pixiId']] = baseTexture;
    }

    return baseTexture;
  }

}
