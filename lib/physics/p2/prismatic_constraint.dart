part of P2;

class PrismaticConstraint extends p2.PrismaticConstraint {
  Phaser.Game game;
  Phaser.P2 world;

  PrismaticConstraint(world, bodyA, bodyB, lockRotation, anchorA, anchorB, axis, maxForce)
  :super() {

    if ( lockRotation == null) { lockRotation = true; }
    if ( anchorA == null) { anchorA = [0, 0]; }
    if ( anchorB == null) { anchorB = [0, 0]; }
    if ( axis == null) { axis = [0, 0]; }
    if ( maxForce == null) { maxForce = double.MAX_FINITE; }

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    anchorA = [ world.pxmi(anchorA[0]), world.pxmi(anchorA[1]) ];
    anchorB = [ world.pxmi(anchorB[0]), world.pxmi(anchorB[1]) ];

    var options = { localAnchorA: anchorA, localAnchorB: anchorB, localAxisA: axis, maxForce: maxForce, disableRotationalLock: !lockRotation };

    p2.PrismaticConstraint.call(this, bodyA, bodyB, options);

  }
}
