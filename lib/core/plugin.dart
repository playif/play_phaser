part of Phaser;

class Plugin {
  Game game;
  PluginManager parent;

  bool active;
  bool visible;
  bool hasPreUpdate;
  bool hasUpdate;
  bool hasPostUpdate;
  bool hasRender;
  bool hasPostRender;

  Plugin(this.game, this.parent) {
    /**
     * @property {boolean} active - A Plugin with active=true has its preUpdate and update methods called by the parent, otherwise they are skipped.
     * @default
     */
    this.active = false;

    /**
     * @property {boolean} visible - A Plugin with visible=true has its render and postRender methods called by the parent, otherwise they are skipped.
     * @default
     */
    this.visible = false;

    /**
     * @property {boolean} hasPreUpdate - A flag to indicate if this plugin has a preUpdate method.
     * @default
     */
    this.hasPreUpdate = false;

    /**
     * @property {boolean} hasUpdate - A flag to indicate if this plugin has an update method.
     * @default
     */
    this.hasUpdate = false;

    /**
     * @property {boolean} hasPostUpdate - A flag to indicate if this plugin has a postUpdate method.
     * @default
     */
    this.hasPostUpdate = false;

    /**
     * @property {boolean} hasRender - A flag to indicate if this plugin has a render method.
     * @default
     */
    this.hasRender = false;

    /**
     * @property {boolean} hasPostRender - A flag to indicate if this plugin has a postRender method.
     * @default
     */
    this.hasPostRender = false;
  }

  /**
   * Pre-update is called at the very start of the update cycle, before any other subsystems have been updated (including Physics).
   * It is only called if active is set to true.
   * @method Phaser.Plugin#preUpdate
   */
  preUpdate () {
  }

  /**
   * Update is called after all the core subsystems (Input, Tweens, Sound, etc) and the State have updated, but before the render.
   * It is only called if active is set to true.
   * @method Phaser.Plugin#update
   */
  update () {
  }

  /**
   * Render is called right after the Game Renderer completes, but before the State.render.
   * It is only called if visible is set to true.
   * @method Phaser.Plugin#render
   */
  render () {
  }

  /**
   * Post-render is called after the Game Renderer and State.render have run.
   * It is only called if visible is set to true.
   * @method Phaser.Plugin#postRender
   */
  postRender () {
  }

  postUpdate(){

  }

  /**
   * Clear down this Plugin and null out references
   * @method Phaser.Plugin#destroy
   */
  destroy () {
    this.game = null;
    this.parent = null;
    this.active = false;
    this.visible = false;
  }
}
