import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assistant_client/home/all_file_manager_page.dart';
import 'package:mobile_assistant_client/home/download_manager_page.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:mobile_assistant_client/home/music_manager_page.dart';
import 'package:mobile_assistant_client/home/video_manager_page.dart';
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

  FileManagerState? state;

  final String title;

  @override
  State createState() {
    state = FileManagerState();
    return state!;
  }
}

class FileManagerState extends State<FileManagerPage> {
  final _icons_size = 30.0;
  final _tab_height = 50.0;
  final _icon_margin_hor = 10.0;
  final _tab_font_size = 16.0;
  final _tab_width = 210.0;
  final _color_tab_selected = "#ededed";

  static final PAGE_INDEX_IMAGE = 0;
  static final PAGE_INDEX_MUSIC = 1;
  static final PAGE_INDEX_VIDEO = 2;
  static final PAGE_INDEX_DOWNLOAD = 3;
  static final PAGE_INDEX_ALL_FILE = 4;

  static final _DEFAULT_SELECTED_PAGE_INDEX = 0;
  int _selectedPageIndex = _DEFAULT_SELECTED_PAGE_INDEX;
  // 用于监听Control、Shift键按下
  late final FocusNode _focusNode;
  late final FocusAttachment _nodeAttachment;
  bool _isControlDown = false;
  bool _isShiftDown = false;
  
  List<Function()> _ctrlAPressedCallbacks = [];
  
  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode(debugLabel: 'All image page');
    _nodeAttachment = _focusNode.attach(context, onKey: (node, event) {
      _isControlDown = event.isControlPressed;
      _isShiftDown = event.isShiftPressed;

      bool isKeyAPressed = event.isKeyPressed(LogicalKeyboardKey.keyA);
      if (_isControlDown && isKeyAPressed) {
        debugPrint("Ctrl + A pressed...");

        for (Function() callback in _ctrlAPressedCallbacks) {
          callback.call();
        }
      }

      return KeyEventResult.handled;
    });
    _focusNode.requestFocus();
  }
  
  void addCtrlAPressedCallback(Function() callback) {
    _ctrlAPressedCallbacks.add(callback);
  }
  
  void removeCtrlAPressedCallback(Function() callback) {
    _ctrlAPressedCallbacks.remove(callback);
  }
  
  bool isControlDown() => _isControlDown;

  bool isShiftDown() => _isShiftDown;
  
  @override
  Widget build(BuildContext context) {
    _nodeAttachment.reparent();

    final pageController = PageController(initialPage: _selectedPageIndex);

    Color getTabBgColor(int currentIndex) {
      if (currentIndex == _selectedPageIndex) {
        return Color(0xffededed);
      } else {
        return Color(0xfffafafa);
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
          child: Column(children: [
            Container(
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("MIX 2S",
                        style: TextStyle(
                            inherit: false, color: "#656565".toColor()))),
                height: 40.0,
                padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
            Divider(height: 1, color: "#e0e0e0".toColor()),
            GestureDetector(
              child: Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Image.asset("icons/icon_image.png",
                              width: _icons_size, height: _icons_size),
                          margin: EdgeInsets.fromLTRB(
                              _icon_margin_hor, 0, _icon_margin_hor, 0)),
                      Text("图片",
                          style: TextStyle(
                              inherit: false,
                              color: "#636363".toColor(),
                              fontSize: _tab_font_size))
                    ]),
                height: _tab_height,
                color: getTabBgColor(0),
              ),
              onTap: () {
                debugPrint("Image tab click");
                pageController.jumpToPage(0);
              },
            ),
            Divider(height: 1, color: "#e0e0e0".toColor()),
            GestureDetector(
              child: Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Image.asset("icons/icon_music.png",
                              width: _icons_size, height: _icons_size),
                          margin: EdgeInsets.fromLTRB(
                              _icon_margin_hor, 0, _icon_margin_hor, 0)),
                      Text("音乐",
                          style: TextStyle(
                              inherit: false,
                              color: "#636363".toColor(),
                              fontSize: _tab_font_size))
                    ]),
                height: _tab_height,
                color: getTabBgColor(1),
              ),
              onTap: () {
                pageController.jumpToPage(1);
              },
            ),
            Divider(height: 1, color: "#e0e0e0".toColor()),
            GestureDetector(
              child: Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Image.asset("icons/icon_video.png",
                              width: _icons_size, height: _icons_size),
                          margin: EdgeInsets.fromLTRB(
                              _icon_margin_hor, 0, _icon_margin_hor, 0)),
                      Text("视频",
                          style: TextStyle(
                              inherit: false,
                              color: "#636363".toColor(),
                              fontSize: _tab_font_size))
                    ]),
                height: _tab_height,
                color: getTabBgColor(2),
              ),
              onTap: () {
                pageController.jumpToPage(2);
              },
            ),
            Divider(height: 1, color: "#e0e0e0".toColor()),
            GestureDetector(
              child: Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Image.asset("icons/icon_download.png",
                              width: _icons_size, height: _icons_size),
                          margin: EdgeInsets.fromLTRB(
                              _icon_margin_hor, 0, _icon_margin_hor, 0)),
                      Text("下载",
                          style: TextStyle(
                              inherit: false,
                              color: "#636363".toColor(),
                              fontSize: _tab_font_size))
                    ]),
                height: _tab_height,
                color: getTabBgColor(3),
              ),
              onTap: () {
                pageController.jumpToPage(3);
              },
            ),
            Divider(height: 1, color: "#e0e0e0".toColor()),
            GestureDetector(
              child: Container(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          child: Image.asset("icons/icon_all_file.png",
                              width: _icons_size, height: _icons_size),
                          margin: EdgeInsets.fromLTRB(
                              _icon_margin_hor, 0, _icon_margin_hor, 0)),
                      Text("全部文件",
                          style: TextStyle(
                              inherit: false,
                              color: "#636363".toColor(),
                              fontSize: _tab_font_size))
                    ]),
                height: _tab_height,
                color: getTabBgColor(4),
              ),
              onTap: () {
                pageController.jumpToPage(4);
              },
            ),
            Divider(height: 1, color: "#e0e0e0".toColor()),
          ]),
          width: _tab_width,
          color: "#fafafa".toColor()),
      VerticalDivider(width: 1.0, thickness: 1.0, color: "#e1e1d3".toColor()),
      Expanded(
          child: PageView(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ImageManagerPage(),
                MusicManagerPage(),
                VideoManagerPage(),
                DownloadManagerPage(),
                AllFileManagerPage()
              ],
              onPageChanged: (index) {
                debugPrint("onPageChanged, index: $index");
                setState(() {
                  _selectedPageIndex = index;
                });
              },
              controller: pageController))
    ]);
  }

  int selectedTabIndex() {
    return _selectedPageIndex;
  }

  @override
  void dispose() {
    super.dispose();

    _focusNode.dispose();
  }
}
