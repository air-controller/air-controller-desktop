import 'file_item.dart';

class FileNode extends Comparable<FileNode> {
  FileNode? parent;
  FileItem data;
  int level;

  bool isExpand = false;
  bool isRenaming = false;

  FileNode(this.parent, this.data, this.level);

  @override
  int compareTo(FileNode other) {
    return this.data.name.compareTo(other.data.name);
  }

  @override
  bool operator ==(Object other) {
    if (other is FileNode) {
      if (other.data.folder == this.data.folder && other.data.name == this.data.name) {
        return true;
      }
    }

    return false;
  }
}