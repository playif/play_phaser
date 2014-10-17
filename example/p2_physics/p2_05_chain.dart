part of example;

class p2_05_chain extends State {
  preload() {

    game.load.image('clouds', 'assets/misc/clouds.jpg');
    game.load.spritesheet('chain', 'assets/sprites/chain.png', 16, 26);

  }
  
  p2.Body mouseBody;
  p2.RevoluteConstraint mouseConstraint;

  create() {

    game.add.tileSprite(0, 0, 800, 600, 'clouds');
    game.physics.startSystem(Physics.P2JS);
    game.physics.p2.gravity.y = 1200;

    // create physics body for mouse which we will use for dragging clicked bodies
    mouseBody = new p2.Body(game);
    game.physics.p2.world.addBody(mouseBody.data);
    
    game.input.onDown.add(click);
    game.input.onUp.add(release);
    game.input.addMoveCallback(move);
    
    //  Length, xAnchor, yAnchor
    createRope(40, 400, 64);

  }
  
  click(Pointer pointer, e) {

      List bodies = game.physics.p2.hitTest(pointer.position, game.physics.p2.world.bodies);

      // p2 uses different coordinate system, so convert the pointer position to p2's coordinate system
      p2.vec2 physicsPos = new p2.vec2(game.physics.p2.pxmi(pointer.position.x), game.physics.p2.pxmi(pointer.position.y));
      print("hi");
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
      print("Re");
      // remove constraint from object's body
      game.physics.p2.removeConstraint(mouseConstraint);

    }

    move(num x, num y, bool fromClick) {
      // p2 uses different coordinate system, so convert the pointer position to p2's coordinate system
      //mouseBody.position = new Point(game.physics.p2.pxmi(x), game.physics.p2.pxmi(y));
      mouseBody.x = x;
      mouseBody.y = y;
    }

  createRope(num length, num xAnchor, num yAnchor) {

    Sprite<p2.Body> lastRect;
    num height = 20; //  Height for the physics body - your image height is 8px
    num width = 16; //  This is the width for the physics body. If too small the rectangles will get scrambled together.
    num maxForce = 20000; //  The force that holds the rectangles together.
    Sprite<p2.Body> newRect;
    for (int i = 0; i <= length; i++) {
      num x = xAnchor; //  All rects are on the same x position
      num y = yAnchor + (i * height); //  Every new rect is positioned below the last

      if (i % 2 == 0) {
        //  Add sprite (and switch frame every 2nd time)
        newRect = game.add.sprite(x, y, 'chain', 1);
      } else {
        newRect = game.add.sprite(x, y, 'chain', 0);
        lastRect.bringToTop();
      }

      //  Enable physicsbody
      game.physics.p2.enable(newRect, false);


      //  Set custom rectangle
      newRect.body.setRectangle(width, height);

      if (i == 0) {
        newRect.body.static = true;
      } else {
        //  Anchor the first one created
        newRect.body.velocity.x = 400; //  Give it a push :) just for fun
        newRect.body.mass = length / i; //  Reduce mass for evey rope element
      }

      //  After the first rectangle is created we can add the constraint
      if (lastRect != null) {
        game.physics.p2.createRevoluteConstraint(newRect, [0, -10], lastRect, [0, 10], maxForce);
      }

      lastRect = newRect;

    }

  }
}
