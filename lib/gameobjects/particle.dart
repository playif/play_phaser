part of Phaser;

class Particle extends Sprite {
  bool autoScale;
  List<Map<String,num>> scaleData;
  int _s;
  bool autoAlpha;
  List<Map<String,num>> alphaData;
  int _a;




  Particle(Game game, num x,num y,String key,num frame)
  :super(game, x, y, key, frame) {
    /**
     * @property {boolean} autoScale - If this Particle automatically scales this is set to true by Particle.setScaleData.
     * @protected
     */
    this.autoScale = false;

    /**
     * @property {array} scaleData - A reference to the scaleData array owned by the Emitter that emitted this Particle.
     * @protected
     */
    this.scaleData = null;

    /**
     * @property {number} _s - Internal cache var for tracking auto scale.
     * @private
     */
    this._s = 0;

    /**
     * @property {boolean} autoAlpha - If this Particle automatically changes alpha this is set to true by Particle.setAlphaData.
     * @protected
     */
    this.autoAlpha = false;

    /**
     * @property {array} alphaData - A reference to the alphaData array owned by the Emitter that emitted this Particle.
     * @protected
     */
    this.alphaData = null;

    /**
     * @property {number} _a - Internal cache var for tracking auto alpha.
     * @private
     */
    this._a = 0;
  }

  update() {

    if (this.autoScale)
    {
      this._s--;

      if (this._s >= 0)
      {
        //this.scale.set(0.5,0.5);
        this.scale.set(this.scaleData[this._s]['x'], this.scaleData[this._s]['y']);
        //print(this._s);
      }
      else
      {
        this.autoScale = false;
      }
    }

    if (this.autoAlpha)
    {
      this._a--;

      if (this._a >= 0)
      {
        this.alpha = this.alphaData[this._a]['v'];
      }
      else
      {
        this.autoAlpha = false;
      }
    }

  }

  /**
   * Called by the Emitter when this particle is emitted. Left empty for you to over-ride as required.
   *
   * @method Phaser.Particle#onEmit
   * @memberof Phaser.Particle
   */
  onEmit() {
  }

  /**
   * Called by the Emitter if autoAlpha has been enabled. Passes over the alpha ease data and resets the alpha counter.
   *
   * @method Phaser.Particle#setAlphaData
   * @memberof Phaser.Particle
   */
  setAlphaData (List<Map<String,num>> data) {

    this.alphaData = data;
    this._a = data.length - 1;
    this.alpha = this.alphaData[this._a]['v'];
    this.autoAlpha = true;

  }

  /**
   * Called by the Emitter if autoScale has been enabled. Passes over the scale ease data and resets the scale counter.
   *
   * @method Phaser.Particle#setScaleData
   * @memberof Phaser.Particle
   */
  setScaleData (List<Map<String,num>> data) {

    this.scaleData = data;
    this._s = data.length - 1;
    this.scale.set(this.scaleData[this._s]['x'], this.scaleData[this._s]['y']);
    this.autoScale = true;

  }

  /**
   * Resets the Particle. This places the Particle at the given x/y world coordinates and then
   * sets alive, exists, visible and renderable all to true. Also resets the outOfBounds state and health values.
   * If the Particle has a physics body that too is reset.
   *
   * @method Phaser.Particle#reset
   * @memberof Phaser.Particle
   * @param {number} x - The x coordinate (in world space) to position the Particle at.
   * @param {number} y - The y coordinate (in world space) to position the Particle at.
   * @param {number} [health=1] - The health to give the Particle.
   * @return (Phaser.Particle) This instance.
   */
  Particle reset (num x, num y, [num health=1]) {

    if ( health == null) { health = 1; }

    this.world.setTo(x, y);
    this.position.x = x;
    this.position.y = y;
    this.alive = true;
    this.exists = true;
    this.visible = true;
    this.renderable = true;
    this._outOfBoundsFired = false;

    this.health = health;

    if (this.body != null)
    {
      this.body.reset(x, y, false, false);
    }

    this._cache[4] = 1;

    this.alpha = 1;
    this.scale.set(1);

    this.autoScale = false;
    this.autoAlpha = false;

    return this;

  }

}
