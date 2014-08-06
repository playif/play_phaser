part of Phaser;

class Particles {
  Map Arcade = {};
  static int ID=0;
  Game game;
  Map<String,Emitter> emitters;
//  int ID;

  Particles(this.game) {

    /**
     * @property {object} emitters - Internal emitters store.
     */
    this.emitters = {
    };

    /**
     * @property {number} ID -
     * @default
     */
    //this.ID = 0;

  }


  /**
   * Adds a new Particle Emitter to the Particle Manager.
   * @method Phaser.Particles#add
   * @param {Phaser.Emitter} emitter - The emitter to be added to the particle manager.
   * @return {Phaser.Emitter} The emitter that was added.
   */

  Emitter add(Emitter emitter) {
    this.emitters[emitter.name] = emitter;
    return emitter;
  }


  /**
   * Removes an existing Particle Emitter from the Particle Manager.
   * @method Phaser.Particles#remove
   * @param {Phaser.Emitter} emitter - The emitter to remove.
   */

  remove(emitter) {
    this.emitters.remove(emitter.name);
  }


  /**
   * Called by the core game loop. Updates all Emitters who have their exists value set to true.
   * @method Phaser.Particles#update
   * @protected
   */

  update() {
    for (var key in this.emitters.keys) {
      if (this.emitters[key].exists) {
        this.emitters[key].update();
      }
    }
  }

}
