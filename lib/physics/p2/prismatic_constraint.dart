part of P2;

class PrismaticConstraint extends p2.PrismaticConstraint {
  PrismaticConstraint(world, bodyA, bodyB, lockRotation, anchorA, anchorB, axis, maxForce) {

    if (typeof lockRotation === 'undefined') { lockRotation = true; }
    if (typeof anchorA === 'undefined') { anchorA = [0, 0]; }
    if (typeof anchorB === 'undefined') { anchorB = [0, 0]; }
    if (typeof axis === 'undefined') { axis = [0, 0]; }
    if (typeof maxForce === 'undefined') { maxForce = Number.MAX_VALUE; }

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
