part of P2;

class RotationalSpring extends RotationalSpring {
  Phaser.Game game;
  Phaser.P2 world;
  p2.LinearSpring data;

  RotationalSpring(Phaser.P2 world, Body bodyA, Body bodyB, num restAngle, num stiffness, num damping)
      : super() {
    /** 
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    if (restAngle == null) {
      restAngle = null;
    }
    if (stiffness == null) {
      stiffness = 100;
    }
    if (damping == null) {
      damping = 1;
    }

    if (restAngle) {
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
