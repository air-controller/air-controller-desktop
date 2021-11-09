

class ImageItem {
  String id;
  String thumbnail;
  String path;

  ImageItem(this.id, this.thumbnail, this.path) {}

  factory ImageItem.fromJson(Map<String, dynamic> parsedJson) {
    return ImageItem(parsedJson["id"], parsedJson["thumbnail"], parsedJson["path"]);
  }
}