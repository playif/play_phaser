part of example;


class animation_01_events extends State {

  Image back;
  Sprite mummy;
  Animation anim;
  Text loopText;
  TextStyle style = new TextStyle()..fill = 'white';

  preload() {
    game.load.image('lazur', 'assets/pics/thorn_lazur.png');
    game.load.spritesheet('mummy', 'assets/sprites/metalslug_mummy37x45.png', 37, 45, 18);
  }

  create() {
    game.stage.smoothed = false;

    back = game.add.image(0, -400, 'lazur');
    back.scale.set(2);

    mummy = game.add.sprite(200, 360, 'mummy', 5);
    mummy.scale.set(4);

    anim = mummy.animations.add('walk');

    anim.onStart.add(animationStarted);
    anim.onLoop.add(animationLooped);
    anim.onComplete.add(animationStopped);

    anim.play(10, true);
  }

  animationStarted(Sprite sprite, Animation animation) {
    game.add.text(32, 32, 'Animation started', style);
  }

  animationLooped(Sprite sprite, Animation animation) {
    if (animation.loopCount == 1) {
      loopText = game.add.text(32, 64, 'Animation looped', style);
    } else {
      loopText.text = 'Animation looped x2';
      animation.loop = false;
    }
  }

  animationStopped(Sprite sprite, Animation animation) {
    game.add.text(32, 64 + 32, 'Animation stopped', style);
  }

  update() {
    if (anim.isPlaying) {
      back.x -= 1;
    }
  }

}
