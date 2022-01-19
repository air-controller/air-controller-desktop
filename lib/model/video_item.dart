
class VideoItem {
  int id;
  String name;
  String path;
  int duration;
  int size;
  int createTime;
  int lastModifyTime;

  VideoItem(this.id, this.name, this.path, this.duration, this.size, this.createTime,
      this.lastModifyTime);

  factory VideoItem.fromJson(Map<String, dynamic> parsedJson) {
    return VideoItem(parsedJson["id"], parsedJson["name"],
        parsedJson["path"], parsedJson["duration"], parsedJson["size"], parsedJson["createTime"],
        parsedJson["lastModifyTime"]);
  }

  @override
  bool operator ==(Object other) {
    if (other is VideoItem) {
      return other.id == this.id || other.path == this.path;
    }
    return super == other;
  }
}