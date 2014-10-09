part of example;

class p2_02_basic_movement extends State{
  preload() {

    game.load.image('atari', 'assets/sprites/atari130xe.png');
    game.load.image('sky', 'assets/skies/sunset.png');

  }

  Sprite<p2.Body> sprite;
  CursorKeys cursors;

  create() {

    game.add.image(0, 0, 'sky');

    //	Enable p2 physics
    game.physics.startSystem(Physics.P2JS,gravity: [0,0]);

    //  Make things a bit more bouncey
    //game.physics.p2.defaultRestitution = 0.8;

    //  Add a sprite
    sprite = game.add.sprite(200, 200, 'atari');

    //  Enable if for physics. This creates a default rectangular body.
    game.physics.p2.enable(sprite);

    //  Modify a few body properties
    sprite.body.setZeroDamping();
    sprite.body.fixedRotation = true;

    Text text = game.add.text(20, 20, 'move with arrow keys', new TextStyle( fill: '#ffffff' ));

    cursors = game.input.keyboard.createCursorKeys();

  }

  update() {
    sprite.body.setZeroVelocity();

    if (cursors.left.isDown)
    {
      sprite.body.moveLeft(400);
    }
    else if (cursors.right.isDown)
    {
      sprite.body.moveRight(400);
    }

    if (cursors.up.isDown)
    {
      sprite.body.moveUp(400);
    }
    else if (cursors.down.isDown)
    {
      sprite.body.moveDown(400);
    }

  }
}
