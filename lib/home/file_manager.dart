import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/home/all_file_manager_page.dart';
import 'package:mobile_assistant_client/home/download_manager_page.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:mobile_assistant_client/home/music_manager_page.dart';
import '../ext/string-ext.dart';
import '../constant.dart';

class FileManagerWidget extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文件管理页面',
      debugShowCheckedModeBanner: !Constant.HIDE_DEBUG_MARK,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FileManagerPage(title: '手机助手PC端'),
    );
  }
}

class FileManagerPage extends StatefulWidget {
  FileManagerPage({Key? key, required this.title}) : super(key: key) {}

  final String title;

  @override
  State createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManagerPage> {
  final _icons_size = 30.0;
  final _tab_height = 50.0;
  final _icon_margin_hor = 10.0;
  final _tab_font_size = 16.0;
  final _tab_width = 210.0;
  final _color_tab_selected = "#ededed";

  @override
  Widget build(BuildContext context) {
    final pageController = PageController(initialPage: 4);

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(child: Column(children: [
        Container(child: Align(alignment: Alignment.centerLeft,child: Text("MIX 2S", style: TextStyle(inherit: false, color: "#656565".toColor()))),
        height: 40.0, padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),

        Divider(height: 1, color: "#e0e0e0".toColor()),
        Container(child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(child: Image.asset("icons/icon_image.png", width: _icons_size, height: _icons_size), margin: EdgeInsets.fromLTRB(_icon_margin_hor, 0, _icon_margin_hor, 0)),
            Text("图片", style: TextStyle(inherit: false, color: "#636363".toColor(), fontSize: _tab_font_size))
          ]
        ), height: _tab_height),

        Divider(height: 1, color: "#e0e0e0".toColor()),

        Container(child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child: Image.asset("icons/icon_music.png", width: _icons_size, height: _icons_size), margin: EdgeInsets.fromLTRB(_icon_margin_hor, 0, _icon_margin_hor, 0)),
              Text("音乐", style: TextStyle(inherit: false, color: "#636363".toColor(), fontSize: _tab_font_size))
            ]
        ), height: _tab_height),

        Divider(height: 1, color: "#e0e0e0".toColor()),

        Container(child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child: Image.asset("icons/icon_video.png", width: _icons_size, height: _icons_size), margin: EdgeInsets.fromLTRB(_icon_margin_hor, 0, _icon_margin_hor, 0)),
              Text("视频", style: TextStyle(inherit: false, color: "#636363".toColor(), fontSize: _tab_font_size))
            ]
        ), height: _tab_height),

        Divider(height: 1, color: "#e0e0e0".toColor()),

        Container(child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child: Image.asset("icons/icon_download.png", width: _icons_size, height: _icons_size), margin: EdgeInsets.fromLTRB(_icon_margin_hor, 0, _icon_margin_hor, 0)),
              Text("下载", style: TextStyle(inherit: false, color: "#636363".toColor(), fontSize: _tab_font_size))
            ]
        ), height: _tab_height),

        Divider(height: 1, color: "#e0e0e0".toColor()),

        Container(child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(child: Image.asset("icons/icon_all_file.png", width: _icons_size, height: _icons_size), margin: EdgeInsets.fromLTRB(_icon_margin_hor, 0, _icon_margin_hor, 0)),
              Text("全部文件", style: TextStyle(inherit: false, color: "#636363".toColor(), fontSize: _tab_font_size))
            ]
        ), height: _tab_height),
        Divider(height: 1, color: "#e0e0e0".toColor()),

      ]), width: _tab_width, color: "#fafafa".toColor()),

      VerticalDivider(width: 1.0, thickness: 1.0, color: "#e1e1d3".toColor()),

      Expanded(
          child: PageView(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ImageManagerPage(),
                MusicManagerPage(),
                DownloadManagerPage(),
                DownloadManagerPage(),
                AllFileManagerPage()
              ],
              controller: pageController))
    ]);
  }
}
