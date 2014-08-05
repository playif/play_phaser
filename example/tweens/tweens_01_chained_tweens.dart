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
        Fields.X: 300,
        Fields.ALPHA: 0.1,
    }, 2000, Easing.Quart.INOUT)
    .to({
        Fields.X: 500,
        Fields.ALPHA: 1,
    }, 2000, null, false, 0, 0)
    .yoyo(true)
    .repeat(1)
    .setCallback((type, source) {
      print(type);
    }, Tween.COMPLETE)
    .start();

//    Object o = new Point();
//    //o.runtimeType
//    game.add.tween(sprite.position)
//    .to({
//        PointAccessor.Y:200
//    }, 1000, null, false, 200,10,true)
//    .start();

  }

}
