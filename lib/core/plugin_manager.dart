part of Phaser;

class PluginManager {
  Game game;
  List<Plugin> plugins;
  int _len;
  int _i;


  PluginManager(this.game) {
    /**
     * @property {array} plugins - An array of all the plugins being managed by this PluginManager.
     */
    this.plugins = [];

    /**
     * @property {number} _len - Internal cache var.
     * @private
     */
    this._len = 0;

    /**
     * @property {number} _i - Internal cache var.
     * @private
     */
    this._i = 0;

  }


  /**
   * Add a new Plugin into the PluginManager.
   * The Plugin must have 2 properties: game and parent. Plugin.game is set to the game reference the PluginManager uses, and parent is set to the PluginManager.
   *
   * @method Phaser.PluginManager#add
   * @param {object|Phaser.Plugin} plugin - The Plugin to add into the PluginManager. This can be a function or an existing object.
   * @param {...*} parameter - Additional parameters that will be passed to the Plugin.init method.
   * @return {Phaser.Plugin} The Plugin that was added to the manager.
   */

  Plugin add(Plugin plugin, [List args]) {

    //var args = Array.prototype.splice.call(arguments, 1);
    bool result = true;

    //  Prototype?
    //if (plugin is Function) {
    //  plugin = plugin(this.game, this);
    //}
    //else {
    plugin.game = this.game;
    plugin.parent = this;
    //}

    //  Check for methods now to avoid having to do this every loop
//    if (plugin['preUpdate'] is Function) {
//      plugin.hasPreUpdate = true;
//      result = true;
//    }
//
//    if (plugin['update'] is Function) {
//      plugin.hasUpdate = true;
//      result = true;
//    }
//
//    if (plugin['postUpdate'] is Function) {
//      plugin.hasPostUpdate = true;
//      result = true;
//    }
//
//    if (plugin['render'] is Function) {
//      plugin.hasRender = true;
//      result = true;
//    }
//
//    if (plugin['postRender'] is Function) {
//      plugin.hasPostRender = true;
//      result = true;
//    }

    //  The plugin must have at least one of the above functions to be added to the PluginManager.
    if (result) {
      if (plugin.hasPreUpdate || plugin.hasUpdate || plugin.hasPostUpdate) {
        plugin.active = true;
      }

      if (plugin.hasRender || plugin.hasPostRender) {
        plugin.visible = true;
      }

      this.plugins.add(plugin);
      this._len = this.plugins.length;
      // Allows plugins to run potentially destructive code outside of the constructor, and only if being added to the PluginManager
//      if (plugin['init'] is Function) {
//        plugin.init.apply(plugin, args);
//      }

      return plugin;
    }
    else {
      return null;
    }
  }

  /**
   * Remove a Plugin from the PluginManager. It calls Plugin.destroy on the plugin before removing it from the manager.
   *
   * @method Phaser.PluginManager#remove
   * @param {Phaser.Plugin} plugin - The plugin to be removed.
   */

  remove(Plugin plugin) {
    this._i = this._len;
    while (this._i-- > 0) {
      if (this.plugins[this._i] == plugin) {
        plugin.destroy();
        this.plugins.removeAt(this._i);
        this._len--;
        return;
      }
    }
  }

  /**
   * Remove all Plugins from the PluginManager. It calls Plugin.destroy on every plugin before removing it from the manager.
   *
   * @method Phaser.PluginManager#removeAll
   */

  removeAll() {
    this._i = this._len;
    while (this._i-- > 0) {
      this.plugins[this._i].destroy();
    }
    this.plugins.clear();
    this._len = 0;
  }

  /**
   * Pre-update is called at the very start of the update cycle, before any other subsystems have been updated (including Physics).
   * It only calls plugins who have active=true.
   *
   * @method Phaser.PluginManager#preUpdate
   */

  preUpdate() {
    this._i = this._len;
    while (this._i-- > 0) {
      if (this.plugins[this._i].active && this.plugins[this._i].hasPreUpdate) {
        this.plugins[this._i].preUpdate();
      }
    }
  }

  /**
   * Update is called after all the core subsystems (Input, Tweens, Sound, etc) and the State have updated, but before the render.
   * It only calls plugins who have active=true.
   *
   * @method Phaser.PluginManager#update
   */

  update() {
    this._i = this._len;
    while (this._i-- > 0) {
      if (this.plugins[this._i].active && this.plugins[this._i].hasUpdate) {
        this.plugins[this._i].update();
      }
    }
  }

  /**
   * PostUpdate is the last thing to be called before the world render.
   * In particular, it is called after the world postUpdate, which means the camera has been adjusted.
   * It only calls plugins who have active=true.
   *
   * @method Phaser.PluginManager#postUpdate
   */

  postUpdate() {
    this._i = this._len;
    while (this._i-- > 0) {
      if (this.plugins[this._i].active && this.plugins[this._i].hasPostUpdate) {
        this.plugins[this._i].postUpdate();
      }
    }
  }

  /**
   * Render is called right after the Game Renderer completes, but before the State.render.
   * It only calls plugins who have visible=true.
   *
   * @method Phaser.PluginManager#render
   */

  render() {
    this._i = this._len;
    while (this._i-- > 0) {
      if (this.plugins[this._i].visible && this.plugins[this._i].hasRender) {
        this.plugins[this._i].render();
      }
    }
  }

  /**
   * Post-render is called after the Game Renderer and State.render have run.
   * It only calls plugins who have visible=true.
   *
   * @method Phaser.PluginManager#postRender
   */

  postRender() {
    this._i = this._len;
    while (this._i-- > 0) {
      if (this.plugins[this._i].visible && this.plugins[this._i].hasPostRender) {
        this.plugins[this._i].postRender();
      }
    }
  }

  /**
   * Clear down this PluginManager, calls destroy on every plugin and nulls out references.
   *
   * @method Phaser.PluginManager#destroy
   */

  destroy() {
    this.removeAll();
    this.game = null;
  }


}
