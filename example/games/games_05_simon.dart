part of example;

class games_05_simon extends State {
  preload() {

    game.load.spritesheet('item', 'assets/buttons/number-buttons.png', 160, 160);
  }

  Group simon;
  int N = 1;
  int userCount = 0;
  int currentCount = 0;
  int sequenceCount = 16;
  List sequenceList = [];
  bool simonSez = false;
  num timeCheck=0;
  int litSquare;
  bool winner = false;
  bool loser = false;
  bool intro;

  create() {

    simon = game.add.group();
    Sprite item;

    for (var i = 0; i < 3; i++) {
      item = simon.create(150 + 168 * i, 150, 'item', i);
      // Enable input.
      item.inputEnabled = true;
      item.input.start(0, true);
      item.events.onInputDown.add(select);
      item.events.onInputUp.add(release);
      item.events.onInputOut.add(moveOff);
      simon.getAt(i).alpha = 0;
    }

    for (var i = 0; i < 3; i++) {
      item = simon.create(150 + 168 * i, 318, 'item', i + 3);
      // Enable input.
      item.inputEnabled = true;
      item.input.start(0, true);
      item.events.onInputDown.add(select);
      item.events.onInputUp.add(release);
      item.events.onInputOut.add(moveOff);
      simon.getAt(i + 3).alpha = 0;
    }

    introTween();
    setUp();

    game.time.events.add(5000, () {
      simonSequence();
      intro = false;
    });
    //setTimeout((){}, 5000);

  }

  restart() {

    N = 1;
    userCount = 0;
    currentCount = 0;
    sequenceList = [];
    winner = false;
    loser = false;
    introTween();
    setUp();

    game.time.events.add(5000, () {
      simonSequence();
      intro = false;
    });
    //setTimeout((){simonSequence(); intro=false;}, 5000);

  }

  introTween() {

    intro = true;

    for (var i = 0; i < 6; i++) {
      game.add.tween(simon.getAt(i)).to({
        'alpha': 1
      }, 500, Easing.Linear.None, true, 0, 4, true).to({
        'alpha': .25
      }, 500, Easing.Linear.None);
    }

  }

  update() {

    if (simonSez) {
      if (game.time.now - timeCheck > 700 - N * 40) {
        simon.getAt(litSquare).alpha = .25;
        //game.paused = true;
        timeCheck = game.time.now;

        game.time.events.add(400 - N * 20, () {
          if (currentCount < N) {
            //game.paused = false;
            simonSequence();
          } else {
            simonSez = false;
            //game.paused = false;
          }
        });
        //        setTimeout(()
        //        , );
      }
    }
  }

  playerSequence(selected) {

    var correctSquare = sequenceList[userCount];
    userCount++;
    var thisSquare = simon.getIndex(selected);

    if (thisSquare == correctSquare) {
      if (userCount == N) {
        if (N == sequenceCount) {
          winner = true;
          game.time.events.add(3000, () {
            restart();
          });
        } else {
          userCount = 0;
          currentCount = 0;
          N++;
          simonSez = true;
        }
      }
    } else {
      loser = true;
      game.time.events.add(3000, () {
        restart();
      });
    }

  }

  simonSequence() {

    simonSez = true;
    litSquare = sequenceList[currentCount];
    simon.getAt(litSquare).alpha = 1;
    timeCheck = game.time.now;
    currentCount++;

  }

  setUp() {

    for (var i = 0; i < sequenceCount; i++) {
      var thisSquare = game.rnd.integerInRange(0, 5);
      sequenceList.add(thisSquare);
    }

  }

  select(Sprite item, Pointer pointer) {

    if (!simonSez && !intro && !loser && !winner) {
      item.alpha = 1;
    }

  }

  release(Sprite item, Pointer pointer, bool over) {

    if (!simonSez && !intro && !loser && !winner) {
      item.alpha = .25;
      playerSequence(item);
    }
  }

  moveOff(Sprite item, Pointer pointer) {

    if (!simonSez && !intro && !loser && !winner) {
      item.alpha = .25;
    }

  }

  render() {

    if (!intro) {
      if (simonSez) {
        game.debug.text('Simon Sez', 360, 96, 'rgb(255,0,0)');
      } else {
        game.debug.text('Your Turn', 360, 96, 'rgb(0,255,0)');
      }
    } else {
      game.debug.text('Get Ready', 360, 96, 'rgb(0,0,255)');
    }

    if (winner) {
      game.debug.text('You Win!', 360, 32, 'rgb(0,0,255)');
    } else if (loser) {
      game.debug.text('You Lose!', 360, 32, 'rgb(0,0,255)');
    }

  }
}
