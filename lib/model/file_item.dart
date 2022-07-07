class FileItem {
  String name;
  String folder;
  bool isDir;
  int size;
  int changeDate;
  bool isEmpty;

  FileItem(this.name, this.folder, this.isDir, this.size, this.changeDate, this.isEmpty) {}

  factory FileItem.fromJson(Map<String, dynamic> parsedJson) {
    return FileItem(
        parsedJson["name"],
        parsedJson["folder"],
        parsedJson["isDir"],
        parsedJson["size"],
        parsedJson["changeDate"],
        parsedJson["isEmpty"]
    );
  }

  String get path => "${this.folder}/${this.name}";
}