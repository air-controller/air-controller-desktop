import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/model/AudioItem.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';

class MusicManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MusicManagerState();
  }
}

class _MusicManagerState extends State<MusicManagerPage> {
  var _isLoadingSuccess = false;
  late AudioItemDataSource audioItemDataSource;
  final _icon_delete_btn_size = 10.0;
  final _delete_btn_width = 40.0;
  final _delete_btn_height = 25.0;
  final _delete_btn_padding_hor = 8.0;
  final _delete_btn_padding_vertical = 4.5;
  final _divider_line_color = Color(0xffe0e0e0);
  List<AudioItem> _audioItems = [];
  final _headerTextStyle =
      TextStyle(color: Color(0xff5d5e63), fontSize: 14, inherit: false);
  final DataGridController _dataGridController = DataGridController();
  final _headerPaddingStart = 15.0;
  final _minColumnWidth = 100.0;
  final _maxColumnWidth = 300.0;

  late Map<String, double> columnWidths = {
    'folder': double.nan,
    'name': double.nan,
    'type': double.nan,
    'duration': double.nan,
    'size': double.nan
  };

  @override
  void initState() {
    super.initState();

    audioItemDataSource = AudioItemDataSource(context, _audioItems);

    _getAllAudios((audios) {
      setState(() {
        _audioItems = audios;
        audioItemDataSource.setNewDatas(_audioItems);
        _isLoadingSuccess = true;
      });
    }, (error) {
      debugPrint("_getAllAudios, error: $error");
      setState(() {
        _isLoadingSuccess = true;
      });
    });
  }
  
  // 获取音乐列表
  void _getAllAudios(Function(List<AudioItem> audios) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/audio/all");
    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({}))
        .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("Get all image list, body: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          onSuccess.call(data
              .map((e) => AudioItem.fromJson(e as Map<String, dynamic>))
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
    int num = audioItemDataSource.audios.length;

    String itemNumStr = "共${num}项";

    if (audioItemDataSource.selectedIndex() >= 0) {
      itemNumStr = "选中1项（共${num}项目)";
    }

    return Column(children: [
      Container(
          child: Stack(children: [
            Align(
                alignment: Alignment.center,
                child: Text("音乐",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        inherit: false,
                        color: Color(0xff616161),
                        fontSize: 16.0))),
            Align(
                child: Container(
                    child: Image.asset("icons/icon_delete.png",
                        width: _icon_delete_btn_size,
                        height: _icon_delete_btn_size),
                    decoration: BoxDecoration(
                        color: Color(0xffcb6357),
                        border: new Border.all(
                            color: Color(0xffb43f32), width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    width: _delete_btn_width,
                    height: _delete_btn_height,
                    padding: EdgeInsets.fromLTRB(
                        _delete_btn_padding_hor,
                        _delete_btn_padding_vertical,
                        _delete_btn_padding_hor,
                        _delete_btn_padding_vertical),
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                alignment: Alignment.centerRight)
          ]),
          color: Color(0xfff4f4f4),
          height: Constant.HOME_NAVI_BAR_HEIGHT),
      Divider(
        color: _divider_line_color,
        height: 1.0,
        thickness: 1.0,
      ),

      /// 内容区域
      _createContent(),

      /// 底部固定区域
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
      Container(
          child: Align(
              alignment: Alignment.center,
              child: Text(itemNumStr,
                  style: TextStyle(
                      color: Color(0xff646464), fontSize: 12, inherit: false))),
          height: 20,
          color: Color(0xfffafafa)),
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
    ], mainAxisSize: MainAxisSize.max);
  }

  Widget _createContent() {
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
                    columnResizeIndicatorStrokeWidth: 0),
                child: SfDataGrid(
                  source: audioItemDataSource,
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
                    // setState(() {
                    //   audioItemDataSource
                    //       .setSelectedRow(_dataGridController.selectedIndex);
                    // });
                  },
                  onCellDoubleTap: (details) {
                    _openVideoWithSystemApp(_audioItems[details.rowColumnIndex.rowIndex]);
                  },
                  columns: <GridColumn>[
                    GridColumn(
                        columnName: 'folder',
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '文件夹',
                            style: _headerTextStyle,
                          ),
                          padding: EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0),
                        ),
                        columnWidthMode: ColumnWidthMode.fill,
                        width: columnWidths['name']!,
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth),
                    GridColumn(
                        columnName: 'name',
                        width: columnWidths['name']!,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('名称', style: _headerTextStyle),
                          padding: EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                        allowEditing: false),
                    GridColumn(
                        columnName: 'type',
                        width: columnWidths['type']!,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '类型',
                            style: _headerTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          padding: EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                        allowEditing: false),
                    GridColumn(
                        columnName: 'duration',
                        width: columnWidths['duration']!,
                        label: Container(
                          alignment: Alignment.centerLeft,
                          child: Text('时长', style: _headerTextStyle),
                          padding: EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0),
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                        allowEditing: false),
                    GridColumn(
                        columnName: 'size',
                        width: columnWidths['size']!,
                        label: Container(
                            alignment: Alignment.centerLeft,
                            child: Text('大小', style: _headerTextStyle),
                            padding: EdgeInsets.fromLTRB(_headerPaddingStart, 0, 0, 0)
                        ),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                        allowEditing: false),
                  ],
                ))));
  }

  void _openVideoWithSystemApp(AudioItem audioItem) async {
    String encodedPath = Uri.encodeComponent(audioItem.path);
    String videoUrl = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/stream/file?path=${encodedPath}";

    if (!await launch(
        videoUrl,
        universalLinksOnly: true
    )) {
      debugPrint("Open video: $videoUrl fail");
    } else {
      debugPrint("Open video: $videoUrl success");
    }
  }
}

