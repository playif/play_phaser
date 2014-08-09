part of example;


class basic_01_load_an_image extends State {

  Text text;
  Sprite image;

  preload() {
    //Phaser.Easing.Linear.None;
    //  You can fill the preloader with as many assets as your game requires

    //  Here we are loading an image. The first parameter is the unique
    //  string by which we'll identify the image later in our code.

    //  The second parameter is the URL of the image (relative)
    game.load.image('car', 'assets/sprites/car.png');

  }

  create() {
    //  This creates a simple sprite that is using our loaded image and
    //  displays it on-screen
    for (int i = 0; i < 10; i++) {
      var image = game.add.sprite(game.world.centerX, game.world.centerY, 'car');

      //  Moves the image anchor to the middle, so it centers inside the game properly
      image.anchor.set(0.5);

      image.scale.set(2);
      image.position.set(game.rnd.integerInRange(0, 800), game.rnd.integerInRange(0, 600));

      //  Enables all kind of input actions on this image (click, etc)
      image.inputEnabled = true;

      // When moving on the image, kill it.
      image.events.onInputOver.add((Sprite s, Pointer p) {
        image.kill();
      });
    }

    // Add a text
    text = game.add.text(250, 16, 'Hello World!!', new TextStyle(fill:'#ffffff'));

  }


}
