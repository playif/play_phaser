part of P2;

class RotationalSpring extends RotationalSpring {
  RotationalSpring(world, bodyA, bodyB, restAngle, stiffness, damping) {
    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    if (typeof restAngle === 'undefined') { restAngle = null; }
    if (typeof stiffness === 'undefined') { stiffness = 100; }
    if (typeof damping === 'undefined') { damping = 1; }

    if (restAngle)
    {
      restAngle = world.pxm(restAngle);
    }

    var options = {
        restAngle: restAngle,
        stiffness: stiffness,
        damping: damping
    };

    /**
     * @property {p2.RotationalSpring} data - The actual p2 spring object.
     */
    this.data = new p2.RotationalSpring(bodyA, bodyB, options);

    this.data.parent = this;
  }
}
