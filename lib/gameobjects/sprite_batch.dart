part of Phaser;

class SpriteBatch extends Group {
  Game game;
  SpriteBatch(Game game, parent, name, addToStage)
  :super(game){
    this.game=game;

  }
}
