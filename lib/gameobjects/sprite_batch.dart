part of Phaser;

class SpriteBatch extends Group {



  //Game game;
  SpriteBatch(Game game, parent, name, addToStage)
  :super(game){

    if ( parent == null) { parent = game.world; }

    //PIXI.SpriteBatch.call(this);

    //Phaser.Group.call(this, game, parent, name, addToStage);

    /**
     * @property {number} type - Internal Phaser Type value.
     * @protected
     */
    this.type = SPRITEBATCH;
  }


}
