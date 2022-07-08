import 'dart:io';

import 'package:air_controller/ext/build_context_x.dart';
import 'package:air_controller/ext/global_key_x.dart';
import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bootstrap.dart';
import '../../file_home/bloc/file_home_bloc.dart';
import '../../home/bloc/home_bloc.dart';
import '../../model/display_type.dart';
import '../../model/file_item.dart';
import '../../model/file_node.dart';
import '../../util/common_util.dart';
import '../../util/sound_effect.dart';
import '../../util/system_app_launcher.dart';
import '../model/data_row_key.dart';

class ListModeFilesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileHomeBloc>(
      create: (context) => context.read<FileHomeBloc>(),
      child: ListModeFilesView(),
    );
  }
}

class ListModeFilesView extends StatelessWidget {
  final _INDENT_STEP = 10.0;
  final _dataRowKeys = Map<FileNode, DataRowKey>();

  @override
  Widget build(BuildContext context) {
    TextStyle headerStyle = TextStyle(fontSize: 14, color: Colors.black);

    List<FileNode> files =
        context.select((FileHomeBloc bloc) => bloc.state.files);
    List<FileNode> checkedFiles =
        context.select((FileHomeBloc bloc) => bloc.state.checkedFiles);
    FileNode? currentRenamingFile =
        context.select((FileHomeBloc bloc) => bloc.state.currentRenamingFile);
    bool isRenamingMode =
        context.select((FileHomeBloc bloc) => bloc.state.isRenamingMode);
    FileHomeSortColumn sortColumn =
        context.select((FileHomeBloc bloc) => bloc.state.sortColumn);
    FileHomeSortDirection sortDirection =
        context.select((FileHomeBloc bloc) => bloc.state.sortDirection);
    FileNode? currentDir =
        context.select((FileHomeBloc bloc) => bloc.state.currentDir);
    bool isRootDir =
        context.select((FileHomeBloc bloc) => bloc.state.isRootDir);

    Visibility getRightArrowIcon(int index, FileNode node) {
      String iconPath = "";

      if (checkedFiles.contains(node)) {
        if (node.isExpand) {
          iconPath = "assets/icons/icon_down_arrow_selected.png";
        } else {
          iconPath = "assets/icons/icon_right_arrow_selected.png";
        }
      } else {
        if (node.isExpand) {
          iconPath = "assets/icons/icon_down_arrow_normal.png";
        } else {
          iconPath = "assets/icons/icon_right_arrow_normal.png";
        }
      }

      Image icon = Image.asset(iconPath, width: 20, height: 20);

      double indent = 0;

      if (null == currentDir || isRootDir) {
        indent = node.level * _INDENT_STEP;
      } else {
        indent = (node.level - currentDir.level - 1) * _INDENT_STEP;
      }

      return Visibility(
          child: GestureDetector(
              child: Container(
                  child: icon, padding: EdgeInsets.only(left: indent)),
              onTap: () {
                debugPrint("Expand folder...");
                if (!node.isExpand) {
                  context
                      .read<FileHomeBloc>()
                      .add(FileHomeExpandChildTree(node));
                } else {
                  context
                      .read<FileHomeBloc>()
                      .add(FileHomeFoldUpChildTree(node));
                }
              }),
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          visible: node.data.isDir);
    }

    Image getFileTypeIcon(FileItem fileItem) {
      if (fileItem.isDir) {
        return Image.asset("assets/icons/icon_folder.png",
            width: 20, height: 20);
      }

      String name = fileItem.name.toLowerCase();

      if (name.endsWith(".jpg") ||
          name.endsWith(".jpeg") ||
          name.endsWith(".png")) {
        return Image.asset("assets/icons/icon_file_type_image.png",
            width: 20, height: 20);
      }

      if (name.endsWith(".mp3")) {
        return Image.asset("assets/icons/icon_file_type_audio.png",
            width: 20, height: 20);
      }

      if (name.endsWith(".txt")) {
        return Image.asset("assets/icons/icon_file_type_text.png",
            width: 20, height: 20);
      }

      return Image.asset("assets/icons/icon_file_type_doc.png",
          width: 20, height: 20);
    }

    List<DataRow> _generateRows() {
      return List<DataRow>.generate(files.length, (int index) {
        FileNode file = files[index];

        TextStyle textStyle = _getRowTextStyle(context, file);

        final inputController = TextEditingController();

        inputController.text = file.data.name;

        final focusNode = FocusNode();

        focusNode.addListener(() {
          if (focusNode.hasFocus) {
            inputController.selection = TextSelection(
                baseOffset: 0, extentOffset: inputController.text.length);
          }
        });

        final key1 = GlobalKey();
        final key2 = GlobalKey();
        final key3 = GlobalKey();
        final key4 = GlobalKey();

        _dataRowKeys[file] = DataRowKey(key1, key2, key3, key4);

        return DataRow2(
          cells: [
            DataCell(Listener(
              child: Container(
                key: key1,
                child: Row(children: [
                  getRightArrowIcon(0, file),
                  getFileTypeIcon(file.data),
                  SizedBox(width: 10.0),
                  Flexible(
                    child: Stack(
                      children: [
                        Visibility(
                          child: Text(file.data.name,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: textStyle),
                          visible: isRenamingMode
                              ? currentRenamingFile != file
                              : true,
                        ),
                        Visibility(
                          child: Container(
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: inputController,
                                focusNode: focusNode,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffcccbcd),
                                            width: 3,
                                            style: BorderStyle.solid)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffcccbcd),
                                            width: 3,
                                            style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(4)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Color(0xffcccbcd),
                                            width: 4,
                                            style: BorderStyle.solid),
                                        borderRadius: BorderRadius.circular(4)),
                                    contentPadding:
                                        EdgeInsets.fromLTRB(8, 3, 8, 3)),
                                cursorColor: Color(0xff333333),
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xff333333)),
                                onChanged: (value) {
                                  context
                                      .read<FileHomeBloc>()
                                      .add(FileHomeNewNameChanged(value));
                                },
                              ),
                            ),
                            height: 30,
                            color: Colors.white,
                          ),
                          visible: isRenamingMode
                              ? currentRenamingFile == file
                              : false,
                          maintainState: false,
                          maintainSize: false,
                        )
                      ],
                    ),
                  )
                ]),
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
              onPointerDown: (event) {
                _tryToOpenMenu(context, event, file);
              },
            )),
            DataCell(Listener(
              child: Container(
                key: key2,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(
                    file.data.isDir
                        ? "--"
                        : CommonUtil.convertToReadableSize(file.data.size),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle),
                color: Colors.transparent,
              ),
              onPointerDown: (event) {
                _tryToOpenMenu(context, event, file);
              },
            )),
            DataCell(Listener(
              child: Container(
                key: key3,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(_convertToCategory(context, file.data),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle),
                color: Colors.transparent,
              ),
              onPointerDown: (event) {
                _tryToOpenMenu(context, event, file);
              },
            )),
            DataCell(Listener(
              child: Container(
                key: key4,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(_formatTime(context, file.data.changeDate),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle),
                color: Colors.transparent,
              ),
              onPointerDown: (event) {
                _tryToOpenMenu(context, event, file);
              },
            )),
          ],
          color: _getDataRowColor(context, file),
          selected: checkedFiles.contains(file),
          onSelectChanged: (isSelected) {
            debugPrint("onSelectChanged: $isSelected");
          },
          onTap: () {
            context.read<FileHomeBloc>().add(FileHomeCheckedChanged(file));

            FileNode? currentRenamingFile =
                context.read<FileHomeBloc>().state.currentRenamingFile;
            if (currentRenamingFile != file) {
              context.read<FileHomeBloc>().add(FileHomeRenameExit());
            }
          },
          onDoubleTap: () {
            if (file.data.isDir) {
              context.read<FileHomeBloc>().add(FileHomeOpenDir(file));
            } else {
              SystemAppLauncher.openFile(file.data);
            }
          },
        );
      });
    }

    return DropTarget(
        enable: _isShowing(context),
        onDragEntered: (details) {
          _updateDraggingStatus(context, details);
          context
              .read<FileHomeBloc>()
              .add(FileHomeDragToUploadStatusChanged(DragToUploadStatus.enter));
        },
        onDragExited: (details) {
          context
              .read<FileHomeBloc>()
              .add(FileHomeDragToUploadStatusChanged(DragToUploadStatus.exit));
        },
        onDragDone: (details) {
          final files = details.files.map((e) => File(e.path)).toList();

          if (files.isEmpty) {
            logger.d("Selected files is empty");
            return;
          }

          final currentDraggingTarget =
              context.read<FileHomeBloc>().state.currentDraggingTarget;
          final isDraggingToRoot =
              context.read<FileHomeBloc>().state.isDraggingToRoot;

          if (isDraggingToRoot) {
            final currentDir = context.read<FileHomeBloc>().state.currentDir;
            context
                .read<FileHomeBloc>()
                .add(FileHomeUploadFiles(files, currentDir?.data.path));
          } else {
            context.read<FileHomeBloc>().add(
                FileHomeUploadFiles(files, currentDraggingTarget?.data.path));
          }
        },
        onDragUpdated: (details) {
          _updateDraggingStatus(context, details);
        },
        child: GestureDetector(
          child: SizedBox(
            child: DataTable2(
              dividerThickness: 1,
              bottomMargin: 10,
              columnSpacing: 0,
              sortColumnIndex: sortColumn.index,
              sortAscending: sortDirection == FileHomeSortDirection.ascending,
              showCheckboxColumn: false,
              showBottomBorder: false,
              scrollController: ScrollController(),
              columns: [
                DataColumn2(
                    label: Container(
                      child: Text(
                        context.l10n.name,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onSort: (sortColumnIndex, isSortAscending) {
                      FileHomeSortColumn sortColumn =
                          FileHomeSortColumnX.convertToColumn(sortColumnIndex);
                      FileHomeSortDirection sortDirection = isSortAscending
                          ? FileHomeSortDirection.ascending
                          : FileHomeSortDirection.descending;

                      context.read<FileHomeBloc>().add(
                          FileHomeSortInfoChanged(sortColumn, sortDirection));
                    },
                    size: ColumnSize.L),
                DataColumn2(
                    label: Container(
                        child: Text(
                          context.l10n.size,
                          textAlign: TextAlign.center,
                        ),
                        padding: EdgeInsets.only(left: 15)),
                    onSort: (sortColumnIndex, isSortAscending) {
                      FileHomeSortColumn sortColumn =
                          FileHomeSortColumnX.convertToColumn(sortColumnIndex);
                      FileHomeSortDirection sortDirection = isSortAscending
                          ? FileHomeSortDirection.ascending
                          : FileHomeSortDirection.descending;

                      context.read<FileHomeBloc>().add(
                          FileHomeSortInfoChanged(sortColumn, sortDirection));
                    }),
                DataColumn2(
                    label: Container(
                  child: Text(
                    context.l10n.type,
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.only(left: 15),
                )),
                DataColumn2(
                    label: Container(
                      child: Text(
                        context.l10n.dateModified,
                        textAlign: TextAlign.center,
                      ),
                      padding: EdgeInsets.only(left: 15),
                    ),
                    onSort: (sortColumnIndex, isSortAscending) {
                      FileHomeSortColumn sortColumn =
                          FileHomeSortColumnX.convertToColumn(sortColumnIndex);
                      FileHomeSortDirection sortDirection = isSortAscending
                          ? FileHomeSortDirection.ascending
                          : FileHomeSortDirection.descending;

                      context.read<FileHomeBloc>().add(
                          FileHomeSortInfoChanged(sortColumn, sortDirection));
                    })
              ],
              rows: _generateRows(),
              headingRowHeight: 40,
              headingTextStyle: headerStyle,
              onSelectAll: (val) {},
              empty: Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.green[200],
                  child: Text("No files"),
                ),
              ),
            ),
            width: double.infinity,
            height: double.infinity,
          ),
          onTap: () {
            context.read<FileHomeBloc>().add(FileHomeClearChecked());
            context.read<FileHomeBloc>().add(FileHomeRenameExit());
          },
        ));
  }

  MaterialStateProperty<Color?>? _getDataRowColor(
      BuildContext context, FileNode fileNode) {
    final bool isDraggingToRoot =
        context.select((FileHomeBloc bloc) => bloc.state.isDraggingToRoot);
    final FileNode? currentDraggingTarget =
        context.select((FileHomeBloc bloc) => bloc.state.currentDraggingTarget);
    final dragToUploadStatus =
        context.select((FileHomeBloc bloc) => bloc.state.dragToUploadStatus);

    if (dragToUploadStatus == DragToUploadStatus.enter &&
        !isDraggingToRoot &&
        fileNode == currentDraggingTarget) {
      return MaterialStateProperty.all(Colors.lightBlue);
    }

    return MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return Color(0xff5e86ec);
      }

      if (states.any([MaterialState.hovered, MaterialState.focused].contains)) {
        return Color(0x22000000);
      }

      return null;
    });
  }

  TextStyle _getRowTextStyle(BuildContext context, FileNode file) {
    final checkedFiles =
        context.select((FileHomeBloc bloc) => bloc.state.checkedFiles);
    final bool isDraggingToRoot =
        context.select((FileHomeBloc bloc) => bloc.state.isDraggingToRoot);
    final FileNode? currentDraggingTarget =
        context.select((FileHomeBloc bloc) => bloc.state.currentDraggingTarget);
    final dragToUploadStatus =
        context.select((FileHomeBloc bloc) => bloc.state.dragToUploadStatus);

    Color textColor = Color(0xff313237);

    if ((dragToUploadStatus == DragToUploadStatus.enter &&
            !isDraggingToRoot &&
            file == currentDraggingTarget) ||
        checkedFiles.contains(file)) {
      textColor = Colors.white;
    }

    TextStyle textStyle = TextStyle(fontSize: 14, color: textColor);

    return textStyle;
  }

  void _updateDraggingStatus(BuildContext context, DropEventDetails details) {
    final globalPosition = details.globalPosition;

    bool isHitedDir = false;

    final isDraggingToRoot =
        context.read<FileHomeBloc>().state.isDraggingToRoot;
    final currentDraggingTarget =
        context.read<FileHomeBloc>().state.currentDraggingTarget;

    for (int i = 0; i < _dataRowKeys.length; i++) {
      final fileNode = _dataRowKeys.keys.elementAt(i);
      final dataRowKey = _dataRowKeys.values.elementAt(i);

      if (_dataRowContains(dataRowKey, globalPosition) && fileNode.data.isDir) {
        if (isDraggingToRoot ||
            (!isDraggingToRoot && currentDraggingTarget != fileNode)) {
          context
              .read<FileHomeBloc>()
              .add(FileHomeDraggingUpdate(false, fileNode));
          SoundEffect.play(SoundType.bubble);
        }
        isHitedDir = true;
        break;
      }
    }

    if (!isHitedDir && !isDraggingToRoot) {
      context.read<FileHomeBloc>().add(FileHomeDraggingUpdate(true, null));
    }
  }

  bool _isShowing(BuildContext context) {
    final homeTab = context.read<HomeBloc>().state.tab;
    final displayType = context.read<FileHomeBloc>().state.displayType;

    final isOnlyDownloadDir = context.read<FileHomeBloc>().isOnlyDownloadDir;

    if (isOnlyDownloadDir &&
        homeTab == HomeTab.download &&
        displayType == DisplayType.list) {
      return true;
    }

    if (!isOnlyDownloadDir &&
        homeTab == HomeTab.allFile &&
        displayType == DisplayType.list) {
      return true;
    }

    return false;
  }

  bool _dataRowContains(DataRowKey dataRowKey, Offset point) {
    if (dataRowKey.key1.globalPaintBounds?.contains(point) == true) return true;
    if (dataRowKey.key2.globalPaintBounds?.contains(point) == true) return true;
    if (dataRowKey.key3.globalPaintBounds?.contains(point) == true) return true;
    if (dataRowKey.key4.globalPaintBounds?.contains(point) == true) return true;

    return false;
  }

  void _tryToOpenMenu(
      BuildContext context, PointerDownEvent event, FileNode file) {
    if (event.isRightMouseClick()) {
      List<FileNode> checkedFiles =
          context.read<FileHomeBloc>().state.checkedFiles;
      if (!checkedFiles.contains(file)) {
        context.read<FileHomeBloc>().add(FileHomeCheckedChanged(file));
      }

      context.read<FileHomeBloc>().add(FileHomeMenuStatusChanged(
          FileHomeMenuStatus(
              isOpened: true, position: event.position, current: file)));
    }
  }

  String _convertToCategory(BuildContext context, FileItem item) {
    if (item.isDir) {
      return context.l10n.folder;
    } else {
      String name = item.name.toLowerCase();
      if (name.trim() == "") return "--";

      if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
        return context.l10n.jpegImage;
      }

      if (name.endsWith(".png")) {
        return context.l10n.pngImage;
      }

      if (name.endsWith(".raw")) {
        return context.l10n.rawImage;
      }

      if (name.endsWith(".mp3")) {
        return context.l10n.mp3Audio;
      }

      if (name.endsWith(".txt")) {
        return context.l10n.textFile;
      }

      return context.l10n.document;
    }
  }

  String _formatTime(BuildContext context, int timeInMills) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeInMills);
    final DateFormat dateFormat =
        DateFormat.yMMMd(context.currentAppLocale.toString())
            .addPattern("HH:mm");
    return dateFormat.format(dateTime);
  }
}
