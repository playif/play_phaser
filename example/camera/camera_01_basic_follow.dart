part of example;

class camera_01_basic_follow extends State {
  preload() {

    game.load.image('background', 'assets/tests/debug-grid-1920x1920.png');
    game.load.image('player', 'assets/sprites/phaser-dude.png');

  }

  Sprite player;
  CursorKeys cursors;

  create() {

    game.add.tileSprite(0, 0, 1920, 1920, 'background');

    game.world.setBounds(0, 0, 1920, 1920);

    game.physics.startSystem(Physics.ARCADE);

    player = game.add.sprite(game.world.centerX, game.world.centerY, 'player');

    game.physics.arcade.enable(player);

    cursors = game.input.keyboard.createCursorKeys();

    game.camera.follow(player);

  }

  update() {

    //player.body.setZeroVelocity();

    if (cursors.left.isDown) {
      player.body.velocity.x -= 4;
    } else if (cursors.right.isDown) {
      player.body.velocity.x += 4;
    }

    if (cursors.up.isDown) {
      player.body.velocity.y -= 4;
    } else if (cursors.down.isDown) {
      player.body.velocity.y += 4;
    }

  }

  render() {

    game.debug.cameraInfo(game.camera, 32, 32);
    game.debug.spriteCoords(player, 32, 500);

  }

  shutdown() {

    game.world.setBounds(0, 0, 800, 600);

  }
}
