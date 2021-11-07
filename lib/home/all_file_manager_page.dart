import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/model/Device.dart';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../ext/string-ext.dart';
import '../constant.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../model/FileItem.dart';
import '../model/FileItemVO.dart';
import 'package:http/http.dart' as http;

class AllFileManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AllFileManagerState();
  }
}

final _URL_SERVER = "http://192.168.0.101:8080";

void _showTipsDialog(BuildContext context, String btnText, String message,
    bool cancelable, Function() onDismiss) {
  showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text(btnText),
              onPressed: () {
                onDismiss();
                Navigator.pop(context, 'OK');
              },
            )
          ],
        );
      });
}

class _AllFileManagerState extends State<AllFileManagerPage> {
  final _icon_display_mode_size = 10.0;
  final _segment_control_radius = 4.0;
  final _segment_control_height = 26.0;
  final _segment_control_width = 32.0;
  final _segment_control_padding_hor = 8.0;
  final _segment_control_padding_vertical = 6.0;
  final _icon_delete_btn_size = 10.0;
  final _delete_btn_width = 40.0;
  final _delete_btn_height = 25.0;
  final _delete_btn_padding_hor = 8.0;
  final _delete_btn_padding_vertical = 4.5;
  final _divider_line_color = "#e0e0e0";
  final _isListMode = true;
  final _headerTextStyle =
      TextStyle(color: "#5d5e63".toColor(), fontSize: 14, inherit: false);
  final _minColumnWidth = 200.0;
  final _maxColumnWidth = 400.0;
  final _headerPaddingStart = 15.0;
  final DataGridController _dataGridController = DataGridController();

  List<FileItem> _fileItems = <FileItem>[];
  late FileItemDataSource fileItemDataSource;

  var _isLoadingSuccess = false;

  @override
  void initState() {
    super.initState();
    fileItemDataSource = FileItemDataSource(this, context,
        datas: _fileItems.map((e) => FileItemVO(e, 0)).toList());

    _getFileList(
        "",
        (items) => {
              setState(() {
                _isLoadingSuccess = true;
                fileItemDataSource
                    .setNewDatas(items.map((e) => FileItemVO(e, 0)).toList());
              })
            }, (error) {
      debugPrint("Get root file list error: $error");

      _showTipsDialog(context, "确定", error, false, () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);

    const spinKit = SpinKitCircle(color: color, size: 60.0);

    return Stack(children: [
      _realContent(),
      Visibility(
        child: Container(child: spinKit, color: Colors.white),
        maintainSize: false,
        visible: !_isLoadingSuccess,
      )
    ]);
  }

  Widget _realContent() {
    int num = fileItemDataSource._datas.length;

    String itemNumStr = "共${num}项";

    if (fileItemDataSource.selectedIndex() >= 0) {
      itemNumStr = "选中1项（共${num}项目)";
    }

    return Column(children: [
      Container(
          child: Stack(children: [
            Align(
                alignment: Alignment.center,
                child: Text("手机存储",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        inherit: false,
                        color: "#616161".toColor(),
                        fontSize: 16.0))),
            Align(
                child: Container(
                    child: Row(
                        children: [
                          Container(
                              child: Image.asset(
                                  "icons/icon_image_text_selected.png",
                                  width: _icon_display_mode_size,
                                  height: _icon_display_mode_size),
                              decoration: BoxDecoration(
                                  color: "#c1c1c1".toColor(),
                                  border: new Border.all(
                                      color: "#ababab".toColor(), width: 1.0),
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          _segment_control_radius),
                                      bottomLeft: Radius.circular(
                                          _segment_control_radius))),
                              height: _segment_control_height,
                              width: _segment_control_width,
                              padding: EdgeInsets.fromLTRB(
                                  _segment_control_padding_hor,
                                  _segment_control_padding_vertical,
                                  _segment_control_padding_hor,
                                  _segment_control_padding_vertical)),
                          Container(
                              child: Image.asset("icons/icon_list_normal.png",
                                  width: _icon_display_mode_size,
                                  height: _icon_display_mode_size),
                              decoration: BoxDecoration(
                                  color: "#f5f6f5".toColor(),
                                  border: new Border.all(
                                      color: "#dededd".toColor(), width: 1.0),
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(
                                          _segment_control_radius),
                                      bottomRight: Radius.circular(
                                          _segment_control_radius))),
                              height: _segment_control_height,
                              width: _segment_control_width,
                              padding: EdgeInsets.fromLTRB(
                                  _segment_control_padding_hor,
                                  _segment_control_padding_vertical,
                                  _segment_control_padding_hor,
                                  _segment_control_padding_vertical)),
                          Container(
                              child: Image.asset("icons/icon_delete.png",
                                  width: _icon_delete_btn_size,
                                  height: _icon_delete_btn_size),
                              decoration: BoxDecoration(
                                  color: "#cb6357".toColor(),
                                  border: new Border.all(
                                      color: "#b43f32".toColor(), width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4.0))),
                              width: _delete_btn_width,
                              height: _delete_btn_height,
                              padding: EdgeInsets.fromLTRB(
                                  _delete_btn_padding_hor,
                                  _delete_btn_padding_vertical,
                                  _delete_btn_padding_hor,
                                  _delete_btn_padding_vertical),
                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0))
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center),
                    width: 200),
                alignment: Alignment.centerRight)
          ]),
          color: "#f4f4f4".toColor(),
          height: Constant.HOME_NAVI_BAR_HEIGHT),
      Divider(
        color: _divider_line_color.toColor(),
        height: 1.0,
        thickness: 1.0,
      ),

