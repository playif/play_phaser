part of Phaser;

//class TweenManager extends tween.TweenManager {
//  Tween remove(Tween tween){
//    return tween.kill();
//    //super.removeTween(tween._timeline);
//  }
//}
//
class TweenManager {
  final Game game;
  final List<Tween> _tweens = [];
  final List<Tween> _add = [];


  TweenManager(this.game) {

    this.game.onPause.add(this._pauseAll);
    this.game.onResume.add(this._resumeAll);
  }

  /**
   * Get all the tween objects in an array.
   * @method Phaser.TweenManager#getAll
   * @returns {Phaser.Tween[]} Array with all tween objects.
   */

  getAll() {
    return this._tweens;
  }

  /**
   * Remove all tweens running and in the queue. Doesn't call any of the tween onComplete events.
   * @method Phaser.TweenManager#removeAll
   */

  removeAll() {
    for (var i = 0; i < this._tweens.length; i++) {
      this._tweens[i].pendingDelete = true;
    }
    this._add.clear();
  }

  /**
   * Add a new tween into the TweenManager.
   *
   * @method Phaser.TweenManager#add
   * @param {Phaser.Tween} tween - The tween object you want to add.
   * @returns {Phaser.Tween} The tween object you added to the manager.
   */

  Tween add(Tween tween) {
    tween._manager = this;
    this._add.add(tween);
    return tween;
  }

  /**
   * Create a tween object for a specific object. The object can be any JavaScript object or Phaser object such as Sprite.
   *
   * @method Phaser.TweenManager#create
   * @param {Object} object - Object the tween will be run on.
   * @returns {Phaser.Tween} The newly created tween object.
   */

  Tween create(object) {
    return new Tween(object, this.game, this);
  }

  /**
   * Remove a tween from this manager.
   *
   * @method Phaser.TweenManager#remove
   * @param {Phaser.Tween} tween - The tween object you want to remove.
   */

  remove(Tween tween) {
    var i = this._tweens.indexOf(tween);
    if (i != -1) {
      this._tweens[i].pendingDelete = true;
    }
  }

  /**
   * Update all the tween objects you added to this manager.
   *
   * @method Phaser.TweenManager#update
   * @returns {boolean} Return false if there's no tween to update, otherwise return true.
   */

  bool update() {
    if (this._tweens.length == 0 && this._add.length == 0) {
      return false;
    }

    int i = 0;
    int numTweens = this._tweens.length;

    while (i < numTweens) {
      if (this._tweens[i].update(this.game.time.now)) {
        i++;
      }
      else {
        this._tweens.removeAt(i);
        numTweens--;
      }
    }

    //  If there are any new tweens to be added, do so now - otherwise they can be spliced out of the array before ever running
    if (this._add.length > 0) {
      this._tweens.addAll(this._add);
      this._add.length = 0;
    }

    return true;

  }

  /**
   * Checks to see if a particular Sprite is currently being tweened.
   *
   * @method Phaser.TweenManager#isTweening
   * @param {object} object - The object to check for tweens against.
   * @returns {boolean} Returns true if the object is currently being tweened, false if not.
   */

  bool isTweening(object) {
    return this._tweens.any((Tween tween) {
      return tween._object == object;
    });
  }

  /**
   * Private. Called by game focus loss. Pauses all currently running tweens.
   *
   * @method Phaser.TweenManager#_pauseAll
   * @private
   */

  _pauseAll() {
    for (int i = this._tweens.length - 1; i >= 0; i--) {
      this._tweens[i]._pause();
    }
  }

  /**
   * Private. Called by game focus loss. Resumes all currently paused tweens.
   *
   * @method Phaser.TweenManager#_resumeAll
   * @private
   */

  _resumeAll() {
    for (int i = this._tweens.length - 1; i >= 0; i--) {
      this._tweens[i]._resume();
    }
  }

  /**
   * Pauses all currently running tweens.
   *
   * @method Phaser.TweenManager#pauseAll
   */

  pauseAll() {
    for (int i = this._tweens.length - 1; i >= 0; i--) {
      this._tweens[i].pause();
    }
  }

  /**
   * Resumes all currently paused tweens.
   *
   * @method Phaser.TweenManager#resumeAll
   */

  resumeAll() {
    for (int i = this._tweens.length - 1; i >= 0; i--) {
      this._tweens[i].resume();
    }
  }

}
