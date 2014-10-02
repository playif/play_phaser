part of example;

class p2_05_chain extends State {
  preload() {

    game.load.image('clouds', 'assets/misc/clouds.jpg');
    game.load.spritesheet('chain', 'assets/sprites/chain.png', 16, 26);

  }

  create() {

    game.add.tileSprite(0, 0, 800, 600, 'clouds');
    game.physics.startSystem(Physics.P2JS);
    game.physics.p2.gravity.y = 1200;

    //  Length, xAnchor, yAnchor
    createRope(40, 400, 64);

  }

  createRope(num length, num xAnchor, num yAnchor) {

    Sprite lastRect;
    num height = 20; //  Height for the physics body - your image height is 8px
    num width = 16; //  This is the width for the physics body. If too small the rectangles will get scrambled together.
    num maxForce = 20000; //  The force that holds the rectangles together.
    Sprite newRect;
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
      (newRect.body as p2.Body).setRectangle(width, height);

      if (i == 0) {
        (newRect.body as p2.Body).static = true;
      } else {
        //  Anchor the first one created
        newRect.body.velocity.x = 400; //  Give it a push :) just for fun
        (newRect.body as p2.Body).mass = length / i; //  Reduce mass for evey rope element
      }

      //  After the first rectangle is created we can add the constraint
      if (lastRect != null) {
        game.physics.p2.createRevoluteConstraint(newRect, [0, -10], lastRect, [0, 10], maxForce);
      }

      lastRect = newRect;

    }

  }
}
