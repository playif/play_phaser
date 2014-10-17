part of P2;

class LockConstraint extends p2.LockConstraint {
  /// Local reference to game.
  Phaser.Game game;
  /// Local reference to P2 World.
  P2 world;

  LockConstraint(world, bodyA, bodyB, offset, angle, maxForce) : super(bodyA, bodyB, localOffsetB: new p2.vec2(world.pxm(offset[0]), world.pxm(offset[1])), localAngleB: angle, maxForce: maxForce) {
    if (offset == null) {
      offset = [0, 0];
    }
    if (angle == null) {
      angle = 0;
    }
    if (maxForce == null) {
      maxForce = double.MAX_FINITE;
    }

    this.game = world.game;

    this.world = world;

    offset = [world.pxm(offset[0]), world.pxm(offset[1])];

//    var options = {
//      localOffsetB: offset,
//      localAngleB: angle,
//      maxForce: maxForce
//    };

    //p2.LockConstraint.call(this, bodyA, bodyB, options);
  }
}
