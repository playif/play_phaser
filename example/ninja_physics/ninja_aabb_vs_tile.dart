part of example;

class ninja_aabb_vs_tile extends State {
  preload() {

    game.load.image('block', 'assets/sprites/block.png');
    game.load.spritesheet('ninja-tiles', 'assets/physics/ninja-tiles128.png', 128, 128);

  }

  Sprite<ninja.Body> sprite1;
  Sprite<ninja.Body> sprite2;
  Sprite<ninja.Body> tile;
  CursorKeys cursors;

  create() {

    // Here we tell the physics manager we system we want to use
    game.physics.startSystem(Physics.NINJA);


    sprite1 = game.add.sprite(600, 100, 'block');
    sprite1.name = 'blockA';

    // Enable ninja on the sprite and creates an AABB around it
    game.physics.ninja.enableAABB(sprite1);

    //
    tile = game.add.sprite(600, 280, 'ninja-tiles', 2);
    game.physics.ninja.enableTile(tile, tile.frame);

    cursors = game.input.keyboard.createCursorKeys();
    //game.add.sprite(600, 280, 'ninja-tiles', 3);
  }

  update() {


    game.physics.ninja.collide(sprite1, tile);


    if (cursors.left.isDown) {
      sprite1.body.moveLeft(20);
    }
    else if (cursors.right.isDown) {
      sprite1.body.moveRight(20);
    }

    if (cursors.up.isDown) {
      sprite1.body.moveUp(30);
    }

  }

  render() {

    game.debug.text('left: ' + sprite1.body.touching.left.toString(), 32, 32);
    game.debug.text('right: ' + sprite1.body.touching.right.toString(), 256, 32);
    game.debug.text('up: ' + sprite1.body.touching.up.toString(), 32, 64);
    game.debug.text('down: ' + sprite1.body.touching.down.toString(), 256, 64);

  }
}
