import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/event/back_btn_visibility.dart';
import 'package:mobile_assistant_client/event/refresh_download_file_list.dart';
import 'package:mobile_assistant_client/event/update_bottom_item_num.dart';
import 'package:mobile_assistant_client/event/update_delete_btn_status.dart';
import 'package:mobile_assistant_client/home/download/download_file_manager.dart';
import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:mobile_assistant_client/model/FileNode.dart';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';
import 'package:mobile_assistant_client/model/UIModule.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';

import '../file_manager.dart';
import 'all_file_manager.dart';

class AllFileListModePage extends StatefulWidget {
  _DownloadListModeState? state;

  @override
  State<StatefulWidget> createState() {
    state = _DownloadListModeState();
    debugPrint("DownloadIconModePage, createState, instance: $this");
    return state!;
  }
}

final COLUMN_NAME_NAME = "name";
final COLUMN_NAME_SIZE = "size";
final COLUMN_NAME_CATEGORY = "category";
final COLUMN_NAME_MODIFY_DATE = "modifyDate";

class _DownloadListModeState extends State<AllFileListModePage>  with AutomaticKeepAliveClientMixin {
  final _headerTextStyle =
      TextStyle(color: Color(0xff5d5e63), fontSize: 14, inherit: false);
  final _minColumnWidth = 200.0;
  final _maxColumnWidth = 400.0;
  final _headerPaddingStart = 15.0;

  final _KB_BOUND = 1 * 1024;
  final _MB_BOUND = 1 * 1024 * 1024;
  final _GB_BOUND = 1 * 1024 * 1024 * 1024;

  final _INDENT_STEP = 10.0;

  static final COLUMN_INDEX_NAME = 0;
  static final COLUMN_INDEX_SIZE = 1;
  static final COLUMN_INDEX_CATEGORY = 2;
  static final COLUMN_INDEX_MODIFY_DATE = 3;

  int _sortColumnIndex = COLUMN_INDEX_NAME;
  bool _isAscending = true;

  final _URL_SERVER =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/";

  late Function() _ctrlAPressedCallback;

  StreamSubscription<RefreshDownloadFileList>? _refreshDownloadFileList;

  @override
  void initState() {
    super.initState();

    _registerEventBus();

    _ctrlAPressedCallback = () {
      _setAllSelected();
      debugPrint("Ctrl + A pressed...");
    };

    _addCtrlAPressedCallback(_ctrlAPressedCallback);
    debugPrint("_DownloadListModeState: initState, instance: $this");
  }

  void _registerEventBus() {
    _refreshDownloadFileList =
        eventBus.on<RefreshDownloadFileList>().listen((event) {
          setState(() {

          });
        });
  }

  void _unRegisterEventBus() {
    _refreshDownloadFileList?.cancel();
  }

  void _setAllSelected() {
    setState(() {
      List<FileNode> allFiles = AllFileManager.instance.allFiles();

      List<FileNode> selectedFiles = [...allFiles];
      AllFileManager.instance.updateSelectedFiles(selectedFiles);
      updateBottomItemNum();
      _setDeleteBtnEnabled(selectedFiles.length > 0);
    });
  }

  void updateBottomItemNum() {
    eventBus.fire(UpdateBottomItemNum(AllFileManager.instance.totalFileCount(),
        AllFileManager.instance.selectedFileCount(), module: UIModule.Download));
  }

