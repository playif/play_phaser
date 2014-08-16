part of example;

class basics_05_render_text extends State {
  create() {

    var text = "- phaser -\n with a sprinkle of \n pixi dust.";
    TextStyle style = new TextStyle(font: "65px Arial", fill: "#ff0044", align: "center");

    var t = game.add.text(game.world.centerX - 300, 0, text, style);

  }
}
