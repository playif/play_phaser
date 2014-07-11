library Physics;

import "../phaser.dart";

part "arcade/body.dart";
part "arcade/world.dart";


class Physics {
  Game game;
  Map config;
  Arcade arcade;


  Physics(game, [Map config = const {}]) {

    /**
     * @property {Phaser.Game} game - Local reference to game.
     */
    this.game = game;

    /**
     * @property {object} config - The physics configuration object as passed to the game on creation.
     */
    this.config = config;

    /**
     * @property {Phaser.Physics.Arcade} arcade - The Arcade Physics system.
     */
    this.arcade = null;

    /**
     * @property {Phaser.Physics.P2} p2 - The P2.JS Physics system.
     */
    this.p2 = null;

    /**
     * @property {Phaser.Physics.Ninja} ninja - The N+ Ninja Physics System.
     */
    this.ninja = null;

    /**
     * @property {Phaser.Physics.Box2D} box2d - The Box2D Physics system (to be done).
     */
    this.box2d = null;

    /**
     * @property {Phaser.Physics.Chipmunk} chipmunk - The Chipmunk Physics system (to be done).
     */
    this.chipmunk = null;

    this.parseConfig();
  }
}
