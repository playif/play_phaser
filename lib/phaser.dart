library Phaser;

//import "dart:core";
import "dart:typed_data";
import "dart:web_audio";
import "dart:async" as async;
import "dart:html";
import "dart:convert";
import "dart:collection";
import "dart:math" as DMath;
import "dart:js";


//@MirrorsUsed(targets: 'Phaser',  override: '*')
//@MirrorsUsed(targets: const [GameObject, Sprite, Text, Particle], symbols: const ["*",'x','y'],  override: '*')
//@MirrorsUsed(symbols: "*", override: '*')
@MirrorsUsed(targets:const ['PIXI', 'Phaser'], override: '*')
import "dart:mirrors";

import "package:play_pixi/pixi.dart" as PIXI;
import "package:p2/p2.dart" as p2js;

import "arcade.dart" as Arcade;
import "ninja.dart" as Ninja;
import "p2.dart" as P2;



part "animation/animation.dart";
part "animation/animation_manager.dart";
part "animation/animation_parser.dart";
part "animation/frame.dart";
part "animation/frame_data.dart";


part "core/camera.dart";
part "core/core_signal.dart";
part "core/filter.dart";
part "core/flex_grid.dart";
part "core/flex_layer.dart";
part "core/game.dart";
part "core/group.dart";
part "core/plugin.dart";
part "core/plugin_manager.dart";
part "core/scale_manager.dart";
part "core/signal_binding.dart";
part "core/stage.dart";
part "core/state.dart";
part "core/state_manager.dart";
part "core/world.dart";


part "gameobjects/bitmap_data.dart";
part "gameobjects/bitmap_text.dart";
part "gameobjects/button.dart";
part "gameobjects/events.dart";
part "gameobjects/game_object.dart";
part "gameobjects/game_object_creator.dart";
part "gameobjects/game_object_factory.dart";
part "gameobjects/graphics.dart";
part "gameobjects/image.dart";
part "gameobjects/particle.dart";
part "gameobjects/render_texture.dart";
part "gameobjects/retro_font.dart";
part "gameobjects/rope.dart";
part "gameobjects/sprite.dart";
part "gameobjects/sprite_batch.dart";
part "gameobjects/text.dart";
part "gameobjects/tile_sprite.dart";


part "geom/circle.dart";
part "geom/ellipse.dart";
part "geom/line.dart";
part "geom/point.dart";
part "geom/polygon.dart";
part "geom/rectangle.dart";


part "input/gamepad.dart";
part "input/gamepad_button.dart";
part "input/input.dart";
part "input/input_handler.dart";
part "input/key.dart";
part "input/keyboard.dart";
part "input/mouse.dart";
part "input/ms_pointer.dart";
part "input/pointer.dart";
part "input/single_pad.dart";
part "input/touch.dart";


part "loader/cache.dart";
part "loader/loader.dart";
part "loader/loader_parser.dart";


part "math/math.dart";
part "math/quad_tree.dart";
part "math/random_data_generator.dart";


part "net/net.dart";


part "particles/arcade/arcade_particles.dart";
part "particles/arcade/emitter.dart";
part "particles/particles.dart";


part "physics/physics.dart";
part "physics/ibody.dart";

//part "physics/ninja/ninja.dart";
//part "physics/p2/p2.dart";

part "sound/audio_sprite.dart";
part "sound/sound.dart";
part "sound/sound_manager.dart";


part "system/canvas.dart";
part "system/device.dart";
part "system/request_animation_frame.dart";


part "tilemap/tile.dart";
part "tilemap/tilemap.dart";
part "tilemap/tilemap_layer.dart";
part "tilemap/tilemap_parser.dart";
part "tilemap/tileset.dart";


part "time/time.dart";
part "time/timer.dart";
part "time/timer_event.dart";


part "tween/easing.dart";
part "tween/tween.dart";
part "tween/tween_manager.dart";


part "utils/color.dart";
part "utils/debug.dart";
part "utils/utils.dart";


const String VERSION = '2.1.2';
final List<Game> GAMES = [];


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
const int ROPE = 20;

