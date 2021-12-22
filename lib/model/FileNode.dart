

import 'package:mobile_assistant_client/model/FileItem.dart';

class FileNode extends Comparable<FileNode> {
  FileNode? parent;
  FileItem data;
  int level;

  bool isExpand = false;

  FileNode(this.parent, this.data, this.level);

  @override
  int compareTo(FileNode other) {
    return this.data.name.compareTo(other.data.name);
  }
}