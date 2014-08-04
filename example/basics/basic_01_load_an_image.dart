part of example;


class basic_01_load_an_image extends Phaser.State {
  //Phaser.Game game;
  Phaser.Text text;
  Phaser.Sprite image;
  int counter = 0;

  double t = 0.5;


  preload() {

    //Phaser.Easing.Linear.None;
    //  You can fill the preloader with as many assets as your game requires

    //  Here we are loading an image. The first parameter is the unique
    //  string by which we'll identify the image later in our code.

    //  The second parameter is the URL of the image (relative)
    game.load.image('einstein', 'assets/sprites/car.png');

  }

  create() {

    //  This creates a simple sprite that is using our loaded image and
    //  displays it on-screen
    for (int i = 0; i < 3000; i++) {
      var image = game.add.sprite(game.world.centerX, game.world.centerY, 'einstein');

      //  Moves the image anchor to the middle, so it centers inside the game properly
      image.anchor.set(0.5);
      image.scale.set(2);
      image.position.set(game.rnd.integerInRange(0, 800), game.rnd.integerInRange(0, 600));
      //  Enables all kind of input actions on this image (click, etc)
      image.inputEnabled = true;

      image.events.onInputOver.add((Phaser.Sprite s, Phaser.Pointer p) {
        image.kill();
      });
    }
//
    //image.position=new Phaser.Point(200,200);



    text = game.add.text(250, 16, 'Hi', new Phaser.TextStyle()..fill = '#ffffff');

    //image.events.onInputDown.add(listener);

  }

  update() {
    game.world.forEach((Phaser.GameObject o) {
      o.x += game.rnd.frac();
      if (o.x > 800) {
        o.x = 0;
      }
      //o.scale.set(game.rnd.frac() * 5);
      o.alpha = 0.5;
      o.rotation += game.rnd.frac() * 0.1;
    });
    //image.anchor.set(t);
    //image.x += 1;
    //image.rotation += 0.1;
    //text.x += 1;

    //t+=0.01;
  }

  listener(Phaser.Sprite s, Phaser.Pointer p) {
    counter++;
    text.text = "You clicked " + counter.toString() + " times!";
  }
}
