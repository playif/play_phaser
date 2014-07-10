part of PIXI;

Map AnimCache = {
};

Map AttachmentType = {
    'region':0
};

class BoneData {
  String name;
  BoneData parent;
  num length = 0,
  x = 0, y = 0,
  rotation = 0,
  scaleX = 1, scaleY = 1;

  BoneData(this.name, this.parent);
}

class SlotData {
  String name;
  BoneData boneData;
  num r = 1, g = 1, b = 1, a = 1;
  String attachmentName = null;

  SlotData(this.name, this.boneData);
}

class Bone {
  Bone parent;
  BoneData data;

//  String name;

  Bone(this.data, this.parent) {

    this.setToSetupPose();
  }

  num x = 0, y = 0,
  rotation = 0,
  scaleX = 1, scaleY = 1,
  m00 = 0, m01 = 0, worldX = 0, // a b x
  m10 = 0, m11 = 0, worldY = 0, // c d y
  worldRotation = 0,
  worldScaleX = 1, worldScaleY = 1;

  //bool yDown = false;
  static bool yDown = true;

  updateWorldTransform(bool flipX, bool flipY) {
    Bone parent = this.parent;
    if (parent != null) {
      this.worldX = this.x * parent.m00 + this.y * parent.m01 + parent.worldX;
      this.worldY = this.x * parent.m10 + this.y * parent.m11 + parent.worldY;
      this.worldScaleX = parent.worldScaleX * this.scaleX;
      this.worldScaleY = parent.worldScaleY * this.scaleY;
      this.worldRotation = parent.worldRotation + this.rotation;
    } else {
      this.worldX = this.x;
      this.worldY = this.y;
      this.worldScaleX = this.scaleX;
      this.worldScaleY = this.scaleY;
      this.worldRotation = this.rotation;
    }
    num radians = this.worldRotation * PI / 180;
    num _cos = cos(radians);
    num _sin = sin(radians);
    this.m00 = _cos * this.worldScaleX;
    this.m10 = _sin * this.worldScaleX;
    this.m01 = -_sin * this.worldScaleY;
    this.m11 = _cos * this.worldScaleY;
    if (flipX) {
      this.m00 = -this.m00;
      this.m01 = -this.m01;
    }
    if (flipY) {
      this.m10 = -this.m10;
      this.m11 = -this.m11;
    }
    if (yDown) {
      this.m10 = -this.m10;
      this.m11 = -this.m11;
    }
  }

  setToSetupPose() {
    BoneData data = this.data;
    this.x = data.x;
    this.y = data.y;
    this.rotation = data.rotation;
    this.scaleX = data.scaleX;
    this.scaleY = data.scaleY;
  }
}
//
//class spine {
//  spine.SkeletonJson();
//}
class Slot {
  SlotData data;
  Skeleton skeleton;
  Bone bone;
  Map<String, Sprite> sprites;

  Sprite currentSprite;
  String currentSpriteName;

//  String name;

  num r = 1, g = 1, b = 1, a = 1,
  _attachmentTime = 0;
  Attachment attachment;

  Slot(this.data, this.skeleton, this.bone) {
    this.setToSetupPose();
  }

  setAttachment(attachment) {
    this.attachment = attachment;
    this._attachmentTime = this.skeleton.time;
  }

  setAttachmentTime(time) {
    this._attachmentTime = this.skeleton.time - time;
  }

  getAttachmentTime() {
    return this.skeleton.time - this._attachmentTime;
  }

  setToSetupPose() {

    this.r = data.r;
    this.g = data.g;
    this.b = data.b;
    this.a = data.a;

    List<SlotData> slotDatas = this.skeleton.data.slots;
    for (int i = 0, n = slotDatas.length; i < n; i++) {
      if (slotDatas[i] == data) {
        this.setAttachment(data.attachmentName == null ? null : this.skeleton.getAttachmentBySlotIndex(i, data.attachmentName));
        break;
      }
    }
  }
}

class Skin {
  String name;
  Map<String, Attachment> attachments = {
  };

  Skin(this.name) {

  }

  addAttachment(int slotIndex, String name, attachment) {
    this.attachments["$slotIndex:$name"] = attachment;
  }

  getAttachment(int slotIndex, String name) {
    return this.attachments["$slotIndex:$name"];
  }

  _attachAll(Skeleton skeleton, Skin oldSkin) {
    for (String key in oldSkin.attachments.keys) {
      int colon = key.indexOf(":");
      int slotIndex = int.parse(key.substring(0, colon));
      String name = key.substring(colon + 1);
      Slot slot = skeleton.slots[slotIndex];
      if (slot.attachment != null && slot.attachment.name == name) {
        Attachment attachment = this.getAttachment(slotIndex, name);
        if (attachment != null) slot.setAttachment(attachment);
      }
    }
  }

}

class Animation {
  String name;
  List<Timeline> timelines;
  num duration;

  Animation(this.name, this.timelines, this.duration) {

  }

  apply(Skeleton skeleton, num time, bool loop) {
    if (loop && this.duration != 0) time %= this.duration;
    List<Timeline> timelines = this.timelines;
    for (int i = 0, n = timelines.length; i < n; i++)
      timelines[i].apply(skeleton, time, 1);
  }

  mix(Skeleton skeleton, num time, bool loop, num alpha) {
    if (loop && this.duration != 0) time %= this.duration;
    List<Timeline> timelines = this.timelines;
    for (int i = 0, n = timelines.length; i < n; i++)
      timelines[i].apply(skeleton, time, alpha);
  }

}

int binarySearch(List<num> values, num target, int step) {
  int low = 0;
  int high = (values.length / step).floor() - 2;
  if (high == 0) return step;
  int current = high >> 1;
  while (true) {
    if (values[(current + 1) * step] <= target)
      low = current + 1;
    else
      high = current;
    if (low == high) return (low + 1) * step;
    current = (low + high) >> 1;
  }
}

int linearSearch(List<num> values, num target, int step) {
  for (int i = 0, last = values.length - step; i <= last; i += step)
    if (values[i] > target) return i;
  return -1;
}

class Curves {
  List<num> curves;

  Curves(int frameCount) {
    curves = new List<num>((frameCount - 1) * 6);
  }

  setLinear(int frameIndex) {
    this.curves[frameIndex * 6] = 0;
  }

  setStepped(int frameIndex) {
    this.curves[frameIndex * 6] = -1;
  }

  /** Sets the control handle positions for an interpolation bezier curve used to transition from this keyframe to the next.
   * cx1 and cx2 are from 0 to 1, representing the percent of time between the two keyframes. cy1 and cy2 are the percent of
   * the difference between the keyframe's values. */

