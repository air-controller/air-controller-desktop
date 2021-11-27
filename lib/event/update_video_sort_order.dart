
class UpdateVideoSortOrder {
  int type;

  static int TYPE_CREATE_TIME = 1;
  static int TYPE_VIDEO_SIZE = 2;

  UpdateVideoSortOrder(this.type);
}