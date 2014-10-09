part of Ninja;

abstract class Shape {
  ///property {Phaser.Physics.Ninja.Body} system - A reference to the body that owns this shape.
  Body body;


  ///property {Phaser.Physics.Ninja} system - A reference to the physics system.
  Ninja system;


  /// property {Phaser.Point} pos - The position of this object.
  Phaser.Point pos;


  /// property {Phaser.Point} oldpos - The position of this object in the previous update.
  Phaser.Point oldpos;

  /**
   * @property {number} xw - Half the width.
   * @readonly
   */

  num get xw => Phaser.Math.abs(width / 2);

  /**
   * @property {number} xw - Half the height.
   * @readonly
   */

  num get yw => Phaser.Math.abs(height / 2);

  num _width;

  /**
   * @property {number} width - The width.
   * @readonly
   */

  num get width => _width;

  num _height;

  /**
   * @property {number} height - The height.
   * @readonly
   */

  num get height => _height;

  /**
   * @property {number} oH - Internal var.
   * @private
   */
  num oH;

  /**
   * @property {number} oV - Internal var.
   * @private
   */
  num oV;

  /**
   * @property {Phaser.Point} velocity - The velocity of this object.
   */
  Phaser.Point velocity;

  /**
   * @property {object} aabbTileProjections - All of the collision response handlers.
   */
  Map aabbTileProjections;

  integrate();
  collideWorldBounds();
  destroy();
  render(dom.CanvasRenderingContext2D context, num xOffset, num yOffset, String color, bool filled);
}