// 用于构建表格数据
class AudioItemDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];
  int _selectedIndex = -1;
  final _KB_BOUND = 1 * 1024;
  final _MB_BOUND = 1 * 1024 * 1024;
  final _GB_BOUND = 1 * 1024 * 1024 * 1024;
  BuildContext context;
  List<AudioItem> audios = [];

  final _ONE_HOUR = 60 * 60 * 1000;
  final _ONE_MINUTE = 60 * 1000;
  final _ONE_SECOND = 1000;

  AudioItemDataSource(this.context, this.audios) {
    setNewDatas(audios);
  }

  void setNewDatas(List<AudioItem> datas) {
    this.audios = datas;
    _dataGridRows = datas
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<AudioItem>(columnName: 'folder', value: e),
              DataGridCell<AudioItem>(columnName: 'name', value: e),
              DataGridCell<AudioItem>(columnName: 'type', value: e),
              DataGridCell<AudioItem>(columnName: 'duration', value: e),
              DataGridCell<AudioItem>(columnName: 'size', value: e),
            ]))
        .toList();
    notifyListeners();
  }

  void setSelectedRow(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int selectedIndex() {
    return _selectedIndex;
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
        return Color(0xfff7f7f7);
      }
    }

    return DataGridRowAdapter(
        color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
          var audioItem = e.value as AudioItem;

          String itemValue = audioItem.name;

          switch(e.columnName) {
            case "folder": {
              String folder = audioItem.folder;
              int index = folder.lastIndexOf("/");
              if (index != -1) {
                folder = folder.substring(index + 1);
              }
              itemValue = folder;
              break;
            }
            case "type": {
              String type = "";
              String name = audioItem.name;
              int index = name.lastIndexOf(".");
              if (index != -1) {
                type = name.substring(index + 1);
              }
              itemValue = type.toUpperCase();
              break;
            }
            case "duration": {
              itemValue = _convertToReadableDuration(audioItem.duration);
              break;
            }
            case "size": {
              itemValue = _convertToReadableSize(audioItem.size);
              break;
            }
          }

          return Container(
            child: Align(
              child: Text(
                itemValue,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    inherit: false,
                    color: Color(0xff313237),
                    fontSize: 14
                ),
                textAlign: TextAlign.left,
              ),
              alignment: Alignment.centerLeft,
            ),
            padding: EdgeInsets.only(left: 10),

          );
        }).toList());
  }

  String _convertToReadableDuration(int duration) {
    if (duration >= _ONE_HOUR) {
      int hour = (duration / _ONE_HOUR).truncate();

      String durStr = "${hour}小时";

      if (duration - hour * _ONE_HOUR > 0) {
        int min = ((duration - hour * _ONE_HOUR) / _ONE_MINUTE).truncate();

        durStr = "${durStr}${min}分";

        if (duration - hour * _ONE_HOUR - min * _ONE_MINUTE > 0) {
          int sec = ((duration - hour * _ONE_HOUR - min * _ONE_MINUTE) / _ONE_SECOND).truncate();

          durStr = "${durStr}${sec}秒";
        }
      }

      return durStr;
    } else if (duration < _ONE_HOUR && duration >= _ONE_MINUTE) {
      int min = (duration / _ONE_MINUTE).truncate();

      String durStr = "${min}分";

      if (duration - min * _ONE_MINUTE > 0) {
        int sec = ((duration - min * _ONE_MINUTE) / _ONE_SECOND).truncate();

        durStr = "${durStr}${sec}秒";
      }

      return durStr;
    } else {
      int sec = (duration / _ONE_SECOND).truncate();

      return "${sec}秒";
    }
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
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails details) {
    if (details.name == "folder") {
      AudioItem audioItemA = a?.getCells().singleWhere((element) => element.columnName == "folder").value as AudioItem;
      AudioItem audioItemB = b?.getCells().singleWhere((element) => element.columnName == "folder").value as AudioItem;

      String folderA = audioItemA.folder;
      String folderB = audioItemB.folder;

      int lastIndexA = folderA.lastIndexOf("/");

      if (lastIndexA != -1) {
        folderA = folderA.substring(lastIndexA + 1);
      }

      int lastIndexB = folderB.lastIndexOf("/");

      if (lastIndexB != -1) {
        folderB = folderB.substring(lastIndexB + 1);
      }

      if (details.sortDirection == DataGridSortDirection.ascending) {
        return folderA.toLowerCase().compareTo(folderB.toLowerCase());
      } else {
        return folderB.toLowerCase().compareTo(folderA.toLowerCase());
      }
    }

    if (details.name == "name") {
      AudioItem audioItemA = a?.getCells().singleWhere((element) => element.columnName == "name").value as AudioItem;
      AudioItem audioItemB = b?.getCells().singleWhere((element) => element.columnName == "name").value as AudioItem;

      if (details.sortDirection == DataGridSortDirection.ascending) {
        return audioItemA.name.toLowerCase().compareTo(audioItemB.name.toLowerCase());
      } else {
        return audioItemB.name.toLowerCase().compareTo(audioItemA.name.toLowerCase());
      }
    }

    if (details.name == "size") {
      AudioItem audioItemA = a?.getCells().singleWhere((element) => element.columnName == "size").value as AudioItem;
      AudioItem audioItemB = b?.getCells().singleWhere((element) => element.columnName == "size").value as AudioItem;

      if (details.sortDirection == DataGridSortDirection.ascending) {
        return audioItemA.size.compareTo(audioItemB.size);
      } else {
        return audioItemB.size.compareTo(audioItemA.size);
      }
    }

    if (details.name == "duration") {
      AudioItem audioItemA = a?.getCells().singleWhere((element) => element.columnName == "size").value as AudioItem;
      AudioItem audioItemB = b?.getCells().singleWhere((element) => element.columnName == "size").value as AudioItem;

      if (details.sortDirection == DataGridSortDirection.ascending) {
        return audioItemA.duration.compareTo(audioItemB.duration);
      } else {
        return audioItemB.duration.compareTo(audioItemA.duration);
      }
    }

    return 0;
  }
}
