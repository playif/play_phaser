part of example;

class tweens_01_chained_tweens extends State {
  preload() {
    game.load.image('diamond', 'assets/sprites/diamond.png');
  }


  create() {
    game.stage.backgroundColor = 0x2d2d2d;
    var sprite = game.add.sprite(100, 100, 'diamond');

    //  Here we'll chain 4 different tweens together and play through them all in a loop
    var tween = game.add.tween(sprite).to({
        X: 300,
        ALPHA: 0.1,
    }, 2000, Easing.Quart.INOUT)
    .to({
        X: 500,
        ALPHA: 1,
    }, 2000, null, false, 0, 0)
    .yoyo(true)
    .repeat(1)
    .setCallback((type, source) {
      print(type);
    }, Tween.COMPLETE)
    .start();

    game.add.tween(sprite.position)
    .to({
        Y:200
    }, 1000, null, false, 200,10,true)
    .start();

  }

}
