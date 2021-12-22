import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:mobile_assistant_client/model/FileNode.dart';

abstract class DownloadFileManager {
  static final DownloadFileManager _instance = DownloadFileManagerImpl();

  void updateFiles(List<FileNode> files);

  void updateSelectedFiles(List<FileNode> selectedFiles);

  List<FileNode> allFiles();

  List<FileNode> selectedFiles();

  void clear();

  static DownloadFileManager get instance {
    return _instance;
  }
}

class DownloadFileManagerImpl extends DownloadFileManager {
  List<FileNode> _allFiles = [];
  List<FileNode> _selectedFiles = [];

  @override
  void updateFiles(List<FileNode> files) {
    _allFiles = files;
  }

  @override
  void updateSelectedFiles(List<FileNode> selectedFiles) {
    _selectedFiles = selectedFiles;
  }

  @override
  List<FileNode> allFiles() {
    return _allFiles;
  }

  @override
  List<FileNode> selectedFiles() {
    return _selectedFiles;
  }

  @override
  void clear() {
    _allFiles.clear();
    _selectedFiles.clear();
  }
}