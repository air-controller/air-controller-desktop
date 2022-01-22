import 'FileItem.dart';

/**
 * 用于完成特定UI需求，例如缩进等
 *
 * @author Scott Smith 2021/11/7 13:01
 */
class FileItemVO {
  FileItem item;
  int indentLevel = 0;
  bool isExpanded = false;
  List<String> ancestors = [];
  FileItemVO? parent = null;

  FileItemVO(this.item, this.indentLevel) {}

  /**
   * 添加祖先文件夹路径
   */
  void addAncestor(String ancestor) {
    if (!ancestors.contains(ancestor)) {
      ancestors.add(ancestor);
    }
  }

  bool containsAncestor(String path) {
    return ancestors.contains(path);
  }
}