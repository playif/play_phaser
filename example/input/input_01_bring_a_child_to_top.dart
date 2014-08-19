part of example;

class input_01_bring_a_child_to_top extends State {

  preload() {

    game.load.image('atari1', 'assets/sprites/atari130xe.png');
    game.load.image('atari2', 'assets/sprites/atari800xl.png');
    game.load.image('atari4', 'assets/sprites/atari800.png');
    game.load.image('sonic', 'assets/sprites/sonic_havok_sanity.png');
    game.load.image('duck', 'assets/sprites/darkwing_crazy.png');
    game.load.image('firstaid', 'assets/sprites/firstaid.png');
    game.load.image('diamond', 'assets/sprites/diamond.png');
    game.load.image('mushroom', 'assets/sprites/mushroom2.png');

  }

  create() {

    //  This returns an array of all the image keys in the cache
    var images = game.cache.getKeys(Cache.IMAGE);

    //  Now let's create some random sprites and enable them all for drag and 'bring to top'
    for (int i = 0; i < 20; i++)
    {
      var img = game.rnd.pick(images);
      var tempSprite = game.add.sprite(game.world.randomX, game.world.randomY, img);
      tempSprite.inputEnabled = true;
      tempSprite.input.enableDrag(false, true);
    }

  }

  render() {
    //game.debug.inputInfo(32, 32);
  }

}
