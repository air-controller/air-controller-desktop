class AudioItem {
  String id;
  String name;
  String folder;
  String path;
  int duration;
  int size;
  int createTime;
  bool isMusic;

  AudioItem(this.id, this.name, this.folder, this.path, this.duration, this.size,
      this.createTime, this.isMusic);

  factory AudioItem.fromJson(Map<String, dynamic> parsedJson) {
    return AudioItem(
        parsedJson["id"],
        parsedJson["name"],
        parsedJson["folder"],
        parsedJson["path"],
        parsedJson["duration"],
        parsedJson["size"],
        parsedJson["createTime"],
        parsedJson["isMusic"]
    );
  }
}