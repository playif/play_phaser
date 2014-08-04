library example;

import "package:play_phaser/phaser.dart" as Phaser;
import "dart:html";
//import "package:play_pixi/pixi.dart" as PIXI;

part "basics/basic_01_load_an_image.dart";
part "basics/basic_02_click_on_an_image.dart";

Map<String, Phaser.State> examples = {
  "basic_01_load_an_image": new basic_01_load_an_image(),
  "basic_02_click_on_an_image": new basic_02_click_on_an_image(),
};

main() {
  Phaser.Game game = new Phaser.Game(800, 600, Phaser.WEBGL, 'phaser-example');
  var select = querySelector("#examples") as SelectElement;
  for (var key in examples.keys) {
    game.state.add(key, examples[key]);
    var option = new OptionElement();
    option.text = key;
    select.children.add(option);
  }
  
  select.onChange.listen((Event e) {
    
    //game.state.restart();
    game.state.start(select.children[select.selectedIndex].text);
  });

  game.state.start("basic_01_load_an_image");
  //new basic_01_load_an_image();
}
