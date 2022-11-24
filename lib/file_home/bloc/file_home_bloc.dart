import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'dart:ui';

import 'package:air_controller/repository/root_dir_type.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/display_type.dart';
import '../../model/file_item.dart';
import '../../model/file_node.dart';
import '../../repository/file_repository.dart';
import '../../util/common_util.dart';

part 'file_home_event.dart';
part 'file_home_state.dart';

class FileHomeBloc extends Bloc<FileHomeEvent, FileHomeState> {
  final FileRepository _fileRepository;
  final bool isOnlyDownloadDir;

  FileHomeBloc(FileRepository fileRepository, bool isOnlyDownloadDir)
      : _fileRepository = fileRepository,
        isOnlyDownloadDir = isOnlyDownloadDir,
        super(FileHomeState()) {
    on<FileHomeDisplayTypeChanged>(_onDisplayTypeChanged);
    on<FileHomeSubscriptionRequested>(_onSubscriptionRequested);
    on<FileHomeCheckedChanged>(_onCheckedChanged);
    on<FileHomeKeyStatusChanged>(_onKeyStatusChanged);
    on<FileHomeOpenDir>(_onOpenDir);
    on<FileHomeClearChecked>(_onClearChecked);
    on<FileHomeRenameSubmitted>(_onRenameSubmitted);
    on<FileHomeEnterTapped>(_onEnterTapped);
    on<FileHomeDeleteSubmitted>(_onDeleteSubmitted);
    on<FileHomeExpandChildTree>(_onExpandChildTree);
    on<FileHomeFoldUpChildTree>(_onFoldUpTree);
    on<FileHomeMenuStatusChanged>(_onMenuStatusChanged);
    on<FileHomeRenameEnter>(_onRenameEnter);
    on<FileHomeRenameExit>(_onRenameExit);
    on<FileHomeNewNameChanged>(_onNewNameChanged);
    on<FileHomeCopySubmitted>(_onCopyFilesSubmitted);
    on<FileHomeCopyStatusChanged>(_onCopyStatusChanged);
    on<FileHomeCancelCopySubmitted>(_onCancelCopySubmitted);
    on<FileHomeBackToLastDir>(_onBackToLastDir);
    on<FileHomeSortInfoChanged>(_onSortInfoChanged);
    on<FileHomeDraggingUpdate>(_onDraggingUpdate);
    on<FileHomeUploadFiles>(_onUploadFiles);
    on<FileHomeUploadStatusChanged>(_onUploadStatusChanged);
    on<FileHomeDragToUploadStatusChanged>(_onDragToUploadStatusChanged);
    on<FileHomeSelectAll>(_onSelectAll);
    on<FileHomeDownloadToLocal>(_onDownloadToLocal);
  }

