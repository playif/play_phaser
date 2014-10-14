part of example;

class rope_01_demo extends State {
  Rope rope;
  Key debugKey;
  bool shouldDebug = false;

  preload() {
    game.load.image('snake', 'assets/sprites/snake.png');
  }

  create() {
    num count = 0;
    num length = 918/20;
    List points = [];
    for (var i = 0; i < 20; i++) {
      points.add(new Point(i * length, 0));
    }

    rope = game.add.rope(0,this.game.world.centerY,'snake', null, points);

    rope.updateAnimation = () {
      count += 0.1;
      for (var i = 0; i < points.length; i++) {
        points[i].y = Math.sin(i * 0.5  + count) * 20;
      }
    };

    debugKey = game.input.keyboard.addKey(Keyboard.D);
    debugKey.onDown.add(toggleDebug);
    
    rope.x=-60;
  }

  update() {

  }

  render() {
    if(shouldDebug) {
      game.debug.ropeSegments(rope);
    }
    game.debug.text('(D) to show debug', 20,60);
  }

  toggleDebug(Key key) {
    shouldDebug = !shouldDebug;
  }
}
