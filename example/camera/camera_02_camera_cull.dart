part of example;

class camera_02_camera_cull extends State {
  preload() {
    game.load.image('disk', 'assets/sprites/ra_dont_crack_under_pressure.png');
  }

  Sprite s;

  create() {

    game.world.setBounds(0, 0, 800, 600);

    game.stage.backgroundColor = 0x182d3b;

    s = game.add.sprite(game.world.centerX, game.world.centerY, 'disk');
    s.anchor.setTo(0.5, 0.5);

  }

  update() {

    s.rotation += 0.01;

    if (game.input.keyboard.isDown(Keyboard.LEFT)) {
      s.x -= 4;
    }
    else if (game.input.keyboard.isDown(Keyboard.RIGHT)) {
      s.x += 4;
    }

    if (game.input.keyboard.isDown(Keyboard.UP)) {
      s.y -= 4;
    }
    else if (game.input.keyboard.isDown(Keyboard.DOWN)) {
      s.y += 4;
    }

  }

  render() {

    game.debug.spriteBounds(s);
    game.debug.spriteInfo(s, 20, 32);

  }
}
