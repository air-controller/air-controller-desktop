import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/model/Device.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../ext/string-ext.dart';
import '../constant.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../model/FileItem.dart';

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
  final _headerTextStyle = TextStyle(color: "#5d5e63".toColor(), fontSize: 12, inherit: false);
  final _minColumnWidth = 200.0;
  final _maxColumnWidth = 400.0;

  List<FileItem> _fileItems = <FileItem>[];
  late FileItemDataSource fileItemDataSource;

  @override
  void initState() {
    super.initState();
    _fileItems = mockFileItems();
    fileItemDataSource = FileItemDataSource(datas: _fileItems);
  }

  @override
  Widget build(BuildContext context) {
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
                      columnResizeIndicatorStrokeWidth: 0
                  ),
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
                    onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                      setState(() {
                        columnWidths[details.column.columnName] = details.width;
                      });
                      return true;
                    },
                    columns: <GridColumn>[
                      GridColumn(
                          columnName: 'name',
                          label: Container(
                              alignment: Alignment.center,
                              child: Text(
                                '名称',
                                style: _headerTextStyle,
                              )),
                          columnWidthMode: ColumnWidthMode.fill,
                          width: columnWidths['name']!,
                          minimumWidth: _minColumnWidth,
                      maximumWidth: _maxColumnWidth),
                      GridColumn(
                        columnName: 'size',
                        width: columnWidths['size']!,
                        label: Container(
                            alignment: Alignment.center,
                            child: Text('大小',
                                style: _headerTextStyle)),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                      ),
                      GridColumn(
                        columnName: 'category',
                        width: columnWidths['category']!,
                        label: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '种类',
                              style: _headerTextStyle,
                              overflow: TextOverflow.ellipsis,
                            )),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                      ),
                      GridColumn(
                        columnName: 'changeDate',
                        width: columnWidths['changeDate']!,
                        label: Container(
                            alignment: Alignment.center,
                            child: Text('修改日期',
                                style: _headerTextStyle)),
                        minimumWidth: _minColumnWidth,
                        maximumWidth: _maxColumnWidth,
                        columnWidthMode: ColumnWidthMode.fill,
                      ),

                      GridColumn(
                        columnName: '',
                        width: columnWidths['empty']!,
                        label: Container(
                            alignment: Alignment.center,
                            child: Text('',
                                style: _headerTextStyle)),
                        minimumWidth: 80,
                        columnWidthMode: ColumnWidthMode.none,
                      ),
                    ],
                  )
              )
          )
      );
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

  List<FileItem> mockFileItems() {
    return [
      FileItem("a1", '/d1/d2/d3', true, 100, 10000),
      FileItem("a2", '/d1/d2/d3', false, 100, 10000),
      FileItem("a3", '/d1/d2/d3', true, 100, 10000),
      FileItem("a4", '/d1/d2/d3', true, 100, 10000),
      FileItem("a5", '/d1/d2/d3', true, 100, 10000),
      FileItem("a6", '/d1/d2/d3', true, 100, 10000),

      FileItem("a1", '/d1/d2/d3', true, 100, 10000),
      FileItem("a2", '/d1/d2/d3', false, 100, 10000),
      FileItem("a3", '/d1/d2/d3', true, 100, 10000),
      FileItem("a4", '/d1/d2/d3', true, 100, 10000),
      FileItem("a5", '/d1/d2/d3', true, 100, 10000),
      FileItem("a6", '/d1/d2/d3', true, 100, 10000),

    ];
  }
}

// 用于构建表格数据
class FileItemDataSource extends DataGridSource {
  List<DataGridRow> _dataGridRows = [];

  FileItemDataSource({required List<FileItem> datas}) {
    _dataGridRows = datas
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: e.name),
              DataGridCell<int>(columnName: 'size', value: e.size),
              DataGridCell<String>(
                  columnName: 'category',
                  value: _convertToCategory(e.name, e.isDir)),
              DataGridCell<String>(
                  columnName: 'changeDate', value: "${e.changeDate}"),
              DataGridCell<String>(
                  columnName: 'empty', value: ""),
                    ]))
        .toList();
  }

  String _convertToCategory(String name, bool isDir) {
    if (isDir) {
      return "文件夹";
    } else {
      return name;
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

    return DataGridRowAdapter(
      color: getRowBackgroundColor(),
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  @override
  bool shouldRecalculateColumnWidths() {
    return true;
  }
}
