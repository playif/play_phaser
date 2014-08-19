part of example;

class Gem extends Sprite {
  int posX, posY, id;

  Gem(Game game) : super(game) {

  }
}

class games_02_gemmatch extends State {
  static const int GEM_COLORS = 3;
  static const int GEM_SIZE = 64;
  static const int GEM_SPACING = 2;
  static const int GEM_SIZE_SPACED = GEM_SIZE + GEM_SPACING;
  static int BOARD_COLS;
  static int BOARD_ROWS;
  static const int MATCH_MIN = 3;

  // min number of same color gems required in a row to be considered a match

  Group<Gem> gems;
  Gem selectedGem;
  Point selectedGemStartPos = new Point();
  Tween selectedGemTween;
  Gem tempShiftedGem;
  Tween tempShiftedGemTween;
  bool allowInput;

  Group<Sprite> explosions;

  Group<Text> scores;
  num score = 0;
  String scoreString = '';
  Text scoreText;
  Tween scoreTween;
  int combo = 1;
  int movingGemCount = 0;
  int filledGemCount = 0;

  Graphics marker;

  preload() {
    //print("preload");
    game.load.spritesheet("GEMS", "assets/sprites/diamonds32x5.png", GEM_SIZE, GEM_SIZE);
    game.load.spritesheet('kaboom', 'assets/games/invaders/explode.png', 128, 128);
  }

  create() {
    //print("create");
//    tween.Tween.registerAccessor(Gem, new GameObjectAccessor());
//    tween.Tween.registerAccessor(Text, new GameObjectAccessor());
//    tween.Tween.registerAccessor(Point, new GameObjectAccessor());
//    tween.Tween.registerAccessor(PIXI.Point, new GameObjectAccessor());
//    tween.Tween.registerAccessor(GameObject, new GameObjectAccessor());

    BOARD_COLS = Math.floor(game.world.width / GEM_SIZE_SPACED);
    BOARD_ROWS = Math.floor(game.world.height / GEM_SIZE_SPACED);
    // fill the screen with as many gems as possible
    spawnBoard();

    // currently selected gem starting position. used to stop player form moving gems too far.
    selectedGemStartPos = new Point();

    // used to disable input while gems are dropping down and respawning
    allowInput = true;

    //  An explosion pool
    explosions = game.add.group();
    explosions.createMultiple(BOARD_COLS * BOARD_ROWS * 4, 'kaboom');
    explosions.forEach(setupInvader);

    TextStyle textStyle = new TextStyle(font: '14px Arial', fill: '#fff', strokeThickness: 5, stroke: '#f00');
    scores = game.add.group();
    scores.creator = () => new Text(game, 10, 10, 'Hi', textStyle);
    scores.createMultiple(BOARD_COLS * BOARD_ROWS * 4);


    textStyle = new TextStyle(font: '34px Arial', fill: '#fff', strokeThickness: 5, stroke: '#f00');
    //  The score
    scoreString = 'Score : ';
    scoreText = game.add.text(10, 10, scoreString + score.toString(), textStyle);

    marker = game.add.graphics();
    marker.lineStyle(3, 0xff0000);
    marker.drawCircle(0, 0, 30);
    marker.visible = false;


    checkAllGems();

    //    world.bringToTop(explosions);
    //    world.bringToTop(scores);
    //    world.bringToTop(scoreText);
  }

  setupInvader(Sprite invader) {
    invader.scale.x = 0.5;
    invader.scale.y = 0.5;
    invader.animations.add('kaboom');
  }

