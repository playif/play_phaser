part of example;

class p2_21_pick_up_object extends State {
  preload() {

    game.load.image('tetrisblock1', 'assets/sprites/tetrisblock1.png');
    game.load.image('tetrisblock2', 'assets/sprites/tetrisblock2.png');
    game.load.image('tetrisblock3', 'assets/sprites/tetrisblock3.png');

    game.load.physics('physicsData', 'assets/physics/sprites.json');

  }

  Sprite<p2.Body> tetris1;
  Sprite<p2.Body> tetris2;
  Sprite<p2.Body> tetris3;
  p2.Body mouseBody;
  p2.RevoluteConstraint mouseConstraint;

  create() {

    //	Enable p2 physics
    game.physics.startSystem(Physics.P2JS);
    game.physics.p2.gravity.y = 1000;

    tetris1 = game.add.sprite(300, 100, 'tetrisblock1');
    tetris2 = game.add.sprite(375, 200, 'tetrisblock2');
    tetris3 = game.add.sprite(450, 300, 'tetrisblock3');

    //  Create collision group for the blocks
    p2.CollisionGroup blockCollisionGroup = game.physics.p2.createCollisionGroup();

    //  This part is vital if you want the objects with their own collision groups to still collide with the world bounds
    //  (which we do) - what this does is adjust the bounds to use its own collision group.
    game.physics.p2.updateBoundsCollisionGroup();

    //	Enable the physics bodies on all the sprites
    game.physics.p2.enable([tetris1, tetris2, tetris3], true);

    tetris1.body.clearShapes();
    tetris1.body.loadPolygon('physicsData', 'tetrisblock1');
    tetris1.body.setCollisionGroup(blockCollisionGroup);
    tetris1.body.collides([blockCollisionGroup]);

    tetris2.body.clearShapes();
    tetris2.body.loadPolygon('physicsData', 'tetrisblock2');
    tetris2.body.setCollisionGroup(blockCollisionGroup);
    tetris2.body.collides([blockCollisionGroup]);

    tetris3.body.clearShapes();
    tetris3.body.loadPolygon('physicsData', 'tetrisblock3');
    tetris3.body.setCollisionGroup(blockCollisionGroup);
    tetris3.body.collides([blockCollisionGroup]);

    // create physics body for mouse which we will use for dragging clicked bodies
    mouseBody = new p2.Body(game);
    game.physics.p2.world.addBody(mouseBody.data);

    // attach pointer events
    game.input.onDown.add(click);
    game.input.onUp.add(release);
    game.input.addMoveCallback(move);
  }

  click(Pointer pointer, e) {

    List bodies = game.physics.p2.hitTest(pointer.position, [tetris1.body, tetris2, tetris3]);

    // p2 uses different coordinate system, so convert the pointer position to p2's coordinate system
    p2.vec2 physicsPos = new p2.vec2(game.physics.p2.pxmi(pointer.position.x), game.physics.p2.pxmi(pointer.position.y));

    if (bodies.length != 0) {

      var clickedBody = bodies[0];

      p2.vec2 localPointInBody = new p2.vec2(0, 0);
      // this function takes physicsPos and coverts it to the body's local coordinate system
      clickedBody.toLocalFrame(localPointInBody, physicsPos);

      // use a revoluteContraint to attach mouseBody to the clicked body
      mouseConstraint = this.game.physics.p2.createRevoluteConstraint(mouseBody, [0, 0], clickedBody, [game.physics.p2.mpxi(localPointInBody[0]), game.physics.p2.mpxi(localPointInBody[1])]);
    }

  }

  release(p, e) {

    // remove constraint from object's body
    game.physics.p2.removeConstraint(mouseConstraint);

  }

  move(num x, num y, bool fromClick) {
    // p2 uses different coordinate system, so convert the pointer position to p2's coordinate system
    //mouseBody.position = new Point(game.physics.p2.pxmi(x), game.physics.p2.pxmi(y));
    mouseBody.x = x;
    mouseBody.y = y;
  }

  update() {
  }

  render() {

//	game.debug.text(result, 32, 32);

  }
}