      /// 内容区域
      _createContent(),

      /// 底部固定区域
      Divider(
          color: _divider_line_color.toColor(), height: 1.0, thickness: 1.0),
      Container(
          child: Align(
              alignment: Alignment.center,
              child: Text(itemNumStr,
                  style: TextStyle(
                      color: "#646464".toColor(),
                      fontSize: 12,
                      inherit: false))),
          height: 20,
          color: "#fafafa".toColor()),
      Divider(
          color: _divider_line_color.toColor(), height: 1.0, thickness: 1.0),
    ], mainAxisSize: MainAxisSize.max);
  }

  List<String> getDataList() {
    List<String> list = [];
    for (int i = 0; i < 100; i++) {
      list.add(i.toString());
    }
    return list;
  }

  List<Widget> getWidgetList() {
    return getDataList().map((item) => getItemContainer(item)).toList();
  }

  Widget getItemContainer(String item) {
    return Container(
      width: 5.0,
      height: 5.0,
      alignment: Alignment.center,
      child: Text(
        item,
        style: TextStyle(color: Colors.white, fontSize: 40),
      ),
      color: Colors.blue,
    );
  }

  late Map<String, double> columnWidths = {
    'name': double.nan,
    'size': double.nan,
    'category': double.nan,
    'changeDate': double.nan,
    'empty': double.nan
  };

  Widget _createContent() {
    if (_isListMode) {
      return Expanded(
          child: Container(
              color: Colors.white,
              child: SfDataGridTheme(
                  data: SfDataGridThemeData(
                      gridLineColor: "#dddddd".toColor(),
                      gridLineStrokeWidth: 1.0,
                      headerColor: "#fcfcfc".toColor(),
                      selectionColor: "#5a87ec".toColor(),
                      brightness: Brightness.light,
                      columnResizeIndicatorStrokeWidth: 0),
                  child: SfDataGrid(
                    source: fileItemDataSource,
                    columnWidthMode: ColumnWidthMode.fill,
                    columnResizeMode: ColumnResizeMode.onResize,
                    gridLinesVisibility: GridLinesVisibility.none,
                    headerGridLinesVisibility: GridLinesVisibility.both,
                    allowColumnsResizing: true,
                    showSortNumbers: true,
                    allowSorting: false,
                    headerRowHeight: 28,
                    selectionMode: SelectionMode.single,
                    rowHeight: 40,
                    highlightRowOnHover: false,
                    controller: _dataGridController,
                    allowEditing: true,
                    navigationMode: GridNavigationMode.cell,
                    onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                      setState(() {
                        columnWidths[details.column.columnName] = details.width;
                      });
                      return true;
                    },
                    onSelectionChanged: (List<DataGridRow> addedRows,
                        List<DataGridRow> removedRows) {
                      setState(() {
                        fileItemDataSource
                            .setSelectedRow(_dataGridController.selectedIndex);
                      });
                    },
                    columns: <GridColumn>[
                      GridColumn(
                          columnName: 'name',
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
                          width: columnWidths['name']!,
                          minimumWidth: 250.0,
                          maximumWidth: _maxColumnWidth),
                      GridColumn(
                          columnName: 'size',
                          width: columnWidths['size']!,
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
                          columnName: 'category',
                          width: columnWidths['category']!,
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
                          allowEditing: false),
                      GridColumn(
                          columnName: 'changeDate',
                          width: columnWidths['changeDate']!,
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
                      GridColumn(
                          columnName: '',
                          width: columnWidths['empty']!,
                          label: Container(
                              alignment: Alignment.centerLeft,
                              child: Text('', style: _headerTextStyle)),
                          minimumWidth: 80,
                          columnWidthMode: ColumnWidthMode.none,
                          allowEditing: false),
                    ],
                  ))));
    } else {
      return Expanded(
          child: Column(children: [
        Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("手机存储",
                  style: TextStyle(
                      color: "#5b5c61".toColor(),
                      fontSize: 12.0,
                      inherit: false)),
            ),
            color: "#faf9fa".toColor(),
            padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
            height: 30),
        Divider(
            color: _divider_line_color.toColor(), height: 1.0, thickness: 1.0),
        Expanded(
            child: Container(
                child: GridView.count(
                  crossAxisSpacing: 10.0,
                  crossAxisCount: 6,
                  mainAxisSpacing: 10,
                  padding: EdgeInsets.all(10.0),
                  children: getWidgetList(),
                ),
                color: Colors.white)),
      ]));
    }
  }
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

