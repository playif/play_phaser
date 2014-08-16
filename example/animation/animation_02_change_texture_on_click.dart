part of example;

class animation_02_change_texture_on_click extends State {
  preload() {

    game.load.atlasJSONArray('bot', 'assets/sprites/running_bot.png', 'assets/sprites/running_bot.json');
    game.load.spritesheet('mummy', 'assets/sprites/metalslug_mummy37x45.png', 37, 45, 18);

  }

  var bot;

  create() {

    bot = game.add.sprite(200, 200, 'bot');

    bot.animations.add('run');

    bot.animations.play('run', 15, true);

    game.input.onDown.addOnce(changeMummy);

  }

  changeMummy(Pointer pointer, event) {

    bot.loadTexture('mummy', 0);

    bot.animations.add('walk');

    bot.animations.play('walk', 30, true);

  }

  render() {

    game.debug.body(bot);

  }
}
