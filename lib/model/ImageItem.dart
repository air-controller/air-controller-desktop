

class ImageItem {
  String id;
  String mimeType;
  String path;
  int width;
  int height;
  int modifyTime;
  int createTime;

  ImageItem(this.id, this.mimeType, this.path, this.width, this.height,
      this.modifyTime, this.createTime) {}

  factory ImageItem.fromJson(Map<String, dynamic> parsedJson) {
    return ImageItem(parsedJson["id"], parsedJson["mimeType"],
        parsedJson["path"], parsedJson["width"], parsedJson["height"],
        parsedJson["modifyTime"], parsedJson["createTime"]);
  }
}