  update() {
    //print("update");
    // when the mouse is released with a gem selected
    // 1) check for matches
    // 2) remove matched gems
    // 3) drop down gems above removed gems
    // 4) refill the board

    if (game.input.mousePointer.justReleased()) {

      if (selectedGem != null) {

        //        checkAndKillGemMatches(selectedGem, true);
        //
        //        if (tempShiftedGem != null) {
        //          checkAndKillGemMatches(tempShiftedGem, true);
        //        }
        checkAllGems();


        //removeKilledGems();

        //var dropGemDuration = dropGems();

        //if (dropGemDuration != 0) allowInput = false;

        selectedGem = null;
        tempShiftedGem = null;
      }

    }

    // check if a selected gem should be moved and do it
    marker.visible = false;
    if (selectedGem != null) {
      marker.visible = true;
      marker.position.setTo(selectedGem.x + GEM_SIZE / 2, selectedGem.y + GEM_SIZE / 2);

      var cursorGemPosX = getGemPos(game.input.mousePointer.x);
      var cursorGemPosY = getGemPos(game.input.mousePointer.y);

      if (checkIfGemCanBeMovedHere(selectedGemStartPos.x, selectedGemStartPos.y, cursorGemPosX, cursorGemPosY)) {
        if (cursorGemPosX != selectedGem.posX || cursorGemPosY != selectedGem.posY) {

          // move currently selected gem
          if (selectedGemTween != null) {
            game.tweens.remove(selectedGemTween);
          }
          selectedGemTween = tweenGemPos(selectedGem, cursorGemPosX, cursorGemPosY);
          gems.bringToTop(selectedGem);

          // if we moved a gem to make way for the selected gem earlier, move it back into its starting position
          if (tempShiftedGem != null) {
            tweenGemPos(tempShiftedGem, selectedGem.posX, selectedGem.posY);
            swapGemPosition(selectedGem, tempShiftedGem);
          }

          // when the player moves the selected gem, we need to swap the position of the selected gem with the gem currently in that position
          tempShiftedGem = getGem(cursorGemPosX, cursorGemPosY);
          if (tempShiftedGem != null && tempShiftedGem == selectedGem) {
            tempShiftedGem = null;
          } else {
            tweenGemPos(tempShiftedGem, selectedGem.posX, selectedGem.posY);
            swapGemPosition(selectedGem, tempShiftedGem);
          }
        }
      }
    }


    refillBoard();
    dropGems();
  }

  // fill the screen with as many gems as possible

  spawnBoard() {

    gems = game.add.group();
    gems.creator = () => new Gem(game);

    for (int i = 0; i < BOARD_COLS; i++) {
      for (int j = 0; j < BOARD_ROWS; j++) {
        Gem gem = gems.create(i * GEM_SIZE_SPACED, j * GEM_SIZE_SPACED, "GEMS");
        gem.inputEnabled = true;
        gem.events.onInputDown.add(selectGem);
        randomizeGemColor(gem);
        setGemPos(gem, i, j);
        // each gem has a position on the board
      }
    }
  }

  // select a gem and remember its starting position

  selectGem(Gem gem, Pointer pointer) {
    if (allowInput) {
      selectedGem = gem;
      selectedGemStartPos.x = gem.posX;
      selectedGemStartPos.y = gem.posY;
    }
  }

  // find a gem on the board according to its position on the board

  Gem getGem(int posX, int posY) {
    return gems.getFirst((Gem g) => g.id == calcGemId(posX, posY));
  }

  // convert world coordinates to board position

  getGemPos(num coordinate) {
    return Math.floor(coordinate / GEM_SIZE_SPACED);
  }

  // set the position on the board for a gem

  setGemPos(Gem gem, int posX, int posY) {
    gem.posX = posX;
    gem.posY = posY;
    gem.id = calcGemId(posX, posY);
  }

  // the gem id is used by getGem() to find specific gems in the group
  // each position on the board has a unique id

  calcGemId(int posX, int posY) {
    return posX + posY * BOARD_COLS;
  }

  // since the gems are a spritesheet, their color is the same as the current frame number

  getGemColor(Gem gem) {
    if (gem != null) {
      return gem.frame;
    }
    return null;
  }

  // set the gem spritesheet to a random frame

  randomizeGemColor(Gem gem) {
    gem.frame = game.rnd.integerInRange(0, GEM_COLORS - 1);
  }

  // gems can only be moved 1 square up/down or left/right

  checkIfGemCanBeMovedHere(int fromPosX, int fromPosY, int toPosX, int toPosY) {
    if (toPosX < 0 || toPosX >= BOARD_COLS || toPosY < 0 || toPosY >= BOARD_ROWS) {
      return false;
    }
    if (fromPosX == toPosX && fromPosY >= toPosY - 1 && fromPosY <= toPosY + 1) {
      return true;
    }
    if (fromPosY == toPosY && fromPosX >= toPosX - 1 && fromPosX <= toPosX + 1) {
      return true;
    }
    return false;
  }

