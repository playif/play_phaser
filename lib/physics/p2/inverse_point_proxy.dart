part of P2;

class InversePointProxy {
  Phaser.P2 world;
  List destination;

  /**
   * @name Phaser.Physics.P2.InversePointProxy#x
   * @property {number} x - The x property of this InversePointProxy get and set in pixels.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "x", {

  get x {
    return this.world.mpxi(this.destination[0]);
  }

  set x(value) {
    this.destination[0] = this.world.pxmi(value);
  }

  //});

  /**
   * @name Phaser.Physics.P2.InversePointProxy#y
   * @property {number} y - The y property of this InversePointProxy get and set in pixels.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "y", {

  num get y {
    return this.world.mpxi(this.destination[1]);
  }

  set y(num value) {
    this.destination[1] = this.world.pxmi(value);
  }

  //});

  /**
   * @name Phaser.Physics.P2.InversePointProxy#mx
   * @property {number} mx - The x property of this InversePointProxy get and set in meters.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "mx", {

  num get mx {
    return this.destination[0];
  }

  set mx(num value) {
    this.destination[0] = -value;
  }

  //});

  /**
   * @name Phaser.Physics.P2.InversePointProxy#my
   * @property {number} my - The y property of this InversePointProxy get and set in meters.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "my", {

  num get my {
    return this.destination[1];
  }

  set my(num value) {
    this.destination[1] = -value;
  }

  //});

  InversePointProxy(Phaser.P2 world, List destination) {
    this.world = world;
    this.destination = destination;
  }

}
