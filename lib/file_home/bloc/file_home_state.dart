part of 'file_home_bloc.dart';

enum FileHomeStatus { initial, loading, success, failure }

enum FileHomeKeyStatus { none, ctrlDown, shiftDown }

enum FileHomeOpenDirStatus { initial, loading, success, failure }

enum FileHomeRenameStatus { initial, loading, success, failure }

enum FileHomeEnterTapStatus { none, tap }

enum FileHomeDeleteStatus { initial, loading, success, failure }

class FileHomeMenuStatus extends Equatable {
  final bool isOpened;
  final Offset? position;
  final FileNode? current;

  const FileHomeMenuStatus(
      {this.isOpened = false, this.position = null, this.current = null});

  @override
  List<Object?> get props => [isOpened, position, current];
}

enum FileHomeCopyStatus { initial, start, copying, success, failure }

class FileHomeCopyStatusUnit extends Equatable {
  final FileHomeCopyStatus status;
  final int current;
  final int total;
  final String fileName;
  final String? error;

  const FileHomeCopyStatusUnit({
    this.status = FileHomeCopyStatus.initial,
    this.current = 0,
    this.total = 0,
    this.fileName = '',
    this.error
  });

  @override
  List<Object?> get props => [status, current, total, fileName, error];
}

enum FileHomeSortColumn { name, size, type, modifyTime }

extension FileHomeSortColumnX on FileHomeSortColumn {
  static FileHomeSortColumn convertToColumn(int index) {
    try {
      FileHomeSortColumn column = FileHomeSortColumn.values.firstWhere((
          FileHomeSortColumn column) => column.index == index);
      return column;
    } catch (e) {
      return FileHomeSortColumn.name;
    }
  }
}

enum FileHomeSortDirection { ascending, descending }

class FileHomeState extends Equatable {
  final DisplayType displayType;
  final List<FileNode> files;
  final List<FileNode> checkedFiles;
  final FileHomeStatus status;
  final String? failureReason;
  final List<FileNode> dirStack;
  final FileHomeKeyStatus keyStatus;
  final FileNode? currentDir;
  final FileHomeOpenDirStatus? openDirStatus;
  final FileHomeRenameStatus? renameStatus;
  final FileHomeEnterTapStatus? enterTapStatus;
  final FileHomeDeleteStatus deleteStatus;
  final FileHomeMenuStatus menuStatus;
  final FileHomeCopyStatusUnit copyStatus;
  final FileNode? currentRenamingFile;
  final bool isRenamingMode;
  final String? newFileName;
  final FileHomeSortColumn sortColumn;
  final FileHomeSortDirection sortDirection;
  final bool isRootDir;

  FileHomeState({
    this.displayType = DisplayType.icon,
    this.files = const [],
    this.checkedFiles = const [],
    this.status = FileHomeStatus.initial,
    this.failureReason = null,
    this.dirStack = const [],
    this.keyStatus = FileHomeKeyStatus.none,
    this.currentDir = null,
    this.openDirStatus = FileHomeOpenDirStatus.initial,
    this.renameStatus = FileHomeRenameStatus.initial,
    this.enterTapStatus = FileHomeEnterTapStatus.none,
    this.deleteStatus = FileHomeDeleteStatus.initial,
    this.menuStatus = const FileHomeMenuStatus(isOpened: false),
    this.copyStatus = const FileHomeCopyStatusUnit(),
    this.currentRenamingFile = null,
    this.isRenamingMode = false,
    this.newFileName = null,
    this.sortColumn = FileHomeSortColumn.name,
    this.sortDirection = FileHomeSortDirection.descending,
    this.isRootDir = true
  });

  @override
  List<Object?> get props => [displayType, files, checkedFiles, status,
    failureReason, dirStack, keyStatus, currentDir, openDirStatus, renameStatus,
    enterTapStatus, deleteStatus, menuStatus, copyStatus, currentRenamingFile ,isRenamingMode,
    newFileName, sortColumn, sortDirection, isRootDir];

  FileHomeState copyWith({
    DisplayType? displayType,
    List<FileNode>? files,
    List<FileNode>? checkedFiles,
    FileHomeStatus? status,
    String? failureReason,
    List<FileNode>? dirStack,
    FileHomeKeyStatus? keyStatus,
    FileNode? currentDir,
    FileHomeOpenDirStatus? openDirStatus,
    FileHomeRenameStatus? renameStatus,
    FileHomeEnterTapStatus? enterTapStatus,
    FileHomeDeleteStatus? deleteStatus,
    FileHomeMenuStatus? menuStatus,
    FileHomeCopyStatusUnit? copyStatus,
    FileNode? currentRenamingFile,
    bool? isRenamingMode,
    String? newFileName,
    FileHomeSortColumn? sortColumn,
    FileHomeSortDirection? sortDirection,
    bool? isRootDir
  }) {
    return FileHomeState(
      displayType: displayType ?? this.displayType,
      files: files ?? this.files,
      checkedFiles: checkedFiles ?? this.checkedFiles,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      dirStack: dirStack ?? this.dirStack,
      keyStatus: keyStatus ?? this.keyStatus,
      currentDir: isRootDir == true ? null : (currentDir ?? this.currentDir),
      openDirStatus: openDirStatus ?? this.openDirStatus,
      renameStatus: renameStatus ?? this.renameStatus,
        enterTapStatus: enterTapStatus ?? this.enterTapStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      menuStatus: menuStatus ?? this.menuStatus,
      copyStatus: copyStatus ?? this.copyStatus,
      currentRenamingFile: currentRenamingFile ?? this.currentRenamingFile,
      isRenamingMode: isRenamingMode ?? this.isRenamingMode,
      newFileName: newFileName ?? this.newFileName,
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
      isRootDir: isRootDir ?? this.isRootDir
    );
  }
}