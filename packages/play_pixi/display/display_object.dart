part of PIXI;

class DisplayObject {

  Point position = new Point();
  Point scale = new Point(1, 1);
  Point pivot = new Point(0, 0);
  num rotation = 0;
  num alpha = 1;
  bool visible = true;
  Rectangle hitArea = null;

  bool renderable = false;
  DisplayObjectContainer parent = null;
  DisplayObjectContainer __iParent = null;
  bool interactiveChildren = false;
  bool __hit = false;
  bool __isOver = false;
  bool __mouseIsDown = false;
  bool __isDown = false;

  Function click;
  Function mousemove;
  Function mousedown;
  Function mouseout;
  Function mouseover;
  Function mouseup;
  Function mouseupoutside;


  //bool buttonMode = false;
  //DisplayObjectContainer get parent => _parent;

  Stage stage = null;
  bool buttonMode = false;

  //Stage get stage => _stage;

  num worldAlpha = 1.0;

  //num get worldAlpha => _worldAlpha;

  bool _interactive = false;

  bool get interactive => _interactive ;

  set interactive(value) {
    _interactive = value;
    if (this.stage != null) this.stage.dirty = true;
  }

  String defaultCursor = 'pointer';

  Matrix worldTransform = new Matrix();

//  Matrix get worldTransform => _worldTransform ;

  List color = [];

  bool dynamic = true;

  num _sr = 0;
  num _cr = 1;

  Rectangle filterArea = null;

  Rectangle _bounds = new Rectangle(0, 0, 1, 1);

  Rectangle _currentBounds = null;

  Rectangle _mask = null;

  Rectangle get mask => _mask;

  set mask(Rectangle value) {
    if (this._mask != null)this._mask.isMask = false;
    this._mask = value;
    if (this._mask != null)this._mask.isMask = true;
  }

  bool _cacheAsBitmap = false;

  bool get cacheAsBitmap => _cacheAsBitmap;

  Sprite _cachedSprite;

  set cacheAsBitmap(bool value) {
    if (this._cacheAsBitmap == value)return;

    if (value) {
      //this._cacheIsDirty = true;
      this._generateCachedSprite();
    }
    else {
      this._destroyCachedSprite();
    }

    this._cacheAsBitmap = value;
  }


  bool _cacheIsDirty = false;

  bool get worldVisible {
    DisplayObject item = this;

    do {
      if (!item.visible) return false;
      item = item.parent;
    }
    while (item != null);

    return true;
  }

  FilterBlock _filterBlock = new FilterBlock();

  List<AbstractFilter> _filters = null;

  List<AbstractFilter> get filters => _filters;

  set filters(List<AbstractFilter> value) {
    if (value != null) {
      // now put all the passes in one place..
      List<AbstractFilter> passes = [];
      for (int i = 0; i < value.length; i++) {
        List<AbstractFilter> filterPasses = value[i].passes;
        for (int j = 0; j < filterPasses.length; j++) {
          passes.add(filterPasses[j]);
        }
      }

      // TODO change this as it is legacy
      this._filterBlock.target = this;
      this._filterBlock.filterPasses = passes;
//          'target':this, 'filterPasses':passes
//      };
    }

    this._filters = value;
  }

  num rotationCache = 0;

  void updateTransform() {
    // TODO OPTIMIZE THIS!! with dirty
    if (this.rotation != this.rotationCache) {

      this.rotationCache = this.rotation;
      this._sr = sin(this.rotation);
      this._cr = cos(this.rotation);
    }
    //print("updated");

    Matrix parentTransform = this.parent.worldTransform;
    Matrix worldTransform = this.worldTransform;

    num px = this.pivot.x;
    num py = this.pivot.y;

    num a00 = this._cr * this.scale.x,
    a01 = -this._sr * this.scale.y,
    a10 = this._sr * this.scale.x,
    a11 = this._cr * this.scale.y,
    a02 = this.position.x - a00 * px - py * a01,
    a12 = this.position.y - a11 * py - px * a10,
    b00 = parentTransform.a, b01 = parentTransform.b,
    b10 = parentTransform.c, b11 = parentTransform.d;

    worldTransform.a = b00 * a00 + b01 * a10;
    worldTransform.b = b00 * a01 + b01 * a11;
    worldTransform.tx = b00 * a02 + b01 * a12 + parentTransform.tx;

    worldTransform.c = b10 * a00 + b11 * a10;
    worldTransform.d = b10 * a01 + b11 * a11;
    worldTransform.ty = b10 * a02 + b11 * a12 + parentTransform.ty;

    this.worldAlpha = this.alpha * this.parent.worldAlpha;
  }

  Rectangle getBounds([Matrix matrix]) {
    matrix = matrix;//just to get passed js hinting (and preserve inheritance)
    return EmptyRectangle;
  }

  Rectangle getLocalBounds() {
    return this.getBounds(IdentityMatrix);
  }

  setStageReference(Stage stage) {
    this.stage = stage;
    if (this._interactive)this.stage.dirty = true;
  }

  RenderTexture generateTexture(Renderer renderer) {
    Rectangle bounds = this.getLocalBounds();

    RenderTexture renderTexture = new RenderTexture(bounds.width.floor(), bounds.height.floor(), renderer);
    renderTexture.render(this, new Point(-bounds.x, -bounds.y));

    return renderTexture;
  }

  updateCache() {
    this._generateCachedSprite();
  }

  _renderCachedSprite(RenderSession renderSession) {
    if (renderSession.gl != null) {
      this._cachedSprite._renderWebGL(renderSession);
      //PIXI.Sprite.prototype._renderWebGL.call(this._cachedSprite, renderSession);
    }
    else {
      this._cachedSprite._renderCanvas(renderSession);
      //PIXI.Sprite.prototype._renderCanvas.call(this._cachedSprite, renderSession);
    }
  }


  void _generateCachedSprite() {
    this._cacheAsBitmap = false;
    var bounds = this.getLocalBounds();

    if (this._cachedSprite == null) {
      var renderTexture = new RenderTexture(bounds.width.floor(), bounds.height.floor());//, renderSession.renderer);

      this._cachedSprite = new Sprite(renderTexture);
      this._cachedSprite.worldTransform = this.worldTransform;
    }
    else {
      RenderTexture texture = _cachedSprite.texture as RenderTexture;
      texture.resize(bounds.width.floor(), bounds.height.floor());
    }

    //REMOVE filter!
    var tempFilters = this._filters;
    this._filters = null;

    this._cachedSprite.filters = tempFilters;

    RenderTexture texture = _cachedSprite.texture as RenderTexture;
    texture.render(this, new Point(-bounds.x, -bounds.y), false);

    this._cachedSprite.anchor.x = -( bounds.x / bounds.width );
    this._cachedSprite.anchor.y = -( bounds.y / bounds.height );

    this._filters = tempFilters;

    this._cacheAsBitmap = true;
  }

  void _destroyCachedSprite() {
    if (this._cachedSprite == null)return;

    this._cachedSprite.texture.destroy(true);
    //  console.log("DESTROY")
    // let the gc collect the unused sprite
    // TODO could be object pooled!
    this._cachedSprite = null;
  }

  void _renderWebGL(RenderSession renderSession) {

    // OVERWRITE;
    // this line is just here to pass jshinting :)
    renderSession = renderSession;
  }

  void _renderCanvas(renderSession) {
    // OVERWRITE;
    // this line is just here to pass jshinting :)
    renderSession = renderSession;
  }

  num get x => position.x;

  void set x(num value) {
    position.x = value;
  }

  num get y => position.y;

  void set y(num value) {
    position.y = value;
  }

}
