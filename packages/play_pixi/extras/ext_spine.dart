part of PIXI;

Map AnimCache = {
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

  bool yDown = false;


  updateWorldTransform(flipX, flipY) {
    var parent = this.parent;
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
    var radians = this.worldRotation * PI / 180;
    var _cos = cos(radians);
    var _sin = sin(radians);
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
    var data = this.data;
    this.x = data.x;
    this.y = data.y;
    this.rotation = data.rotation;
    this.scaleX = data.scaleX;
    this.scaleY = data.scaleY;
  }
}

class Spine {
  Spine.SkeletonJson();
}
