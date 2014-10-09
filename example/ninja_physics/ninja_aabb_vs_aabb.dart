part of example;

class ninja_aabb_vs_aabb extends State {
  // var game = new Phaser.Game(800, 600, Phaser.AUTO, 'phaser-example', { preload: preload, create: create, update: update, render: render });

  preload() {

    game.load.image('block', 'assets/sprites/block.png');
    game.load.spritesheet('ninja-tiles', 'assets/physics/ninja-tiles128.png', 128, 128, 34);

  }

  Sprite<ninja.Body> sprite1;
  Sprite<ninja.Body> sprite2;
  Tile tile;
  CursorKeys cursors;


  create() {

    game.physics.startSystem(Physics.NINJA);

    sprite1 = game.add.sprite(100, 450, 'block');
    sprite1.name = 'blockA';

    sprite2 = game.add.sprite(600, 450, 'block');
    sprite2.name = 'blockB';
    sprite2.tint = Math.ceil(Math.random() * 0xffffff);

    game.physics.ninja.enableAABB([sprite1, sprite2]);

    cursors = game.input.keyboard.createCursorKeys();

  }


  update() {

    game.physics.ninja.collide(sprite1, sprite2);


    if (cursors.left.isDown) {
      sprite1.body.moveLeft(20);
    } else if (cursors.right.isDown) {
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
