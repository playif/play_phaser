part of P2;

class RevoluteConstraint extends p2.RevoluteConstraint {
  RevoluteConstraint(world, bodyA, pivotA, bodyB, pivotB, maxForce, worldPivot) {

    if (typeof maxForce === 'undefined') { maxForce = Number.MAX_VALUE; }
    if (typeof worldPivot === 'undefined') { worldPivot = null; }

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

    pivotA = [ world.pxmi(pivotA[0]), world.pxmi(pivotA[1]) ];
    pivotB = [ world.pxmi(pivotB[0]), world.pxmi(pivotB[1]) ];

    if (worldPivot)
    {
      worldPivot = [ world.pxmi(worldPivot[0]), world.pxmi(worldPivot[1]) ];
    }

    var options = { worldPivot: worldPivot, localPivotA: pivotA, localPivotB: pivotB, maxForce: maxForce };

    p2.RevoluteConstraint.call(this, bodyA, bodyB, options);

  }
}
