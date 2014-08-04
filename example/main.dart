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


Map<String, State> examples = {
  "basic_01_load_an_image": new basic_01_load_an_image(),
  "basic_02_click_on_an_image": new basic_02_click_on_an_image(),
  "basic_03_image_follow_input":new basic_03_image_follow_input(),
  "basic_04_load_animation":new basic_04_load_animation(),
  
  
  "animation_01_events":new animation_01_events(),

    "audio_01_audio_sprite":new audio_01_audio_sprite(),
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

  game.state.start("basic_01_load_an_image");

  //game.canvas.style.cursor = "pointer";
  //game.boot();
  //print("start");

}
