

class VideoFolderItem {
  String id;
  String name;
  int videoCount;
  int coverVideoId;

  VideoFolderItem(this.id, this.name, this.videoCount, this.coverVideoId);

  factory VideoFolderItem.fromJson(Map<String, dynamic> parsedJson) {
    return VideoFolderItem(parsedJson["id"], parsedJson["name"],
        parsedJson["videoCount"], parsedJson["coverVideoId"]);
  }
}