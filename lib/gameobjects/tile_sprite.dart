part of Phaser;

class TileSprite extends PIXI.TilingSprite  implements GameObject {

  Game game;
  num x;

  TileSprite(this.game, [num x, num y, int width, int height, key, frame])
  :super( PIXI.TextureCache['__default'], width, height){

  }
}
