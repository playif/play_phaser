part of example;


class basic_02_click_on_an_image extends Phaser.State {
  //Phaser.Game game;
  Phaser.Text text;
  Phaser.Sprite image;
  int counter = 0;

  double t = 0.5;


  preload() {
    //  You can fill the preloader with as many assets as your game requires

    //  Here we are loading an image. The first parameter is the unique
    //  string by which we'll identify the image later in our code.

    //  The second parameter is the URL of the image (relative)
    game.load.image('einstein', 'assets/sprites/car.png');

  }

  create() {

    //  This creates a simple sprite that is using our loaded image and
    //  displays it on-screen
    for (int i = 0; i < 1; i++) {
      image = game.add.sprite(game.world.centerX, game.world.centerY, 'einstein');

      //  Moves the image anchor to the middle, so it centers inside the game properly
      image.anchor.set(0.5);
      image.scale.set(5);
      image.position.set(game.rnd.integerInRange(0, 800), game.rnd.integerInRange(0, 600));
      //  Enables all kind of input actions on this image (click, etc)
      image.inputEnabled = true;
      
      image.events.onInputDown.add(listener);
    }
//
    //image.position=new Phaser.Point(200,200);



    text = game.add.text(250, 16, 'Hi', new Phaser.TextStyle()..fill = '#ffffff');

    //image.events.onInputDown.add(listener);

  }

  update() {

    //image.anchor.set(t);
    //image.x += 1;
    //image.rotation += 0.1;
    //text.x += 1;

    //t+=0.01;
  }

  listener(Phaser.Sprite s, Phaser.Pointer p) {
    //print("here");
    counter++;
    text.setText("You clicked " + counter.toString() + " times!");
  }
}
