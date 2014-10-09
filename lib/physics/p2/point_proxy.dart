part of P2;

class PointProxy {

  /// Local reference to the P2 World.
  P2 world;
  
  List destination;

  PointProxy(P2 world, List destination) {
    this.world = world;
    this.destination = destination;
  }

  /**
   * @name Phaser.Physics.P2.PointProxy#x
   * @property {number} x - The x property of this PointProxy get and set in pixels.
   */
  //Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "x", {

  num get x {

    return this.world.mpx(this.destination[0]);

  }

  set x(num value) {

    this.destination[0] = this.world.pxm(value);

  }


  /**
   * @name Phaser.Physics.P2.PointProxy#y
   * @property {number} y - The y property of this PointProxy get and set in pixels.
   */
  //Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "y", {

  num get y {

    return this.world.mpx(this.destination[1]);

  }

  set y(num value) {

    this.destination[1] = this.world.pxm(value);

  }


  /**
   * @name Phaser.Physics.P2.PointProxy#mx
   * @property {number} mx - The x property of this PointProxy get and set in meters.
   */
  //Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "mx", {

  num get mx {

    return this.destination[0];

  }

  set mx(num value) {

    this.destination[0] = value;

  }


  /**
   * @name Phaser.Physics.P2.PointProxy#my
   * @property {number} my - The x property of this PointProxy get and set in meters.
   */
  //Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "my", {

  num get my {

    return this.destination[1];

  }

  set my(num value) {

    this.destination[1] = value;

  }

}
