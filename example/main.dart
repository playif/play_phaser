library example;

import "package:play_phaser/phaser.dart";
import "dart:html" as dom;
//import "package:play_pixi/pixi.dart" as PIXI;

part "basics/basic_01_load_an_image.dart";
part "basics/basic_02_click_on_an_image.dart";
part "basics/basic_03_image_follow_input.dart";
part "basics/basic_04_load_animation.dart";


part "animation/animation_01_events.dart";
 

part "audio/audio_01_audio_sprite.dart";
part "audio/audio_02_play_music.dart";

part "tweens/tweens_01_chained_tweens.dart";

part "loader/loader_01_asset_pack.dart";

part "input/input_01_bring_a_child_to_top.dart";

part "particles/particles_01_auto_scale.dart";

part "arcade_physics/arcade_physics_34_quadtree.dart";

part "camera/camera_01_basic_follow.dart";

Map<String, State> examples = {
    "basic_01_load_an_image": new basic_01_load_an_image(),
    "basic_02_click_on_an_image": new basic_02_click_on_an_image(),
    "basic_03_image_follow_input": new basic_03_image_follow_input(),
    "basic_04_load_animation": new basic_04_load_animation(),


    "animation_01_events": new animation_01_events(),


    "audio_01_audio_sprite": new audio_01_audio_sprite(),
    "audio_02_play_music": new audio_02_play_music(),


    "tweens_01_chained_tweens": new tweens_01_chained_tweens(),


    "loader_01_asset_pack": new loader_01_asset_pack(),


    "input_01_bring_a_child_to_top": new input_01_bring_a_child_to_top(),


    "particles_01_auto_scale": new particles_01_auto_scale(),

    "arcade_physics_34_quadtree": new arcade_physics_34_quadtree(),

    "camera_01_basic_follow": new camera_01_basic_follow(),
};

main() {
//
//  var w = dom.window.innerWidth * dom.window.devicePixelRatio,
//  h = dom.window.innerHeight * dom.window.devicePixelRatio,
//  width = (h > w) ? h : w,
//  height = (h > w) ? w : h;
//
  //// Hack to avoid iPad Retina and large Android devices. Tell it to scale up.
//  if (dom.window.innerWidth >= 1024 && dom.window.devicePixelRatio >= 2)
//  {
//    width = Math.round(width / 2);
//    height = Math.round(height / 2);
//  }
  //// reduce screen size by one 3rd on devices like Nexus 5
//  if (dom.window.devicePixelRatio == 3)
//  {
//    width = Math.round(width / 3) * 2;
//    height = Math.round(height / 3) * 2;
//  }

  //var game = new Game(width, height, CANVAS, '');


  Game game = new Game(800, 600, WEBGL, '');

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

  game.state.start("particles_01_auto_scale");

  //game.canvas.style.cursor = "pointer";
  //game.boot();
  //print("start");

}
