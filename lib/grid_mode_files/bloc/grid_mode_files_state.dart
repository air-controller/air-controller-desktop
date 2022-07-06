// import 'dart:ui';

// import 'package:equatable/equatable.dart';

// import '../../model/file_node.dart';

// class GridModeFilesMenuStatus extends Equatable {
//   final bool isOpened;
//   final Offset? position;
//   final FileNode? current;

//   const GridModeFilesMenuStatus(
//       {this.isOpened = false, this.position = null, this.current = null});

//   @override
//   List<Object?> get props => [isOpened, position, current];
// }

// enum GridModeFilesCopyStatus { initial, start, copying, success, failure }

// class GridModeFilesCopyStatusUnit extends Equatable {
//   final GridModeFilesCopyStatus status;
//   final int current;
//   final int total;
//   final String fileName;
//   final String? error;

//   const GridModeFilesCopyStatusUnit(
//       {this.status = GridModeFilesCopyStatus.initial,
//       this.current = 0,
//       this.total = 0,
//       this.fileName = '',
//       this.error});

//   @override
//   List<Object?> get props => [status, current, total, fileName, error];
// }

// class GridModeFilesState extends Equatable {
//   final GridModeFilesMenuStatus menuStatus;
//   final FileNode? currentRenamingFile;
//   final bool isRenamingMode;
//   final String? newFileName;
//   final GridModeFilesCopyStatusUnit copyStatus;
//   final bool enableRootDrop;

//   const GridModeFilesState(
//       {this.menuStatus = const GridModeFilesMenuStatus(),
//       this.currentRenamingFile = null,
//       this.isRenamingMode = false,
//       this.newFileName = null,
//       this.copyStatus = const GridModeFilesCopyStatusUnit(),
//       this.enableRootDrop = true});

//   @override
//   List<Object?> get props => [
//         menuStatus,
//         currentRenamingFile,
//         isRenamingMode,
//         newFileName,
//         copyStatus,
//         enableRootDrop
//       ];

//   GridModeFilesState copyWith(
//       {GridModeFilesMenuStatus? openMenuStatus,
//       FileNode? currentRenamingFile,
//       bool? isRenamingMode,
//       String? newFileName,
//       GridModeFilesCopyStatusUnit? copyStatus,
//       bool? enableRootDrop}) {
//     return GridModeFilesState(
//         menuStatus: openMenuStatus ?? this.menuStatus,
//         currentRenamingFile: currentRenamingFile ?? this.currentRenamingFile,
//         isRenamingMode: isRenamingMode ?? this.isRenamingMode,
//         newFileName: newFileName ?? this.newFileName,
//         copyStatus: copyStatus ?? this.copyStatus,
//         enableRootDrop: enableRootDrop ?? this.enableRootDrop);
//   }
// }