  // count how many gems of the same color lie in a given direction
  // eg if moveX=1 and moveY=0, it will count how many gems of the same color lie to the right of the gem
  // stops counting as soon as a gem of a different color or the board end is encountered

  countSameColorGems(Gem startGem, int moveX, int moveY) {
    var curX = startGem.posX + moveX;
    var curY = startGem.posY + moveY;
    var count = 0;
    while (curX >= 0 && curY >= 0 && curX < BOARD_COLS && curY < BOARD_ROWS && getGemColor(getGem(curX, curY)) == getGemColor(startGem)) {
      count++;
      curX += moveX;
      curY += moveY;
    }
    return count;
  }

  // swap the position of 2 gems when the player drags the selected gem into a new location

  swapGemPosition(Gem gem1, Gem gem2) {
    var tempPosX = gem1.posX;
    var tempPosY = gem1.posY;
    setGemPos(gem1, gem2.posX, gem2.posY);
    setGemPos(gem2, tempPosX, tempPosY);
  }

  // count how many gems of the same color are above, below, to the left and right
  // if there are more than 3 matched horizontally or vertically, kill those gems
  // if no match was made, move the gems back into their starting positions

  int checkAndKillGemMatches(Gem gem, [bool isSwapGem = false]) {
    int count = 0;
    if (gem != null) {

      var countUp = countSameColorGems(gem, 0, -1);
      var countDown = countSameColorGems(gem, 0, 1);
      var countLeft = countSameColorGems(gem, -1, 0);
      var countRight = countSameColorGems(gem, 1, 0);

      var countHoriz = countLeft + countRight + 1;
      var countVert = countUp + countDown + 1;

      int total = countVert + countHoriz;

      if (countVert >= MATCH_MIN) {
        count += killGemRange(gem.posX, gem.posY - countUp, gem.posX, gem.posY + countDown, total) * total;
      }

      if (countHoriz >= MATCH_MIN) {
        count += killGemRange(gem.posX - countLeft, gem.posY, gem.posX + countRight, gem.posY, total) * total;
      }

      if (countVert < MATCH_MIN && countHoriz < MATCH_MIN && isSwapGem) {
        replaceGem(gem);
      }
    }

    return count;
  }

  replaceGem(Gem gem) {
    if (gem.posX != selectedGemStartPos.x || gem.posY != selectedGemStartPos.y) {
      if (selectedGemTween != null) {
        game.tweens.remove(selectedGemTween);
      }
      selectedGemTween = tweenGemPos(gem, selectedGemStartPos.x, selectedGemStartPos.y);

      if (tempShiftedGem != null) {
        tweenGemPos(tempShiftedGem, gem.posX, gem.posY);
      }
      swapGemPosition(gem, tempShiftedGem);
      tempShiftedGem = null;
    }
  }

  int checkAllGems() {
    int count = 0;
    for (int i = 0; i < BOARD_COLS; i++) {
      for (int j = 0; j < BOARD_ROWS; j++) {
        Gem gem = getGem(i, j);
        count += checkAndKillGemMatches(gem);
        
      }
    }

    if (count > 0) {

      score += combo * count;
      scoreText.text = scoreString + score.toString();


      scoreText.scale.set(1);
      if (scoreTween != null) {
        game.tweens.remove(scoreTween);
      }

      scoreTween = game.add.tween(scoreText.scale).to({
        'x': 2,
        'y': 2
      }, 200, Easing.Bounce.InOut, true, 1, 1, true);



      removeKilledGems();
      dropGems();

      //if (dropRowCountMax == 0) {
      //  combo = 1;
      //  allowInput = true;
      //}

      // delay board refilling until all existing gems have dropped down

      //refillBoard();
    }


    return count;
  }

  // kill all gems from a starting position to an end position

