part of example;

class games_03_invaders extends State {

  preload() {

    game.load.image('bullet', 'assets/games/invaders/bullet.png');
    game.load.image('enemyBullet', 'assets/games/invaders/enemy-bullet.png');
    game.load.spritesheet('invader', 'assets/games/invaders/invader32x32x4.png', 32, 32);
    game.load.image('ship', 'assets/games/invaders/player.png');
    game.load.spritesheet('kaboom', 'assets/games/invaders/explode.png', 128, 128);
    game.load.image('starfield', 'assets/games/invaders/starfield.png');
    game.load.image('background', 'assets/games/starstruck/background2.png');

  }

  Sprite player;
  Group<Sprite> aliens;
  Group<Sprite> bullets;
  Group<Sprite> enemyBullets;

  num bulletTime = 0;
  CursorKeys cursors;
  Key fireButton;
  Group<Sprite> explosions;
  TileSprite starfield;
  num score = 0;
  String scoreString = '';
  Text scoreText;
  Group<Sprite> lives;

  num firingTimer = 0;
  Text stateText;
  List<Sprite> livingEnemies = [];

  create() {

    game.world.setBounds(0, 0, 800, 600);

    game.physics.startSystem(Physics.ARCADE);

    //  The scrolling starfield background
    starfield = game.add.tileSprite(0, 0, 800, 600, 'starfield');

    //  Our bullet group
    bullets = game.add.group();
    bullets.enableBody = true;
    bullets.physicsBodyType = Physics.ARCADE;
    bullets.createMultiple(100, 'bullet');
    bullets.forEach((Sprite s) {
      s.anchor.set(0.5, 1);
      s.outOfBoundsKill = true;
      s.checkWorldBounds = true;
    });

    // The enemy's bullets
    enemyBullets = game.add.group();
    enemyBullets.enableBody = true;
    enemyBullets.physicsBodyType = Physics.ARCADE;
    enemyBullets.createMultiple(300, 'enemyBullet');
    enemyBullets.forEach((Sprite s) {
      s.anchor.set(0.5, 1);
      s.outOfBoundsKill = true;
      s.checkWorldBounds = true;
    });

    //  The hero!
    player = game.add.sprite(400, 460, 'ship');
    player.anchor.setTo(0.5, 0.5);
    player.checkWorldBounds=true;

    game.physics.enable(player, Physics.ARCADE);
    game.camera.x=0;
    game.camera.reset();
    game.camera.follow(player);

    //  The baddies!
    aliens = game.add.group();
    aliens.enableBody = true;
    aliens.physicsBodyType = Physics.ARCADE;

    createAliens();

    //  The score
    scoreString = 'Score : ';
    scoreText = game.add.text(10, 10, scoreString + score.toString(), new TextStyle()
      ..font = '34px Arial'
      ..fill = '#fff');

    //  Lives
    lives = game.add.group();
    game.add.text(game.world.width - 100, 10, 'Lives : ', new TextStyle()
      ..font = '34px Arial'
      ..fill = '#fff');

    //  Text
    stateText = game.add.text(game.world.centerX, game.world.centerY, ' ', new TextStyle()
      ..font = '84px Arial'
      ..fill = '#fff');


    stateText.anchor.setTo(0.5, 0.5);
    stateText.visible = false;

    for (var i = 0; i < 3; i++) {
      var ship = lives.create(game.world.width - 100 + (30 * i), 60, 'ship');
      ship.anchor.setTo(0.5, 0.5);
      ship.angle = 90;
      ship.alpha = 0.4;
    }

    //  An explosion pool
    explosions = game.add.group();
    explosions.createMultiple(30, 'kaboom');
    explosions.forEach(setupInvader);

    //  And some controls to play the game with
    cursors = game.input.keyboard.createCursorKeys();
    fireButton = game.input.keyboard.addKey(Keyboard.SPACEBAR);

  }

  createAliens() {

    for (int y = 0; y < 4; y++) {
      for (int x = 0; x < 10; x++) {
        var alien = aliens.create(x * 48, y * 50, 'invader');
        alien.anchor.setTo(0.5, 0.5);
        alien.animations.add('fly', [ 0, 1, 2, 3 ], 20, true);
        alien.play('fly');
        alien.body.moves = false;
      }
    }

    aliens.x = 100;
    aliens.y = 50;

    //  All this does is basically start the invaders moving. Notice we're moving the Group they belong to, rather than the invaders directly.
    Tween tween = game.add.tween(aliens)
    .to({
        'x': 200
    }, 2000, Easing.Linear.None, true, 0, 1000, true);


    //  When the tween loops it calls descend
    tween.onLoop.add(descend);
  }

