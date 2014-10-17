part of P2;

class RevoluteConstraint extends p2.RevoluteConstraint {
  Phaser.Game game;
  P2 world;
  //p2.LinearSpring data;

  RevoluteConstraint(P2 world, p2.Body bodyA, List pivotA, p2.Body bodyB, List pivotB, num maxForce, List worldPivot)
      : super(bodyA, bodyB, worldPivot: worldPivot!=null? [world.pxmi(worldPivot[0]), world.pxmi(worldPivot[1])]:null, localPivotA: new p2.vec2(world.pxmi(pivotA[0]), world.pxmi(pivotA[1])), localPivotB: new p2.vec2(world.pxmi(pivotB[0]), world.pxmi(pivotB[1])), maxForce: maxForce) {

    if (maxForce == null) {
      maxForce = double.MAX_FINITE;
    }
    if (worldPivot == null) {
      worldPivot = null;
    }

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = world.game;

    /**
     * @property {Phaser.Physics.P2} world - Local reference to P2 World.
     */
    this.world = world;

//    pivotA = [world.pxmi(pivotA[0]), world.pxmi(pivotA[1])];
//    pivotB = [world.pxmi(pivotB[0]), world.pxmi(pivotB[1])];
//
//    if (worldPivot != null) {
//      worldPivot = [world.pxmi(worldPivot[0]), world.pxmi(worldPivot[1])];
//    }


    //p2.RevoluteConstraint.call(this, bodyA, bodyB, options);

  }
}