  int killGemRange(int fromX, int fromY, int toX, int toY, int total) {
    int count = 0;
    fromX = Math.clamp(fromX, 0, BOARD_COLS - 1);
    fromY = Math.clamp(fromY, 0, BOARD_ROWS - 1);
    toX = Math.clamp(toX, 0, BOARD_COLS - 1);
    toY = Math.clamp(toY, 0, BOARD_ROWS - 1);
    for (int i = fromX; i <= toX; i++) {
      for (int j = fromY; j <= toY; j++) {
        var gem = getGem(i, j);
        if (gem.exists) {
          makeAnimation(i * GEM_SIZE_SPACED, j * GEM_SIZE_SPACED, total);
        }
        gem.kill();


        count++;
      }
    }
    return count;
  }
  int cc = 0;
  makeAnimation(int x, int y, int total) {
    Sprite explosion = explosions.getFirstExists(false);
    if (explosion != null) {
      explosion.reset(x, y);
      explosion.play('kaboom', 30, false, true);
    }


    Text text = scores.getFirstExists(false);
    if (text != null) {
      text.exists = true;
      text.visible = true;
      text.text = "+${total * combo}";
      text.position.set(x, y);
      Tween tween = game.add.tween(text).to({
        'y': y - 20
      }, 200, Easing.Quintic.Out);
      tween.onComplete.add((Text t) {
        text.exists = false;
        text.visible = false;
        cc++;
        //print(cc);
      });
      tween.start();
    }


  }

  // move gems that have been killed off the board

  removeKilledGems() {
    gems.forEach((gem) {
      if (!gem.alive) {
        setGemPos(gem, -1, -1);
      }
    });
  }

  // animated gem movement

  tweenGemPos(Gem gem, num newPosX, num newPosY, [num durationMultiplier = 1]) {
    if (durationMultiplier == null) {
      durationMultiplier = 1;
    }

    return game.add.tween(gem).to({
      'x': newPosX * GEM_SIZE_SPACED,
      'y': newPosY * GEM_SIZE_SPACED
    }, 200 * durationMultiplier, Easing.Bounce.InOut, true);
  }

  // look for gems with empty space beneath them and move them down

  dropGems() {
    var dropRowCountMax = 0;
    for (var i = 0; i < BOARD_COLS; i++) {
      var dropRowCount = 0;
      for (var j = BOARD_ROWS - 1; j >= 0; j--) {
        Gem gem = getGem(i, j);
        if (gem == null) {
          dropRowCount++;
        } else if (dropRowCount > 0) {

          setGemPos(gem, gem.posX, gem.posY + dropRowCount);
          //movingGemCount=0;
          movingGemCount++;
          //print(movingGemCount);
          Tween tween = tweenGemPos(gem, gem.posX, gem.posY, dropRowCount);
          tween.onComplete.add((tween) {
            movingGemCount--;
            //print(movingGemCount);
            if (movingGemCount == 0) {
              movingGemCount = 0;
              
              refillBoard();
            }
          });
        }
      }
      dropRowCountMax = Math.max(dropRowCount, dropRowCountMax);
    }

    //print("max $dropRowCountMax");
    return dropRowCountMax;
  }

  // look for any empty spots on the board and spawn new gems in their place that fall down from above

  refillBoard() {
    var maxGemsMissingFromCol = 0;
    for (var i = 0; i < BOARD_COLS; i++) {
      var gemsMissingFromCol = 0;
      for (var j = BOARD_ROWS - 1; j >= 0; j--) {
        Gem gem = getGem(i, j);
        if (gem == null) {
          gemsMissingFromCol++;
          gem = gems.getFirstDead();
          gem.reset(i * GEM_SIZE_SPACED, -gemsMissingFromCol * GEM_SIZE_SPACED);
          randomizeGemColor(gem);
          setGemPos(gem, i, j);
          filledGemCount++;
          Tween tween = tweenGemPos(gem, gem.posX, gem.posY, gemsMissingFromCol * 2);
          tween.onComplete.add((tween) {
            filledGemCount--;
            //print(filledGemCount);
            if (filledGemCount == 0) {
              filledGemCount = 0;
              boardRefilled();
            }
          });
        }
      }
      maxGemsMissingFromCol = Math.max(maxGemsMissingFromCol, gemsMissingFromCol);
    }

  }

  // when the board has finished refilling, re-enable player input

  boardRefilled() {
    combo += 1;

    int count = checkAllGems();
    //print(count);
    //checkAllGems();
    //    refillBoard();
    //dropGems();
  }
}