  @override
  Widget build(BuildContext context) {
    TextStyle headerStyle =
        TextStyle(inherit: false, fontSize: 14, color: Colors.black);
    return Container(
        color: Colors.white,
        child: DataTable2(
          dividerThickness: 1,
          bottomMargin: 10,
          columnSpacing: 0,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _isAscending,
          showCheckboxColumn: false,
          showBottomBorder: false,
          columns: [
            DataColumn2(
                label: Container(
                  child: Text(
                    "名称",
                    textAlign: TextAlign.center,
                  ),
                ),
                onSort: (sortColumnIndex, isSortAscending) {
                  _performSort(sortColumnIndex, isSortAscending);
                  debugPrint(
                      "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
                },
                size: ColumnSize.L),
            DataColumn2(
                label: Container(
                    child: Text(
                      "大小",
                      textAlign: TextAlign.center,
                    ),
                    padding: EdgeInsets.only(left: 15)),
                onSort: (sortColumnIndex, isSortAscending) {
                  _performSort(sortColumnIndex, isSortAscending);
                  debugPrint(
                      "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
                }),
            DataColumn2(
                label: Container(
                  child: Text(
                    "种类",
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.only(left: 15),
                )),
            DataColumn2(
                label: Container(
                  child: Text(
                    "修改日期",
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.only(left: 15),
                ),
                onSort: (sortColumnIndex, isSortAscending) {
                  _performSort(sortColumnIndex, isSortAscending);
                  debugPrint(
                      "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
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
              child: Text("No download files"),
            ),
          ),
        ));
  }

  void _performSort(int sortColumnIndex, bool isSortAscending) {
    List<FileNode> allFileNodes = AllFileManager.instance.allFiles();

    FileNode? currentFileNode = AllFileManager.instance.currentDir();

    // 1.找到当前节点下的所有节点
    List<FileNode> directedChildNodes = allFileNodes
        .where((element) => element.parent == currentFileNode)
        .toList();

    directedChildNodes.sort((nodeA, nodeB) {
      return _sortFileNode(sortColumnIndex, isSortAscending, nodeA, nodeB);
    });

    if (directedChildNodes.length < allFileNodes.length) {
      // 2.获取最大的层级值，依次循环插入
      int maxLevel = allFileNodes.map((e) => e.level).toList().reduce(max);

      int currentLevel = currentFileNode == null ? 0 : currentFileNode!.level;

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
            return _sortFileNode(
                sortColumnIndex, isSortAscending, nodeA, nodeB);
          });

          int index = directedChildNodes.indexOf(parent);
          if (index != -1) {
            directedChildNodes.insertAll(index + 1, childNodes);
          }
        });
      }
    }

    // 5.刷新列表
    setState(() {
      AllFileManager.instance.updateFiles(directedChildNodes);
      _sortColumnIndex = sortColumnIndex;
      _isAscending = isSortAscending;
    });
  }

  int _sortFileNode(
      int columnIndex, bool isSortAscending, FileNode nodeA, FileNode nodeB) {
    if (columnIndex == COLUMN_INDEX_NAME) {
      // 如果节点是目录，应该始终排在前面
      if (nodeA.data.isDir && !nodeB.data.isDir) return -1;
      if (!nodeA.data.isDir && nodeB.data.isDir) return 1;

      if (isSortAscending) {
        return nodeA.data.name.compareTo(nodeB.data.name);
      } else {
        return nodeB.data.name.compareTo(nodeA.data.name);
      }
    }

    if (columnIndex == COLUMN_INDEX_SIZE) {
      // 如果节点是目录，应该始终排在前面
      if (nodeA.data.isDir && !nodeB.data.isDir) return -1;
      if (!nodeA.data.isDir && nodeB.data.isDir) return 1;

      if (isSortAscending) {
        return nodeA.data.size.compareTo(nodeB.data.size);
      } else {
        return nodeB.data.size.compareTo(nodeA.data.size);
      }
    }

    if (columnIndex == COLUMN_INDEX_MODIFY_DATE) {
      // 如果节点是目录，应该始终排在前面
      if (nodeA.data.isDir && !nodeB.data.isDir) return -1;
      if (!nodeA.data.isDir && nodeB.data.isDir) return 1;

      if (isSortAscending) {
        return nodeA.data.changeDate.compareTo(nodeB.data.changeDate);
      } else {
        return nodeB.data.changeDate.compareTo(nodeA.data.changeDate);
      }
    }

    return 0;
  }

  Visibility getRightArrowIcon(int index, FileNode node) {
    String iconPath = "";

    if (AllFileManager.instance.isSelected(node)) {
      if (node.isExpand) {
        iconPath = "icons/icon_down_arrow_selected.png";
      } else {
        iconPath = "icons/icon_right_arrow_selected.png";
      }
    } else {
      if (node.isExpand) {
        iconPath = "icons/icon_down_arrow_normal.png";
      } else {
        iconPath = "icons/icon_right_arrow_normal.png";
      }
    }

    Image icon = Image.asset(iconPath, width: 20, height: 20);

    FileNode? currentDir = AllFileManager.instance.currentDir();

    double indent = 0;

    if (null == currentDir) {
      indent = node.level * _INDENT_STEP;
    } else {
      indent = (node.level - currentDir.level - 1) * _INDENT_STEP;
    }

    return Visibility(
        child: GestureDetector(
            child: Container(
                child: icon,
                margin: EdgeInsets.only(left: indent)),
            onTap: () {
              debugPrint("Expand folder...");
              if (!node.isExpand) {
                _expandFolder(node);
              } else {
                _foldUp(node);
              }
            }),
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        visible: node.data.isDir);
  }

  void _getFileList(String? path, Function(List<FileItem> items) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/file/list");
    http
        .post(url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({"path": path == null ? "" : path}))
        .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("getFileList, body: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          onSuccess.call(data
              .map((e) => FileItem.fromJson(e as Map<String, dynamic>))
              .toList());
        } else {
          onError.call(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).catchError((error) {
      onError.call(error.toString());
    });
  }

  void _expandFolder(FileNode fileItemVO) {
    _getFileList("${fileItemVO.data.folder}/${fileItemVO.data.name}", (items) {
      setState(() {
        List<FileNode> allFiles = AllFileManager.instance.allFiles();

        int index = allFiles.indexWhere((element) =>
            "${element.data.folder}/${element.data.name}" ==
            "${fileItemVO.data.folder}/${fileItemVO.data.name}");

        if (index >= 0) {
          allFiles.insertAll(index + 1, items.map((file) {
            FileNode fileNode =
                FileNode(fileItemVO, file, fileItemVO.level + 1);

            return fileNode;
          }));
        }

        AllFileManager.instance.updateFiles(allFiles);
      });

      fileItemVO.isExpand = true;
    }, (error) {
      developer.log("_getFileList, error: $error");
    });
  }

  void _foldUp(FileNode fileNode) {
    setState(() {
      List<FileNode> allFiles = AllFileManager.instance.allFiles();
      allFiles.removeWhere((node) => _isChild(fileNode, node));

      AllFileManager.instance.updateFiles(allFiles);

      fileNode.isExpand = false;
    });
  }

  bool _isChild(FileNode parent, FileNode node) {
    FileNode? currentFolder = node.parent;

    while (currentFolder != null) {
      if (currentFolder == parent) return true;

      currentFolder = currentFolder.parent;
    }

    return false;
  }

  Image getFileTypeIcon(FileItem fileItem) {
    if (fileItem.isDir) {
      return Image.asset("icons/icon_folder.png", width: 20, height: 20);
    }

    String name = fileItem.name.toLowerCase();

    if (name.endsWith(".jpg") ||
        name.endsWith(".jpeg") ||
        name.endsWith(".png")) {
      return Image.asset("icons/icon_file_type_image.png",
          width: 20, height: 20);
    }

    if (name.endsWith(".mp3")) {
      return Image.asset("icons/icon_file_type_audio.png",
          width: 20, height: 20);
    }

    if (name.endsWith(".txt")) {
      return Image.asset("icons/icon_file_type_text.png",
          width: 20, height: 20);
    }

    return Image.asset("icons/icon_file_type_doc.png", width: 20, height: 20);
  }

  List<DataRow> _generateRows() {
    List<FileNode> allFileNode = AllFileManager.instance.allFiles();
    List<FileNode> selectedFileNode = AllFileManager.instance.selectedFiles();

    return List<DataRow>.generate(allFileNode.length, (int index) {
      FileNode fileNode = allFileNode[index];

      Color textColor = _isContains(selectedFileNode, fileNode) ? Colors.white : Color(0xff313237);
      TextStyle textStyle = TextStyle(inherit: false, fontSize: 14, color: textColor);

      return DataRow2(
          cells: [
            DataCell(Row(children: [
              getRightArrowIcon(0, fileNode),
              getFileTypeIcon(fileNode.data),
              SizedBox(width: 10.0),
              Flexible(
                  child: Text(fileNode.data.name,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: textStyle))
            ])),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(
                  fileNode.data.isDir
                      ? "--"
                      : _convertToReadableSize(fileNode.data.size),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(_convertToCategory(fileNode.data),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(_formatChangeDate(fileNode.data.changeDate),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
          ],
          selected: _isContains(selectedFileNode, fileNode),
          onSelectChanged: (isSelected) {
            debugPrint("onSelectChanged: $isSelected");
          },
          onTap: () {
            debugPrint("onTap: ${fileNode.data.name}");
            _setFileSelected(fileNode);
          },
          onDoubleTap: () {
            _tryToOpenDirectory(fileNode, (fileNodes) {
              setState(() {
                AllFileManager.instance.updateSelectedFiles([]);
                AllFileManager.instance.updateFiles(fileNodes);
                AllFileManager.instance.updateCurrentDir(fileNode);
                AllFileManager.instance.pushToStack(fileNode);
                _updateBackBtnVisibility();
                _setDeleteBtnEnabled(AllFileManager.instance.selectedFileCount() > 0);
                updateBottomItemNum();
              });
            }, (error) {

            });
          },
          color: MaterialStateColor.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return Colors.red;
            }

            if (states.contains(MaterialState.pressed)) {
              return Colors.blue;
            }

            if (states.contains(MaterialState.selected)) {
              return Color(0xff5e86ec);
            }

            return Colors.white;
          }));
    });
  }

  void _updateBackBtnVisibility() {
    var isRoot = AllFileManager.instance.isRoot();
    eventBus.fire(BackBtnVisibility(!isRoot, module: UIModule.Download));
  }

  void _tryToOpenDirectory(FileNode dir, Function(List<FileNode>) onSuccess, Function(String) onError) {
    debugPrint("_tryToOpenDirectory, dir: ${dir.data.folder}/${dir.data.name}");
    _getFileList("${dir.data.folder}/${dir.data.name}", (files) {
      List<FileNode> allFiles =
      files.map((e) => FileNode(dir, e, dir.level + 1)).toList();

      onSuccess.call(allFiles);
    }, (error) {
      debugPrint("_tryToOpenDirectory, error: $error");

      onError.call(error);
    });
  }

  bool _isControlDown() {
    return FileManagerPage.fileManagerKey.currentState?.isControlDown() == true;
  }

  bool _isShiftDown() {
    return FileManagerPage.fileManagerKey.currentState?.isShiftDown() == true;
  }

  void _addCtrlAPressedCallback(Function() callback) {
    FileManagerPage.fileManagerKey.currentState?.addCtrlAPressedCallback(callback);
  }

  void _removeCtrlAPressedCallback(Function() callback) {
    FileManagerPage.fileManagerKey.currentState?.removeCtrlAPressedCallback(callback);
  }

  void _setFileSelected(FileNode fileNode) {
    debugPrint("Shift key down status: ${_isShiftDown()}");
    debugPrint("Control key down status: ${_isControlDown()}");

    List<FileNode> selectedFiles = AllFileManager.instance.selectedFiles();
    List<FileNode> allFiles = AllFileManager.instance.allFiles();

    if (!_isContains(selectedFiles, fileNode)) {
      if (_isControlDown()) {
        selectedFiles.add(fileNode);
      } else if (_isShiftDown()) {
        if (selectedFiles.length == 0) {
          selectedFiles.add(fileNode);
        } else if (selectedFiles.length == 1) {
          int index = allFiles.indexOf(selectedFiles[0]);

          int current = allFiles.indexOf(fileNode);

          if (current > index) {
            selectedFiles = allFiles.sublist(index, current + 1);
          } else {
            selectedFiles = allFiles.sublist(current, index + 1);
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < selectedFiles.length; i++) {
            FileNode current = selectedFiles[i];
            int index = allFiles.indexOf(current);
            if (index < 0) {
              debugPrint("Error image");
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          debugPrint("minIndex: $minIndex, maxIndex: $maxIndex");

          int current = allFiles.indexOf(fileNode);

          if (current >= minIndex && current <= maxIndex) {
            selectedFiles = allFiles.sublist(current, maxIndex + 1);
          } else if (current < minIndex) {
            selectedFiles = allFiles.sublist(current, maxIndex + 1);
          } else if (current > maxIndex) {
            selectedFiles = allFiles.sublist(minIndex, current + 1);
          }
        }
      } else {
        selectedFiles.clear();
        selectedFiles.add(fileNode);
      }
    } else {
      debugPrint("It's already contains this file, file: ${fileNode.data.name}");

      if (_isControlDown()) {
        selectedFiles.remove(fileNode);
      } else if (_isShiftDown()) {
        selectedFiles.remove(fileNode);
      } else {
        selectedFiles.clear();
        selectedFiles.add(fileNode);
      }
    }

    setState(() {
      debugPrint("Selected files length: ${selectedFiles.length}");
      AllFileManager.instance.updateSelectedFiles(selectedFiles);
    });

    _setDeleteBtnEnabled(selectedFiles.length > 0);
    updateBottomItemNum();
  }

  void _setDeleteBtnEnabled(bool enable) {
    eventBus.fire(UpdateDeleteBtnStatus(enable, module: UIModule.Download));
  }

  bool _isContains(List<FileNode> nodes, FileNode node) {
    for (FileNode fileNode in nodes) {
      if (fileNode.data.folder == node.data.folder &&
          fileNode.data.name == node.data.name) {
        return true;
      }
    }

    return false;
  }

  String _convertToReadableSize(int size) {
    if (size < _KB_BOUND) {
      return "${size} bytes";
    }
    if (size >= _KB_BOUND && size < _MB_BOUND) {
      return "${(size / 1024).toStringAsFixed(1)} KB";
    }

    if (size >= _MB_BOUND && size <= _GB_BOUND) {
      return "${(size / 1024 ~/ 1024).toStringAsFixed(1)} MB";
    }

    return "${(size / 1024 / 1024 ~/ 1024).toStringAsFixed(1)} GB";
  }

  String _convertToCategory(FileItem item) {
    if (item.isDir) {
      return "文件夹";
    } else {
      String name = item.name.toLowerCase();
      if (name.trim() == "") return "--";

      if (name.endsWith(".jpg") || name.endsWith(".jpeg")) {
        return "JPEG图像";
      }

      if (name.endsWith(".png")) {
        return "PNG图像";
      }

      if (name.endsWith(".raw")) {
        return "Panasonic raw图像";
      }

      if (name.endsWith(".mp3")) {
        return "MP3音频";
      }

      if (name.endsWith(".txt")) {
        return "文本";
      }

      return "文档";
    }
  }

  String _formatChangeDate(int changeDate) {
    final df = DateFormat("yyyy年M月d日 HH:mm");
    return df.format(new DateTime.fromMillisecondsSinceEpoch(changeDate));
  }

  @override
  void deactivate() {
    super.deactivate();

    _unRegisterEventBus();
    _removeCtrlAPressedCallback(_ctrlAPressedCallback);
    debugPrint("DownloadListModePage deactivate, instance: $this");
  }

  @override
  void dispose() {


    super.dispose();
  }

  @override
  bool get wantKeepAlive => false;
}
