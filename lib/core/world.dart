part of Phaser;

class World extends Group {
  Game game;
  Rectangle bounds;
  Camera camera;

  /// True if the World has been given a specifically defined size (i.e. from a Tilemap or direct in code) or false if it's just matched to the Game dimensions.
  bool _definedSize;

  /// The defined width of the World. Sometimes the bounds needs to grow larger than this (if you resize the game) but this retains the original requested dimension.
  num _width;

  /// The defined height of the World. Sometimes the bounds needs to grow larger than this (if you resize the game) but this retains the original requested dimension.
  num _height;


  num get width {
    return this.bounds.width;
  }

  set width(num value) {
    if (value < this.game.width) {
      value = this.game.width;
    }
    this.bounds.width = value;
    this._width = value;
    this._definedSize = true;
  }

  num get height {
    return this.bounds.height;
  }

  set height(num value) {
    if (value < this.game.height) {
      value = this.game.height;
    }
    this.bounds.height = value;
    this._height = value;
    this._definedSize = true;
  }

  num get centerX {
    return this.bounds.halfWidth;
  }

  num get centerY {
    return this.bounds.halfHeight;
  }

  num get randomX {
    if (this.bounds.x < 0) {
      return this.game.rnd.integerInRange(this.bounds.x, (this.bounds.width - Math.abs(this.bounds.x)));
    } else {
      return this.game.rnd.integerInRange(this.bounds.x, this.bounds.width);
    }
  }

  num get randomY {
    if (this.bounds.y < 0) {
      return this.game.rnd.integerInRange(this.bounds.y, (this.bounds.height - Math.abs(this.bounds.y)));
    } else {
      return this.game.rnd.integerInRange(this.bounds.y, this.bounds.height);
    }
  }

  World(Game game) : super(game, null, '__world', false) {

    this.game = game;

    /**
     * The World has no fixed size, but it does have a bounds outside of which objects are no longer considered as being "in world" and you should use this to clean-up the display list and purge dead objects.
     * By default we set the Bounds to be from 0,0 to Game.width,Game.height. I.e. it will match the size given to the game constructor with 0,0 representing the top-left of the display.
     * However 0,0 is actually the center of the world, and if you rotate or scale the world all of that will happen from 0,0.
     * So if you want to make a game in which the world itself will rotate you should adjust the bounds so that 0,0 is the center point, i.e. set them to -1000,-1000,2000,2000 for a 2000x2000 sized world centered around 0,0.
     * @property {Phaser.Rectangle} bounds - Bound of this world that objects can not escape from.
     */
    this.bounds = new Rectangle(0, 0, game.width, game.height);

    /**
     * @property {Phaser.Camera} camera - Camera instance.
     */
    this.camera = null;


    this._definedSize = false;

    this._width = game.width;

    this._height = game.height;

  }

  boot() {

    this.camera = new Camera(this.game, 0, 0, 0, this.game.width, this.game.height);

    this.camera.displayObject = this;

    this.camera.scale = this.scale;

    this.game.camera = this.camera;

    this.game.stage.addChild(this);

  }

  /**
   * Updates the size of this world. Note that this doesn't modify the world x/y coordinates, just the width and height.
   *
   * @method Phaser.World#setBounds
   * @param {number} x - Top left most corner of the world.
   * @param {number} y - Top left most corner of the world.
   * @param {number} width - New width of the world. Can never be smaller than the Game.width.
   * @param {number} height - New height of the world. Can never be smaller than the Game.height.
   */

  setBounds(num x, num y, num width, num height) {

    this._definedSize = true;
    this._width = width;
    this._height = height;

    this.bounds.setTo(x, y, width, height);

    if (this.camera.bounds != null) {
      //  The Camera can never be smaller than the game size
      //this.camera.bounds.setTo(x, y, width, height);
      this.camera.bounds.setTo(x, y, Math.max(width, this.game.width), Math.max(height, this.game.height));
    }

    this.game.physics.setBoundsToWorld();

  }

  resize(num width, num height) {
    //  Don't ever scale the World bounds lower than the original requested dimensions if it's a defined world size
    if (this._definedSize) {
      if (width < this._width) {
        width = this._width;
      }

      if (height < this._height) {
        height = this._height;
      }
    }
    this.bounds.width = width;
    this.bounds.height = height;

    this.game.camera.setBoundsToWorld();
    this.game.physics.setBoundsToWorld();
  }

  /**
   * Destroyer of worlds.
   *
   * @method Phaser.World#shutdown
   */

  shutdown() {

    //  World is a Group, so run a soft destruction on this and all children.
    this.destroy(true, true);

  }

  /**
   * This will take the given game object and check if its x/y coordinates fall outside of the world bounds.
   * If they do it will reposition the object to the opposite side of the world, creating a wrap-around effect.
   *
   * @method Phaser.World#wrap
   * @param {Phaser.Sprite|Phaser.Image|Phaser.TileSprite|Phaser.Text} sprite - The object you wish to wrap around the world bounds.
   * @param {number} [padding=0] - Extra padding added equally to the sprite.x and y coordinates before checking if within the world bounds. Ignored if useBounds is true.
   * @param {boolean} [useBounds=false] - If useBounds is false wrap checks the object.x/y coordinates. If true it does a more accurate bounds check, which is more expensive.
   * @param {boolean} [horizontal=true] - If horizontal is false, wrap will not wrap the object.x coordinates horizontally.
   * @param {boolean} [vertical=true] - If vertical is false, wrap will not wrap the object.y coordinates vertically.
   */

  wrap(GameObject sprite, [num padding = 0, bool useBounds = false, bool horizontal = true, bool vertical = true]) {

    if (!useBounds) {
      if (horizontal && sprite.x + padding < this.bounds.x) {
        sprite.x = this.bounds.right + padding;
      } else if (horizontal && sprite.x - padding > this.bounds.right) {
        sprite.x = this.bounds.left - padding;
      }

      if (vertical && sprite.y + padding < this.bounds.top) {
        sprite.y = this.bounds.bottom + padding;
      } else if (vertical && sprite.y - padding > this.bounds.bottom) {
        sprite.y = this.bounds.top - padding;
      }
    } else {
      sprite.getBounds();

      if (horizontal && sprite._currentBounds.right < this.bounds.x) {
        sprite.x = this.bounds.right;
      } else if (horizontal && sprite._currentBounds.x > this.bounds.right) {
        sprite.x = this.bounds.left;
      }

      if (vertical && sprite._currentBounds.bottom < this.bounds.top) {
        sprite.y = this.bounds.bottom;
      } else if (vertical && sprite._currentBounds.top > this.bounds.bottom) {
        sprite.y = this.bounds.top;
      }
    }

  }
}
