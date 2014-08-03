part of example;


class basic_01_load_an_image extends Phaser.State {
  Phaser.Game game;
  Phaser.Text text;
  Phaser.Sprite image;
  int counter = 0;

  double t = 0.5;

  basic_01_load_an_image() {
    game = new Phaser.Game(800, 600, Phaser.WEBGL, 'phaser-example', this);
  }

  preload() {

    //Phaser.Easing.Linear.None;
    //  You can fill the preloader with as many assets as your game requires

    //  Here we are loading an image. The first parameter is the unique
    //  string by which we'll identify the image later in our code.

    //  The second parameter is the URL of the image (relative)
    game.load.image('einstein', 'assets/pics/ra_einstein.png');

  }

  create() {

    //  This creates a simple sprite that is using our loaded image and
    //  displays it on-screen
    for (int i = 0 ;i < 200;i++) {
      image = game.add.sprite(game.world.centerX, game.world.centerY, 'einstein');

      //  Moves the image anchor to the middle, so it centers inside the game properly
      image.anchor.set(0.5);
      image.scale.set(0.5);
      image.position.set(0 + i + 0.5);
    }
//
    //image.position=new Phaser.Point(200,200);

    //  Enables all kind of input actions on this image (click, etc)
    image.inputEnabled = true;

    text = game.add.text(250, 16, 'Hi', new PIXI.TextStyle()
      ..fill = '#ffffff'
    );

    image.events.onInputDown.add(listener);

  }

  update() {
    game.world.forEach((Phaser.GameObject o) {
      o.x += 1;
    });
    //image.anchor.set(t);
    //image.x += 1;
    //image.rotation += 0.1;
    //text.x += 1;

    //t+=0.01;
  }

  listener() {

    counter++;
    text.text = "You clicked " + counter.toString() + " times!";

  }
}
