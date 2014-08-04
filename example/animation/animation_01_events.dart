part of example;


class animation_01_events extends Phaser.State {

  Phaser.Image back;
  Phaser.Sprite mummy;
  Phaser.Animation anim;
  Phaser.Text loopText;
  Phaser.TextStyle style = new Phaser.TextStyle()..fill = 'white';

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

  animationStarted(Phaser.Sprite sprite, Phaser.Animation animation) {
    game.add.text(32, 32, 'Animation started', style);
  }

  animationLooped(Phaser.Sprite sprite, Phaser.Animation animation) {
    if (animation.loopCount == 1) {
      loopText = game.add.text(32, 64, 'Animation looped', style);
    } else {
      loopText.text = 'Animation looped x2';
      animation.loop = false;
    }
  }

  animationStopped(Phaser.Sprite sprite, Phaser.Animation animation) {
    game.add.text(32, 64 + 32, 'Animation stopped', style);
  }

  update() {
    if (anim.isPlaying) {
      back.x -= 1;
    }
  }

}
