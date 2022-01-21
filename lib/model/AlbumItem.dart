

class AlbumItem {
  String id;
  String name;
  int photoNum;
  String coverImageId;
  String path;

  AlbumItem(this.id, this.name, this.photoNum, this.coverImageId, this.path) {}

  factory AlbumItem.fromJson(Map<String, dynamic> parsedJson) {
    return AlbumItem(parsedJson["id"], parsedJson["name"],
        parsedJson["photoNum"], parsedJson["coverImageId"], parsedJson["path"]);
  }

  @override
  bool operator ==(Object other) {
    if (other is AlbumItem) {
      return other.id == this.id || other.path == this.path;
    }
    return super == other;
  }
}