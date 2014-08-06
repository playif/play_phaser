part of Phaser;

class RenderTexture extends PIXI.RenderTexture {
  String key;
  int type;
  Point _temp;

  Game game;

  RenderTexture(Game game, num width, num height, [String key, PIXI.scaleModes scaleMode])
  :super(width, height, game.renderer, scaleMode) {

    this.game=game;

    if (key == null) {
      key = '';
    }
    if (scaleMode == null) {
      scaleMode = PIXI.scaleModes.DEFAULT;
    }

    /**
     * @property {Phaser.Game} game - A reference to the currently running game.
     */
    this.game = game;

    /**
     * @property {string} key - The key of the RenderTexture in the Cache, if stored there.
     */
    this.key = key;

    /**
     * @property {number} type - Base Phaser object type.
     */
    this.type = RENDERTEXTURE;

    /**
     * @property {Phaser.Point} _temp - Internal var.
     * @private
     */
    this._temp = new Point();

    //PIXI.RenderTexture.call(this, width, height, this.game.renderer, scaleMode);

  }


  /**
   * This function will draw the display object to the texture.
   *
   * @method Phaser.RenderTexture.prototype.renderXY
   * @param {Phaser.Sprite|Phaser.Image|Phaser.Text|Phaser.BitmapText|Phaser.Group} displayObject  The display object to render to this texture.
   * @param {number} x - The x position to render the object at.
   * @param {number} y - The y position to render the object at.
   * @param {boolean} clear - If true the texture will be cleared before the display object is drawn.
   */
  renderXY (PIXI.DisplayObject displayObject, x, y, clear) {

    this._temp.set(x, y);

    this.render(displayObject, this._temp, clear);

  }

}
