part of P2;

class DistanceConstraint extends p2.DistanceConstraint {
  Phaser.Game game;
  P2 world;
  /**
   * A constraint that tries to keep the distance between two bodies constant.
   *
   * @class Phaser.Physics.P2.DistanceConstraint
   * @classdesc Physics DistanceConstraint Constructor
   * @constructor
   * @param {Phaser.Physics.P2} world - A reference to the P2 World.
   * @param {p2.Body} bodyA - First connected body.
   * @param {p2.Body} bodyB - Second connected body.
   * @param {number} distance - The distance to keep between the bodies.
   * @param {Array} [localAnchorA] - The anchor point for bodyA, defined locally in bodyA frame. Defaults to [0,0].
   * @param {Array} [localAnchorB] - The anchor point for bodyB, defined locally in bodyB frame. Defaults to [0,0].
   * @param {object} [maxForce=Number.MAX_VALUE] - Maximum force to apply.
   */
  DistanceConstraint(P2 world, p2.Body bodyA, p2.Body bodyB, [num distance=100, localAnchorA=const [0,0], List localAnchorB=const [0,0], num maxForce=double.MAX_FINITE])
  :super(bodyA,bodyB,distance:distance,localAnchorA:localAnchorA,localAnchorB: p2.vec2.fromValues(localAnchorB[0], localAnchorB[1]),maxForce:maxForce) {
    this.game=world.game;
    this.world=world;
    distance = world.pxm(distance);
    localAnchorA = [ world.pxmi(localAnchorA[0]), world.pxmi(localAnchorA[1]) ];
    localAnchorB = [ world.pxmi(localAnchorB[0]), world.pxmi(localAnchorB[1]) ];

    //var options = { distance: distance, localAnchorA: localAnchorA, localAnchorB: localAnchorB, maxForce: maxForce };

    //p2.DistanceConstraint.call(this, bodyA, bodyB, options);
  }
}
