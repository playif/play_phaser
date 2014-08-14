part of example;

class games_01_breakout extends State {

  preload() {

    game.load.atlas('breakout', 'assets/games/breakout/breakout.png', 'assets/games/breakout/breakout.json');
    game.load.image('starfield', 'assets/misc/starfield.jpg');

  }

  Sprite ball;
  Sprite paddle;
  Group bricks;

  var ballOnPaddle = true;

  var lives = 3;
  var score = 0;

  Text scoreText;
  Text livesText;
  Text introText;

  var s;

  create() {

    game.world.setBounds(0, 0, 800, 600);

    game.physics.startSystem(Physics.ARCADE);

    //  We check bounds collisions against all walls other than the bottom one
    game.physics.arcade.checkCollision.down = false;

    s = game.add.tileSprite(0, 0, 800, 600, 'starfield');

    bricks = game.add.group();
    bricks.enableBody = true;
    bricks.physicsBodyType = Physics.ARCADE;

    var brick;

    for (var y = 0; y < 4; y++)
    {
      for (var x = 0; x < 15; x++)
      {
        brick = bricks.create(120 + (x * 36), 100 + (y * 52), 'breakout', 'brick_' + (y+1).toString() + '_1.png');
        brick.body.bounce.set(1);
        brick.body.immovable = true;
      }
    }

    paddle = game.add.sprite(game.world.centerX, 500, 'breakout', 'paddle_big.png');
    paddle.anchor.setTo(0.5, 0.5);

    game.physics.enable(paddle, Physics.ARCADE);

    paddle.body.collideWorldBounds = true;
    paddle.body.bounce.set(1);
    paddle.body.immovable = true;

    ball = game.add.sprite(game.world.centerX, paddle.y - 16, 'breakout', 'ball_1.png');
    ball.anchor.set(0.5);
    ball.checkWorldBounds = true;

    game.physics.enable(ball, Physics.ARCADE);

    ball.body.collideWorldBounds = true;
    ball.body.bounce.set(1);

    ball.animations.add('spin', [ 'ball_1.png', 'ball_2.png', 'ball_3.png', 'ball_4.png', 'ball_5.png' ], 50, true, false);

    ball.events.onOutOfBounds.add(ballLost);

    scoreText = game.add.text(32, 550, 'score: 0', new TextStyle()
    ..font= "20px Arial"
    ..fill= "#ffffff"
    ..align= "left");
    livesText = game.add.text(680, 550, 'lives: 3',new TextStyle()
    ..font= "20px Arial"
    ..fill= "#ffffff"
    ..align= "left");

    introText = game.add.text(game.world.centerX, 400, '- click to start -',new TextStyle()
    ..font= "40px Arial"
    ..fill= "#ffffff"
    ..align= "center");

    introText.anchor.setTo(0.5, 0.5);

    game.input.onDown.add(releaseBall);

  }

  update () {

    //  Fun, but a little sea-sick inducing :) Uncomment if you like!
    // s.tilePosition.x += (game.input.speed.x / 2);

    paddle.body.x = game.input.x;

    if (paddle.x < 24)
    {
      paddle.x = 24;
    }
    else if (paddle.x > game.width - 24)
    {
      paddle.x = game.width - 24;
    }

    if (ballOnPaddle)
    {
      ball.body.x = paddle.x;
    }
    else
    {
      game.physics.arcade.collide(ball, paddle, ballHitPaddle, null);
      game.physics.arcade.collide(ball, bricks, ballHitBrick, null);
    }

  }

  releaseBall (Pointer p, dom.MouseEvent e) {

    if (ballOnPaddle)
    {
      ballOnPaddle = false;
      ball.body.velocity.y = -300;
      ball.body.velocity.x = -75;
      ball.animations.play('spin');
      introText.visible = false;
    }

  }

  ballLost (Sprite s) {

    lives--;
    livesText.text = 'lives: ' + lives.toString();

    if (lives == 0)
    {
      gameOver();
    }
    else
    {
      ballOnPaddle = true;

      ball.reset(paddle.body.x + 16, paddle.y - 16);

      ball.animations.stop();
    }

  }

  gameOver () {

    ball.body.velocity.setTo(0, 0);

    introText.text = 'Game Over!';
    introText.visible = true;

  }

  ballHitBrick (_ball, _brick) {

    _brick.kill();

    score += 10;

    scoreText.text = 'score: ' + score.toString();

    //  Are they any bricks left?
    if (bricks.countLiving() == 0)
    {
      //  New level starts
      score += 1000;
      scoreText.text = 'score: ' + score.toString();
      introText.text = '- Next Level -';

      //  Let's move the ball back to the paddle
      ballOnPaddle = true;
      ball.body.velocity.set(0);
      ball.x = paddle.x + 16;
      ball.y = paddle.y - 16;
      ball.animations.stop();


      //  And bring the bricks back from the dead :)
      bricks.forEach((Sprite s){
        s.revive();
      });
      //ball.revive()
    }

  }

  ballHitPaddle (_ball, _paddle) {

    var diff = 0;

    if (_ball.x < _paddle.x)
    {
      //  Ball is on the left-hand side of the paddle
      diff = _paddle.x - _ball.x;
      _ball.body.velocity.x = (-10 * diff);
    }
    else if (_ball.x > _paddle.x)
    {
      //  Ball is on the right-hand side of the paddle
      diff = _ball.x -_paddle.x;
      _ball.body.velocity.x = (10 * diff);
    }
    else
    {
      //  Ball is perfectly in the middle
      //  Add a little random X to stop it bouncing straight up!
      _ball.body.velocity.x = 2 + Math.random() * 8;
    }

  }
}
