part of example;


class arcade_physics_34_quadtree extends State {

  preload() {
    game.load.image('ship', 'assets/sprites/xenon2_ship.png');
    game.load.image('baddie', 'assets/sprites/space-baddie.png');
  }

  Sprite<arcade.Body> ship;
  Group aliens;
  CursorKeys cursors;

  create() {

    game.world.setBounds(0, 0, 800, 600);

    game.physics.startSystem(Physics.ARCADE);


    aliens = game.add.group();
    aliens.enableBody = true;

    for (var i = 0; i < 50; i++) {
      Sprite<arcade.Body> s = aliens.create(game.world.randomX, game.world.randomY, 'baddie');
      s.scale.set(1);
      s.body.collideWorldBounds = true;
      s.body.bounce.set(1);
      s.body.velocity.setTo(10 + Math.random() * 40, 10 + Math.random() * 40);
    }

    ship = game.add.sprite(500, 500, 'ship');

    game.physics.enable(ship, Physics.ARCADE);

    ship.body.collideWorldBounds = true;
    ship.body.bounce.set(1);

    cursors = game.input.keyboard.createCursorKeys();

    //game.camera.follow(ship);
  }

  update() {

    game.physics.arcade.collide(ship, aliens);

    if (cursors.left.isDown) {
      ship.body.velocity.x -= 4;
    }
    else if (cursors.right.isDown) {
      ship.body.velocity.x += 4;
    }

    if (cursors.up.isDown) {
      ship.body.velocity.y -= 4;
    }
    else if (cursors.down.isDown) {
      ship.body.velocity.y += 4;
    }

  }

  render() {
    game.debug.quadTree(game.physics.arcade.quadTree);
  }
}
