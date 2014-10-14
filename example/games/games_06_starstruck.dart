part of example;

class games_06_starstruck extends State {
  preload() {

    game.load.tilemap('level1', 'assets/games/starstruck/level1.json', null, Tilemap.TILED_JSON);
    game.load.image('tiles-1', 'assets/games/starstruck/tiles-1.png');
    game.load.spritesheet('dude', 'assets/games/starstruck/dude.png', 32, 48);
    game.load.spritesheet('droid', 'assets/games/starstruck/droid.png', 32, 32);
    game.load.image('starSmall', 'assets/games/starstruck/star.png');
    game.load.image('starBig', 'assets/games/starstruck/star2.png');
    game.load.image('background', 'assets/games/starstruck/background2.png');

  }

  var map;
  var tileset;
  var layer;
  Sprite<arcade.Body> player;
  String facing = 'left';
  var jumpTimer = 0;
  var cursors;
  var jumpButton;
  var bg;

  create() {

    game.physics.startSystem(Physics.ARCADE);

    game.stage.backgroundColor = 0x000000;

    bg = game.add.tileSprite(0, 0, 800, 600, 'background');
    bg.fixedToCamera = true;

    map = game.add.tilemap('level1');

    map.addTilesetImage('tiles-1');

    map.setCollisionByExclusion([13, 14, 15, 16, 46, 47, 48, 49, 50, 51]);

    layer = map.createLayer('Tile Layer 1');

    //  Un-comment this on to see the collision tiles
    // layer.debug = true;

    layer.resizeWorld();

    game.physics.arcade.gravity.y = 250;

    player = game.add.sprite(32, 32, 'dude');
    game.physics.enable(player, Physics.ARCADE);

    player.body.bounce.y = 0.2;
    player.body.collideWorldBounds = true;
    player.body.setSize(20, 32, 5, 16);

    player.animations.add('left', [0, 1, 2, 3], 16);
    player.animations.add('turn', [4], 60);
    player.animations.add('right', [5, 6, 7, 8], 16);

    game.camera.follow(player);

    cursors = game.input.keyboard.createCursorKeys();
    jumpButton = game.input.keyboard.addKey(Keyboard.SPACEBAR);

  }

  update() {

    game.physics.arcade.collide(player, layer);

    player.body.velocity.x = 0;

    if (cursors.left.isDown) {
      player.body.velocity.x = -150;

      if (facing != 'left') {
        player.animations.play('left');
        facing = 'left';
      }
    } else if (cursors.right.isDown) {
      player.body.velocity.x = 150;

      if (facing != 'right') {
        player.animations.play('right');
        facing = 'right';
      }
    } else {
      if (facing != 'idle') {
        player.animations.stop();

        if (facing == 'left') {
          player.frame = 0;
        } else {
          player.frame = 5;
        }

        facing = 'idle';
      }
    }

    if (jumpButton.isDown && player.body.onFloor() && game.time.now > jumpTimer) {
      player.body.velocity.y = -250;
      jumpTimer = game.time.now + 750;
    }

  }

  render() {

    // game.debug.text(game.time.physicsElapsed, 32, 32);
    // game.debug.body(player);
    // game.debug.bodyInfo(player, 16, 24);

  }
}
