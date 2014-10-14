part of Phaser;

class MapCache {
  num cw,
  ch,
  ga = 1,
  dx = 0,
  dy = 0,
  dw = 0,
  dh = 0,
  tx = 0,
  ty = 0,
  tw = 0,
  th = 0,
  tl = 0,
  maxX = 0,
  maxY = 0,
  startX = 0,
  startY = 0,
  x = 0,
  y = 0,
  prevX = 0,
  prevY = 0;
}

class TilemapLayerData {
  String name;
  num x;
  num y;
  num width;
  num height;
  num widthInPixels;
  num heightInPixels;
  num alpha;
  bool visible;
  Map properties;
  List<int> indexes;
  List<Function> callbacks;
  List<Body> bodies;
  List<List<Tile>> data;

  bool dirty = false;
}

class TilemapLayer extends Image {


  Game game;
  Tilemap map;

  int index;

  TilemapLayerData layer;
  CanvasElement canvas;
  CanvasRenderingContext2D context;
  PIXI.BaseTexture baseTexture;
  PIXI.Texture texture;
  Frame textureFrame;
  String name;
  int type;

  Point cameraOffset;
  String tileColor;
  bool debug;
  num debugAlpha;
  String debugColor;
  bool debugFill;
  String debugFillColor;
  String debugCallbackColor;
  num scrollFactorX;
  num scrollFactorY;
  bool dirty;
  num rayStepRate;
  bool wrap;
  MapCache _mc;
  List _results;

  List<Tile> _column;
  


  /**
   * @name Phaser.TilemapLayer#scrollX
   * @property {number} scrollX - Scrolls the map horizontally or returns the current x position.
   */
  //Object.defineProperty(Phaser.TilemapLayer.prototype, "scrollX", {

  num get scrollX {
    return this._mc.x;
  }