  setCurve(int frameIndex, num cx1, num cy1, num cx2, num cy2) {
    num subdiv_step = 1 / 10;
    num subdiv_step2 = subdiv_step * subdiv_step;
    num subdiv_step3 = subdiv_step2 * subdiv_step;
    num pre1 = 3 * subdiv_step;
    num pre2 = 3 * subdiv_step2;
    num pre4 = 6 * subdiv_step2;
    num pre5 = 6 * subdiv_step3;
    num tmp1x = -cx1 * 2 + cx2;
    num tmp1y = -cy1 * 2 + cy2;
    num tmp2x = (cx1 - cx2) * 3 + 1;
    num tmp2y = (cy1 - cy2) * 3 + 1;
    int i = frameIndex * 6;
    List curves = this.curves;
    //window.console.log(curves);
    curves[i] = cx1 * pre1 + tmp1x * pre2 + tmp2x * subdiv_step3;
    curves[i + 1] = cy1 * pre1 + tmp1y * pre2 + tmp2y * subdiv_step3;
    curves[i + 2] = tmp1x * pre4 + tmp2x * pre5;
    curves[i + 3] = tmp1y * pre4 + tmp2y * pre5;
    curves[i + 4] = tmp2x * pre5;
    curves[i + 5] = tmp2y * pre5;
  }

  num getCurvePercent(int frameIndex, num percent) {
    percent = percent < 0 ? 0 : (percent > 1 ? 1 : percent);
    int curveIndex = frameIndex * 6;

    num dfx = curves[curveIndex];
    if (dfx == 0 || dfx == null) return percent;
    if (dfx == -1) return 0;
    num dfy = curves[curveIndex + 1];
    num ddfx = curves[curveIndex + 2];
    num ddfy = curves[curveIndex + 3];
    num dddfx = curves[curveIndex + 4];
    num dddfy = curves[curveIndex + 5];


    num x = dfx, y = dfy;

    num i = 10/*BEZIER_SEGMENTS*/ - 2;
    while (true) {
      if (x >= percent) {
        num lastX = x - dfx;
        num lastY = y - dfy;
        return lastY + (y - lastY) * (percent - lastX) / (x - lastX);
      }
      if (i == 0) break;
      i--;
      dfx += ddfx;
      dfy += ddfy;
      ddfx += dddfx;
      ddfy += dddfy;
      x += dfx;
      y += dfy;
    }
    return y + (1 - y) * (percent - x) / (1 - x);
    // Last point is 1,1.
  }

}

abstract class Timeline {
  Curves curves;
  List<int> frames;
  int boneIndex = 0;

  getFrameCount();

  setFrame(int frameIndex, time, r, [g, b, a]);

  apply(skeleton, time, alpha);
}

class RotateTimeline extends Timeline {


  RotateTimeline(int frameCount) {
    curves = new Curves(frameCount);
    frames = new List(frameCount * 2);
  }

  int getFrameCount() {
    return this.frames.length ~/ 2;
  }

  setFrame(int frameIndex, num time, num angle, [a, b, c]) {
    frameIndex *= 2;
    this.frames[frameIndex] = time;
    this.frames[frameIndex + 1] = angle;
  }

  apply(Skeleton skeleton, num time, num alpha) {
    num amount;

    if (time < frames[0]) return;
    // Time is before first frame.

    Bone bone = skeleton.bones[this.boneIndex];

    if (time >= frames[frames.length - 2]) {
      // Time is after last frame.
      amount = bone.data.rotation + frames[frames.length - 1] - bone.rotation;
      while (amount > 180)
        amount -= 360;
      while (amount < -180)
        amount += 360;
      bone.rotation += amount * alpha;
      return;
    }

    // Interpolate between the last frame and the current frame.
    int frameIndex = binarySearch(frames, time, 2);
    num lastFrameValue = frames[frameIndex - 1];
    num frameTime = frames[frameIndex];
    num percent = 1 - (time - frameTime) / (frames[frameIndex - 2/*LAST_FRAME_TIME*/
                                            ] - frameTime);
    percent = this.curves.getCurvePercent(frameIndex ~/ 2 - 1, percent);

    amount = frames[frameIndex + 1/*FRAME_VALUE*/
             ] - lastFrameValue;
    while (amount > 180)
      amount -= 360;
    while (amount < -180)
      amount += 360;
    amount = bone.data.rotation + (lastFrameValue + amount * percent) - bone.rotation;
    while (amount > 180)
      amount -= 360;
    while (amount < -180)
      amount += 360;
    bone.rotation += amount * alpha;
  }


}


class TranslateTimeline extends Timeline {
//  Curves curves;
//  List frames;
//  int boneIndex = 0;

  TranslateTimeline(int frameCount) {
    this.curves = new Curves(frameCount);
    this.frames = new List(frameCount * 3);
    // time, x, y, ...
  }


  getFrameCount() {
    return this.frames.length / 3;
  }


  setFrame(int frameIndex, time, x, [y, a, b]) {
    frameIndex *= 3;
    this.frames[frameIndex] = time;
    this.frames[frameIndex + 1] = x;
    this.frames[frameIndex + 2] = y;
  }

  apply(skeleton, time, alpha) {
    List frames = this.frames;
    if (time < frames[0]) return;
    // Time is before first frame.

    Bone bone = skeleton.bones[this.boneIndex];

    if (time >= frames[frames.length - 3]) {
      // Time is after last frame.
      bone.x += (bone.data.x + frames[frames.length - 2] - bone.x) * alpha;
      bone.y += (bone.data.y + frames[frames.length - 1] - bone.y) * alpha;
      return;
    }

    // Interpolate between the last frame and the current frame.
    int frameIndex = binarySearch(frames, time, 3);
    num lastFrameX = frames[frameIndex - 2];
    num lastFrameY = frames[frameIndex - 1];
    num frameTime = frames[frameIndex];
    num percent = 1 - (time - frameTime) / (frames[frameIndex + -3/*LAST_FRAME_TIME*/
                                            ] - frameTime);
    percent = this.curves.getCurvePercent(frameIndex ~/ 3 - 1, percent);

    bone.x += (bone.data.x + lastFrameX + (frames[frameIndex + 1/*FRAME_X*/
                                           ] - lastFrameX) * percent - bone.x) * alpha;
    bone.y += (bone.data.y + lastFrameY + (frames[frameIndex + 2/*FRAME_Y*/
                                           ] - lastFrameY) * percent - bone.y) * alpha;
  }


}

class ScaleTimeline extends Timeline {
//
//  Curves curves;
//  List frames;
//  int boneIndex = 0;

  ScaleTimeline(int frameCount) {
    curves = new Curves(frameCount);
    frames = new List(frameCount * 3);
  }

  getFrameCount() {
    return this.frames.length / 3;
  }

  setFrame(int frameIndex, time, x, [y, a, b]) {
    frameIndex *= 3;
    this.frames[frameIndex] = time;
    this.frames[frameIndex + 1] = x;
    this.frames[frameIndex + 2] = y;
  }

