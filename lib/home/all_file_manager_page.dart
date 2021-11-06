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
import 'package:http/http.dart' as http;

class AllFileManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AllFileManagerState();
  }
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
  final _URL_SERVER = "http://192.168.0.102:8080";

  var _isLoadingSuccess = false;

  @override
  void initState() {
    super.initState();
    fileItemDataSource = FileItemDataSource(datas: _fileItems);

    getFileList("", (items) => {
      setState(() {
        _isLoadingSuccess = true;
        fileItemDataSource.setNewDatas(items);
      })
    }, (error) {
      debugPrint("Get root file list error: $error");

      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text(error),
            actions: [
              TextButton(
                child: Text("取消"),
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                },
              ),
              TextButton(
                child: Text("确定"),
                onPressed: () {
                  Navigator.pop(context, 'OK');
                },
              )
            ],
          );
        }
      );
    });
  }

  void _showLoadingDialog() {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8.0))
              ),
              backgroundColor: Colors.black87,
              content: Container(
                  child: CircularProgressIndicator(
                      strokeWidth: 3,
                  ),
                width: 32,
                height: 32,
              ),
            ), 
            onWillPop: () async {
              Navigator.pop(context);
              return true;
            });
      }
    );
  }

  void getFileList(
        String? path,
        Function(List<FileItem> items) onSuccess,
        Function(String error) onError
      ) {
    var url = Uri.parse("${_URL_SERVER}/file/list");
    http.post(url,
        headers: { "Content-Type": "application/json" },
        body: json.encode({"path" : path == null ? "" : path}))
    .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null ? response.reasonPhrase! : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("getFileList, body: $body");
        
        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);
        
        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          onSuccess.call(data.map((e) => FileItem.fromJson(e as Map<String, dynamic>)).toList());
        } else {
          onError.call(httpResponseEntity.msg == null ? "Unknown error" : httpResponseEntity.msg!);
        }
      }
    })
    .catchError((error) {
      onError.call(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);

    const spinkit = SpinKitCircle(
      color: color,
      size: 60.0
    );

    return Stack(children: [
      _realContent(),

      Visibility(
          child: Container(child: spinkit, color: Colors.white),
        maintainSize: false,
        visible: !_isLoadingSuccess,
      )
    ]);
  }

  Widget _realContent() {
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
              child: Text("100项",
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
                    allowSorting: true,
                    headerRowHeight: 28,
                    selectionMode: SelectionMode.single,
                    rowHeight: 40,
                    highlightRowOnHover: false,
                    controller: _dataGridController,
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
                          padding:
                              EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                      ),
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
                          padding:
                              EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                      ),
                      GridColumn(
                        columnName: 'changeDate',
                        width: columnWidths['changeDate']!,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('修改日期', style: _headerTextStyle),
                          padding:
                              EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                      ),
                      GridColumn(
                        columnName: '',
                        width: columnWidths['empty']!,
                        label: Container(
                            alignment: Alignment.centerLeft,
                            child: Text('', style: _headerTextStyle)),
                        minimumWidth: 80,
                        columnWidthMode: ColumnWidthMode.none,
                      ),
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

// 用于构建表格数据
class FileItemDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  int _selectedIndex = -1;
  final _KB_BOUND = 1 * 1024;
  final _MB_BOUND = 1 * 1024 * 1024;
  final _GB_BOUND = 1 * 1024 * 1024 * 1024;

  FileItemDataSource({required List<FileItem> datas}) {
    setNewDatas(datas);
  }

  void setNewDatas(List<FileItem> datas) {
    _dataGridRows = datas
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<FileItem>(columnName: 'name', value: e),
      DataGridCell<FileItem>(columnName: 'size', value: e),
      DataGridCell<FileItem>(
          columnName: 'category',
          value: e),
      DataGridCell<FileItem>(
          columnName: 'changeDate', value: e),
      DataGridCell<String>(columnName: 'empty', value: ""),
    ])).toList();
    notifyListeners();
  }

  void setSelectedRow(int index) {
    _selectedIndex = index;
    notifyListeners();
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

    Color getTextColor() {
      int index = rows.indexOf(row);
      debugPrint("getTextColor, index: $index, selectedIndex: $_selectedIndex");

      if (index == _selectedIndex) {
        return Colors.white;
      } else {
        return "#323237".toColor();
      }
    }

    Visibility getRightArrowIcon(FileItem fileItem) {
      int index = rows.indexOf(row);
      debugPrint("getTextColor, index: $index, selectedIndex: $_selectedIndex");

      late Image icon;

      if (index == _selectedIndex) {
        icon = Image.asset("icons/icon_right_arrow_selected.png",
            width: 20, height: 20);
      } else {
        icon = Image.asset("icons/icon_right_arrow_normal.png",
            width: 20, height: 20);
      }

      return Visibility(
          child: GestureDetector(child: icon, onTap: () {
            debugPrint("Expand folder...");
          }),
          maintainSize: true,
          maintainState: true,
          maintainAnimation: true,
          visible: fileItem.isDir);
    }
    
    Image getFileTypeIcon(FileItem fileItem) {
      if (fileItem.isDir) {
        return Image.asset("icons/icon_folder.png", width: 20, height: 20);
      }

      String name = fileItem.name.toLowerCase();

      if (name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png")) {
        return Image.asset("icons/icon_file_type_image.png", width: 20, height: 20);
      }
      
      if (name.endsWith(".mp3")) {
        return Image.asset("icons/icon_file_type_audio.png", width: 20, height: 20);
      }
      
      if (name.endsWith(".txt")) {
        return Image.asset("icons/icon_file_type_text.png", width: 20, height: 20);
      }

      return Image.asset("icons/icon_file_type_doc.png", width: 20, height: 20);
    }

    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          dynamic value = e.value;
          if (value is FileItem) {
            final fileItem = e.value as FileItem;

            if (e.columnName == "name") {
              return Row(children: [
                getRightArrowIcon(fileItem),
                getFileTypeIcon(fileItem),
                SizedBox(width: 10.0),
                Flexible(
                    child: Text(fileItem.name,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            inherit: false, fontSize: 14, color: getTextColor())))
              ]);
            } else {
              String text = value.toString();

              if (e.columnName == "size") {
                if (fileItem.isDir) {
                  text = "--";
                } else {
                  text = _convertToReadableSize(fileItem.size);
                }
              }

              if (e.columnName == "category") {
                text = _convertToCategory(fileItem);
              }

              if (e.columnName == "changeDate") {
                text = _formatChangeDate(fileItem.changeDate);
              }

              return Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                        inherit: false, fontSize: 14, color: getTextColor())),
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
                      inherit: false, fontSize: 14, color: getTextColor())),
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
    FileItem itemA = a?.getCells().firstWhere((element) => element.columnName == sortColumn.name).value;
    FileItem itemB = b?.getCells().firstWhere((element) => element.columnName == sortColumn.name).value;


    if (sortColumn.name == "name" || sortColumn.name == "category") {
      if (sortColumn.sortDirection == DataGridSortDirection.descending) {
        return itemA.name.compareTo(itemB.name);
      } else {
        return itemB.name.compareTo(itemA.name);
      }
    }

    if (sortColumn.name == "size") {
      if (sortColumn.sortDirection == DataGridSortDirection.descending) {
        return itemA.size.compareTo(itemB.size);
      } else {
        return itemB.size.compareTo(itemA.size);
      }
    }

    if (sortColumn.name == "changeDate") {
      if (sortColumn.sortDirection == DataGridSortDirection.descending) {
        return itemA.changeDate.compareTo(itemB.changeDate);
      } else {
        return itemB.changeDate.compareTo(itemA.changeDate);

      }
    }

    return super.compare(a, b, sortColumn);
  }
}
