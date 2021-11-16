

class AlbumItem {
  String id;
  String mimeType;
  String path;
  int width;
  int height;
  int modifyTime;
  int createTime;

  AlbumItem(this.id, this.mimeType, this.path, this.width, this.height,
      this.modifyTime, this.createTime) {}

  factory AlbumItem.fromJson(Map<String, dynamic> parsedJson) {
    return AlbumItem(parsedJson["id"], parsedJson["mimeType"],
        parsedJson["path"], parsedJson["width"], parsedJson["height"],
        parsedJson["modifyTime"], parsedJson["createTime"]);
  }
}