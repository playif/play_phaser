part of P2;

class Spring {
  /// Local reference to game.
  Phaser.Game game;
  /// Local reference to P2 World.
  P2 world;
  p2.LinearSpring data;

  Spring(P2 world, p2.Body bodyA, p2.Body bodyB, [num restLength, num stiffness, num damping, List worldA, List worldB, List localA, List localB])
      {

    this.game = world.game;
    this.world = world;

    if (restLength == null) {
      restLength = 1;
    }
    if (stiffness == null) {
      stiffness = 100;
    }
    if (damping == null) {
      damping = 1;
    }

    restLength = world.pxm(restLength);

//    var options = {
//      restLength: restLength,
//      stiffness: stiffness,
//      damping: damping
//    };

//    if (worldA != null) {
//      worldAnchorA = [world.pxm(worldA[0]), world.pxm(worldA[1])];
//    }
//
//    if (worldB != null) {
//      options.worldAnchorB = [world.pxm(worldB[0]), world.pxm(worldB[1])];
//    }
//
//    if (localA != null) {
//      options.localAnchorA = [world.pxm(localA[0]), world.pxm(localA[1])];
//    }
//
//    if (localB != null) {
//      options.localAnchorB = [world.pxm(localB[0]), world.pxm(localB[1])];
//    }

    /**
     * @property {p2.LinearSpring} data - The actual p2 spring object.
     */
    this.data = new p2.LinearSpring(bodyA,
        bodyB,
        stiffness: stiffness,
        damping: damping,
        worldAnchorA:new p2.vec2(world.pxm(worldA[0]), world.pxm(worldA[1])),
        worldAnchorB:new p2.vec2(world.pxm(worldB[0]), world.pxm(worldB[1])),
        localAnchorA:new p2.vec2(world.pxm(localA[0]), world.pxm(localA[1])),
        localAnchorB:new p2.vec2(world.pxm(localB[0]), world.pxm(localB[1]))
        );

    this.data.parent = this;

  }
}
