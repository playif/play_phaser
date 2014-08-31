part of example;

class tweens_01_chained_tweens extends State {
  preload() {
    game.load.image('diamond', 'assets/sprites/diamond.png');
  }
  Sprite sprite;

  create() {
    game.stage.backgroundColor = 0x2d2d2d;
    sprite = game.add.sprite(100, 100, 'diamond');

    //  Here we'll chain 4 different tweens together and play through them all in a loop
    var tween = game.add.tween(sprite).to({
        'x': 300,
        //ALPHA: 0.1,
    }, 500, Easing.Linear.None, false, 0, 0, false)
//    .delay(40)
//    .to({
//        X: 500
//    }, 2000)

    .yoyo(true)
    .repeat(1)
    .start();

//    game.add.tween(sprite.position)
//    .to({
//        Y:200
//    }, 1000, null, false, 200, 10, true)
//    .start();

  }

  render() {
    game.debug.spriteInfo(sprite,10,20);
  }

}