  setupInvader(invader) {
    invader.anchor.x = 0.5;
    invader.anchor.y = 0.5;
    invader.animations.add('kaboom');
  }

  descend(Group group) {
    aliens.y += 10;
  }

  update() {

    //  Scroll the background
    starfield.tilePosition.y += 2;

    //  Reset the player, then check for movement keys
    player.body.velocity.setTo(0, 0);

    if (cursors.left.isDown) {
      player.body.velocity.x = -200;
    }
    else if (cursors.right.isDown) {
      player.body.velocity.x = 200;
    }

    //  Firing?
    if (fireButton.isDown && player.alive) {
      fireBullet();
    }

    if (game.time.now > firingTimer) {
      enemyFires();
    }

    //  Run collision
    game.physics.arcade.overlap(bullets, aliens, collisionHandler);
    game.physics.arcade.overlap(enemyBullets, player, enemyHitsPlayer);

  }

  render() {
    //game.debug.quadTree(game.physics.arcade.quadTree);
//    for (var i = 0; i < aliens.length; i++)
//    {
//         game.debug.body(aliens.children[i]);
//    }

  }

  collisionHandler(bullet, alien) {

    //  When a bullet hits an alien we kill them both
    bullet.kill();
    alien.kill();

    //  Increase the score
    score += 20;
    scoreText.text = scoreString + score.toString();

    //  And create an explosion :)
    var explosion = explosions.getFirstExists(false);
    explosion.reset(alien.body.x, alien.body.y);
    explosion.play('kaboom', 30, false, true);

    if (aliens.countLiving() == 0) {
      score += 1000;
      scoreText.text = scoreString + score.toString();

      enemyBullets.forEach((Sprite s) => s.kill());
      stateText.text = " You Won, \n Click to restart";
      stateText.visible = true;

      //the "click to restart" handler
      game.input.onTap.addOnce(restart);
    }

  }

  enemyHitsPlayer(player, bullet) {

    bullet.kill();

    Sprite live = lives.getFirstAlive();

    if (live != null) {
      live.kill();
    }

    //  And create an explosion :)
    var explosion = explosions.getFirstExists(false);
    explosion.reset(player.body.x, player.body.y);
    explosion.play('kaboom', 30, false, true);

    // When the player dies
    if (lives.countLiving() < 1) {
      player.kill();
      enemyBullets.forEach((Sprite s) => s.kill());

      stateText.text = " GAME OVER \n Click to restart";
      stateText.visible = true;

      //the "click to restart" handler
      game.input.onTap.addOnce(restart);
    }

  }

  enemyFires() {

    //  Grab the first bullet we can from the pool
    Sprite enemyBullet = enemyBullets.getFirstExists(false);

    livingEnemies.clear();

    aliens.forEachAlive((alien) {
      // put every living enemy in an array
      livingEnemies.add(alien);
    });


    if (enemyBullet != null && livingEnemies.length > 0) {

      var random = game.rnd.integerInRange(0, livingEnemies.length - 1);

      // randomly select one of them
      var shooter = livingEnemies[random];
      // And fire the bullet from this enemy
      enemyBullet.reset(shooter.body.x, shooter.body.y);

      game.physics.arcade.moveToObject(enemyBullet, player, 120);
      firingTimer = game.time.now + 2000;
    }

  }

  fireBullet() {

    //  To avoid them being allowed to fire too fast we set a time limit
    if (game.time.now > bulletTime) {
      //  Grab the first bullet we can from the pool
      for (int i = -10;i < 11;i++) {
        Sprite bullet = bullets.getFirstExists(false);

        if (bullet != null) {
          //  And fire it
          bullet.reset(player.x, player.y + 8);
          //bullet.body.velocity.y = -400;
          bullet.body.velocity.rotate(0, 0, 270 + i * 15, true, 400);
          bullet.rotation = Math.degToRad(i * 15);
          bulletTime = game.time.now + 200;
        }
      }
    }

  }

  resetBullet(bullet) {

    //  Called if the bullet goes out of the screen
    bullet.kill();

  }

  restart(Pointer pointer, bool doubleTab) {

    //  A new level starts

    //resets the life count
    lives.forEach((Sprite s) => s.revive());
    //  And brings the aliens back from the dead :)
    aliens.removeAll();
    createAliens();


    //revives the player
    player.revive();
    //hides the text
    stateText.visible = false;

  }

}
