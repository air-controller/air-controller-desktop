import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:mobile_assistant_client/model/FileNode.dart';
import 'package:mobile_assistant_client/util/stack.dart';

abstract class DownloadFileManager {
  static final DownloadFileManager _instance = DownloadFileManagerImpl();

  void updateFiles(List<FileNode> files);

  void updateSelectedFiles(List<FileNode> selectedFiles);

  void clearSelectedFiles();

  List<FileNode> allFiles();

  List<FileNode> selectedFiles();

  int totalFileCount();

  int selectedFileCount();

  bool isSelected(FileNode fileNode);

  void updateCurrentDir(FileNode? current);

  FileNode? currentDir();

  void pushToStack(FileNode dir);

  FileNode? takeLast();

  FileNode? pop();

  int dirStackLength();

  List<FileNode> dirStackToList();

  void popTo(FileNode dir);

  bool isRoot();

  void clear();

  void clearDirStack();

  static DownloadFileManager get instance {
    return _instance;
  }
}

class DownloadFileManagerImpl extends DownloadFileManager {
  List<FileNode> _allFiles = [];
  List<FileNode> _selectedFiles = [];
  FileNode? _currentDir;
  StackQueue<FileNode> _dirStack = StackQueue<FileNode>();

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
    _dirStack.clear();
  }

  @override
  FileNode? currentDir() {
    return _currentDir;
  }

  @override
  void updateCurrentDir(FileNode? current) {
    _currentDir = current;
  }

  @override
  bool isRoot() {
    return _dirStack.isEmpty;
  }

  @override
  FileNode? pop() {
    return _dirStack.pop();
  }

  @override
  void popTo(FileNode dir) {
    _dirStack.popTo(dir);
  }

  @override
  FileNode? takeLast() {
    return _dirStack.takeLast();
  }

  @override
  int dirStackLength() {
    return _dirStack.length;
  }

  @override
  List<FileNode> dirStackToList() {
    return _dirStack.toList();
  }

  @override
  void pushToStack(FileNode dir) {
    _dirStack.push(dir);
  }

  @override
  void clearDirStack() {
    _dirStack.clear();
  }

  @override
  void clearSelectedFiles() {
    _selectedFiles.clear();
  }

  @override
  bool isSelected(FileNode fileNode) {
    return _selectedFiles.contains(fileNode);
  }

  @override
  int selectedFileCount() {
    return _selectedFiles.length;
  }

  @override
  int totalFileCount() {
    return _allFiles.length;
  }
}