  apply(skeleton, time, alpha) {
    List frames = this.frames;
    if (time < frames[0]) return;
    // Time is before first frame.

    Bone bone = skeleton.bones[this.boneIndex];

    if (time >= frames[frames.length - 3]) {
      // Time is after last frame.
      bone.scaleX += (bone.data.scaleX - 1 + frames[frames.length - 2] - bone.scaleX) * alpha;
      bone.scaleY += (bone.data.scaleY - 1 + frames[frames.length - 1] - bone.scaleY) * alpha;
      return;
    }

    // Interpolate between the last frame and the current frame.
    int frameIndex = binarySearch(frames, time, 3);
    num lastFrameX = frames[frameIndex - 2];
    num lastFrameY = frames[frameIndex - 1];
    num frameTime = frames[frameIndex];
    num percent = 1 - (time - frameTime) / (frames[frameIndex + -3/*LAST_FRAME_TIME*/
                                            ] - frameTime);
    percent = this.curves.getCurvePercent(frameIndex ~/ 3 - 1, percent);

    bone.scaleX += (bone.data.scaleX - 1 + lastFrameX + (frames[frameIndex + 1/*FRAME_X*/
                                                         ] - lastFrameX) * percent - bone.scaleX) * alpha;
    bone.scaleY += (bone.data.scaleY - 1 + lastFrameY + (frames[frameIndex + 2/*FRAME_Y*/
                                                         ] - lastFrameY) * percent - bone.scaleY) * alpha;
  }


}


class ColorTimeline extends Timeline {
//  Curves curves;
//  List frames;
  int slotIndex = 0;

  ColorTimeline(frameCount) {
    curves = new Curves(frameCount);
    frames = new List(frameCount * 5);
  }

  getFrameCount() {
    return this.frames.length / 5;
  }

  setFrame(int frameIndex, time, r, [g, b, a]) {
    frameIndex *= 5;
    this.frames[frameIndex] = time;
    this.frames[frameIndex + 1] = r;
    this.frames[frameIndex + 2] = g;
    this.frames[frameIndex + 3] = b;
    this.frames[frameIndex + 4] = a;
  }

  apply(skeleton, time, alpha) {
    List frames = this.frames;
    if (time < frames[0]) return;
    // Time is before first frame.

    Slot slot = skeleton.slots[this.slotIndex];

    if (time >= frames[frames.length - 5]) {
      // Time is after last frame.
      int i = frames.length - 1;
      slot.r = frames[i - 3];
      slot.g = frames[i - 2];
      slot.b = frames[i - 1];
      slot.a = frames[i];
      return;
    }

    // Interpolate between the last frame and the current frame.
    num frameIndex = binarySearch(frames, time, 5);
    num lastFrameR = frames[frameIndex - 4];
    num lastFrameG = frames[frameIndex - 3];
    num lastFrameB = frames[frameIndex - 2];
    num lastFrameA = frames[frameIndex - 1];
    num frameTime = frames[frameIndex];
    num percent = 1 - (time - frameTime) / (frames[frameIndex - 5/*LAST_FRAME_TIME*/
                                            ] - frameTime);
    percent = this.curves.getCurvePercent(frameIndex ~/ 5 - 1, percent);

    num r = lastFrameR + (frames[frameIndex + 1/*FRAME_R*/
                          ] - lastFrameR) * percent;
    num g = lastFrameG + (frames[frameIndex + 2/*FRAME_G*/
                          ] - lastFrameG) * percent;
    num b = lastFrameB + (frames[frameIndex + 3/*FRAME_B*/
                          ] - lastFrameB) * percent;
    num a = lastFrameA + (frames[frameIndex + 4/*FRAME_A*/
                          ] - lastFrameA) * percent;
    if (alpha < 1) {
      slot.r += (r - slot.r) * alpha;
      slot.g += (g - slot.g) * alpha;
      slot.b += (b - slot.b) * alpha;
      slot.a += (a - slot.a) * alpha;
    } else {
      slot.r = r;
      slot.g = g;
      slot.b = b;
      slot.a = a;
    }
  }

}


class AttachmentTimeline extends Timeline {
//  Curves curves;
//  List frames;
  int slotIndex = 0;
  List attachmentNames;

  AttachmentTimeline(int frameCount) {
    curves = new Curves(frameCount);
    frames = new List(frameCount);
    attachmentNames = new List(frameCount);
  }

  getFrameCount() {
    return this.frames.length;
  }

  setFrame(int frameIndex, time, String attachmentName, [a, b, c]) {
    this.frames[frameIndex] = time;
    this.attachmentNames[frameIndex] = attachmentName;
  }

  apply(skeleton, time, alpha) {
    List frames = this.frames;
    if (time < frames[0]) return;
    // Time is before first frame.

    int frameIndex;
    if (time >= frames[frames.length - 1]) // Time is after last frame.
      frameIndex = frames.length - 1;
    else
      frameIndex = binarySearch(frames, time, 1) - 1;

    String attachmentName = this.attachmentNames[frameIndex];
    skeleton.slots[this.slotIndex].setAttachment(attachmentName == null ? null : skeleton.getAttachmentBySlotIndex(this.slotIndex, attachmentName));
  }


}

class SkeletonData {
  List<BoneData> bones = [];
  List<SlotData> slots = [];
  List skins = [];
  List<Animation> animations = [];

  Skin defaultSkin;

  SkeletonData() {

  }

  BoneData findBone(String boneName) {
    for (int i = 0, n = bones.length; i < n; i++)
      if (bones[i].name == boneName) return bones[i];
    return null;
  }

  /** @return -1 if the bone was not found. */

  int findBoneIndex(String boneName) {
    for (int i = 0, n = bones.length; i < n; i++)
      if (bones[i].name == boneName) return i;
    return -1;
  }

  /** @return May be null. */

  SlotData findSlot(String slotName) {
    for (int i = 0, n = slots.length; i < n; i++) {
      if (slots[i].name == slotName) return slots[i];
    }
    return null;
  }

  /** @return -1 if the bone was not found. */

  int findSlotIndex(String slotName) {
    for (int i = 0, n = slots.length; i < n; i++)
      if (slots[i].name == slotName) return i;
    return -1;
  }

  /** @return May be null. */

  Skin findSkin(String skinName) {
    for (int i = 0, n = skins.length; i < n; i++)
      if (skins[i].name == skinName) return skins[i];
    return null;
  }

  /** @return May be null. */

  Animation findAnimation(String animationName) {
    for (int i = 0, n = animations.length; i < n; i++)
      if (animations[i].name == animationName) return animations[i];
    return null;
  }


}

class Skeleton {
  SkeletonData data;
  List<Bone> bones = [];
  List<Slot> slots = [];
  List<Slot> drawOrder = [];

