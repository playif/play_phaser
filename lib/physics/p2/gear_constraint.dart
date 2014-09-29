part of P2;

class GearConstraint extends p2.GearConstraint {
  GearConstraint(world, bodyA, bodyB, angle, ratio) {

    if (typeof angle === 'undefined') { angle = 0; }
    if (typeof ratio === 'undefined') { ratio = 1; }

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    var options = { angle: angle, ratio: ratio };

    p2.GearConstraint.call(this, bodyA, bodyB, options);
  }
}
