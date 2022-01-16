import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_assistant_client/event/update_mobile_info.dart';
import 'package:mobile_assistant_client/home/download_manager_page.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:mobile_assistant_client/home/music_manager_page.dart';
import 'package:mobile_assistant_client/home/video_manager_page.dart';
import 'package:mobile_assistant_client/main.dart';
import 'package:mobile_assistant_client/model/mobile_info.dart';
import 'package:mobile_assistant_client/network/cmd_client.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/network/heartbeat_service.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';
import '../ext/string-ext.dart';
import '../constant.dart';
import 'all_file_manager_page.dart';

class FileManagerPage extends StatefulWidget {
  static final GlobalKey<FileManagerState> fileManagerKey = GlobalKey();

  FileManagerPage({Key? key}) : super(key: key) {}

  FileManagerState? state;

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

  MobileInfo? _mobileInfo;

  StreamSubscription<UpdateMobileInfo>? _updateMobileInfoStream;

  bool _isPopupIconHover = false;

  bool _isPopupIconDown = false;

  @override
  void initState() {
    super.initState();

    _registerEventBus();

    // _focusNode = FocusNode(debugLabel: 'All image page');
    // _nodeAttachment = _focusNode.attach(context, onKey: (node, event) {
    //   _isControlDown = event.isControlPressed;
    //   _isShiftDown = event.isShiftPressed;
    //
    //   bool isKeyAPressed = event.isKeyPressed(LogicalKeyboardKey.keyA);
    //   if (_isControlDown && isKeyAPressed) {
    //     debugPrint("Ctrl + A pressed...");
    //
    //     for (Function() callback in _ctrlAPressedCallbacks) {
    //       callback.call();
    //     }
    //   }
    //
    //   return KeyEventResult.handled;
    // });
    // _focusNode.requestFocus();
  }

  void _registerEventBus() {
    _updateMobileInfoStream = eventBus.on<UpdateMobileInfo>().listen((event) {
      setState(() {
        _mobileInfo = event.mobileInfo;
      });
    });
  }

  void _unRegisterEventBus() {
    _updateMobileInfoStream?.cancel();
  }

  void addCtrlAPressedCallback(Function() callback) {
    _ctrlAPressedCallbacks.add(callback);
    debugPrint(
        "After addCtrlAPressedCallback, _ctrlAPressedCallbacks length: ${_ctrlAPressedCallbacks.length}");
  }

  void removeCtrlAPressedCallback(Function() callback) {
    _ctrlAPressedCallbacks.remove(callback);
    debugPrint(
        "After removeCtrlAPressedCallback, _ctrlAPressedCallbacks length: ${_ctrlAPressedCallbacks.length}");
  }

  bool isControlDown() => _isControlDown;

  bool isShiftDown() => _isShiftDown;

  @override
  Widget build(BuildContext context) {
    // _nodeAttachment.reparent();

    final pageController = PageController(initialPage: _selectedPageIndex);

    Color getTabBgColor(int currentIndex) {
      if (currentIndex == _selectedPageIndex) {
        return Color(0xffededed);
      } else {
        return Color(0xfffafafa);
      }
    }

    String batteryInfo = "";
    if (null != _mobileInfo) {
      batteryInfo = "电量：${_mobileInfo?.batteryLevel}%";
    }

    String storageInfo = "";
    if (null != _mobileInfo) {
      storageInfo =
          "手机存储：${(_mobileInfo!.storageSize.availableSize ~/ (1024 * 1024 * 1024)).toStringAsFixed(1)}/" +
              "${_mobileInfo!.storageSize.totalSize ~/ (1024 * 1024 * 1024)}GB";
    }

    Color hoverIconBgColor = Color(0xfffafafa);
    if (_isPopupIconDown) {
      hoverIconBgColor = Color(0xffe4e4e4);
    }

    if (!_isPopupIconDown && _isPopupIconHover) {
      hoverIconBgColor = Color(0xffededed);
    }

    if (!_isPopupIconDown && !_isPopupIconHover) {
      hoverIconBgColor = Color(0xfffafafa);
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
              child: Stack(
                children: [
                  Column(children: [
                    Container(
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("${DeviceConnectionManager.instance.currentDevice?.name}",
                                style: TextStyle(
                                    inherit: false,
                                    color: "#656565".toColor()))),
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
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
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
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
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
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
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
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
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
                                  margin: EdgeInsets.fromLTRB(_icon_margin_hor,
                                      0, _icon_margin_hor, 0)),
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
                  Positioned(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "${DeviceConnectionManager.instance.currentDevice?.name}",
                                style: TextStyle(
                                    inherit: false,
                                    fontSize: 16,
                                    color: Color(0xff656568)),
                              ),
                              // color: Colors.blue,
                            ),

                            InkWell(
                              child: Container(
                                child: Image.asset("icons/ic_popup.png",
                                    width: 13, height: 13),
                                // 注意：这里尚未找到方案，让该控件靠右排列，暂时使用margin
                                // 方式进行处理
                                margin: EdgeInsets.only(left: 100),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                  color: hoverIconBgColor
                                ),
                                padding: EdgeInsets.all(3.0),
                                // color: Colors.yellow,
                              ),
                              onTap: () {
                                _exitFileManager();

                                setState(() {
                                  _isPopupIconDown = false;
                                });
                              },
                              onTapDown: (detail) {
                                debugPrint("onTapDown");

                                setState(() {
                                  _isPopupIconDown = true;
                                });
                              },
                              onTapCancel: () {
                                debugPrint("onTapCancel");

                                setState(() {
                                  _isPopupIconDown = false;
                                });
                              },
                              onHover: (isHover) {
                                debugPrint("isHover: $isHover");

                                setState(() {
                                  _isPopupIconHover = isHover;
                                });
                              },
                              autofocus: true,
                            )
                          ],
                        ),
                        Container(
                          child: Text(
                            batteryInfo,
                            style: TextStyle(
                                inherit: false,
                                color: Color(0xff8b8b8e),
                                fontSize: 13),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        ),
                        Container(
                          child: Text(
                            storageInfo,
                            style: TextStyle(
                                inherit: false,
                                color: Color(0xff8b8b8e),
                                fontSize: 13),
                          ),
                          margin: EdgeInsets.only(top: 10),
                        )
                      ],
                    ),
                    bottom: 20,
                    left: 20,
                  )
                ],
              ),
              width: _tab_width,
              height: double.infinity,
              color: "#fafafa".toColor()),
          VerticalDivider(
              width: 1.0, thickness: 1.0, color: "#e1e1d3".toColor()),
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

  void _exitFileManager() {
    DeviceConnectionManager.instance.currentDevice = null;
    CmdClient.getInstance().disconnect();
    HeartbeatService.instance.cancel();
    Navigator.pop(context);
  }

  int selectedTabIndex() {
    return _selectedPageIndex;
  }

  @override
  void dispose() {
    super.dispose();

    _focusNode.dispose();
    _ctrlAPressedCallbacks.clear();

    _unRegisterEventBus();
  }
}
