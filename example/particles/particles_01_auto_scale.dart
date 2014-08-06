part of example;

class particles_01_auto_scale extends State {
  Emitter emitter;
  //var x;

  preload() {

    game.load.image('bubble', 'assets/sprites/shinyball.png');
    // game.load.image('bubble', 'assets/sprites/bubble.png');
    game.load.image('water', 'assets/skies/sunset.png');

  }

  create() {

    // game.add.image(0, 0, 'water');

    //	Emitters have a center point and a width/height, which extends from their center point to the left/right and up/down
    emitter = game.add.emitter(game.world.centerX, 200, 400);

    //	This emitter will have a width of 800px, so a particle can emit from anywhere in the range emitter.x += emitter.width / 2
    // emitter.width = 800;

    emitter.makeParticles('bubble');

    // emitter.minParticleSpeed.set(0, 300);
    // emitter.maxParticleSpeed.set(0, 600);

    emitter.setRotation(0, 0);
    emitter.setAlpha(0.1, 1, 3000);
    emitter.setScale(0.1, 1, 0.1, 1, 6000, Easing.Quintic.Out);
    emitter.setRotation(-360,360);
    emitter.gravity = -200;

    emitter.start(false, 5000, 10);

    emitter.emitX = 0;

    game.add.tween(emitter).to( { 'x': 800 }, 2000, Easing.Linear.None, true, 0, 999999, true);

  }

  update() {

    // emitter.emitX

    emitter.customSort(scaleSort);

  }

  scaleSort(a, b) {

    if (a.scale.x < b.scale.x)
    {
      return -1;
    }
    else if (a.scale.x > b.scale.x)
    {
      return 1;
    }
    else
    {
      return 0;
    }

  }

  render() {
    // game.debug.text(emitter.total, 32, 32);
  }
}
