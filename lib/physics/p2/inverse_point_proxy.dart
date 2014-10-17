part of P2;

class InversePointProxy extends Phaser.Point {
  P2 world;
  p2.vec2 destination;

  /**
   * @name Phaser.Physics.P2.InversePointProxy#x
   * @property {number} x - The x property of this InversePointProxy get and set in pixels.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "x", {

  get x {
    return this.world.mpxi(this.destination.x);
  }

  set x(value) {
    this.destination.x = this.world.pxmi(value);
  }

  //});

  /**
   * @name Phaser.Physics.P2.InversePointProxy#y
   * @property {number} y - The y property of this InversePointProxy get and set in pixels.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "y", {

  num get y {
    return this.world.mpxi(this.destination.y);
  }

  set y(num value) {
    this.destination.y = this.world.pxmi(value);
  }

  //});

  /**
   * @name Phaser.Physics.P2.InversePointProxy#mx
   * @property {number} mx - The x property of this InversePointProxy get and set in meters.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "mx", {

  num get mx {
    return this.destination.x;
  }

  set mx(num value) {
    this.destination.x = -value;
  }

  //});

  /**
   * @name Phaser.Physics.P2.InversePointProxy#my
   * @property {number} my - The y property of this InversePointProxy get and set in meters.
   */
  //Object.defineProperty(Phaser.Physics.P2.InversePointProxy.prototype, "my", {

  num get my {
    return this.destination.y;
  }

  set my(num value) {
    this.destination.y = -value;
  }

  //});

  InversePointProxy(this.world, this.destination):super() {
//    this.world = world;
//    this.destination = destination;
  }

}
