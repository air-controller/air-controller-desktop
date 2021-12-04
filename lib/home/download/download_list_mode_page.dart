import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/home/download/download_file_manager.dart';
import 'package:mobile_assistant_client/model/Device.dart';
import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:mobile_assistant_client/model/FileNode.dart';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'dart:developer' as developer;

class DownloadListModePage extends StatefulWidget {
  _DownloadListModeState? state;

  @override
  State<StatefulWidget> createState() {
    state = _DownloadListModeState();
    return state!;
  }
}

 final COLUMN_NAME_NAME = "name";
 final COLUMN_NAME_SIZE = "size";
 final COLUMN_NAME_CATEGORY = "category";
 final COLUMN_NAME_MODIFY_DATE = "modifyDate";

class _DownloadListModeState extends State<DownloadListModePage> {
  final DataGridController _dataGridController = DataGridController();
  final FileNodeDataSource _dataSource = FileNodeDataSource(nodes: []);

  final _headerTextStyle = TextStyle(color: Color(0xff5d5e63), fontSize: 14, inherit: false);
  final _minColumnWidth = 200.0;
  final _maxColumnWidth = 400.0;
  final _headerPaddingStart = 15.0;

  @override
  void initState() {
    super.initState();

    List<FileItem> allFiles = DownloadFileManager.instance.allFiles();
    _dataSource.setNewData(allFiles.map((file) => FileNode(0, null, file, 0)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            color: Colors.white,
            child: SfDataGridTheme(
                data: SfDataGridThemeData(
                    gridLineColor: Color(0xffdddddd),
                    gridLineStrokeWidth: 1.0,
                    headerColor: Color(0xfffcfcfc),
                    selectionColor: Color(0xff5a87ec),
                    brightness: Brightness.light,
                    columnResizeIndicatorStrokeWidth: 0,
                ),
                child: SfDataGrid(
                  source: _dataSource,
                  columnWidthMode: ColumnWidthMode.fill,
                  columnResizeMode: ColumnResizeMode.onResize,
                  gridLinesVisibility: GridLinesVisibility.none,
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  allowColumnsResizing: true,
                  showSortNumbers: true,
                  allowSorting: true,
                  headerRowHeight: 28,
                  selectionMode: SelectionMode.single,
                  rowHeight: 40,
                  highlightRowOnHover: true,
                  controller: _dataGridController,
                  allowEditing: true,
                  navigationMode: GridNavigationMode.cell,
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    // setState(() {
                    //   columnWidths[details.column.columnName] = details.width;
                    // });
                    return true;
                  },
                  onSelectionChanged: (List<DataGridRow> addedRows,
                      List<DataGridRow> removedRows) {

                  },
                  columns: <GridColumn>[
                    GridColumn(
                        columnName: COLUMN_NAME_NAME,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '名称',
                            style: _headerTextStyle,
                          ),
                          padding: EdgeInsets.fromLTRB(
                              _headerPaddingStart, 0, 0, 0),
                        ),
                        columnWidthMode: ColumnWidthMode.fill,
                        // width: columnWidths['name']!,
                        minimumWidth: 250.0,
                        maximumWidth: _maxColumnWidth),
                    GridColumn(
                        columnName: COLUMN_NAME_SIZE,
                        // width: columnWidths['size']!,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('大小', style: _headerTextStyle),
                          padding: EdgeInsets.fromLTRB(
                              _headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                        allowEditing: false),
                    GridColumn(
                        columnName: COLUMN_NAME_CATEGORY,
                        // width: columnWidths['category']!,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '种类',
                            style: _headerTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          padding: EdgeInsets.fromLTRB(
                              _headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                        allowEditing: false,
                      allowSorting: false
                    ),
                    GridColumn(
                        columnName: COLUMN_NAME_MODIFY_DATE,
                        // width: columnWidths['changeDate']!,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('修改日期', style: _headerTextStyle),
                          padding: EdgeInsets.fromLTRB(
                              _headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                        allowEditing: false),
                  ],
                ))));
  }
}

class FileNodeDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  List<FileNode> _fileNodes = [];
  FileNode? currentFileNode = null;
  int currentLevel = 0;

  final _KB_BOUND = 1 * 1024;
  final _MB_BOUND = 1 * 1024 * 1024;
  final _GB_BOUND = 1 * 1024 * 1024 * 1024;

  final _INDENT_STEP = 10.0;

  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/";

  FileNodeDataSource({required List<FileNode> nodes}) {
    setNewData(nodes);
  }
  
  void setNewData(List<FileNode> nodes) {
    _fileNodes = nodes;
    _dataGridRows = nodes.map((e) => DataGridRow(cells: [
      DataGridCell(columnName: COLUMN_NAME_NAME, value: e),
      DataGridCell(columnName: COLUMN_NAME_SIZE, value: e),
      DataGridCell(columnName: COLUMN_NAME_CATEGORY, value: e),
      DataGridCell(columnName: COLUMN_NAME_MODIFY_DATE, value: e),
    ])).toList();
    performSorting(_dataGridRows);
    notifyListeners();
  }

  @override
  void performSorting(List<DataGridRow> rows) {
    if (sortedColumns.isEmpty) {
      return;
    }

    // super.performSorting(rows)

    developer.log("performSorting, rows size: ${rows.length}, sorted columns: ${sortedColumns.length}");

    SortColumnDetails details = sortedColumns.last;

    developer.log("Detail, log: ${details.name}，sort direcation: ${details.sortDirection}");

    if (_needSortOrder(details.name)) {
      List<DataGridRow> childRows = rows.where((row) {
        DataGridCell? cell = row.getCells().where((element) => element.columnName == COLUMN_NAME_NAME).first;
        return (cell.value as FileNode).parent == currentFileNode;
      }).toList();

      developer.log("childRows, size: ${childRows.length}");

      childRows.sort((a, b) {
        FileNode nodeA = a.getCells().first.value as FileNode;
        FileNode nodeB = b.getCells().first.value as FileNode;

        FileItem fileItemA = nodeA.data;
        FileItem fileItemB = nodeB.data;

        return _compareValues(details.sortDirection, details.name, fileItemA, fileItemB);
      });

      // 如果当前节点数量等于所有节点数量，即表示所有节点均未展开，无需进行如下处理
      if (childRows.length < rows.length) {
        int maxLevel = _fileNodes.map((e) => e.level).toList().reduce(max);

        int currentLevel = this.currentLevel;

        developer.log("maxLevel: $maxLevel, currentLevel: $currentLevel");

        while (currentLevel < maxLevel) {
          currentLevel ++;

          // 获取当前级别的所有子节点
          List<DataGridRow> otherRows = rows.where((row) {
            DataGridCell? cell = row
                .getCells()
                .where((element) => element.columnName == COLUMN_NAME_NAME)
                .first;
            return (cell.value as FileNode).level == currentLevel;
          }).toList();

          // 根据不同父节点，进行分组并排序
          LinkedHashMap<FileNode, List<DataGridRow>> map = new LinkedHashMap();

          otherRows.forEach((element) {
            FileNode fileNode = element
                .getCells()
                .first
                .value;

            List<DataGridRow>? groupRows = map[fileNode];
            if (null == groupRows) {
              groupRows = [];
              groupRows.add(element);
              map[fileNode] = groupRows;
            } else {
              groupRows.add(element);

              groupRows.sort((a, b) {
                FileNode nodeA = a
                    .getCells()
                    .first
                    .value as FileNode;
                FileNode nodeB = b
                    .getCells()
                    .first
                    .value as FileNode;

                FileItem fileItemA = nodeA.data;
                FileItem fileItemB = nodeB.data;

                return _compareValues(details.sortDirection, details.name, fileItemA, fileItemB);
              });

              map[fileNode] = groupRows;
            }
          });

          // 重新插入到原队列中
          map.forEach((key, value) {
            int index = childRows.indexWhere((element) =>
            element
                .getCells()
                .first
                .value == key.parent);

            if (index != -1) {
              childRows.insertAll(index + 1, value);
            }
          });
        }
      }

      for (int i = 0; i < childRows.length; i++) {
        rows[i] = childRows[i];
      }
    }
  }

  bool _needSortOrder(String columnName) {
    if (columnName == COLUMN_NAME_NAME) return true;

    if (columnName == COLUMN_NAME_SIZE) return true;

    if (columnName == COLUMN_NAME_MODIFY_DATE) return true;

    return false;
  }

  int _compareValues(DataGridSortDirection direction, String sortColumnName, FileItem a, FileItem b) {
    if (direction == DataGridSortDirection.ascending) {
      if (COLUMN_NAME_NAME == sortColumnName) {
        if (a.isDir && !b.isDir) return -1;

        if (!a.isDir && b.isDir) return 1;
      }

      if (COLUMN_NAME_NAME == sortColumnName) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }

      if (COLUMN_NAME_SIZE == sortColumnName) {
        return a.size.compareTo(b.size);
      }

      if (COLUMN_NAME_MODIFY_DATE == sortColumnName) {
        return a.changeDate.compareTo(b.changeDate);
      }

      return 0;
    } else {
      if (COLUMN_NAME_NAME == sortColumnName) {
        if (a.isDir && !b.isDir) return 1;

        if (!a.isDir && b.isDir) return -1;
      }

      if (COLUMN_NAME_NAME == sortColumnName) {
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }

      if (COLUMN_NAME_SIZE == sortColumnName) {
        return b.size.compareTo(a.size);
      }

      if (COLUMN_NAME_MODIFY_DATE == sortColumnName) {
        return b.changeDate.compareTo(a.changeDate);
      }

      return 0;
    }
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      int index = rows.indexOf(row);
      debugPrint("Row index: $index");

      if (index % 2 == 0) {
        return Colors.white;
      } else {
        return Color(0xfff7f7f7);
      }
    }

    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          FileNode fileNode = e.value;
          FileItem fileItem = fileNode.data;

            if (e.columnName == COLUMN_NAME_NAME) {
              return Row(children: [
                getRightArrowIcon(0, fileNode),
                getFileTypeIcon(fileItem),
                SizedBox(width: 10.0),
                Flexible(
                    child: Text(fileNode.data.name,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            inherit: false,
                            fontSize: 14,
                            color: Colors.black)))
              ]);
            } else {
              String text = "";

              if (e.columnName == COLUMN_NAME_SIZE) {
                if (fileItem.isDir) {
                  text = "--";
                } else {
                  text = _convertToReadableSize(fileItem.size);
                }
              }

              if (e.columnName == COLUMN_NAME_CATEGORY) {
                text = _convertToCategory(fileItem);
              }

              if (e.columnName == COLUMN_NAME_MODIFY_DATE) {
                text = _formatChangeDate(fileItem.changeDate);
              }

              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                        inherit: false,
                        fontSize: 14,
                        color: Colors.black)),
              );
            }

        }).toList());
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

  Visibility getRightArrowIcon(int index, FileNode fileItemVO) {
    // debugPrint("getTextColor, index: $index, selectedIndex: $_selectedIndex");

    late Image icon;

    // if (index == _selectedIndex) {
    //   String iconPath = fileItemVO.isExpanded
    //       ? "icons/icon_down_arrow_selected.png"
    //       : "icons/icon_right_arrow_selected.png";
    //   icon = Image.asset(iconPath, width: 20, height: 20);
    // } else {
    //   String iconPath = fileItemVO.isExpanded
    //       ? "icons/icon_down_arrow_normal.png"
    //       : "icons/icon_right_arrow_normal.png";
    //   icon = Image.asset(iconPath, width: 20, height: 20);
    // }

    String iconPath = fileItemVO.isExpand
        ? "icons/icon_down_arrow_normal.png"
        : "icons/icon_right_arrow_normal.png";
    icon = Image.asset(iconPath, width: 20, height: 20);

    return Visibility(
        child: GestureDetector(
            child: Container(
                child: icon,
                margin: EdgeInsets.only(
                    left: fileItemVO.level * _INDENT_STEP)),
            onTap: () {
              debugPrint("Expand folder...");
              if (!fileItemVO.isExpand) {
                _expandFolder(fileItemVO);
              } else {
                _foldUp(fileItemVO);
              }
            }),
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        visible: fileItemVO.data.isDir);
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

      int index = _fileNodes.indexWhere((element) =>
      "${element.data.folder}/${element.data.name}" ==
          "${fileItemVO.data.folder}/${fileItemVO.data.name}");

      if (index >= 0) {
        _fileNodes.insertAll(index + 1, items.map((file) {
          FileNode fileNode = FileNode(0, fileItemVO, file, fileItemVO.level + 1);

          return fileNode;
        }));
        setNewData(_fileNodes);
      }
    }, (error) {
      developer.log("_getFileList, error: $error");
    });

    fileItemVO.isExpand = true;
  }

  void _foldUp(FileNode fileNode) {
    _fileNodes.removeWhere((node) => _isChild(fileNode, node));

    setNewData(_fileNodes);
    fileNode.isExpand = false;
  }

  bool _isChild(FileNode parent, FileNode node) {
    FileNode? currentFolder = node.parent;

    while (currentFolder != null) {
      if (currentFolder == parent) return true;

      currentFolder = currentFolder.parent;
    }

    return false;
  }

  String _formatChangeDate(int changeDate) {
    final df = DateFormat("yyyy年M月d日 HH:mm");
    return df.format(new DateTime.fromMillisecondsSinceEpoch(changeDate));
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
}