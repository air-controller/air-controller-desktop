import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../ext/string-ext.dart';
import '../constant.dart';

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
}