  set scrollX(num value) {

    if (value != this._mc.x) {
      this._mc.x = value;
      this._mc.startX = Math.floor(this._mc.x / this.map.tileWidth);
      this.dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.TilemapLayer#scrollY
   * @property {number} scrollY - Scrolls the map vertically or returns the current y position.
   */
  //Object.defineProperty(Phaser.TilemapLayer.prototype, "scrollY", {

  num get scrollY {
    return this._mc.y;
  }

  set scrollY(num value) {

    if (value != this._mc.y) {
      this._mc.y = value;
      this._mc.startY = Math.floor(this._mc.y / this.map.tileHeight);
      this.dirty = true;
    }

  }

  //});

  /**
   * @name Phaser.TilemapLayer#collisionWidth
   * @property {number} collisionWidth - The width of the collision tiles.
   */
  //Object.defineProperty(Phaser.TilemapLayer.prototype, "collisionWidth", {

  num get collisionWidth {
    return this._mc.cw;
  }

  set collisionWidth(num value) {

    this._mc.cw = value;

    this.dirty = true;

  }

  //});

  /**
   * @name Phaser.TilemapLayer#collisionHeight
   * @property {number} collisionHeight - The height of the collision tiles.
   */
  //Object.defineProperty(Phaser.TilemapLayer.prototype, "collisionHeight", {

  num get collisionHeight {
    return this._mc.ch;
  }

  set collisionHeight(num value) {

    this._mc.ch = value;

    this.dirty = true;

  }

  //});

  TilemapLayer(Game game, [Tilemap tilemap, int index, num width, num height])
  : super(game) {

    /**
     * @property {Phaser.Game} game - A reference to the currently running Game.
     */
    this.game = game;

    /**
     * @property {Phaser.Tilemap} map - The Tilemap to which this layer is bound.
     */
    this.map = tilemap;

    /**
     * @property {number} index - The index of this layer within the Tilemap.
     */
    this.index = index;

    /**
     * @property {object} layer - The layer object within the Tilemap that this layer represents.
     */
    this.layer = tilemap.layers[index];

    /**
     * @property {HTMLCanvasElement} canvas - The canvas to which this TilemapLayer draws.
     */
    this.canvas = Canvas.create(width, height, '');

    /**
     * @property {CanvasRenderingContext2D} context - The 2d context of the canvas.
     */
    this.context = this.canvas.getContext('2d');

    /**
     * @property {PIXI.BaseTexture} baseTexture - Required Pixi var.
     */
    this.baseTexture = new PIXI.BaseTexture(this.canvas);

    /**
     * @property {PIXI.Texture} texture - Required Pixi var.
     */
    this.texture = new PIXI.Texture(this.baseTexture);

    /**
     * @property {Phaser.Frame} textureFrame - Dimensions of the renderable area.
     */
    this.textureFrame = new Frame(0, 0, 0, width, height, 'tilemapLayer', game.rnd.uuid());

    //Phaser.Image.call(this, this.game, 0, 0, this.texture, this.textureFrame);

    /**
     * @property {string} name - The name of the layer.
     */
    this.name = '';

    /**
     * @property {number} type - The const type of this object.
     * @default
     */
    this.type = TILEMAPLAYER;

    /**
     * An object that is fixed to the camera ignores the position of any ancestors in the display list and uses its x/y coordinates as offsets from the top left of the camera.
     * @property {boolean} fixedToCamera - Fixes this object to the Camera.
     * @default
     */
    this.fixedToCamera = true;

    /**
     * @property {Phaser.Point} cameraOffset - If this object is fixed to the camera then use this Point to specify how far away from the Camera x/y it's rendered.
     */
    this.cameraOffset = new Point(0, 0);

    /**
     * @property {string} tileColor - If no tileset is given the tiles will be rendered as rectangles in this color. Provide in hex or rgb/rgba string format.
     * @default
     */
    this.tileColor = 'rgb(255, 255, 255)';

    /**
     * @property {boolean} debug - If set to true the collideable tile edges path will be rendered. Only works when game is running in Phaser.CANVAS mode.
     * @default
     */
    this.debug = false;

    /**
     * @property {number} debugAlpha - If debug is true then the tileset is rendered with this alpha level, to make the tile edges clearer.
     * @default
     */
    this.debugAlpha = 0.5;

    /**
     * @property {string} debugColor - If debug is true this is the color used to outline the edges of collidable tiles. Provide in hex or rgb/rgba string format.
     * @default
     */
    this.debugColor = 'rgba(0, 255, 0, 1)';

    /**
     * @property {boolean} debugFill - If true the debug tiles are filled with debugFillColor AND stroked around.
     * @default
     */
    this.debugFill = false;

    /**
     * @property {string} debugFillColor - If debugFill is true this is the color used to fill the tiles. Provide in hex or rgb/rgba string format.
     * @default
     */
    this.debugFillColor = 'rgba(0, 255, 0, 0.2)';

    /**
     * @property {string} debugCallbackColor - If debug is true this is the color used to outline the edges of tiles that have collision callbacks. Provide in hex or rgb/rgba string format.
     * @default
     */
    this.debugCallbackColor = 'rgba(255, 0, 0, 1)';

    /**
     * @property {number} scrollFactorX - speed at which this layer scrolls
     * horizontally, relative to the camera (e.g. scrollFactorX of 0.5 scrolls
     * half as quickly as the 'normal' camera-locked layers do)
     * @default 1
     */
    this.scrollFactorX = 1;

    /**
     * @property {number} scrollFactorY - speed at which this layer scrolls
     * vertically, relative to the camera (e.g. scrollFactorY of 0.5 scrolls
     * half as quickly as the 'normal' camera-locked layers do)
     * @default 1
     */
    this.scrollFactorY = 1;

    /**
     * @property {boolean} dirty - Flag controlling when to re-render the layer.
     */
    this.dirty = true;

    /**
     * @property {number} rayStepRate - When ray-casting against tiles this is the number of steps it will jump. For larger tile sizes you can increase this to improve performance.
     * @default
     */
    this.rayStepRate = 4;

    /**
     * @property {boolean} wrap - Flag controlling if the layer tiles wrap at the edges. Only works if the World size matches the Map size.
     * @default false
     */
    this.wrap = false;

    /**
     * @property {object} _mc - Local map data and calculation cache.
     * @private
     */
    this._mc = new MapCache()
      ..cw = tilemap.tileWidth
      ..ch = tilemap.tileHeight;


    /**
     * @property {array} _results - Local render loop var to help avoid gc spikes.
     * @private
     */
    this._results = [];

    this.updateMax();

  }

  /**
   * Automatically called by World.postUpdate. Handles cache updates.
   *
   * @method Phaser.TilemapLayer#postUpdate
   * @memberof Phaser.TilemapLayer
   */

  postUpdate() {

    super.postUpdate();

    //  Stops you being able to auto-scroll the camera if it's not following a sprite
    this.scrollX = this.game.camera.x * this.scrollFactorX;
    this.scrollY = this.game.camera.y * this.scrollFactorY;

    this.render();

    //  Fixed to Camera?
    if (this._cache[7] == 1) {
      this.position.x = (this.game.camera.view.x + this.cameraOffset.x) / this.game.camera.scale.x;
      this.position.y = (this.game.camera.view.y + this.cameraOffset.y) / this.game.camera.scale.y;
    }

    //  Update any Children
    // for (var i = 0, len = this.children.length; i < len; i++)
    // {
    // this.children[i].postUpdate();
    // }

  }

  /**
   * Sets the world size to match the size of this layer.
   *
   * @method Phaser.TilemapLayer#resizeWorld
   * @memberof Phaser.TilemapLayer
   */

  resizeWorld() {
    this.game.world.setBounds(0, 0, this.layer.widthInPixels, this.layer.heightInPixels);
  }

  /**
   * Take an x coordinate that doesn't account for scrollFactorX and 'fix' it
   * into a scrolled local space. Used primarily internally
   * @method Phaser.TilemapLayer#_fixX
   * @memberof Phaser.TilemapLayer
   * @private
   * @param {number} x - x coordinate in camera space
   * @return {number} x coordinate in scrollFactor-adjusted dimensions
   */

  num _fixX(num x) {

    if (x < 0) {
      x = 0;
    }

    if (this.scrollFactorX == 1) {
      return x;
    }

    return this._mc.x + (x - (this._mc.x / this.scrollFactorX));

  }

  /**
   * Take an x coordinate that _does_ account for scrollFactorX and 'unfix' it
   * back to camera space. Used primarily internally
   * @method Phaser.TilemapLayer#_unfixX
   * @memberof Phaser.TilemapLayer
   * @private
   * @param {number} x - x coordinate in scrollFactor-adjusted dimensions
   * @return {number} x coordinate in camera space
   */

  num _unfixX(num x) {

    if (this.scrollFactorX == 1) {
      return x;
    }

    return (this._mc.x / this.scrollFactorX) + (x - this._mc.x);

  }

  /**
   * Take a y coordinate that doesn't account for scrollFactorY and 'fix' it
   * into a scrolled local space. Used primarily internally
   * @method Phaser.TilemapLayer#_fixY
   * @memberof Phaser.TilemapLayer
   * @private
   * @param {number} y - y coordinate in camera space
   * @return {number} y coordinate in scrollFactor-adjusted dimensions
   */

  num _fixY(num y) {

    if (y < 0) {
      y = 0;
    }

    if (this.scrollFactorY == 1) {
      return y;
    }

    return this._mc.y + (y - (this._mc.y / this.scrollFactorY));

  }

  /**
   * Take a y coordinate that _does_ account for scrollFactorY and 'unfix' it
   * back to camera space. Used primarily internally
   * @method Phaser.TilemapLayer#_unfixY
   * @memberof Phaser.TilemapLayer
   * @private
   * @param {number} y - y coordinate in scrollFactor-adjusted dimensions
   * @return {number} y coordinate in camera space
   */

  num _unfixY(num y) {

    if (this.scrollFactorY == 1) {
      return y;
    }

    return (this._mc.y / this.scrollFactorY) + (y - this._mc.y);

  }

  /**
   * Convert a pixel value to a tile coordinate.
   * @method Phaser.TilemapLayer#getTileX
   * @memberof Phaser.TilemapLayer
   * @param {number} x - X position of the point in target tile.
   * @return {Phaser.Tile} The tile with specific properties.
   */

  int getTileX(num x) {
    return Math.snapToFloor(this._fixX(x), this.map.tileWidth) ~/ this.map.tileWidth;
  }

  /**
   * Convert a pixel value to a tile coordinate.
   * @method Phaser.TilemapLayer#getTileY
   * @memberof Phaser.TilemapLayer
   * @param {number} y - Y position of the point in target tile.
   * @return {Phaser.Tile} The tile with specific properties.
   */

  int getTileY(num y) {
    return Math.snapToFloor(this._fixY(y), this.map.tileHeight) ~/ this.map.tileHeight;
  }

  /**
   * Convert a pixel value to a tile coordinate.
   * @method Phaser.TilemapLayer#getTileXY
   * @memberof Phaser.TilemapLayer
   * @param {number} x - X position of the point in target tile.
   * @param {number} y - Y position of the point in target tile.
   * @param {Phaser.Point|object} point - The Point object to set the x and y values on.
   * @return {Phaser.Point|object} A Point object with its x and y properties set.
   */

  Point getTileXY(x, y, Point point) {
    point.x = this.getTileX(x);
    point.y = this.getTileY(y);
    return point;
  }

  /**
   * Gets all tiles that intersect with the given line.
   *
   * @method Phaser.TilemapLayer#getRayCastTiles
   * @memberof Phaser.TilemapLayer
   * @param {Phaser.Line} line - The line used to determine which tiles to return.
   * @param {number} [stepRate] - How many steps through the ray will we check? If undefined or null it uses TilemapLayer.rayStepRate.
   * @param {boolean} [collides=false] - If true only return tiles that collide on one or more faces.
   * @param {boolean} [interestingFace=false] - If true only return tiles that have interesting faces.
   * @return {array<Phaser.Tile>} An array of Phaser.Tiles.
   */

  List<Tile> getRayCastTiles(Line line, [num stepRate, bool collides = false, bool interestingFace = false]) {

    if (stepRate == null) {
      stepRate = this.rayStepRate;
    }
    //if (typeof collides === 'undefined') { collides = false; }
    //if (typeof interestingFace === 'undefined') { interestingFace = false; }

    //  First get all tiles that touch the bounds of the line
    var tiles = this.getTiles(line.x, line.y, line.width, line.height, collides, interestingFace);

    if (tiles.length == 0) {
      return [];
    }

    //  Now we only want the tiles that intersect with the points on this line
    List<List<num>> coords = line.coordinatesOnLine(stepRate);
    int total = coords.length;
    List results = [];

    for (int i = 0; i < tiles.length; i++) {
      for (int t = 0; t < total; t++) {
        if (tiles[i].containsPoint(coords[t][0], coords[t][1])) {
          results.add(tiles[i]);
          break;
        }
      }
    }

    return results;

  }

  /**
   * Get all tiles that exist within the given area, defined by the top-left corner, width and height. Values given are in pixels, not tiles.
   * @method Phaser.TilemapLayer#getTiles
   * @memberof Phaser.TilemapLayer
   * @param {number} x - X position of the top left corner.
   * @param {number} y - Y position of the top left corner.
   * @param {number} width - Width of the area to get.
   * @param {number} height - Height of the area to get.
   * @param {boolean} [collides=false] - If true only return tiles that collide on one or more faces.
   * @param {boolean} [interestingFace=false] - If true only return tiles that have interesting faces.
   * @return {array<Phaser.Tile>} An array of Phaser.Tiles.
   */

  List<Tile> getTiles(num x, num y, num width, num height, [bool collides = false, bool interestingFace = false]) {

    //  Should we only get tiles that have at least one of their collision flags set? (true = yes, false = no just get them all)
    //if (typeof collides === 'undefined') { collides = false; }
    //if (typeof interestingFace === 'undefined') { interestingFace = false; }

    // adjust the x,y coordinates for scrollFactor
    x = this._fixX(x);
    y = this._fixY(y);

    if (width > this.layer.widthInPixels) {
      width = this.layer.widthInPixels;
    }

    if (height > this.layer.heightInPixels) {
      height = this.layer.heightInPixels;
    }

    //  Convert the pixel values into tile coordinates
    this._mc.tx = Math.snapToFloor(x, this._mc.cw) ~/ this._mc.cw;
    this._mc.ty = Math.snapToFloor(y, this._mc.ch) ~/ this._mc.ch;
    this._mc.tw = (Math.snapToCeil(width, this._mc.cw) + this._mc.cw) ~/ this._mc.cw;
    this._mc.th = (Math.snapToCeil(height, this._mc.ch) + this._mc.ch) ~/ this._mc.ch;

    //  This should apply the layer x/y here
    this._results.clear();

    for (int wy = this._mc.ty; wy < this._mc.ty + this._mc.th; wy++) {
      for (int wx = this._mc.tx; wx < this._mc.tx + this._mc.tw; wx++) {
        if (this.layer.data.length > wy && this.layer.data[wy].length > wx) {
          if ((!collides && !interestingFace) || this.layer.data[wy][wx].isInteresting(collides, interestingFace)) {
            this._results.add(this.layer.data[wy][wx]);
          }
        }
      }
    }

    return this._results;

  }

  /**
   * Internal function to update maximum values.
   * @method Phaser.TilemapLayer#updateMax
   * @memberof Phaser.TilemapLayer
   */

  updateMax() {

    this._mc.maxX = Math.ceil(this.canvas.width / this.map.tileWidth) + 1;
    this._mc.maxY = Math.ceil(this.canvas.height / this.map.tileHeight) + 1;

    this.dirty = true;

  }

  /**
   * Renders the tiles to the layer canvas and pushes to the display.
   * @method Phaser.TilemapLayer#render
   * @memberof Phaser.TilemapLayer
   */

  render() {

    if (this.layer.dirty) {
      this.dirty = true;
    }

    if (!this.dirty || !this.visible) {
      return false;
    }

    this._mc.prevX = this._mc.dx;
    this._mc.prevY = this._mc.dy;

    this._mc.dx = -(this._mc.x - (this._mc.startX * this.map.tileWidth));
    this._mc.dy = -(this._mc.y - (this._mc.startY * this.map.tileHeight));

    this._mc.tx = this._mc.dx;
    this._mc.ty = this._mc.dy;

    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);

    this.context.fillStyle = this.tileColor;

    Tile tile;
    Tileset set;

    if (this.debug) {
      this.context.globalAlpha = this.debugAlpha;
    }

    for (int y = this._mc.startY,
    lenY = this._mc.startY + this._mc.maxY; y < lenY; y++) {
      this._column = null;

      if (y < 0 && this.wrap) {
        this._column = this.layer.data[y + this.map.height];
      } else if (y >= this.map.height && this.wrap) {
        this._column = this.layer.data[y - this.map.height];
      } else if (this.layer.data.length > y) {
        this._column = this.layer.data[y];
      }

      if (this._column != null) {
        for (int x = this._mc.startX,
        lenX = this._mc.startX + this._mc.maxX; x < lenX; x++) {
          tile = null;

          if (x < 0 && this.wrap) {
            tile = this._column[x + this.map.width];
          } else if (x >= this.map.width && this.wrap) {
            tile = this._column[x - this.map.width];
          } else if (this._column.length > x) {
            tile = this._column[x];
          }

          if (tile != null && tile.index > -1 && tile.index < this.map.tiles.length ) {
            set = this.map.tilesets[this.map.tiles[tile.index.toInt()][2]];

            if (this.debug == false && tile.alpha != this.context.globalAlpha) {
              this.context.globalAlpha = tile.alpha;
            }

            set.draw(this.context, Math.floor(this._mc.tx), Math.floor(this._mc.ty), tile.index.toInt());

            if (tile.debug) {
              this.context.fillStyle = 'rgba(0, 255, 0, 0.4)';
              this.context.fillRect(Math.floor(this._mc.tx), Math.floor(this._mc.ty), this.map.tileWidth, this.map.tileHeight);
            }
          }

          this._mc.tx += this.map.tileWidth;

        }

      }

      this._mc.tx = this._mc.dx;
      this._mc.ty += this.map.tileHeight;

    }

    if (this.debug) {
      this.context.globalAlpha = 1;
      this.renderDebug();
    }

    if (this.game.renderType == WEBGL) {
      // PIXI.updateWebGLTexture(this.baseTexture, renderSession.gl);
      PIXI.updateWebGLTexture(this.baseTexture, this.game.renderer.gl);
    }

    this.dirty = false;
    this.layer.dirty = false;

    return true;

  }

  /**
   * Renders a collision debug overlay on-top of the canvas. Called automatically by render when debug = true.
   * @method Phaser.TilemapLayer#renderDebug
   * @memberof Phaser.TilemapLayer
   */

  renderDebug() {

    this._mc.tx = this._mc.dx;
    this._mc.ty = this._mc.dy;

    this.context.strokeStyle = this.debugColor;
    this.context.fillStyle = this.debugFillColor;

    for (int y = this._mc.startY,
    lenY = this._mc.startY + this._mc.maxY; y < lenY; y++) {
      this._column = null;

      if (y < 0 && this.wrap) {
        this._column = this.layer.data[y + this.map.height];
      } else if (y >= this.map.height && this.wrap) {
        this._column = this.layer.data[y - this.map.height];
      } else if (this.layer.data.length > y) {
        this._column = this.layer.data[y];
      }

      if (this._column != null) {
        for (int x = this._mc.startX,
        lenX = this._mc.startX + this._mc.maxX; x < lenX; x++) {
          Tile tile = null;

          if (x < 0 && this.wrap) {
            tile = this._column[x + this.map.width];
          } else if (x >= this.map.width && this.wrap) {
            tile = this._column[x - this.map.width];
          } else if (this._column.length > x) {
            tile = this._column[x];
          }

          if (tile != null && (tile.faceTop || tile.faceBottom || tile.faceLeft || tile.faceRight)) {
            this._mc.tx = Math.floor(this._mc.tx);

            if (this.debugFill) {
              this.context.fillRect(this._mc.tx, this._mc.ty, this._mc.cw, this._mc.ch);
            }

            this.context.beginPath();

            if (tile.faceTop) {
              this.context.moveTo(this._mc.tx, this._mc.ty);
              this.context.lineTo(this._mc.tx + this._mc.cw, this._mc.ty);
            }

            if (tile.faceBottom) {
              this.context.moveTo(this._mc.tx, this._mc.ty + this._mc.ch);
              this.context.lineTo(this._mc.tx + this._mc.cw, this._mc.ty + this._mc.ch);
            }

            if (tile.faceLeft) {
              this.context.moveTo(this._mc.tx, this._mc.ty);
              this.context.lineTo(this._mc.tx, this._mc.ty + this._mc.ch);
            }

            if (tile.faceRight) {
              this.context.moveTo(this._mc.tx + this._mc.cw, this._mc.ty);
              this.context.lineTo(this._mc.tx + this._mc.cw, this._mc.ty + this._mc.ch);
            }

            this.context.stroke();
          }

          this._mc.tx += this.map.tileWidth;

        }
      }

      this._mc.tx = this._mc.dx;
      this._mc.ty += this.map.tileHeight;

    }

  }

}
