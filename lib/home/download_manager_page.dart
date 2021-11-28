import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_assistant_client/home/download/download_file_manager.dart';
import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_assistant_client/model/ResponseEntity.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';

import '../constant.dart';
import '../ext/string-ext.dart';
import 'download/download_icon_mode_page.dart';
import 'download/download_list_mode_page.dart';

class DownloadManagerPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _DownloadManagerState();
  }
}

class _DownloadManagerState extends State<DownloadManagerPage> {
  bool _isLoadingCompleted = false;
  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  final _downloadIconModePage = DownloadIconModePage();
  final _downloadListModePage = DownloadListModePage();

  @override
  void initState() {
    super.initState();

    _getDownloadFiles((files) {
      setState(() {
        DownloadFileManager.instance.updateFiles(files);
        _downloadIconModePage.rebuild();
        // _downloadListModePage.reb
        _isLoadingCompleted = true;
      });
    }, (error) {
      _isLoadingCompleted = true;
      debugPrint("_getDownloadFiles, error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _createContent();

    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    return Stack(
      children: [
        content,
        Visibility(
          child: Container(child: spinKit, color: Colors.white),
          maintainSize: false,
          visible: !_isLoadingCompleted,
        )
      ],
    );
  }

  void _getDownloadFiles(Function(List<FileItem> files) onSuccess, Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/file/downloadedFiles");
    http
        .post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({}))
        .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("Get download file list, body: $body");

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

  Widget _createContent() {
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
    final _divider_line_color = Color(0xffe0e0e0);

    String itemNumStr = "共108项";

    return Column(children: [
      Container(
          child: Stack(children: [
            Align(
                alignment: Alignment.center,
                child: Text("全部文件",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        inherit: false,
                        color: Color(0xff616161),
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
                                  color: Color(0xffc1c1c1),
                                  border: new Border.all(
                                      color: Color(0xffababab), width: 1.0),
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
                                  color: Color(0xfff5f6f5),
                                  border: new Border.all(
                                      color: Color(0xffdededd), width: 1.0),
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
                                  color: Color(0xffcb6357),
                                  border: new Border.all(
                                      color: Color(0xffb43f32), width: 1.0),
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
                    width: 125),
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
      _createPageView(),

      /// 底部固定区域
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
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
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
    ], mainAxisSize: MainAxisSize.max);
  }

  Widget _createPageView() {
    PageController controller = PageController();

    return Expanded(
        child: PageView(
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _downloadIconModePage,
        _downloadListModePage
      ],
      onPageChanged: (index) {
        debugPrint("onPageChanged, index: $index");
        setState(() {});
      },
      controller: controller,
    ));
  }
}
