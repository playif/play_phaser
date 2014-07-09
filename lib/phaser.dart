library Phaser;

import "dart:async";
import "dart:html";
import "dart:convert";
import "dart:web_gl";
import "package:play_pixi/pixi.dart" as PIXI;


part "core/game.dart";
part "core/signal.dart";
part "core/signal_binding.dart";
part "core/state.dart";

part "gameobjects/game_object_creator.dart";
part "gameobjects/game_object_factory.dart";

part "system/canvas.dart";
part "system/device.dart";
part "system/request_animation_frame.dart";


const String VERSION = '2.0.5';

const int AUTO = 0;
const int CANVAS = 1;
const int WEBGL = 2;
const int HEADLESS = 3;


const int NONE = 0;
const int LEFT = 1;
const int RIGHT = 2;
const int UP = 3;
const int DOWN = 4;


const int SPRITE = 0;
const int BUTTON = 1;
const int IMAGE = 2;
const int GRAPHICS = 3;
const int TEXT = 4;
const int TILESPRITE = 5;
const int BITMAPTEXT = 6;
const int GROUP = 7;
const int RENDERTEXTURE = 8;
const int TILEMAP = 9;
const int TILEMAPLAYER = 10;
const int EMITTER = 11;
const int POLYGON = 12;
const int BITMAPDATA = 13;
const int CANVAS_FILTER = 14;
const int WEBGL_FILTER = 15;
const int ELLIPSE = 16;
const int SPRITEBATCH = 17;
const int RETROFONT = 17;
const int POINTER = 19;

