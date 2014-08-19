library example;
import "package:tweenengine/tweenengine.dart" as tween;
import "package:play_phaser/phaser.dart";
import "package:play_pixi/pixi.dart" as PIXI;
import "dart:html" as dom;

//@MirrorsUsed(targets: const [Sprite, Text, Particle, Gem], symbols: const ["call"], override: '*')
import "dart:mirrors";

//import "package:play_pixi/pixi.dart" as PIXI;

part "basics/basic_01_load_an_image.dart";
part "basics/basic_02_click_on_an_image.dart";
part "basics/basic_03_image_follow_input.dart";
part "basics/basic_04_load_animation.dart";
part "basics/basics_05_render_text.dart";


part "animation/animation_01_events.dart";
part "animation/animation_02_change_texture_on_click.dart";
part "animation/animation_03_group_creation.dart";
part "animation/animation_08_multiple_anims.dart";

part "audio/audio_01_audio_sprite.dart";
part "audio/audio_02_play_music.dart";

part "tweens/tweens_01_chained_tweens.dart";

part "loader/loader_01_asset_pack.dart";

part "input/input_01_bring_a_child_to_top.dart";

part "particles/particles_01_auto_scale.dart";

part "arcade_physics/arcade_physics_34_quadtree.dart";

part "camera/camera_01_basic_follow.dart";
part "camera/camera_02_camera_cull.dart";
part "camera/camera_03_camera_view.dart";


part "tilemaps/tilemaps_01_blank_map.dart";
part "tilemaps/tilemaps_16_tilemap_ray_cast.dart";

part "display/display_01_alpha_mask.dart";
part "display/display_02_bitmapdata_atlas.dart";
part "display/display_14_bitmapdata_wobble.dart";
part "display/display_19_graphics.dart";
part "display/display_20_bitmapdata_set_hsl.dart";


part "games/games_01_breakout.dart";
part "games/games_02_gemmatch.dart";
part "games/games_03_invaders.dart";
part "games/games_04_matching_pairs.dart";
part "games/games_05_simon.dart";
part "games/games_06_starstruck.dart";
part "games/games_07_tanks.dart";

//Map<String, Map<String, State>> Examples = {
//    "Basic":{
//        "basic_01_load_an_image": new basic_01_load_an_image(),
//        "basic_02_click_on_an_image": new basic_02_click_on_an_image(),
//        "basic_03_image_follow_input": new basic_03_image_follow_input(),
//        "basic_04_load_animation": new basic_04_load_animation(),
//    },
//
//
//};

Map<String, State> examples = {

    "basic_01_load_an_image": new basic_01_load_an_image(),
    "basic_02_click_on_an_image": new basic_02_click_on_an_image(),
    "basic_03_image_follow_input": new basic_03_image_follow_input(),
    "basic_04_load_animation": new basic_04_load_animation(),
    "basic_05_render_text": new basics_05_render_text(),


    "animation_01_events": new animation_01_events(),
    "animation_02_change_texture_on_click": new animation_02_change_texture_on_click(),
    "animation_03_group_creation": new animation_03_group_creation(),
    "animation_08_multiple_anims": new animation_08_multiple_anims(),


    "audio_01_audio_sprite": new audio_01_audio_sprite(),
    "audio_02_play_music": new audio_02_play_music(),


    "tweens_01_chained_tweens": new tweens_01_chained_tweens(),


    "loader_01_asset_pack": new loader_01_asset_pack(),


    "input_01_bring_a_child_to_top": new input_01_bring_a_child_to_top(),


    "particles_01_auto_scale": new particles_01_auto_scale(),


    "arcade_physics_34_quadtree": new arcade_physics_34_quadtree(),


    "camera_01_basic_follow": new camera_01_basic_follow(),
    "camera_02_camera_cull": new camera_02_camera_cull(),
    "camera_03_camera_view": new camera_03_camera_view(),


    "tilemaps_01_blank_map": new tilemaps_01_blank_map(),
    "tilemaps_16_tilemap_ray_cast": new tilemaps_16_tilemap_ray_cast(),

    "display_01_alpha_mask":new display_01_alpha_mask(),
    "display_02_bitmapdata_atlas":new display_02_bitmapdata_atlas(),
    "display_14_bitmapdata_wobble":new display_14_bitmapdata_wobble(),
    "display_19_graphics":new display_19_graphics(),
    "display_20_bitmapdata_set_hsl":new display_20_bitmapdata_set_hsl(),


    "games_01_breakout":new games_01_breakout(),
    "games_02_gemmatch":new games_02_gemmatch(),
    "games_03_invaders":new games_03_invaders(),
    "games_04_matching_pairs":new games_04_matching_pairs(),
    "games_05_simon":new games_05_simon(),
    "games_06_starstruck":new games_06_starstruck(),
    "games_07_tanks":new games_07_tanks(),

};

main() {
//  dom.window.console.log("preload");


//  var w = dom.window.innerWidth * dom.window.devicePixelRatio,
//  h = dom.window.innerHeight * dom.window.devicePixelRatio,
//  width = (h > w) ? h : w,
//  height = (h > w) ? w : h;
//
//  // Hack to avoid iPad Retina and large Android devices. Tell it to scale up.
//  if (dom.window.innerWidth >= 1024 && dom.window.devicePixelRatio >= 2)
//  {
//    width = Math.round(width / 2);
//    height = Math.round(height / 2);
//  }
//  // reduce screen size by one 3rd on devices like Nexus 5
//  if (dom.window.devicePixelRatio == 3)
//  {
//    width = Math.round(width / 3) * 2;
//    height = Math.round(height / 3) * 2;
//  }

  //var game = new Game(width, height, CANVAS, '');


  Game game = new Game(800, 600, CANVAS, '');

  dom.SelectElement select = dom.document.getElementById("examples") as dom.SelectElement;
  for (String key in examples.keys) {
    game.state.add(key, examples[key]);
    dom.OptionElement option = new dom.OptionElement();
    option.text = key;
    select.children.add(option);
  }
//
  select.onChange.listen((dom.Event e) {
    game.state.start(select.children[select.selectedIndex].text);
  });

  game.state.start("games_02_gemmatch");

  //game.canvas.style.cursor = "pointer";
  //game.boot();
  //print("start");

}