  void _onDisplayTypeChanged(
      FileHomeDisplayTypeChanged event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(displayType: event.displayType));
  }

  void _onSubscriptionRequested(
      FileHomeSubscriptionRequested event, Emitter<FileHomeState> emit) async {
    emit(state.copyWith(status: FileHomeStatus.loading));

    try {
      List<FileItem> files = [];

      if (isOnlyDownloadDir) {
        files = await _fileRepository.getDownloadFiles();
      } else {
        files = await _fileRepository.getFiles(null);
      }

      emit(state.copyWith(
          status: FileHomeStatus.success,
          files: files.map((file) => FileNode(null, file, 0)).toList()));
    } on Exception catch (e) {
      emit(state.copyWith(
          status: FileHomeStatus.failure,
          failureReason: CommonUtil.convertHttpError(e)));
    }
  }

  void _onCheckedChanged(
      FileHomeCheckedChanged event, Emitter<FileHomeState> emit) {
    List<FileNode> allFiles = state.files;
    List<FileNode> checkedFiles = [...state.checkedFiles];
    FileNode image = event.file;

    FileHomeKeyStatus keyStatus = state.keyStatus;

    if (!checkedFiles.contains(image)) {
      if (keyStatus == FileHomeKeyStatus.ctrlDown) {
        checkedFiles.add(image);
      } else if (keyStatus == FileHomeKeyStatus.shiftDown) {
        if (checkedFiles.length == 0) {
          checkedFiles.add(image);
        } else if (checkedFiles.length == 1) {
          int index = allFiles.indexOf(checkedFiles[0]);

          int current = allFiles.indexOf(image);

          if (current > index) {
            checkedFiles = allFiles.sublist(index, current + 1);
          } else {
            checkedFiles = allFiles.sublist(current, index + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < checkedFiles.length; i++) {
            FileNode current = checkedFiles[i];
            int index = allFiles.indexOf(current);
            if (index < 0) {
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          int current = allFiles.indexOf(image);

          if (current >= minIndex && current <= maxIndex) {
            checkedFiles = allFiles.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            checkedFiles = allFiles.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            checkedFiles = allFiles.sublist(minIndex, current + 1);
          }
        }
      } else {
        checkedFiles.clear();
        checkedFiles.add(image);
      }
    } else {
      if (keyStatus == FileHomeKeyStatus.ctrlDown) {
        checkedFiles.remove(image);
      } else if (keyStatus == FileHomeKeyStatus.shiftDown) {
        checkedFiles.remove(image);
      } else {
        checkedFiles.clear();
        checkedFiles.add(image);
      }
    }

    emit(state.copyWith(checkedFiles: checkedFiles));
  }

  void _onKeyStatusChanged(
      FileHomeKeyStatusChanged event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(keyStatus: event.status));
  }

  void _onOpenDir(FileHomeOpenDir event, Emitter<FileHomeState> emit) async {
    emit(state.copyWith(openDirStatus: FileHomeOpenDirStatus.loading));

    try {
      String path = "";

      FileNode? dir = event.dir;

      if (dir != null) {
        path = "${event.dir!.data.folder}/${event.dir!.data.name}";
      }

      List<FileItem> fileItems = [];

      if (dir != null) {
        fileItems = await _fileRepository.getFiles(path);
      } else {
        if (isOnlyDownloadDir) {
          fileItems = await _fileRepository.getDownloadFiles();
        } else {
          fileItems = await _fileRepository.getFiles(path);
        }
      }

      List<FileNode> dirStack = [...state.dirStack];

      if (dir == null) {
        dirStack.clear();
      } else {
        if (dirStack.contains(dir)) {
          int index = dirStack.indexOf(dir);

          dirStack = dirStack.sublist(0, index + 1);
        } else {
          dirStack = [...dirStack, dir];
        }
      }

      emit(state.copyWith(
          openDirStatus: FileHomeOpenDirStatus.success,
          currentDir: event.dir,
          files: fileItems
              .map((item) => FileNode(event.dir, item,
                  event.dir == null ? 1 : event.dir!.level + 1))
              .toList(),
          dirStack: dirStack,
          isRootDir: event.dir == null));
    } on Exception catch (e) {
      emit(state.copyWith(
          openDirStatus: FileHomeOpenDirStatus.failure,
          failureReason: CommonUtil.convertHttpError(e)));
    }
  }

  void _onClearChecked(
      FileHomeClearChecked event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(checkedFiles: []));
  }

  void _onRenameSubmitted(
      FileHomeRenameSubmitted event, Emitter<FileHomeState> emit) async {
    emit(state.copyWith(renameStatus: FileHomeRenameStatus.loading));

    try {
      await _fileRepository.rename(event.file.data, event.newName);

      List<FileNode> files = [...state.files];
      List<FileNode> checkedFiles = state.checkedFiles;

      FileNode file = event.file;

      int index = files.indexOf(file);
      if (index != -1) {
        file.data.name = event.newName;

        files.replaceRange(index, index + 1, [file]);
      }

      index = checkedFiles.indexOf(file);
      if (index != -1) {
        file.data.name = event.newName;

        checkedFiles.replaceRange(index, index + 1, [file]);
      }

      emit(state.copyWith(
          renameStatus: FileHomeRenameStatus.success,
          files: files,
          checkedFiles: checkedFiles,
          isRenamingMode: false));
    } on Exception catch (e) {
      emit(state.copyWith(
          renameStatus: FileHomeRenameStatus.failure,
          failureReason: CommonUtil.convertHttpError(e)));
    }
  }

  void _onEnterTapped(FileHomeEnterTapped event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(enterTapStatus: FileHomeEnterTapStatus.tap));
    emit(state.copyWith(enterTapStatus: FileHomeEnterTapStatus.none));
  }

  void _onDeleteSubmitted(
      FileHomeDeleteSubmitted event, Emitter<FileHomeState> emit) async {
    emit(state.copyWith(deleteStatus: FileHomeDeleteStatus.loading));

    try {
      await _fileRepository.deleteFiles(event.files
          .map((file) => "${file.data.folder}/${file.data.name}")
          .toList());

      List<FileNode> files = [...state.files];
      List<FileNode> checkedFiles = [...state.checkedFiles];

      files.removeWhere((file) => event.files.contains(file));
      checkedFiles.removeWhere((file) => event.files.contains(file));

      emit(state.copyWith(
          deleteStatus: FileHomeDeleteStatus.success,
          files: files,
          checkedFiles: checkedFiles));
    } on Exception catch (e) {
      emit(state.copyWith(
          deleteStatus: FileHomeDeleteStatus.failure,
          failureReason: CommonUtil.convertHttpError(e)));
    }
  }

  void _onExpandChildTree(
      FileHomeExpandChildTree event, Emitter<FileHomeState> emit) async {
    try {
      String path = "${event.file.data.folder}/${event.file.data.name}";
      List<FileItem> files = await _fileRepository.getFiles(path);

      List<FileNode> allFiles = [...state.files];

      int index = allFiles.indexWhere((file) =>
          "${file.data.folder}/${file.data.name}" ==
          "${event.file.data.folder}/${event.file.data.name}");

      if (index >= 0) {
        allFiles.insertAll(index + 1, files.map((file) {
          FileNode fileNode = FileNode(event.file, file, event.file.level + 1);

          return fileNode;
        }));

        FileNode current = allFiles[index];
        current.isExpand = true;
      }

      emit(state.copyWith(files: allFiles));
    } catch (e) {
      log("_onExpandChildTree, failure: ${e.toString()}");
    }
  }

  void _onFoldUpTree(
      FileHomeFoldUpChildTree event, Emitter<FileHomeState> emit) async {
    List<FileNode> allFiles = [...state.files];

    allFiles.removeWhere((node) => _isChild(event.file, node));
    event.file.isExpand = false;

    emit(state.copyWith(files: allFiles));
  }

  bool _isChild(FileNode parent, FileNode node) {
    FileNode? currentFolder = node.parent;

    while (currentFolder != null) {
      if (currentFolder == parent) return true;

      currentFolder = currentFolder.parent;
    }

    return false;
  }

  void _onMenuStatusChanged(
      FileHomeMenuStatusChanged event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(menuStatus: event.status));
  }

  void _onRenameEnter(FileHomeRenameEnter event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(
        isRenamingMode: true,
        currentRenamingFile: event.file,
        newFileName: event.file.data.name));
  }

  void _onRenameExit(FileHomeRenameExit event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(isRenamingMode: false));
  }

  void _onNewNameChanged(
      FileHomeNewNameChanged event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(newFileName: event.name));
  }

  void _onCopyFilesSubmitted(
      FileHomeCopySubmitted event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(
        copyStatus: FileHomeCopyStatusUnit(status: FileHomeCopyStatus.start)));

    String? fileName = null;

    if (event.files.length == 1) {
      fileName = "${event.files.single.data.name}.zip";
    }

    _fileRepository.copyFilesTo(
        fileName: fileName,
        paths: event.files
            .map((file) => "${file.data.folder}/${file.data.name}")
            .toList(),
        dir: event.dir,
        onProgress: (fileName, current, total) {
          add(FileHomeCopyStatusChanged(FileHomeCopyStatusUnit(
              status: FileHomeCopyStatus.copying,
              fileName: fileName,
              current: current,
              total: total)));
        },
        onDone: (fileName) {
          add(FileHomeCopyStatusChanged(FileHomeCopyStatusUnit(
              status: FileHomeCopyStatus.success, fileName: fileName)));
        },
        onError: (String error) {
          add(FileHomeCopyStatusChanged(FileHomeCopyStatusUnit(
              status: FileHomeCopyStatus.failure, error: error)));
        });
  }

  void _onCopyStatusChanged(
      FileHomeCopyStatusChanged event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(copyStatus: event.status));
  }

  void _onCancelCopySubmitted(
      FileHomeCancelCopySubmitted event, Emitter<FileHomeState> emit) {
    _fileRepository.cancelCopy();
    emit(state.copyWith(copyStatus: FileHomeCopyStatusUnit()));
  }

  void _onBackToLastDir(
      FileHomeBackToLastDir event, Emitter<FileHomeState> emit) async {
    List<FileNode> dirStack = [...state.dirStack];

    if (dirStack.isEmpty) {
      log("warn: Dir stack is empty.");
      return;
    }

    FileNode? lastDir = null;

    if (dirStack.length > 1) {
      lastDir = dirStack[dirStack.length - 2];
    }

    emit(state.copyWith(openDirStatus: FileHomeOpenDirStatus.loading));

    try {
      List<FileItem> files = await _fileRepository.getFiles(lastDir == null
          ? null
          : "${lastDir.data.folder}/${lastDir.data.name}");

      dirStack.removeAt(dirStack.length - 1);

      emit(state.copyWith(
          files: files
              .map((file) => FileNode(
                  lastDir, file, lastDir == null ? 0 : lastDir.level + 1))
              .toList(),
          dirStack: dirStack,
          openDirStatus: FileHomeOpenDirStatus.success,
          currentDir: lastDir,
          isRootDir: lastDir == null));
    } on Exception catch (e) {
      log("_onBackToLastDir, failure: ${e.toString()}");
      emit(state.copyWith(
          openDirStatus: FileHomeOpenDirStatus.failure,
          failureReason: CommonUtil.convertHttpError(e)));
    }
  }

  void _onSortInfoChanged(
      FileHomeSortInfoChanged event, Emitter<FileHomeState> emit) {
    if (state.sortColumn == event.sortColumn &&
        state.sortDirection == event.sortDirection) {
      log("_onSortInfoChanged, sort info is not changed");
      return;
    }

    List<FileNode> allFileNodes = state.files;
    FileNode? currentDir = state.currentDir;

    FileHomeSortColumn sortColumn = event.sortColumn;
    FileHomeSortDirection sortDirection = event.sortDirection;

    // 1.找到当前节点下的所有节点
    List<FileNode> directedChildNodes =
        allFileNodes.where((element) => element.parent == currentDir).toList();

    int _sortFile(FileNode nodeA, FileNode nodeB, FileHomeSortColumn column,
        FileHomeSortDirection direction) {
      if (sortColumn == FileHomeSortColumn.name) {
        // 如果节点是目录，应该始终排在前面
        if (nodeA.data.isDir && !nodeB.data.isDir) return -1;
        if (!nodeA.data.isDir && nodeB.data.isDir) return 1;

        if (sortDirection == FileHomeSortDirection.ascending) {
          return nodeA.data.name.compareTo(nodeB.data.name);
        } else {
          return nodeB.data.name.compareTo(nodeA.data.name);
        }
      }

      if (sortColumn == FileHomeSortColumn.size) {
        // 如果节点是目录，应该始终排在前面
        if (nodeA.data.isDir && !nodeB.data.isDir) return -1;
        if (!nodeA.data.isDir && nodeB.data.isDir) return 1;

        if (sortDirection == FileHomeSortDirection.ascending) {
          return nodeA.data.size.compareTo(nodeB.data.size);
        } else {
          return nodeB.data.size.compareTo(nodeA.data.size);
        }
      }

      if (sortColumn == FileHomeSortColumn.modifyTime) {
        // 如果节点是目录，应该始终排在前面
        if (nodeA.data.isDir && !nodeB.data.isDir) return -1;
        if (!nodeA.data.isDir && nodeB.data.isDir) return 1;

        if (sortDirection == FileHomeSortDirection.ascending) {
          return nodeA.data.changeDate.compareTo(nodeB.data.changeDate);
        } else {
          return nodeB.data.changeDate.compareTo(nodeA.data.changeDate);
        }
      }

      return 0;
    }

    directedChildNodes.sort((nodeA, nodeB) {
      return _sortFile(nodeA, nodeB, sortColumn, sortDirection);
    });

    if (directedChildNodes.length < allFileNodes.length) {
      // 2.获取最大的层级值，依次循环插入
      int maxLevel = allFileNodes.map((e) => e.level).toList().reduce(max);

      int currentLevel = currentDir == null ? 0 : currentDir.level;

      while (currentLevel < maxLevel) {
        currentLevel++;

        List<FileNode> nodes = allFileNodes
            .where((element) => element.level == currentLevel)
            .toList();

        // 3.根据不同父节点进行分组
        Map<FileNode, List<FileNode>> groupFileNodes = new Map();

        nodes.forEach((node) {
          List<FileNode>? tempNodes = groupFileNodes[node.parent];

          if (null == tempNodes) {
            tempNodes = [];
          }

          tempNodes.add(node);

          groupFileNodes[node.parent!] = tempNodes;
        });

        // 4.将分组后的节点依次排序并插入到父节点位置处
        groupFileNodes.forEach((parent, childNodes) {
          childNodes.sort((nodeA, nodeB) {
            return _sortFile(nodeA, nodeB, sortColumn, sortDirection);
          });

          int index = directedChildNodes.indexOf(parent);
          if (index != -1) {
            directedChildNodes.insertAll(index + 1, childNodes);
          }
        });
      }
    }

    emit(state.copyWith(
        files: directedChildNodes,
        sortColumn: sortColumn,
        sortDirection: sortDirection));
  }

  void _onDraggingUpdate(
      FileHomeDraggingUpdate event, Emitter<FileHomeState> emit) {
    if (event.isDraggingToRoot != state.isDraggingToRoot ||
        event.currentDraggingTarget != state.currentDraggingTarget) {
      emit(state.copyWith(
          isDraggingToRoot: event.isDraggingToRoot,
          currentDraggingTarget: event.currentDraggingTarget));
    }
  }

  void _onUploadFiles(FileHomeUploadFiles event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(
        uploadStatus:
            FileHomeUploadStatusUnit(status: FileHomeUploadStatus.start)));

    final rootDirType =
        isOnlyDownloadDir ? RootDirType.downloadDir : RootDirType.sdcard;
    _fileRepository.uploadFiles(
        rootDirType: rootDirType,
        files: event.files,
        folder: event.folder,
        onError: (msg) {
          add(FileHomeUploadStatusChanged(FileHomeUploadStatusUnit(
              status: FileHomeUploadStatus.failure, failureReason: msg)));
        },
        onUploading: (sent, total) {
          add(FileHomeUploadStatusChanged(FileHomeUploadStatusUnit(
              status: FileHomeUploadStatus.uploading,
              current: sent,
              total: total)));
        },
        onSuccess: () {
          add(FileHomeUploadStatusChanged(
              FileHomeUploadStatusUnit(status: FileHomeUploadStatus.success)));
        });
  }

  void _onUploadStatusChanged(
      FileHomeUploadStatusChanged event, Emitter<FileHomeState> emit) async {
    emit(state.copyWith(uploadStatus: event.status));

    // Refresh the file list after upload finished if it's uploading to current folder.
    if (event.status.status == FileHomeUploadStatus.success &&
        state.isDraggingToRoot) {
      final currentDir = state.currentDir;

      final files = [];

      if (currentDir == null) {
        if (isOnlyDownloadDir) {
          final fileItems = await _fileRepository.getDownloadFiles();
          files.addAll(fileItems);
        } else {
          final fileItems =
              await _fileRepository.getFiles(currentDir?.data.path);
          files.addAll(fileItems);
        }
      } else {
        final fileItems = await _fileRepository.getFiles(currentDir.data.path);
        files.addAll(fileItems);
      }

      final fileNodes = files
          .map((item) => FileNode(
              currentDir, item, currentDir == null ? 1 : currentDir.level + 1))
          .toList();
      emit(state.copyWith(files: fileNodes));
    }
  }

  void _onDragToUploadStatusChanged(
      FileHomeDragToUploadStatusChanged event, Emitter<FileHomeState> emit) {
    emit(state.copyWith(dragToUploadStatus: event.status));
  }

  void _onSelectAll(FileHomeSelectAll event, Emitter<FileHomeState> emit) {
    final checkedFiles = [...state.files];
    emit(state.copyWith(checkedFiles: checkedFiles));
  }

  FutureOr<void> _onDownloadToLocal(
      FileHomeDownloadToLocal event, Emitter<FileHomeState> emit) async {
    emit(state.copyWith(showLoading: true));

    try {
      final bytes = await _fileRepository
          .readAsBytes(event.files.map((e) => e.data).toList());

      String fileName = "";
      if (event.files.length == 1) {
        final singleFile = event.files.first.data;
        fileName = singleFile.name;

        if (singleFile.isDir) {
          fileName = "$fileName.zip";
        }
      } else if (event.files.length > 1) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        fileName = "files_$timestamp.zip";
      }
      CommonUtil.downloadAsWebFile(bytes: bytes, fileName: fileName);

      emit(state.copyWith(showLoading: false));
    } catch (e) {
      emit(state.copyWith(
          showLoading: false, showError: true, errorMessage: e.toString()));
    }
  }
}
