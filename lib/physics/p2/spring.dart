part of P2;

class Spring extends p2.Spring {
  Phaser.Game game;
  Phaser.P2 world;
  p2.LinearSpring data;

  Spring(Phaser.P2 world, Body bodyA, Body bodyB, num restLength, num stiffness, num damping, List worldA, List worldB, List localA, List localB)
  :super(){

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    if ( restLength == null) { restLength = 1; }
    if ( stiffness == null) { stiffness = 100; }
    if ( damping == null) { damping = 1; }

    restLength = world.pxm(restLength);

    var options = {
        restLength: restLength,
        stiffness: stiffness,
        damping: damping
    };

    if (worldA != null)
    {
      options.worldAnchorA = [ world.pxm(worldA[0]), world.pxm(worldA[1]) ];
    }

    if (worldB != null)
    {
      options.worldAnchorB = [ world.pxm(worldB[0]), world.pxm(worldB[1]) ];
    }

    if (localA != null)
    {
      options.localAnchorA = [ world.pxm(localA[0]), world.pxm(localA[1]) ];
    }

    if (localB != null)
    {
      options.localAnchorB = [ world.pxm(localB[0]), world.pxm(localB[1]) ];
    }

    /**
     * @property {p2.LinearSpring} data - The actual p2 spring object.
     */
    this.data = new p2.LinearSpring(bodyA, bodyB, options);

    this.data.parent = this;

  }
}
