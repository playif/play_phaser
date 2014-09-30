part of P2;

class GearConstraint extends p2.GearConstraint {
  Phaser.Game game;
  Phaser.P2 world;

  GearConstraint(Phaser.P2 world, Body bodyA, Body bodyB, [num angle, num ratio])
  :super(){

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