  num x = 0, y = 0;
  Skin skin;
  num r = 1, g = 1, b = 1, a = 1;
  bool flipX = false, flipY = false;

  num time;

  Skeleton(SkeletonData skeletonData) {
    data = skeletonData;
    for (int i = 0, n = skeletonData.bones.length; i < n; i++) {
      BoneData boneData = skeletonData.bones[i];
      Bone parent = boneData.parent == null ? null : this.bones[skeletonData.bones.indexOf(boneData.parent)];
      this.bones.add(new Bone(boneData, parent));
    }

    this.slots = [];
    this.drawOrder = [];
    for (int i = 0, n = skeletonData.slots.length; i < n; i++) {
      SlotData slotData = skeletonData.slots[i];
      Bone bone = this.bones[skeletonData.bones.indexOf(slotData.boneData)];
      Slot slot = new Slot(slotData, this, bone);
      this.slots.add(slot);
      this.drawOrder.add(slot);
    }
  }


  /** Updates the world transform for each bone. */

  updateWorldTransform() {
    for (int i = 0, n = bones.length; i < n; i++)
      bones[i].updateWorldTransform(flipX, flipY);
  }

  /** Sets the bones and slots to their setup pose values. */

  setToSetupPose() {
    this.setBonesToSetupPose();
    this.setSlotsToSetupPose();
  }

  setBonesToSetupPose() {
    for (int i = 0, n = bones.length; i < n; i++)
      bones[i].setToSetupPose();
  }

  //TODO no arguments

  setSlotsToSetupPose() {
    for (int i = 0, n = slots.length; i < n; i++)
      slots[i].setToSetupPose();
  }

  /** @return May return null. */

  Bone getRootBone() {
    return this.bones.length != 0 ? this.bones[0] : null;
  }

  /** @return May be null. */

  Bone findBone(String boneName) {
    for (int i = 0, n = bones.length; i < n; i++)
      if (bones[i].data.name == boneName) return bones[i];
    return null;
  }

  /** @return -1 if the bone was not found. */

  int findBoneIndex(String boneName) {
    for (int i = 0, n = bones.length; i < n; i++)
      if (bones[i].data.name == boneName) return i;
    return -1;
  }

  /** @return May be null. */

  Slot findSlot(String slotName) {
    for (int i = 0, n = slots.length; i < n; i++)
      if (slots[i].data.name == slotName) return slots[i];
    return null;
  }

  /** @return -1 if the bone was not found. */

  int findSlotIndex(String slotName) {
    for (int i = 0, n = slots.length; i < n; i++)
      if (slots[i].data.name == slotName) return i;
    return -1;
  }

  setSkinByName(String skinName) {
    Skin skin = this.data.findSkin(skinName);
    if (skin == null) throw new Exception("Skin not found: $skinName");
    this.setSkin(skin);
  }

  /** Sets the skin used to look up attachments not found in the {@link SkeletonData#getDefaultSkin() default skin}. Attachments
   * from the new skin are attached if the corresponding attachment from the old skin was attached.
   * @param newSkin May be null. */

  setSkin(Skin newSkin) {
    if (this.skin != null && newSkin != null) newSkin._attachAll(this, this.skin);
    this.skin = newSkin;
  }

  /** @return May be null. */

  getAttachmentBySlotName(String slotName, String attachmentName) {
    return this.getAttachmentBySlotIndex(this.data.findSlotIndex(slotName), attachmentName);
  }

  /** @return May be null. */

  getAttachmentBySlotIndex(int slotIndex, String attachmentName) {
    if (this.skin != null) {
      Attachment attachment = this.skin.getAttachment(slotIndex, attachmentName);
      if (attachment != null) return attachment;
    }
    if (this.data.defaultSkin != null) return this.data.defaultSkin.getAttachment(slotIndex, attachmentName);
    return null;
  }

  /** @param attachmentName May be null. */

  setAttachment(String slotName, String attachmentName) {
    List<Slot> slots = this.slots;
    for (int i = 0, n = slots.length; i < n; i++) {
      Slot slot = slots[i];
      if (slot.data.name == slotName) {
        Attachment attachment = null;
        if (attachmentName != null) {
          attachment = this.getAttachment(i, attachmentName);
          if (attachment == null) throw "Attachment not found: $attachmentName for slot: $slotName";
        }
        slot.setAttachment(attachment);
        return;
      }
    }
    throw new Exception("Slot not found: $slotName");
  }

  //TODO

  getAttachment(int i, attachmentName) {
    throw new Exception("error");
  }

  update(num delta) {
    time += delta;
  }

}

abstract class Attachment {
  String name;
  List offset;
  List uvs;

  num x = 0, y = 0,
  rotation = 0,
  scaleX = 1, scaleY = 1,
  width = 0, height = 0,
  regionOffsetX = 0, regionOffsetY = 0,
  regionWidth = 0, regionHeight = 0,
  regionOriginalWidth = 0, regionOriginalHeight = 0;

  AtlasRegion rendererObject;

  updateOffset();

  setUVs(u, v, u2, v2, rotate);
}


class RegionAttachment extends Attachment {


  RegionAttachment([String name]) {
    this.name = name;
    offset = new List(8);
    uvs = new List(8);
  }


  setUVs(num u, num v, num u2, num v2, bool rotate) {
    List uvs = this.uvs;
    if (rotate) {
      uvs[2] = u;
      uvs[3] = v2;
      uvs[4] = u;
      uvs[5] = v;
      uvs[6] = u2;
      uvs[7] = v;
      uvs[0] = u2;
      uvs[1] = v2;
    } else {
      uvs[0] = u;
      uvs[1] = v2;
      uvs[2] = u;
      uvs[3] = v;
      uvs[4] = u2;
      uvs[5] = v;
      uvs[6] = u2;
      uvs[7] = v2;
    }
  }

  updateOffset() {
    num regionScaleX = this.width / this.regionOriginalWidth * this.scaleX;
    num regionScaleY = this.height / this.regionOriginalHeight * this.scaleY;
    num localX = -this.width / 2 * this.scaleX + this.regionOffsetX * regionScaleX;
    num localY = -this.height / 2 * this.scaleY + this.regionOffsetY * regionScaleY;
    num localX2 = localX + this.regionWidth * regionScaleX;
    num localY2 = localY + this.regionHeight * regionScaleY;
    num radians = this.rotation * PI / 180;
    num _cos = cos(radians);
    num _sin = sin(radians);
    num localXCos = localX * _cos + this.x;
    num localXSin = localX * _sin;
    num localYCos = localY * _cos + this.y;
    num localYSin = localY * _sin;
    num localX2Cos = localX2 * _cos + this.x;
    num localX2Sin = localX2 * _sin;
    num localY2Cos = localY2 * _cos + this.y;
    num localY2Sin = localY2 * _sin;
    List offset = this.offset;
    offset[0] = localXCos - localYSin;
    offset[1] = localYCos + localXSin;
    offset[2] = localXCos - localY2Sin;
    offset[3] = localY2Cos + localXSin;
    offset[4] = localX2Cos - localY2Sin;
    offset[5] = localY2Cos + localX2Sin;
    offset[6] = localX2Cos - localYSin;
    offset[7] = localYCos + localX2Sin;
  }

