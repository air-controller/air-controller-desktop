class AudioItem {
  String id;
  String name;
  String folder;
  String path;
  int duration;
  int size;
  int createTime;
  bool isMusic;
  int modifyDate;

  AudioItem(this.id, this.name, this.folder, this.path, this.duration, this.size,
      this.createTime, this.isMusic, this.modifyDate);

  factory AudioItem.fromJson(Map<String, dynamic> parsedJson) {
    return AudioItem(
        parsedJson["id"],
        parsedJson["name"],
        parsedJson["folder"],
        parsedJson["path"],
        parsedJson["duration"],
        parsedJson["size"],
        parsedJson["createTime"],
        parsedJson["isMusic"],
        parsedJson["modifyDate"]
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is AudioItem) {
      return this.id == other.id || this.path == other.path;
    }
    return super == other;
  }
}