part of example;

class p2_01_accelerate_to_object extends State {
  preload() {
    game.load.image('car', 'assets/sprites/car.png');
    game.load.image('tinycar', 'assets/sprites/tinycar.png');
  }

  Group bullets;
  CursorKeys cursors;
  Sprite<p2.Body> ship;

  create() {
    game.world.setBounds(0, 0, 800, 600);
    
    game.physics.startSystem(Physics.P2JS, gravity: [0, 0]);
    bullets = game.add.group();
    for (var i = 0; i < 10; i++) {
      Sprite bullet = bullets.create(game.rnd.integerInRange(200, 1700), game.rnd.integerInRange(-200, 400), 'tinycar');
      game.physics.p2.enable(bullet, false);
    }
    cursors = game.input.keyboard.createCursorKeys();
    ship = game.add.sprite(32, game.world.height - 150, 'car');
    game.physics.p2.enable(ship);
  }

  update() {
    bullets.forEachAlive(moveBullets); //make bullets accelerate to ship
    if (cursors.left.isDown) {
      ship.body.rotateLeft(100);
    } //ship movement
    else if (cursors.right.isDown) {
      ship.body.rotateRight(100);
    } else {
      ship.body.setZeroRotation();
    }
    if (cursors.up.isDown) {
      ship.body.thrust(400);
    } else if (cursors.down.isDown) {
      ship.body.reverse(400);
    }
  }


  moveBullets(bullet) {
    accelerateToObject(bullet, ship, 30); //start accelerateToObject on every bullet
  }

  accelerateToObject(Sprite obj1, Sprite obj2, num speed) {
    if (speed == null) {
      speed = 60;
    }
    var angle = Math.atan2(obj2.y - obj1.y, obj2.x - obj1.x);
    obj1.body.rotation = angle + Math.degToRad(90); // correct angle of angry bullets (depends on the sprite used)
    obj1.body.force.x = Math.cos(angle) * speed; // accelerateToObject
    obj1.body.force.y = Math.sin(angle) * speed;
  }
}
