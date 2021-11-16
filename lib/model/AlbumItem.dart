

class AlbumItem {
  String id;
  String name;
  int photoNum;
  String coverImageId;

  AlbumItem(this.id, this.name, this.photoNum, this.coverImageId,) {}

  factory AlbumItem.fromJson(Map<String, dynamic> parsedJson) {
    return AlbumItem(parsedJson["id"], parsedJson["name"],
        parsedJson["photoNum"], parsedJson["coverImageId"]);
  }
}