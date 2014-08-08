play_phaser
=========
A Dart port of Phaser.js (2.0.7)

Very easy to learn and fun game engine.

Built on top of my Canvas / WebGL drawing library [play_pixi][1].

0.8.5 several examples were added.



Feel free to let me know if there is any problem.


What are done:
=========
* animation (100%)
* core (100%): camera, singal, game, group, plugin, stage, state, world, etc.
* gameobject (100%)
* Physics: arcade physics (missing p2.js)
* geom (100%): finished
* input : keyboard, mouse, touch (missing gamepad)
* loader (100%)
* math (100%)
* particles (100%)
* sound & music (100%)
* system (100%)
* time (100%)
* tilemap (100%)
* tween (90%) (missing pre-defined fields) (thanks to https://github.com/xaguzman/tween-engine-dart)
* utils (100%)



Examples:
=========
```dart

class basic_01_load_an_image extends State {

  Text text;
  Sprite image;

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
    for (int i = 0; i < 10; i++) {
      var image = game.add.sprite(game.world.centerX, game.world.centerY, 'einstein');

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

    text = game.add.text(250, 16, 'Hi', new TextStyle()..fill = '#ffffff');

  }

  update() {

    game.world.forEach((GameObject o) {
      o.x += game.rnd.frac();
      if (o.x > 800) {
        o.x = 0;
      }
      o.alpha = 0.5;
      o.rotation += game.rnd.frac() * 0.1;
    });
  }

}

```

please download examples from [github repo][2]

* animation
* arcade physics
* audio * 2
* basics * 4
* camera * 3
* display * 2
* games * 4
* imput
* loader
* particles
* tilemaps * 2
* tweens


Install:
=========

dependencies:
  play_phaser: any


[1]: https://github.com/playif/play_pixi
[2]: https://github.com/playif/play_phraser
