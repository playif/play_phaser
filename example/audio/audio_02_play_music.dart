part of example;

class audio_02_play_music extends State {
  Sprite s;
  Sound music;

  preload() {

    game.load.image('disk', 'assets/sprites/ra_dont_crack_under_pressure.png');

    //  Firefox doesn't support mp3 files, so use ogg
    game.load.audio('boden', ['assets/audio/bodenstaendig_2000_in_rock_4bit.mp3', 'assets/audio/bodenstaendig_2000_in_rock_4bit.ogg']);

  }

  create() {
    
    game.world.setBounds(0, 0, 800, 600);

    game.stage.backgroundColor = 0x182d3b;
    game.input.touch.preventDefault = false;

    music = game.add.audio('boden');

    music.play();

    s = game.add.sprite(game.world.centerX, game.world.centerY, 'disk');
    s.anchor.setTo(0.5, 0.5);

    game.input.onDown.add(changeVolume);
  }

  changeVolume(pointer, dom.MouseEvent event) {

    if (pointer.y < 300) {
      music.volume += 0.1;
    } else {
      music.volume -= 0.1;
    }

  }

  update() {
    s.rotation += 0.01;
  }

  render() {
    game.debug.soundInfo(music, 20, 32);
    //game.debug.spriteInputInfo(btn, 50,20);
    //game.debug.inputInfo(50, 100);
  }

  shutdown() {

    music.stop();
  }
}
