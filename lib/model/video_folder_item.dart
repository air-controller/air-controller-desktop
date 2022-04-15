class VideoFolderItem {
  String id;
  String name;
  int videoCount;
  int coverVideoId;
  String path;

  VideoFolderItem(this.id, this.name, this.videoCount, this.coverVideoId, this.path);

  factory VideoFolderItem.fromJson(Map<String, dynamic> parsedJson) {
    return VideoFolderItem(parsedJson["id"], parsedJson["name"],
        parsedJson["videoCount"], parsedJson["coverVideoId"], parsedJson["path"]);
  }

  @override
  bool operator ==(Object other) {
    if (other is VideoFolderItem) {
      if (other.id == this.id || other.path == this.path) return true;
    }
    return super == other;
  }
}