  computeVertices(num x, num y, Bone bone, vertices) {
    x += bone.worldX;
    y += bone.worldY;
    num m00 = bone.m00;
    num m01 = bone.m01;
    num m10 = bone.m10;
    num m11 = bone.m11;
    List offset = this.offset;
    vertices[0] = offset[0] * m00 + offset[1] * m01 + x;
    vertices[1] = offset[0] * m10 + offset[1] * m11 + y;
    vertices[2] = offset[2] * m00 + offset[3] * m01 + x;
    vertices[3] = offset[2] * m10 + offset[3] * m11 + y;
    vertices[4] = offset[4] * m00 + offset[5] * m01 + x;
    vertices[5] = offset[4] * m10 + offset[5] * m11 + y;
    vertices[6] = offset[6] * m00 + offset[7] * m01 + x;
    vertices[7] = offset[6] * m10 + offset[7] * m11 + y;
  }


}


class AnimationStateData {
  SkeletonData skeletonData;
  Map animationToMixTime = {
  };
  int defaultMix = 0;


  AnimationStateData(this.skeletonData) {

  }

  setMixByName(String fromName, String toName, num duration) {
    Animation from = this.skeletonData.findAnimation(fromName);
    if (from == null) throw new Exception("Animation not found: $fromName");
    Animation to = this.skeletonData.findAnimation(toName);
    if (to == null) throw new Exception("Animation not found: $toName");
    this.setMix(from, to, duration);
  }

  setMix(Animation from, Animation to, num duration) {
    this.animationToMixTime["${from.name}:${to.name}"] = duration;
  }

  getMix(Animation from, Animation to) {
    num time = this.animationToMixTime["${from.name}:${to.name}"];
    return time != null ? time : this.defaultMix;
  }
}

class Entry {
  Animation animation;
  bool loop = true;
  num delay = 0;
}

class AnimationState {
  AnimationStateData stateData;
  List<Entry> queue = [];

  Animation current;
  Animation previous;
  num currentTime = 0;
  num previousTime = 0;
  bool currentLoop = false;
  bool previousLoop = false;
  num mixTime = 0;
  num mixDuration = 0;

  AnimationState(this.stateData) {

  }

  update(delta) {
    this.currentTime += delta;
    this.previousTime += delta;
    this.mixTime += delta;

    if (this.queue.length > 0) {
      Entry entry = this.queue[0];
      if (this.currentTime >= entry.delay) {
        this._setAnimation(entry.animation, entry.loop);
        this.queue.removeAt(0);
      }
    }
  }


  apply(Skeleton skeleton) {
    if (this.current == null) return;
    if (this.previous != null) {
      this.previous.apply(skeleton, this.previousTime, this.previousLoop);
      num alpha = this.mixTime / this.mixDuration;
      if (alpha >= 1) {
        alpha = 1;
        this.previous = null;
      }
      this.current.mix(skeleton, this.currentTime, this.currentLoop, alpha);
    } else
      this.current.apply(skeleton, this.currentTime, this.currentLoop);
  }

  clearAnimation() {
    this.previous = null;
    this.current = null;
    this.queue.clear();
  }

  _setAnimation(Animation animation, [bool loop=true]) {
    this.previous = null;
    if (animation != null && this.current != null) {
      this.mixDuration = this.stateData.getMix(this.current, animation);
      if (this.mixDuration > 0) {
        this.mixTime = 0;
        this.previous = this.current;
        this.previousTime = this.currentTime;
        this.previousLoop = this.currentLoop;
      }
    }
    this.current = animation;
    this.currentLoop = loop;
    this.currentTime = 0;
  }

  /** @see #setAnimation(Animation, Boolean) */

  setAnimationByName(String animationName, loop) {
    Animation animation = this.stateData.skeletonData.findAnimation(animationName);
    if (animation == null) throw new Exception("Animation not found: $animationName");
    this.setAnimation(animation, loop);
  }

  /** Set the current animation. Any queued animations are cleared and the current animation time is set to 0.
   * @param animation May be null. */

  setAnimation(Animation animation, [bool loop=true]) {
    this.queue.clear();
    this._setAnimation(animation, loop);
  }

  /** @see #addAnimation(Animation, Boolean, Number) */

  addAnimationByName(String animationName, [bool loop= true, num delay = 0 ]) {
    Animation animation = this.stateData.skeletonData.findAnimation(animationName);
    if (animation == null) throw new Exception("Animation not found: $animationName");
    this.addAnimation(animation, loop, delay);
  }

  /** Adds an animation to be played delay seconds after the current or last queued animation.
   * @param delay May be <= 0 to use duration of previous animation minus any mix duration plus the negative delay. */

  addAnimation(Animation animation, [bool loop=true, num delay=0]) {
    Entry entry = new Entry();
    entry.animation = animation;
    entry.loop = loop;

    if (delay <= 0) {
      Animation previousAnimation = this.queue.length != 0 ? this.queue[this.queue.length - 1].animation : this.current;
      if (previousAnimation != null)
        delay = previousAnimation.duration - this.stateData.getMix(previousAnimation, animation) + delay;
      else
        delay = 0;
    }
    //print(delay);
    entry.delay = delay;

    this.queue.add(entry);
  }

  /** Returns true if no animation is set or if the current time is greater than the animation duration, regardless of looping. */

  bool isComplete() {
    return this.current == null || this.currentTime >= this.current.duration;
  }

}

class SkeletonJson {
  AtlasAttachmentLoader attachmentLoader;
  int scale = 1;

  SkeletonJson([this.attachmentLoader]) {

  }

