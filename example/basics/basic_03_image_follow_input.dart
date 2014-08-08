part of example;


class basic_03_image_follow_input extends State {
  //Phaser.Game game;
  //Phaser.Text text;
  Sprite sprite;
  int counter = 0;

  double t = 0.5;


  preload() {
    game.load.image('car', 'assets/sprites/car.png');
  }

  create() {
    //  To make the sprite move we need to enable Arcade Physics
    game.physics.startSystem(Physics.ARCADE);

    sprite = game.add.sprite(game.world.centerX, game.world.centerY, 'car');
    sprite.anchor.set(0.5);

    //  And enable the Sprite to have a physics body:
    game.physics.arcade.enable(sprite);
  }

  update() {
//  If the sprite is > 8px away from the pointer then let's move to it
    if (game.physics.arcade.distanceToPointer(sprite, game.input.activePointer) > 8) {
      //  Make the object seek to the active pointer (mouse or touch).
      game.physics.arcade.moveToPointer(sprite, 300);
    } else {
      //  Otherwise turn off velocity because we're close enough to the pointer
      sprite.body.velocity.set(0);
    }
  }


  render() {
    game.debug.inputInfo(32, 32);
  }

}
