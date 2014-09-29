part of P2;

class Spring extends p2.Spring {
  Spring(world, bodyA, bodyB, restLength, stiffness, damping, worldA, worldB, localA, localB) {

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    if (typeof restLength === 'undefined') { restLength = 1; }
    if (typeof stiffness === 'undefined') { stiffness = 100; }
    if (typeof damping === 'undefined') { damping = 1; }

    restLength = world.pxm(restLength);

    var options = {
        restLength: restLength,
        stiffness: stiffness,
        damping: damping
    };

    if (typeof worldA !== 'undefined' && worldA !== null)
    {
      options.worldAnchorA = [ world.pxm(worldA[0]), world.pxm(worldA[1]) ];
    }

    if (typeof worldB !== 'undefined' && worldB !== null)
    {
      options.worldAnchorB = [ world.pxm(worldB[0]), world.pxm(worldB[1]) ];
    }

    if (typeof localA !== 'undefined' && localA !== null)
    {
      options.localAnchorA = [ world.pxm(localA[0]), world.pxm(localA[1]) ];
    }

    if (typeof localB !== 'undefined' && localB !== null)
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