  readSkeletonData(Map root) {
    /*jshint -W069*/
    SkeletonData skeletonData = new SkeletonData();
    BoneData boneData;

    // Bones.
    List bones = root["bones"];
    for (int i = 0, n = bones.length; i < n; i++) {
      Map boneMap = bones[i];
      BoneData parent = null;
      if (boneMap["parent"] != null) {
        parent = skeletonData.findBone(boneMap["parent"]);
        if (parent == null) throw "Parent bone not found: " + boneMap["parent"];
      }
      boneData = new BoneData(boneMap["name"], parent);
      boneData.length = (boneMap["length"] == null ? 0 : boneMap["length"]) * this.scale;
      boneData.x = (boneMap["x"] == null ? 0 : boneMap["x"]) * this.scale;
      boneData.y = (boneMap["y"] == null ? 0 : boneMap["y"]) * this.scale;
      boneData.rotation = (boneMap["rotation"] == null ? 0 : boneMap["rotation"]);
      boneData.scaleX = boneMap["scaleX"] == null ? 1 : boneMap["scaleX"];
      boneData.scaleY = boneMap["scaleY"] == null ? 1 : boneMap["scaleY"];
      skeletonData.bones.add(boneData);
    }

    // Slots.
    List slots = root["slots"];
    for (int i = 0, n = slots.length; i < n; i++) {
      Map slotMap = slots[i];
      boneData = skeletonData.findBone(slotMap["bone"]);
      if (boneData == null) throw new Exception("Slot bone not found: ${slotMap['bone']}");
      SlotData slotData = new SlotData(slotMap["name"], boneData);

      String color = slotMap["color"];
      if (color != null) {
        slotData.r = SkeletonJson.toColor(color, 0);
        slotData.g = SkeletonJson.toColor(color, 1);
        slotData.b = SkeletonJson.toColor(color, 2);
        slotData.a = SkeletonJson.toColor(color, 3);
      }

      slotData.attachmentName = slotMap["attachment"];

      skeletonData.slots.add(slotData);
    }

    // Skins.
    Map skins = root["skins"];
    for (String skinName in skins.keys) {
      //if (!skins.containsKey(skinName)) continue;
      Map skinMap = skins[skinName];
      Skin skin = new Skin(skinName);
      for (String slotName in skinMap.keys) {
        //if (!skinMap.containsKey(slotName)) continue;
        int slotIndex = skeletonData.findSlotIndex(slotName);
        Map slotEntry = skinMap[slotName];
        for (String attachmentName in slotEntry.keys) {
          //if (!slotEntry.containsKey(attachmentName)) continue;
          Attachment attachment = this.readAttachment(skin, attachmentName, slotEntry[attachmentName]);
          if (attachment != null) skin.addAttachment(slotIndex, attachmentName, attachment);
        }
      }
      skeletonData.skins.add(skin);
      if (skin.name == "default") skeletonData.defaultSkin = skin;
    }

    // Animations.
    Map animations = root["animations"];
    for (String animationName in animations.keys) {
      //if (!animations.containsKey(animationName)) continue;
      this.readAnimation(animationName, animations[animationName], skeletonData);
    }

    return skeletonData;
  }

  readAttachment(Skin skin, String name, Map map) {
    /*jshint -W069*/
    if (map["name"] != null) {
      name = map["name"];
    }

    int type = AttachmentType[map["type"] == null ? "region" : map["type"]];

    if (type == AttachmentType['region']) {
      Attachment attachment = new RegionAttachment();
      attachment.x = (map["x"] == null ? 0 : map["x"]) * this.scale;
      attachment.y = (map["y"] == null ? 0 : map["y"]) * this.scale;
      attachment.scaleX = map["scaleX"] == null ? 1 : map["scaleX"];
      attachment.scaleY = map["scaleY"] == null ? 1 : map["scaleY"];
      attachment.rotation = map["rotation"] == null ? 0 : map["rotation"];
      attachment.width = (map["width"] == null ? 32 : map["width"]) * this.scale;
      attachment.height = (map["height"] == null ? 32 : map["height"]) * this.scale;
      attachment.updateOffset();

      attachment.rendererObject = new AtlasRegion();
      attachment.rendererObject.name = name;
      attachment.rendererObject.scale = {
      };
      attachment.rendererObject.scale['x'] = attachment.scaleX;
      attachment.rendererObject.scale['y'] = attachment.scaleY;
      attachment.rendererObject.rotation = -attachment.rotation * PI / 180;
      return attachment;
    }

    throw new Exception("Unknown attachment type: $type");
  }

  readAnimation(String name, Map map, SkeletonData skeletonData) {
    /*jshint -W069*/
    List<Timeline> timelines = [];
    num duration = 0;
    //Timeline timeline;
    int frameIndex;
    String timelineName;
    Map valueMap;
    List values;
    int i, n;

    Map bones = map["bones"];
    for (String boneName in bones.keys) {
      //if (!bones.containsKey(boneName)) continue;
      int boneIndex = skeletonData.findBoneIndex(boneName);
      if (boneIndex == -1) throw "Bone not found: " + boneName;
      Map boneMap = bones[boneName];

      for (String timelineName in boneMap.keys) {
        //if (!boneMap.containsKey(timelineName)) continue;
        List values = boneMap[timelineName];
        //print(timelineName);
        if (timelineName == "rotate") {
          RotateTimeline timeline = new RotateTimeline(values.length);
          timeline.boneIndex = boneIndex;

          frameIndex = 0;
          for (int i = 0, n = values.length; i < n; i++) {
            valueMap = values[i];
            //print(valueMap["time"]);
            timeline.setFrame(frameIndex, valueMap["time"], valueMap["angle"]);
            SkeletonJson.readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          }
          timelines.add(timeline);
          duration = max(duration, timeline.frames[(timeline.getFrameCount() * 2 - 2).floor()]);

        } else if (timelineName == "translate" || timelineName == "scale") {
          num timelineScale = 1;
          Timeline timeline;
          if (timelineName == "scale")
            timeline = new ScaleTimeline(values.length);
          else {
            timeline = new TranslateTimeline(values.length);
            timelineScale = this.scale;
          }
          timeline.boneIndex = boneIndex;

          frameIndex = 0;
          for (int i = 0, n = values.length; i < n; i++) {
            valueMap = values[i];
            num x = (valueMap["x"] == null ? 0 : valueMap["x"]) * timelineScale;
            num y = (valueMap["y"] == null ? 0 : valueMap["y"]) * timelineScale;
            timeline.setFrame(frameIndex, valueMap["time"], x, y);
            SkeletonJson.readCurve(timeline, frameIndex, valueMap);
            frameIndex++;
          }
          timelines.add(timeline);
          duration = max(duration, timeline.frames[(timeline.getFrameCount() * 3 - 3).floor()]);

        } else
          throw new Exception("Invalid timeline type for a bone: $timelineName($boneName)");
      }
    }
    Map slots = map["slots"];
    if (slots != null) {
      for (String slotName in slots.keys) {
        if (!slots.containsKey(slotName)) continue;
        Map slotMap = slots[slotName];
        int slotIndex = skeletonData.findSlotIndex(slotName);

        for (String timelineName in slotMap.keys) {
          if (!slotMap.containsKey(timelineName)) continue;
          values = slotMap[timelineName];
          if (timelineName == "color") {
            ColorTimeline timeline = new ColorTimeline(values.length);
            timeline.slotIndex = slotIndex;

            frameIndex = 0;
            for (int i = 0, n = values.length; i < n; i++) {
              valueMap = values[i];
              String color = valueMap["color"];
              num r = SkeletonJson.toColor(color, 0);
              num g = SkeletonJson.toColor(color, 1);
              num b = SkeletonJson.toColor(color, 2);
              num a = SkeletonJson.toColor(color, 3);
              timeline.setFrame(frameIndex, valueMap["time"], r, g, b, a);
              SkeletonJson.readCurve(timeline, frameIndex, valueMap);
              frameIndex++;
            }
            timelines.add(timeline);
            duration = max(duration, timeline.frames[timeline.getFrameCount() * 5 - 5]);

          } else if (timelineName == "attachment") {
            AttachmentTimeline timeline = new AttachmentTimeline(values.length);
            timeline.slotIndex = slotIndex;

            frameIndex = 0;
            for (int i = 0, n = values.length; i < n; i++) {
              valueMap = values[i];
              timeline.setFrame(frameIndex++, valueMap["time"], valueMap["name"]);
            }
            timelines.add(timeline);
            duration = max(duration, timeline.frames[timeline.getFrameCount() - 1]);

          } else
            throw "Invalid timeline type for a slot: " + timelineName + " (" + slotName + ")";
        }
      }
    }
    //window.console.log(timelines);
    skeletonData.animations.add(new Animation(name, timelines, duration));
  }

