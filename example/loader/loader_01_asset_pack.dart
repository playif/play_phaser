part of example;

class loader_01_asset_pack extends State {
  preload() {

    game.load.pack('level1', 'assets/asset-pack1.json');
    game.load.image('test', 'assets/sprites/ilkke.png');

  }

  var pic;
  var music;

  create() {
  
    game.stage.backgroundColor = 0x182d3b;

    game.add.image(0, 0, 'starwars');
    game.add.image(0, 300, 'spaceship');
    game.add.image(700, 360, 'test');


    music = game.sound.play('boden');

    var mummy = game.add.sprite(370, 200, 'mummy');
    mummy.animations.add('walk');
    mummy.animations.play('walk', 20, true);


  }

  render() {

    game.debug.soundInfo(music, 370, 32);

    if (music.isDecoding)
    {
      game.debug.text("Decoding MP3 ...", 32, 200);
    }

  }
  
  shutdown() {

    music.stop();
  }
}
