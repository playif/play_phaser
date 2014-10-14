part of example;


class basic_02_click_on_an_image extends State {
  Text text;
  Sprite image;
  int counter = 0;

  preload() {
    //  You can fill the preloader with as many assets as your game requires

    //  Here we are loading an image. The first parameter is the unique
    //  string by which we'll identify the image later in our code.

    //  The second parameter is the URL of the image (relative)
    game.load.image('car', 'assets/sprites/car.png');

  }

  create() {

    //  This creates a simple sprite that is using our loaded image and
    //  displays it on-screen
    image = game.add.sprite(game.world.centerX, game.world.centerY, 'car');

    //  Moves the image anchor to the middle, so it centers inside the game properly
    image.anchor.set(0.5);
    image.scale.set(5);
    //image.position.set(game.rnd.integerInRange(0, 800), game.rnd.integerInRange(0, 600));
    //  Enables all kind of input actions on this image (click, etc)
    image.inputEnabled = true;

    image.events.onInputDown.add(listener);


    text = game.add.text(250, 22, 'Please click the image below:', new TextStyle(fill: '#ffffff'));

  }

  update() {
    image.rotation += 0.01;
  }

  listener(Sprite s, Pointer p) {
    counter++;
    text.setText("You clicked " + counter.toString() + " times!");
    //text.text="You clicked " + counter.toString() + " times!";
  }
}