  static readCurve(Timeline timeline, int frameIndex, Map valueMap) {

    if (valueMap["curve"] == null) return;
    if (valueMap["curve"] == "stepped")
      timeline.curves.setStepped(frameIndex);
    else if (valueMap["curve"] is List) {
      List<num> curve = valueMap["curve"];
      timeline.curves.setCurve(frameIndex, curve[0], curve[1], curve[2], curve[3]);
    }
  }

  static toColor(String hexString, int colorIndex) {
    if (hexString.length != 8) throw "Color hexidecimal length must be 8, recieved: " + hexString;
    return ( int.parse(int.parse(hexString.substring(colorIndex * 2, 2)).toRadixString(16))) / 255;
  }

}


class Atlas {
  var textureLoader;
  List<AtlasPage> pages = [];
  List<AtlasRegion> regions = [];

  Atlas(String atlasText, this.textureLoader) {
    AtlasReader reader = new AtlasReader(atlasText);
    List tuple = [];
    tuple.length = 4;
    AtlasPage page = null;
    while (true) {
      String line = reader.readLine();
      if (line == null) break;
      line = reader.trim(line);
      if (line.length == 0)
        page = null;
      else if (page == null) {
        page = new AtlasPage();
        page.name = line;

        page.format = Atlas.Format[reader.readValue()];

        reader.readTuple(tuple);
        page.minFilter = Atlas.TextureFilter[tuple[0]];
        page.magFilter = Atlas.TextureFilter[tuple[1]];

        String direction = reader.readValue();
        page.uWrap = Atlas.TextureWrap['clampToEdge'];
        page.vWrap = Atlas.TextureWrap['clampToEdge'];
        if (direction == "x")
          page.uWrap = Atlas.TextureWrap['repeat'];
        else if (direction == "y")
          page.vWrap = Atlas.TextureWrap['repeat'];
        else if (direction == "xy")
            page.uWrap = page.vWrap = Atlas.TextureWrap['repeat'];

        textureLoader.load(page, line);

        this.pages.add(page);

      } else {
        AtlasRegion region = new AtlasRegion();
        region.name = line;
        region.page = page;

        region.rotate = reader.readValue() == "true";

        reader.readTuple(tuple);
        int x = int.parse(tuple[0]);
        int y = int.parse(tuple[1]);

        reader.readTuple(tuple);
        int width = int.parse(tuple[0]);
        int height = int.parse(tuple[1]);

        region.u = x / page.width;
        region.v = y / page.height;
        if (region.rotate) {
          region.u2 = (x + height) / page.width;
          region.v2 = (y + width) / page.height;
        } else {
          region.u2 = (x + width) / page.width;
          region.v2 = (y + height) / page.height;
        }
        region.x = x;
        region.y = y;
        region.width = width.abs();
        region.height = height.abs();

        if (reader.readTuple(tuple) == 4) {
          // split is optional
          region.splits = [int.parse(tuple[0]), int.parse(tuple[1]), int.parse(tuple[2]), int.parse(tuple[3])];

          if (reader.readTuple(tuple) == 4) {
            // pad is optional, but only present with splits
            region.pads = [int.parse(tuple[0]), int.parse(tuple[1]), int.parse(tuple[2]), int.parse(tuple[3])];

            reader.readTuple(tuple);
          }
        }

        region.originalWidth = int.parse(tuple[0]);
        region.originalHeight = int.parse(tuple[1]);

        reader.readTuple(tuple);
        region.offsetX = int.parse(tuple[0]);
        region.offsetY = int.parse(tuple[1]);

        region.index = int.parse(reader.readValue());

        this.regions.add(region);
      }
    }

  }


  findRegion(name) {
    for (int i = 0, n = regions.length; i < n; i++)
      if (regions[i].name == name) return regions[i];
    return null;
  }

  dispose() {
    List<AtlasPage> pages = this.pages;
    for (int i = 0, n = pages.length; i < n; i++)
      this.textureLoader.unload(pages[i].rendererObject);
  }

  updateUVs(AtlasPage page) {
    List<AtlasRegion> regions = this.regions;
    for (int i = 0, n = regions.length; i < n; i++) {
      AtlasRegion region = regions[i];
      if (region.page != page) continue;
      region.u = region.x / page.width;
      region.v = region.y / page.height;
      if (region.rotate) {
        region.u2 = (region.x + region.height) / page.width;
        region.v2 = (region.y + region.width) / page.height;
      } else {
        region.u2 = (region.x + region.width) / page.width;
        region.v2 = (region.y + region.height) / page.height;
      }
    }
  }

  static Map Format = {
      'alpha': 0,
      'intensity': 1,
      'luminanceAlpha': 2,
      'rgb565': 3,
      'rgba4444': 4,
      'rgb888': 5,
      'rgba8888': 6
  };

  static Map TextureFilter = {
      'nearest': 0,
      'linear': 1,
      'mipMap': 2,
      'mipMapNearestNearest': 3,
      'mipMapLinearNearest': 4,
      'mipMapNearestLinear': 5,
      'mipMapLinearLinear': 6
  };

  static Map TextureWrap = {
      'mirroredRepeat': 0,
      'clampToEdge': 1,
      'repeat': 2,
  };
}

class AtlasPage {
  String name;
  int format;
  int minFilter;
  int magFilter;
  int uWrap;
  int vWrap;
  AtlasRegion rendererObject;
  num width = 0;
  num height = 0;
}

