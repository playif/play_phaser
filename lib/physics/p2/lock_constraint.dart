part of P2;

class LockConstraint extends p2.LockConstraint {
  Phaser.Game game;
  Phaser.P2 world;

  LockConstraint(world, bodyA, bodyB, offset, angle, maxForce):
  super() {

    if (offset == null) { offset = [0, 0]; }
    if (angle == null) { angle = 0; }
    if (maxForce == null) { maxForce = double.MAX_FINITE; }

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    offset = [ world.pxm(offset[0]), world.pxm(offset[1]) ];

    var options = { localOffsetB: offset, localAngleB: angle, maxForce: maxForce };

    p2.LockConstraint.call(this, bodyA, bodyB, options);
  }
}
