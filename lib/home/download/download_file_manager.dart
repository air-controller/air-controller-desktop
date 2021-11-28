import 'package:mobile_assistant_client/model/FileItem.dart';

abstract class DownloadFileManager {
  static final DownloadFileManager _instance = DownloadFileManagerImpl();

  void updateFiles(List<FileItem> files);

  void updateSelectedFiles(List<FileItem> selectedFiles);

  List<FileItem> allFiles();

  List<FileItem> selectedFiles();

  void clear();

  static DownloadFileManager get instance {
    return _instance;
  }
}

class DownloadFileManagerImpl extends DownloadFileManager {
  List<FileItem> _allFiles = [];
  List<FileItem> _selectedFiles = [];

  @override
  void updateFiles(List<FileItem> files) {
    _allFiles = files;
  }

  @override
  void updateSelectedFiles(List<FileItem> selectedFiles) {
    _selectedFiles = selectedFiles;
  }

  @override
  List<FileItem> allFiles() {
    return _allFiles;
  }

  @override
  List<FileItem> selectedFiles() {
    return _selectedFiles;
  }

  @override
  void clear() {
    _allFiles.clear();
    _selectedFiles.clear();
  }
}