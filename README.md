play_phaser
=========
A Dart port of Phaser (2.0.7)

Very easy to learn and fun 2D game engine for dart.

Built on top of my Canvas/WebGL drawing library [play_pixi][1].

Please check the [online demo][3] (includes all game examples)

Feel free to let me know if there is any problem.

pub: [https://pub.dartlang.org/packages/play_phaser]



Features:
=========
* animation (100%)
* core (100%): camera, singal, game, group, plugin, stage, state, world, etc.
* gameobject (100%)
* physics: arcade physics (missing p2.js)
* geom (100%): finished
* input : keyboard, mouse, touch (missing gamepad)
* loader (100%)
* math (100%)
* particles (100%)
* sound & music (100%)
* system (100%)
* time (100%)
* tilemap (100%)
* tween (100%) (use Mirrors API) (thanks to https://github.com/xaguzman/tween-engine-dart)
* utils (100%)



Examples:
=========



please check the [online demo][3] or download examples from [github repo][2]


```dart

class basic_01_load_an_image extends State {

  Text text;
  Sprite image;

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

  }

}

main() {
  Game game = new Game(800, 480, WEBGL, '', new basic_01_load_an_image());
}

```

The number of examples for each class.

* animation * 4
* arcade physics
* audio * 2
* basics * 5
* camera * 3
* display * 5
* games * 7
* imput
* loader
* particles
* tilemaps * 2
* tweens

TODO
=========
* Build more examples to comprehensively test the play_phaser game engine.
* Build in-game UI so that all examples can be tested in one CocoonJS app.
* Refactor the code, to improve the scalibility and performance.
* Complete the Document in Dart style.


[1]: https://github.com/playif/play_pixi
[2]: https://github.com/playif/play_phraser
[3]: http://playif.github.io/phaser_example/index.html
