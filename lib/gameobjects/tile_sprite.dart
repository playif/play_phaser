part of Phaser;

class TileSprite extends PIXI.TilingSprite implements GameObject {

  Game game;
  num x;

  num get renderOrderID {
    return this._cache[3];
  }


  TileSprite(this.game, [num x, num y, int width, int height, key, frame])
  :super( PIXI.TextureCache['__default'], width, height){

  }
}
