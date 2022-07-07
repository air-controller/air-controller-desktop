part of 'file_home_bloc.dart';

class FileHomeEvent extends Equatable {
  const FileHomeEvent();

  @override
  List<Object?> get props => [];
}

class FileHomeDisplayTypeChanged extends FileHomeEvent {
  final DisplayType displayType;

  const FileHomeDisplayTypeChanged(this.displayType);

  @override
  List<Object?> get props => [displayType];
}

class FileHomeSubscriptionRequested extends FileHomeEvent {
  const FileHomeSubscriptionRequested();
}

class FileHomeCheckedChanged extends FileHomeEvent {
  final FileNode file;

  const FileHomeCheckedChanged(this.file);

  @override
  List<Object?> get props => [file];
}

class FileHomeKeyStatusChanged extends FileHomeEvent {
  final FileHomeKeyStatus status;

  const FileHomeKeyStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class FileHomeOpenDir extends FileHomeEvent {
  final FileNode? dir;

  const FileHomeOpenDir(this.dir);

  @override
  List<Object?> get props => [dir];
}

class FileHomeClearChecked extends FileHomeEvent {
  const FileHomeClearChecked();
}

class FileHomeRenameSubmitted extends FileHomeEvent {
  final FileNode file;
  final String newName;

  const FileHomeRenameSubmitted(this.file, this.newName);

  @override
  List<Object?> get props => [file, newName];
}

class FileHomeEnterTapped extends FileHomeEvent {
  const FileHomeEnterTapped();
}

class FileHomeDeleteSubmitted extends FileHomeEvent {
  final List<FileNode> files;

  const FileHomeDeleteSubmitted(this.files);

  @override
  List<Object?> get props => [files];
}

class FileHomeExpandChildTree extends FileHomeEvent {
  final FileNode file;

  const FileHomeExpandChildTree(this.file);

  @override
  List<Object?> get props => [file];
}

class FileHomeFoldUpChildTree extends FileHomeEvent {
  final FileNode file;

  const FileHomeFoldUpChildTree(this.file);

  @override
  List<Object?> get props => [file];
}

class FileHomeMenuStatusChanged extends FileHomeEvent {
  final FileHomeMenuStatus status;

  const FileHomeMenuStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class FileHomeRenameEnter extends FileHomeEvent {
  final FileNode file;

  const FileHomeRenameEnter(this.file);

  @override
  List<Object?> get props => [file];
}

class FileHomeRenameExit extends FileHomeEvent {
  const FileHomeRenameExit();
}

class FileHomeNewNameChanged extends FileHomeEvent {
  final String name;

  const FileHomeNewNameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class FileHomeCopySubmitted extends FileHomeEvent {
  final List<FileNode> files;
  final String dir;

  const FileHomeCopySubmitted(this.files, this.dir);

  @override
  List<Object?> get props => [files, dir];
}

class FileHomeCopyStatusChanged extends FileHomeEvent {
  final FileHomeCopyStatusUnit status;

  const FileHomeCopyStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class FileHomeCancelCopySubmitted extends FileHomeEvent {
  const FileHomeCancelCopySubmitted();
}

class FileHomeBackToLastDir extends FileHomeEvent {
  const FileHomeBackToLastDir();
}

class FileHomeSortInfoChanged extends FileHomeEvent {
  final FileHomeSortColumn sortColumn;
  final FileHomeSortDirection sortDirection;

  const FileHomeSortInfoChanged(this.sortColumn, this.sortDirection);

  @override
  List<Object?> get props => [sortColumn, sortDirection];
}

class FileHomeDraggingUpdate extends FileHomeEvent {
  final bool isDraggingToRoot;
  final FileNode? currentDraggingTarget;

  const FileHomeDraggingUpdate(
      this.isDraggingToRoot, this.currentDraggingTarget);

  @override
  List<Object?> get props => [isDraggingToRoot, currentDraggingTarget];
}

class FileHomeUploadFiles extends FileHomeEvent {
  final List<File> files;
  final String? folder;

  const FileHomeUploadFiles(this.files, this.folder);

  @override
  List<Object?> get props => [files, folder];
}

class FileHomeUploadStatusChanged extends FileHomeEvent {
  final FileHomeUploadStatusUnit status;

  const FileHomeUploadStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class FileHomeDragToUploadStatusChanged extends FileHomeEvent {
  final DragToUploadStatus status;

  const FileHomeDragToUploadStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}