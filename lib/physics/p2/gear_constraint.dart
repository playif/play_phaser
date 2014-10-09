part of P2;

class GearConstraint extends p2.GearConstraint {
  Phaser.Game game;
  P2 world;

  GearConstraint(P2 world, p2.Body bodyA, p2.Body bodyB, [num angle=0, num ratio=1])
  :super(bodyA, bodyB, angle:angle, ratio: ratio){

    if (angle == null) { angle = 0; }
    if (ratio == null) { ratio = 1; }

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    //var options = { angle: angle, ratio: ratio };

    //p2.GearConstraint.call(this, bodyA, bodyB, options);
  }
}
