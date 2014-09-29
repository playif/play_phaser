part of P2;

class PointProxy {
  PointProxy(world, destination) {
    this.world = world;
    this.destination = destination;
  }

  /**
   * @name Phaser.Physics.P2.PointProxy#x
   * @property {number} x - The x property of this PointProxy get and set in pixels.
   */
  Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "x", {

  get: function () {

  return this.world.mpx(this.destination[0]);

  },

  set: function (value) {

  this.destination[0] = this.world.pxm(value);

  }

  });

  /**
   * @name Phaser.Physics.P2.PointProxy#y
   * @property {number} y - The y property of this PointProxy get and set in pixels.
   */
  Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "y", {

  get: function () {

  return this.world.mpx(this.destination[1]);

  },

  set: function (value) {

  this.destination[1] = this.world.pxm(value);

  }

  });

  /**
   * @name Phaser.Physics.P2.PointProxy#mx
   * @property {number} mx - The x property of this PointProxy get and set in meters.
   */
  Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "mx", {

  get: function () {

  return this.destination[0];

  },

  set: function (value) {

  this.destination[0] = value;

  }

  });

  /**
   * @name Phaser.Physics.P2.PointProxy#my
   * @property {number} my - The x property of this PointProxy get and set in meters.
   */
  Object.defineProperty(Phaser.Physics.P2.PointProxy.prototype, "my", {

  get: function () {

  return this.destination[1];

  },

  set: function (value) {

  this.destination[1] = value;

  }

  });
}