// 用于构建表格数据
class FileItemDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  int _selectedIndex = -1;
  final _KB_BOUND = 1 * 1024;
  final _MB_BOUND = 1 * 1024 * 1024;
  final _GB_BOUND = 1 * 1024 * 1024 * 1024;
  BuildContext context;
  List<FileItemVO> _datas = [];
  final _INDENT_STEP = 10.0;
  _AllFileManagerState allFileManagerState;

  FileItemDataSource(this.allFileManagerState, this.context,
      {required List<FileItemVO> datas}) {
    setNewDatas(datas);
  }

  void setNewDatas(List<FileItemVO> datas) {
    _datas = datas;
    _dataGridRows = datas
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<FileItemVO>(columnName: 'name', value: e),
              DataGridCell<FileItemVO>(columnName: 'size', value: e),
              DataGridCell<FileItemVO>(columnName: 'category', value: e),
              DataGridCell<FileItemVO>(columnName: 'changeDate', value: e),
              DataGridCell<String>(columnName: 'empty', value: ""),
            ]))
        .toList();
    notifyListeners();
    allFileManagerState.setState(() {});
  }

  void setSelectedRow(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int selectedIndex() {
    return _selectedIndex;
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

  @override
  List<DataGridRow> get rows => _dataGridRows;

  void _expandFolder(FileItemVO fileItemVO) {
    _getFileList("${fileItemVO.item.folder}/${fileItemVO.item.name}", (items) {
      int index = _datas.indexWhere((element) =>
          "${element.item.folder}/${element.item.name}" ==
          "${fileItemVO.item.folder}/${fileItemVO.item.name}");

      if (index >= 0) {
        _datas.insertAll(index + 1, items.map((e) {
          FileItemVO newFileItemVO = FileItemVO(e, fileItemVO.indentLevel + 1);
          newFileItemVO
              .addAncestor("${fileItemVO.item.folder}/${fileItemVO.item.name}");

          newFileItemVO.parent = fileItemVO;
          return newFileItemVO;
        }));
        setNewDatas(_datas);
      }
    }, (error) {
      _showTipsDialog(context, "确定", error, false, () {});
    });

    fileItemVO.isExpanded = true;
  }

  bool _isChild(FileItemVO parent, FileItemVO second) {
    FileItemVO? currentFolder = second.parent;

    debugPrint("second: ${second.item.name}");

    while (currentFolder != null) {
      debugPrint(
          "current folder: ${currentFolder.item.folder}/${currentFolder.item.name}");
      if (currentFolder.item.folder == parent.item.folder &&
          currentFolder.item.name == parent.item.name) {
        debugPrint("_isChild condition true, file: ${second.item.name}");
        return true;
      }
      currentFolder = currentFolder.parent;
    }

    return false;
  }

  void _foldUp(FileItemVO fileItemVO) {
    _datas.removeWhere((element) => _isChild(fileItemVO, element));

    setNewDatas(_datas);
    fileItemVO.isExpanded = false;
  }

  Visibility getRightArrowIcon(int index, FileItemVO fileItemVO) {
    debugPrint("getTextColor, index: $index, selectedIndex: $_selectedIndex");

    late Image icon;

    if (index == _selectedIndex) {
      String iconPath = fileItemVO.isExpanded
          ? "icons/icon_down_arrow_selected.png"
          : "icons/icon_right_arrow_selected.png";
      icon = Image.asset(iconPath, width: 20, height: 20);
    } else {
      String iconPath = fileItemVO.isExpanded
          ? "icons/icon_down_arrow_normal.png"
          : "icons/icon_right_arrow_normal.png";
      icon = Image.asset(iconPath, width: 20, height: 20);
    }

    return Visibility(
        child: GestureDetector(
            child: Container(
                child: icon,
                margin: EdgeInsets.only(
                    left: fileItemVO.indentLevel * _INDENT_STEP)),
            onTap: () {
              debugPrint("Expand folder...");
              if (!fileItemVO.isExpanded) {
                _expandFolder(fileItemVO);
              } else {
                _foldUp(fileItemVO);
              }
            }),
        maintainSize: true,
        maintainState: true,
        maintainAnimation: true,
        visible: fileItemVO.item.isDir);
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

  Color getTextColor(FileItemVO fileItemVO) {
    int index = _datas.indexOf(fileItemVO);
    debugPrint("getTextColor, index: $index, selectedIndex: $_selectedIndex");

    if (index == _selectedIndex) {
      return Colors.white;
    } else {
      return "#323237".toColor();
    }
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      int index = rows.indexOf(row);
      debugPrint("Row index: $index");

      if (index % 2 == 0) {
        return Colors.white;
      } else {
        return "#f7f7f7".toColor();
      }
    }

    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          dynamic value = e.value;
          if (value is FileItemVO) {
            final fileItemVO = e.value as FileItemVO;

            if (e.columnName == "name") {
              return Row(children: [
                getRightArrowIcon(_datas.indexOf(fileItemVO), fileItemVO),
                getFileTypeIcon(fileItemVO.item),
                SizedBox(width: 10.0),
                Flexible(
                    child: Text(fileItemVO.item.name,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            inherit: false,
                            fontSize: 14,
                            color: getTextColor(fileItemVO))))
              ]);
            } else {
              String text = value.toString();

              if (e.columnName == "size") {
                if (fileItemVO.item.isDir) {
                  text = "--";
                } else {
                  text = _convertToReadableSize(fileItemVO.item.size);
                }
              }

              if (e.columnName == "category") {
                text = _convertToCategory(fileItemVO.item);
              }

              if (e.columnName == "changeDate") {
                text = _formatChangeDate(fileItemVO.item.changeDate);
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
                        color: getTextColor(fileItemVO))),
              );
            }
          } else {
            return Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text("",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                      inherit: false, fontSize: 14, color: Colors.black87)),
            );
          }
        }).toList());
  }

  String _formatChangeDate(int changeDate) {
    final df = DateFormat("yyyy年M月d日 HH:mm");
    return df.format(new DateTime.fromMillisecondsSinceEpoch(changeDate));
  }

  String _convertToReadableSize(int size) {
    if (size < _KB_BOUND) {
      return "${size}Byte";
    }
    if (size >= _KB_BOUND && size < _MB_BOUND) {
      return "${size ~/ 1024}KB";
    }

    if (size >= _MB_BOUND && size <= _GB_BOUND) {
      return "${size / 1024 ~/ 1024}MB";
    }

    return "${size / 1024 / 1024 ~/ 1024}GB";
  }

  @override
  bool shouldRecalculateColumnWidths() {
    return true;
  }

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    FileItemVO itemA = a
        ?.getCells()
        .firstWhere((element) => element.columnName == sortColumn.name)
        .value;
    FileItemVO itemB = b
        ?.getCells()
        .firstWhere((element) => element.columnName == sortColumn.name)
        .value;

    if (sortColumn.name == "name" || sortColumn.name == "category") {
      if (sortColumn.sortDirection == DataGridSortDirection.descending) {
        return itemA.item.name.compareTo(itemB.item.name);
      } else {
        return itemB.item.name.compareTo(itemA.item.name);
      }
    }

    if (sortColumn.name == "size") {
      if (sortColumn.sortDirection == DataGridSortDirection.descending) {
        return itemA.item.size.compareTo(itemB.item.size);
      } else {
        return itemB.item.size.compareTo(itemA.item.size);
      }
    }

    if (sortColumn.name == "changeDate") {
      if (sortColumn.sortDirection == DataGridSortDirection.descending) {
        return itemA.item.changeDate.compareTo(itemB.item.changeDate);
      } else {
        return itemB.item.changeDate.compareTo(itemA.item.changeDate);
      }
    }

    return super.compare(a, b, sortColumn);
  }

  @override
  Widget? buildEditWidget(DataGridRow dataGridRow,
      RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
    if (column.columnName == "name") {
      FileItemVO fileItemVO = dataGridRow.getCells().first.value as FileItemVO;

      TextEditingController controller = new TextEditingController(text: fileItemVO.item.name);

      return Row(children: [
        getRightArrowIcon(_datas.indexOf(fileItemVO), fileItemVO),
        getFileTypeIcon(fileItemVO.item),
        SizedBox(width: 10.0),
        Flexible(
            child: Material(
                child: Container(
                    child: Flexible(
                      child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                              hintText: "请输入新名称",
                              border: OutlineInputBorder(
                                  gapPadding: 0,
                                  borderRadius: BorderRadius.all(Radius.circular(2.0)),
                                  borderSide: BorderSide(
                                      color: Color(0xffccccce),
                                      width: 1.0
                                  )
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10)
                          ),
                          textAlign: TextAlign.left,
                          autofocus: true,
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 5,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                              fontSize: 14,
                              color: Color(0xff333333)
                          )
                      ),
                    ),
                    width: 180, height: 40, alignment: Alignment.centerLeft,)
            )
        )
      ]);
    } else {
      return null;
    }
  }
}
