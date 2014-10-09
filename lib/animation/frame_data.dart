part of Phaser;

class FrameData {
  List<Frame> _frames = [];
  Map<String, int> _frameNames = {};

  int get total => _frames.length;

  FrameData() {
  }


  Frame addFrame(frame) {
    frame.index = this._frames.length;
    this._frames.add(frame);
    if (frame.name != '') {
      this._frameNames[frame.name] = frame.index;
    }
    return frame;
  }

  Frame getFrame(int index) {
    if (index > this._frames.length) {
      index = 0;
    }
    return this._frames[index];
  }

  Frame getFrameByName(String name) {
    if (_frameNames[name] is num) {
      return this._frames[this._frameNames[name]];
    }
    return null;
  }

  bool checkFrameName(name) {
    if (this._frameNames[name] == null) {
      return false;
    }
    return true;
  }

  /**
   * Makes a copy of this FrameData including copies (not references) to all of the Frames it contains.
   *
   * @method clone
   * @return {Phaser.FrameData} A clone of this object, including clones of the Frame objects it contains.
   */
  FrameData clone() {

    FrameData output = new FrameData();

    //  No input array, so we loop through all frames
    for (int i = 0; i < this._frames.length; i++) {
      output._frames.add(this._frames[i].clone());
    }

    this._frameNames.forEach((k, v) {
      output._frameNames[k] = v;
    });

//    for (var i = 0; i < this._frameNames.length; i++) {
//      output._frameNames.add(this._frameNames[i]);
//    }

    return output;

  }



  List<Frame> getFrameRange(int start, int end, [List<Frame> output]) {
    if (output == null) {
      output = [];
    }
    for (int i = start; i <= end; i++) {
      output.add(this._frames[i]);
    }
    return output;
  }

  List<Frame> getFrames([List frames, bool useNumericIndex, List<Frame> output]) {
    if (useNumericIndex == null) {
      useNumericIndex = true;
    }
    if (output == null) {
      output = [];
    }
    if (frames == null || frames.length == 0) {
      //  No input array, so we loop through all frames
      for (var i = 0; i < this._frames.length; i++) {
        //  We only need the indexes
        output.add(this._frames[i]);
      }
    } else {
      //  Input array given, loop through that instead
      for (int i = 0,
          len = frames.length; i < len; i++) {
        //  Does the input array contain names or indexes?
        if (useNumericIndex) {
          //  The actual frame
          output.add(this.getFrame(frames[i]));
        } else {
          //  The actual frame
          output.add(this.getFrameByName(frames[i]));
        }
      }
    }
    return output;
  }

  List<int> getFrameIndexes([List frames, bool useNumericIndex, List<int> output]) {

    if (useNumericIndex == null) {
      useNumericIndex = true;
    }
    if (output == null) {
      output = [];
    }

    if (frames == null || frames.length == 0) {
      //  No frames array, so we loop through all frames
      for (int i = 0,
          len = this._frames.length; i < len; i++) {
        output.add(this._frames[i].index);
      }
    } else {
      //  Input array given, loop through that instead
      for (int i = 0,
          len = frames.length; i < len; i++) {
        //  Does the frames array contain names or indexes?
        if (useNumericIndex) {
          output.add(frames[i]);
        } else {
          if (this.getFrameByName(frames[i]) != null) {
            output.add(this.getFrameByName(frames[i]).index);
          }
        }
      }
    }

    return output;

  }


}
