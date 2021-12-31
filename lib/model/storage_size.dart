
class StorageSize {
  int totalSize;
  int availableSize;

  StorageSize(this.totalSize, this.availableSize);

  factory StorageSize.fromJson(Map<String, dynamic> parsedJson) {
    return StorageSize(
        parsedJson["totalSize"],
        parsedJson["availableSize"]
    );
  }
}