class AtlasRegion {
  AtlasPage page;
  String name;
  num x = 0, y = 0,
  width = 0, height = 0,
  u = 0, v = 0, u2 = 0, v2 = 0,
  offsetX = 0, offsetY = 0,
  originalWidth = 0, originalHeight = 0;
  int index = 0;
  bool rotate = false;
  List<int> splits;
  List<int> pads;

  Map scale;
  num rotation;
}

class AtlasReader {
  static RegExp splitReg = new RegExp("\r\n|\r|\n");
  static RegExp replaceReg = new RegExp("^\s+|\s+\$", multiLine:true);
  List lines;
  int index = 0;

  AtlasReader(String text) {
    lines = text.split(splitReg);
  }

  String trim(value) {
    return value.replace(replaceReg, "");
  }

  String readLine() {
    if (this.index >= this.lines.length) return null;
    return this.lines[this.index++];
  }

  String readValue() {
    String line = this.readLine();
    int colon = line.indexOf(":");
    if (colon == -1) throw new Exception("Invalid line: $line");
    return this.trim(line.substring(colon + 1));
  }

  /** Returns the number of tuple values read (2 or 4). */

  int readTuple(List tuple) {
    String line = this.readLine();
    int colon = line.indexOf(":");
    if (colon == -1) throw new Exception("Invalid line: $line");
    int i, lastMatch = colon + 1;
    for (i = 0; i < 3; i++) {
      int comma = line.indexOf(",", lastMatch);
      if (comma == -1) {
        if (i == 0) throw new Exception("Invalid line: $line");
        break;
      }
      tuple[i] = this.trim(line.substring(lastMatch, comma - lastMatch));
      lastMatch = comma + 1;
    }
    tuple[i] = this.trim(line.substring(lastMatch));
    return i + 1;
  }

}


class AtlasAttachmentLoader {
  Atlas atlas;

  AtlasAttachmentLoader(this.atlas) {

  }

  newAttachment(Skin skin, String type, String name) {
    if (type == AttachmentType['region']) {
      AtlasRegion region = this.atlas.findRegion(name);
      if (region == null) throw new Exception("Region not found in atlas: $name ($type)");
      Attachment attachment = new RegionAttachment(name);
      attachment.rendererObject = region;
      attachment.setUVs(region.u, region.v, region.u2, region.v2, region.rotate);
      attachment.regionOffsetX = region.offsetX;
      attachment.regionOffsetY = region.offsetY;
      attachment.regionWidth = region.width;
      attachment.regionHeight = region.height;
      attachment.regionOriginalWidth = region.originalWidth;
      attachment.regionOriginalHeight = region.originalHeight;
      return attachment;
    }
    throw new Exception("Unknown attachment type: $type");
  }

}

class Spine extends DisplayObjectContainer {
  Skeleton skeleton;
  SkeletonData skeletonData;

  AnimationStateData stateData;
  AnimationState state;

  List<DisplayObjectContainer> slotContainers = [];

  DateTime lastTime;

  Spine(String url) {
    this.skeletonData = AnimCache[url];

    if (this.skeletonData == null) {
      throw new Exception("Spine data must be preloaded using PIXI.SpineLoader or PIXI.AssetLoader: $url");
    }

    this.skeleton = new Skeleton(this.skeletonData);
    this.skeleton.updateWorldTransform();

    this.stateData = new AnimationStateData(this.skeletonData);
    this.state = new AnimationState(this.stateData);

    this.slotContainers = [];

    for (int i = 0, n = this.skeleton.drawOrder.length; i < n; i++) {

      Slot slot = this.skeleton.drawOrder[i];

      //window.console.log(slot);

      Attachment attachment = slot.attachment;
      DisplayObjectContainer slotContainer = new DisplayObjectContainer();
      this.slotContainers.add(slotContainer);
      this.addChild(slotContainer);
      if (!(attachment is RegionAttachment)) {
        continue;
      }

      String spriteName = attachment.rendererObject.name;
      Sprite sprite = this.createSprite(slot, attachment.rendererObject);
      slot.currentSprite = sprite;
      slot.currentSpriteName = spriteName;
      slotContainer.addChild(sprite);
    }
  }

  updateTransform() {
    if (lastTime == null) {
      this.lastTime = new DateTime.now();
    }

    num timeDelta = (new DateTime.now().millisecondsSinceEpoch - this.lastTime.millisecondsSinceEpoch) * 0.001;
    this.lastTime = new DateTime.now();
    this.state.update(timeDelta);
    this.state.apply(this.skeleton);
    this.skeleton.updateWorldTransform();

    List<Slot> drawOrder = this.skeleton.drawOrder;
    for (int i = 0, n = drawOrder.length; i < n; i++) {
      Slot slot = drawOrder[i];
      Attachment attachment = slot.attachment;
      DisplayObjectContainer slotContainer = this.slotContainers[i];
      if (!(attachment is RegionAttachment)) {
        slotContainer.visible = false;
        continue;
      }

      if (attachment.rendererObject != null) {
        if (slot.currentSpriteName == null || slot.currentSpriteName != attachment.name) {
          String spriteName = attachment.rendererObject.name;
          if (slot.currentSprite != null) {
            slot.currentSprite.visible = false;
          }
          if (slot.sprites == null) {
            slot.sprites = {
            };
          }

          if (slot.sprites[spriteName] != null) {
            slot.sprites[spriteName].visible = true;
          } else {
            Sprite sprite = this.createSprite(slot, attachment.rendererObject);
            slotContainer.addChild(sprite);
          }
          slot.currentSprite = slot.sprites[spriteName];
          slot.currentSpriteName = spriteName;
        }
      }
      slotContainer.visible = true;

      Bone bone = slot.bone;

      slotContainer.position.x = bone.worldX + attachment.x * bone.m00 + attachment.y * bone.m01;
      slotContainer.position.y = bone.worldY + attachment.x * bone.m10 + attachment.y * bone.m11;
      slotContainer.scale.x = bone.worldScaleX;
      slotContainer.scale.y = bone.worldScaleY;

      slotContainer.rotation = -(slot.bone.worldRotation * PI / 180);

      slotContainer.alpha = slot.a;
      slot.currentSprite.tint = rgb2hex([slot.r, slot.g, slot.b]);
    }

    super.updateTransform();
  }

  Sprite createSprite(Slot slot, AtlasRegion descriptor) {

    String name = TextureCache[descriptor.name] != null ? descriptor.name : "${descriptor.name}.png";
    Sprite sprite = new Sprite(Texture.fromFrame(name));
    sprite.scale = new Point(descriptor.scale['x'], descriptor.scale['y']);
    sprite.rotation = descriptor.rotation;
    sprite.anchor.x = sprite.anchor.y = 0.5;

    if (slot.sprites == null) {
      slot.sprites = {
      };
    }

    slot.sprites[descriptor.name] = sprite;
    return sprite;
  }
}