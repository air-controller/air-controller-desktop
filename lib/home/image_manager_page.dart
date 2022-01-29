import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/event/back_btn_pressed.dart';
import 'package:mobile_assistant_client/event/back_btn_visibility.dart';
import 'package:mobile_assistant_client/event/delete_op.dart';
import 'package:mobile_assistant_client/event/image_range_mode_visibility.dart';
import 'package:mobile_assistant_client/event/open_image_detail.dart';
import 'package:mobile_assistant_client/event/update_delete_btn_status.dart';
import 'package:mobile_assistant_client/event/update_image_arrange_mode.dart';
import 'package:mobile_assistant_client/home/image/album_image_manager_page.dart';
import 'package:mobile_assistant_client/home/image/all_album_manager_page.dart';
import 'package:mobile_assistant_client/home/image/all_image_manager_page.dart';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';
import 'package:mobile_assistant_client/model/UIModule.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';
import 'package:mobile_assistant_client/widget/confirm_dialog_builder.dart';
import 'package:mobile_assistant_client/widget/progress_indictor_dialog.dart';
import 'package:mobile_assistant_client/widget/upward_triangle.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../event/update_bottom_item_num.dart';
import '../model/ImageItem.dart';
import 'package:http/http.dart' as http;

class ImageManagerPage extends StatefulWidget {
  ImageManagerPage();

  static final ARRANGE_MODE_GRID = 1;
  static final ARRANGE_MODE_DAILY = 2;
  static final ARRANGE_MODE_MONTHLY = 3;

  ImageManagerState? state;

  @override
  State<StatefulWidget> createState() {
    state = ImageManagerState();
    return state!;
  }
}

class ImageManagerState extends State<ImageManagerPage> {
  static final INDEX_ALL_IMAGE = 0;
  static final INDEX_CAMERA_ALBUM = 1;
  static final INDEX_ALL_ALBUM = 2;

  int _currentIndex = INDEX_ALL_IMAGE;
  final _divider_line_color = Color(0xffe0e0e0);

  static const _ARRANGE_MODE_GRID = 0;
  static const _ARRANGE_MODE_DAILY = 1;
  static const _ARRANGE_MODE_MONTHLY = 2;

  final _KB_BOUND = 1 * 1024;
  final _MB_BOUND = 1 * 1024 * 1024;
  final _GB_BOUND = 1 * 1024 * 1024 * 1024;

  int _arrange_mode = _ARRANGE_MODE_GRID;

  AllImageManagerPage _allImageManagerPage = AllImageManagerPage();
  final _albumImageManagerPage = AlbumImageManagerPage();
  final _allAlbumManagerPage = AllAlbumManagerPage();

  bool _isBackBtnDown = false;
  double _imageSizeSliderValue = 0.0;

  int _currentImageIndex = -1;
  List<ImageItem> _allImageItems = <ImageItem>[];

  bool _openImageDetail = false;

  final _URL_SERVER =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  double _currentImageScale = 1.0;

  // 标记删除按钮是否可以点击
  bool _isDeleteBtnEnabled = false;
  int _allItemNum = 0;
  int _selectedItemNum = 0;
  bool _isBackBtnVisible = false;

  // 排列方式按钮可见性
  bool _rangeModeVisibility = true;

  DownloaderCore? _downloaderCore;
  ProgressIndicatorDialog? _progressIndicatorDialog;

  Offset? _aboutIconTapDownPosition;
  bool _isAboutIconTapDown = false;

  GlobalKey _aboutIconKey = GlobalKey();

  FocusNode? _imageDetailFocusNode;

  // 标记图片详情弹窗是否显示中
  bool _isImageInfoDialogShowing = false;

  StreamSubscription<UpdateDeleteBtnStatus>? _updateDeleteBtnStream;
  StreamSubscription<UpdateBottomItemNum>? _updateBottomItemNumStream;
  StreamSubscription<OpenImageDetail>? _openImageDetailStream;
  StreamSubscription<BackBtnVisibility>? _backBtnVisibilityStream;
  StreamSubscription<ImageRangeModeVisibility>? _imageRangeModeVisibilityStream;

  @override
  void initState() {
    super.initState();
    _registerEventBus();
  }

  void _registerEventBus() {
    _updateDeleteBtnStream =
        eventBus.on<UpdateDeleteBtnStatus>().listen((event) {
      setDeleteBtnEnabled(event.isEnable);
    });

    _updateBottomItemNumStream =
        eventBus.on<UpdateBottomItemNum>().listen((event) {
      updateBottomItemNumber(event.totalNum, event.selectedNum);
    });

    _openImageDetailStream = eventBus.on<OpenImageDetail>().listen((event) {
      openImageDetail(event.images, event.current);
    });

    _backBtnVisibilityStream = eventBus.on<BackBtnVisibility>().listen((event) {
      setState(() {
        _isBackBtnVisible = event.visible;
      });
    });

    _imageRangeModeVisibilityStream =
        eventBus.on<ImageRangeModeVisibility>().listen((event) {
      setState(() {
        _rangeModeVisibility = event.visible;
        debugPrint("Event bus _rangeModeVisibility: $_rangeModeVisibility");
      });
    });
  }

  void _unRegisterEventBus() {
    _updateDeleteBtnStream?.cancel();
    _updateBottomItemNumStream?.cancel();
    _openImageDetailStream?.cancel();
    _backBtnVisibilityStream?.cancel();
    _imageRangeModeVisibilityStream?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewWidget = _createImagePreviewWidget();
    Widget imageListWidget = _createImageListWidget();

    return Stack(
      children: [
        Visibility(
          child: imageListWidget,
          visible: _openImageDetail ? false : true,
          maintainState: true,
          maintainSize: false,
          maintainAnimation: false,
        ),
        VisibilityDetector(
            key: Key("image_detail_page"),
            child: Visibility(
              child: previewWidget,
              visible: _openImageDetail ? true : false,
            ),
            onVisibilityChanged: (info) {
              if (info.visibleFraction >= 1) {
                _imageDetailFocusNode?.requestFocus();
              }

              if (info.visibleFraction <= 0) {
                _imageDetailFocusNode?.unfocus();
              }
            })
      ],
    );
  }

  void _updateArrangeMode(int rangeModeIndex) {
    switch (rangeModeIndex) {
      case _ARRANGE_MODE_DAILY:
        {
          eventBus.fire(
              UpdateImageArrangeMode(ImageManagerPage.ARRANGE_MODE_DAILY));
          break;
        }
      case _ARRANGE_MODE_MONTHLY:
        {
          eventBus.fire(
              UpdateImageArrangeMode(ImageManagerPage.ARRANGE_MODE_MONTHLY));
          break;
        }
      default:
        {
          eventBus
              .fire(UpdateImageArrangeMode(ImageManagerPage.ARRANGE_MODE_GRID));
        }
    }
  }

  Widget _createImageListWidget() {
    Color getSegmentBtnColor(int index) {
      if (index == _currentIndex) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    final pageController = PageController(initialPage: _currentIndex);

    String _getArrangeModeIcon(int mode) {
      if (mode == _ARRANGE_MODE_GRID) {
        if (_arrange_mode == mode) {
          return "icons/icon_grid_selected.png";
        } else {
          return "icons/icon_grid_normal.png";
        }
      }

      if (mode == _ARRANGE_MODE_DAILY) {
        if (_arrange_mode == mode) {
          return "icons/icon_weekly_selected.png";
        } else {
          return "icons/icon_weekly_normal.png";
        }
      }

      if (_arrange_mode == mode) {
        return "icons/icon_monthly_selected.png";
      } else {
        return "icons/icon_monthly_normal.png";
      }
    }

    Color _getArrangeModeBgColor(int mode) {
      if (_arrange_mode == mode) {
        return Color(0xffc2c2c2);
      } else {
        return Color(0xfff5f5f5);
      }
    }

    String itemNumStr = "共${_allItemNum}项";
    if (_selectedItemNum > 0) {
      itemNumStr = "$itemNumStr (选中${_selectedItemNum}项)";
    }

    _imageDetailFocusNode = FocusNode();
    _imageDetailFocusNode?.canRequestFocus = true;
    _imageDetailFocusNode?.requestFocus();

    return Focus(
      autofocus: true,
      focusNode: _imageDetailFocusNode,
      child: Column(
        children: [
          Container(
            child: Stack(
              children: [
                GestureDetector(
                  child: Visibility(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Row(
                          children: [
                            Image.asset("icons/icon_right_arrow.png",
                                width: 12, height: 12),
                            Container(
                              child: Text("返回",
                                  style: TextStyle(
                                      color: Color(0xff5c5c62), fontSize: 13)),
                              margin: EdgeInsets.only(left: 3),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: _isBackBtnDown
                                ? Color(0xffe8e8e8)
                                : Color(0xfff3f3f4),
                            borderRadius:
                                BorderRadius.all(Radius.circular(3.0)),
                            border: Border.all(
                                color: Color(0xffdedede), width: 1.0)),
                        height: 25,
                        width: 50,
                        margin: EdgeInsets.only(left: 15),
                      ),
                    ),
                    visible: _isBackBtnVisible,
                  ),
                  onTap: () {
                    _onBackPressed();
                  },
                  onTapDown: (detail) {
                    setState(() {
                      _isBackBtnDown = true;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _isBackBtnDown = false;
                    });
                  },
                  onTapUp: (detail) {
                    setState(() {
                      _isBackBtnDown = false;
                    });
                  },
                ),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      child: MaterialSegmentedControl<int>(
                        children: {
                          INDEX_ALL_IMAGE: Container(
                            child: Text("所有图片",
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        getSegmentBtnColor(INDEX_ALL_IMAGE))),
                            padding: EdgeInsets.only(left: 10, right: 10),
                          ),
                          INDEX_CAMERA_ALBUM: Container(
                            child: Text("相机相册",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: getSegmentBtnColor(
                                        INDEX_CAMERA_ALBUM))),
                          ),
                          INDEX_ALL_ALBUM: Container(
                              child: Text("所有相册",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          getSegmentBtnColor(INDEX_ALL_ALBUM))))
                        },
                        selectionIndex: _currentIndex,
                        borderColor: Color(0xffdedede),
                        selectedColor: Color(0xffc3c3c3),
                        unselectedColor: Color(0xfff7f5f6),
                        borderRadius: 3.0,
                        verticalOffset: 0,
                        disabledChildren: [],
                        onSegmentChosen: (index) {
                          setState(() {
                            _currentIndex = index;
                            pageController.jumpToPage(_currentIndex);

                            if (_currentIndex == INDEX_ALL_IMAGE) {
                              _allImageManagerPage.state?.updateBottomItemNum();
                            } else if (_currentIndex == INDEX_CAMERA_ALBUM) {
                              _albumImageManagerPage.state
                                  ?.updateBottomItemNum();
                            } else {
                              _allAlbumManagerPage.state?.updateBottomItemNum();
                            }
                            _updateDeleteBtnStatus();
                          });
                        },
                      ),
                      height: 30,
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: Row(
                      children: [
                        Visibility(
                          child: Row(
                            children: [
                              GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      _getArrangeModeIcon(_ARRANGE_MODE_GRID),
                                      width: 20,
                                      height: 20),
                                  padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffdddedf), width: 1.0),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(4.0),
                                        bottomLeft: Radius.circular(4.0)),
                                    color: _getArrangeModeBgColor(
                                        _ARRANGE_MODE_GRID),
                                  ),
                                ),
                                onTap: () {
                                  if (_arrange_mode != _ARRANGE_MODE_GRID) {
                                    setState(() {
                                      _arrange_mode = _ARRANGE_MODE_GRID;
                                    });
                                    _updateArrangeMode(_arrange_mode);
                                  }
                                },
                              ),
                              GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      _getArrangeModeIcon(_ARRANGE_MODE_DAILY),
                                      width: 20,
                                      height: 20),
                                  padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffdddedf), width: 1.0),
                                    color: _getArrangeModeBgColor(
                                        _ARRANGE_MODE_DAILY),
                                  ),
                                ),
                                onTap: () {
                                  if (_arrange_mode != _ARRANGE_MODE_DAILY) {
                                    setState(() {
                                      _arrange_mode = _ARRANGE_MODE_DAILY;
                                    });
                                    _updateArrangeMode(_arrange_mode);
                                  }
                                },
                              ),
                              GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      _getArrangeModeIcon(
                                          _ARRANGE_MODE_MONTHLY),
                                      width: 20,
                                      height: 20),
                                  padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xffdddedf), width: 1.0),
                                    color: _getArrangeModeBgColor(
                                        _ARRANGE_MODE_MONTHLY),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4.0),
                                        bottomRight: Radius.circular(4.0)),
                                  ),
                                ),
                                onTap: () {
                                  if (_arrange_mode != _ARRANGE_MODE_MONTHLY) {
                                    setState(() {
                                      _arrange_mode = _ARRANGE_MODE_MONTHLY;
                                    });
                                    _updateArrangeMode(_arrange_mode);
                                  }
                                },
                              ),
                            ],
                          ),
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true,
                          visible: _rangeModeVisibility,
                        ),
                        Container(
                            child: GestureDetector(
                              child: Opacity(
                                opacity: _isDeleteBtnEnabled ? 1.0 : 0.6,
                                child: Container(
                                  child: Image.asset("icons/icon_delete.png",
                                      width: 10, height: 10),
                                  decoration: BoxDecoration(
                                      color: Color(0xffcb6357),
                                      border: new Border.all(
                                          color: Color(0xffb43f32), width: 1.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0))),
                                  width: 40,
                                  height: 25,
                                  padding:
                                      EdgeInsets.fromLTRB(6.0, 4.0, 6.0, 4.0),
                                ),
                              ),
                              onTap: () {
                                debugPrint("当前删除按钮点击状态: $_isDeleteBtnEnabled");

                                if (_isDeleteBtnEnabled) {
                                  eventBus.fire(DeleteOp(UIModule.Image));
                                }
                              },
                            ),
                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0))
                      ],
                    ),
                    width: 210,
                  ),
                )
              ],
            ),
            height: Constant.HOME_NAVI_BAR_HEIGHT,
            color: Color(0xfff6f6f6),
          ),
          Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
          Expanded(
            child: PageView(
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _allImageManagerPage,
                _albumImageManagerPage,
                _allAlbumManagerPage
              ],
              onPageChanged: (index) {
                debugPrint("onPageChanged, index: $index");
                setState(() {
                  _currentIndex = index;
                });
              },
              controller: pageController,
            ),
          ),
          Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
          Container(
            child: Align(
              alignment: Alignment.center,
              child: Text(itemNumStr,
                  style: TextStyle(fontSize: 12, color: Color(0xff646464))),
            ),
            height: 20,
            color: Color(0xfffafafa),
          )
        ],
      ),
      onKey: (node, event) {
        debugPrint(
            "Key => ${event.logicalKey.keyId} : ${event.logicalKey.keyLabel}");
        if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
          _dismissImageInfoDialog();
          _deleteImage();
          return KeyEventResult.handled;
        }

        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          _dismissImageInfoDialog();
          _openPreImage();
          return KeyEventResult.handled;
        }

        if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
          _setImageScale(true);
          return KeyEventResult.handled;
        }

        if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
          _setImageScale(false);
          return KeyEventResult.handled;
        }

        if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          _dismissImageInfoDialog();
          _openNextImage();
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
    );
  }

  void _dismissImageInfoDialog() {
    if (_isImageInfoDialogShowing) {
      Navigator.pop(context);
    }
  }

  void _onBackPressed() {
    eventBus.fire(BackBtnPressed());
  }

  Widget _createImagePreviewWidget() {
    String imageIndictorStr =
        "${_currentImageIndex + 1} / ${_allImageItems.length}";

    String imageScaleStr = "${(_currentImageScale / 1.0 * 100).toInt()}%";

    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      // 返回按钮
                      GestureDetector(
                        child: Container(
                          child: Row(
                            children: [
                              Image.asset("icons/icon_right_arrow.png",
                                  width: 12, height: 12),
                              Container(
                                child: Text("返回",
                                    style: TextStyle(
                                        color: Color(0xff5c5c62),
                                        fontSize: 13)),
                                margin: EdgeInsets.only(left: 3),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: _isBackBtnDown
                                  ? Color(0xffe8e8e8)
                                  : Color(0xfff3f3f4),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              border: Border.all(
                                  color: Color(0xffdedede), width: 1.0)),
                          height: 25,
                          padding: EdgeInsets.only(right: 6, left: 2),
                          margin: EdgeInsets.only(left: 15),
                        ),
                        onTap: () {
                          backToImageListPage();
                        },
                        onTapDown: (detail) {
                          setState(() {
                            _isBackBtnDown = true;
                          });
                        },
                        onTapCancel: () {
                          setState(() {
                            _isBackBtnDown = false;
                          });
                        },
                        onTapUp: (detail) {
                          setState(() {
                            _isBackBtnDown = false;
                          });
                        },
                      ),

                      GestureDetector(
                        child: Container(
                          child: Image.asset(
                              "icons/icon_image_size_minus_normal.png",
                              width: 13,
                              height: 60),
                          // color: Colors.red,
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(left: 15),
                        ),
                        onTap: () {
                          _setImageScale(false);
                        },
                      ),

                      // SeekBar
                      Container(
                        child: SliderTheme(
                            data: SliderThemeData(
                                thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                                overlayShape:
                                    RoundSliderOverlayShape(overlayRadius: 7),
                                activeTrackColor: Color(0xffe3e3e3),
                                inactiveTrackColor: Color(0xffe3e3e3),
                                trackHeight: 3,
                                thumbColor: Colors.white),
                            child: Material(
                              child: Slider(
                                value: _imageSizeSliderValue,
                                onChanged: (value) {
                                  debugPrint("Current value: $value");
                                  setState(() {
                                    _imageSizeSliderValue = value;
                                    _currentImageScale =
                                        _imageSizeSliderValue / 100 + 1.0;
                                  });
                                },
                                min: 0,
                                max: 100.0 * Constant.IMAGE_MAX_SCALE - 100.0,
                              ),
                            )),
                        width: 80,
                        margin: EdgeInsets.only(left: 0, right: 0),
                      ),

                      GestureDetector(
                        child: Container(
                          child: Image.asset(
                              "icons/icon_image_size_plus_normal.png",
                              width: 20,
                              height: 20),
                          margin: EdgeInsets.only(right: 15),
                        ),
                        onTap: () {
                          _setImageScale(true);
                        },
                      ),

                      Text(imageScaleStr,
                          style: TextStyle(
                              fontSize: 13, color: Color(0xff7a7a7a))),
                    ],
                  )),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      child: Container(
                          child: Image.asset("icons/icon_image_pre_normal.png",
                              width: 13, height: 13)),
                      onTap: () {
                        _openPreImage();
                      },
                    ),
                    Container(
                      child: Text(imageIndictorStr,
                          style: TextStyle(
                              color: Color(0xff626160), fontSize: 16)),
                      padding: EdgeInsets.only(left: 20, right: 20),
                    ),
                    GestureDetector(
                      child: Container(
                        child: Image.asset("icons/icon_image_next_normal.png",
                            width: 13, height: 13),
                      ),
                      onTap: () {
                        _openNextImage();
                      },
                    )
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  child: Container(
                    key: _aboutIconKey,
                    child: Image.asset("icons/icon_about_image.png",
                        width: 14, height: 14),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(0xffd5d5d5), width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        color: _isAboutIconTapDown
                            ? Color(0xffe7e7e7)
                            : Color(0xfff4f4f4)),
                    padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                    margin: EdgeInsets.only(right: 15),
                  ),
                  onTap: () {
                    _showImageInfoDialog(_allImageItems[_currentImageIndex]);
                  },
                  onTapDown: (event) {
                    setState(() {
                      _isAboutIconTapDown = true;
                    });

                    _aboutIconTapDownPosition = event.localPosition;
                  },
                  onTapUp: (event) {
                    setState(() {
                      _isAboutIconTapDown = false;
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      _isAboutIconTapDown = false;
                    });
                  },
                ),
              )
            ],
          ),
          height: Constant.HOME_NAVI_BAR_HEIGHT,
          color: Color(0xfff6f6f6),
        ),
        Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
        Expanded(
            child: Container(
          child: ExtendedImageGesturePageView.builder(
            itemBuilder: (context, index) {
              return Listener(
                child: ExtendedImage.network(
                  "${_URL_SERVER}/stream/file?path=${_allImageItems[_currentImageIndex].path}",
                  mode: ExtendedImageMode.gesture,
                  fit: BoxFit.contain,
                  initGestureConfigHandler: (state) {
                    return GestureConfig(
                        minScale: 1.0,
                        animationMinScale: 1.0,
                        maxScale: Constant.IMAGE_MAX_SCALE.toDouble(),
                        animationMaxScale: Constant.IMAGE_MAX_SCALE.toDouble(),
                        speed: 1.0,
                        inertialSpeed: 100.0,
                        initialScale: _currentImageScale,
                        inPageView: false,
                        initialAlignment: InitialAlignment.center,
                        gestureDetailsIsChanged: (detail) {
                          debugPrint("Total scale: ${detail?.totalScale}");
                          setState(() {
                            _currentImageScale = detail?.totalScale ?? 1.0;

                            // 设置Slider的值
                            _imageSizeSliderValue =
                                (_currentImageScale - 1.0) / 1.0 * 100;

                            debugPrint(
                                "Image slider value: ${_imageSizeSliderValue}");
                          });
                        });
                  },
                  onDoubleTap: (event) {
                    _setImageScale(true);
                  },
                ),
                onPointerDown: (event) {
                  if (_isMouseRightClicked(event)) {
                    _openMenu(
                        event.position, _allImageItems[_currentImageIndex]);
                  }
                },
              );
            },
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _allImageItems.length,
          ),
          color: Colors.white,
        ))
      ],
    );
  }

  void _showImageInfoDialog(ImageItem imageItem) {
    TextStyle textStyle = TextStyle(color: Color(0xff636363), fontSize: 13);

    String name = "";
    String path = "";
    int index = imageItem.path.lastIndexOf("/");
    if (index != -1) {
      path = imageItem.path.substring(0, index);
      name = imageItem.path.substring(index + 1);
    }

    String extension = "";
    int pointIndex = imageItem.path.lastIndexOf(".");
    if (pointIndex != -1) {
      extension = imageItem.path.substring(pointIndex + 1);
    }

    double labelWidth = 100;
    double contentWidth = 200;
    double dialogWidth = 380;
    double triangleWidth = 15;

    RenderBox renderBox =
        _aboutIconKey.currentContext?.findRenderObject() as RenderBox;

    var offset = renderBox.localToGlobal(Offset.zero);
    var width = renderBox.size.width;
    var height = renderBox.size.height;

    var screenWidth = MediaQuery.of(context).size.width;

    var left = screenWidth - dialogWidth - 10;
    var top = offset.dy + height + 5;

    var triangleLeft = offset.dx + width / 2 - left - triangleWidth / 2 - 8;

    showDialog(
        context: context,
        builder: (context) {
          return Stack(
            children: [
              Positioned(
                  left: left,
                  top: top,
                  child: Stack(
                    children: [
                      Container(
                        child: Wrap(
                          direction: Axis.vertical,
                          children: [
                            Container(
                              child: Text(
                                "基本信息：",
                                style: TextStyle(
                                    color: Color(0xff313237), fontSize: 16),
                              ),
                              margin: EdgeInsets.only(
                                  top: 10, left: 15, bottom: 15),
                            ),
                            Wrap(
                              children: [
                                Container(
                                  child: Text(
                                    "名称：",
                                    style: textStyle,
                                    textAlign: TextAlign.right,
                                  ),
                                  width: labelWidth,
                                ),
                                Container(
                                  child: Text("$name", style: textStyle),
                                  width: contentWidth,
                                )
                              ],
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      "路径：",
                                      textAlign: TextAlign.right,
                                      style: textStyle,
                                    ),
                                    width: labelWidth,
                                  ),
                                  Container(
                                    child: Text(
                                      "$path",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      "种类：",
                                      textAlign: TextAlign.right,
                                      style: textStyle,
                                    ),
                                    width: labelWidth,
                                  ),
                                  Container(
                                    child: Text(
                                      "$extension",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      "大小：",
                                      textAlign: TextAlign.right,
                                      style: textStyle,
                                    ),
                                    width: labelWidth,
                                  ),
                                  Container(
                                    child: Text(
                                      "${_convertToReadableSize(imageItem.size)}",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      "尺寸：",
                                      style: textStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                    width: labelWidth,
                                  ),
                                  Container(
                                    child: Text(
                                      "${imageItem.width} x ${imageItem.height}",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      "创建时间：",
                                      style: textStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                    width: labelWidth,
                                  ),
                                  Container(
                                    child: Text(
                                      "${_formatTime(imageItem.createTime)}",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      "修改时间：",
                                      style: textStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                    width: labelWidth,
                                  ),
                                  Container(
                                    child: Text(
                                      "${_formatTime(imageItem.modifyTime * 1000)}",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xfffdfdfc),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black54,
                                offset: Offset(0, 0),
                                blurRadius: 1),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                        margin: EdgeInsets.only(top: 10),
                        width: dialogWidth,
                      ),
                      Container(
                        child: UpwardTriangle(
                          key: Key("upward_triangle"),
                          width: triangleWidth,
                          height: 10,
                          color: Colors.white,
                          dividerColor: Colors.black26,
                        ),
                        margin: EdgeInsets.only(left: triangleLeft),
                      )
                    ],
                  ))
            ],
          );
        },
        barrierColor: Colors.transparent).then((value) {
          _isImageInfoDialogShowing = false;
    });
    _isImageInfoDialogShowing = true;
  }

  String _formatTime(int time) {
    final df = DateFormat("yyyy年M月d日 HH:mm");
    return df.format(new DateTime.fromMillisecondsSinceEpoch(time));
  }

  bool _isMouseRightClicked(PointerDownEvent event) {
    return event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton;
  }

  void _openMenu(Offset position, ImageItem imageItem) {
    RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    String name = imageItem.path;
    int index = name.lastIndexOf("/");
    if (index != -1) {
      name = name.substring(index + 1);
    }

    showMenu(
        context: context,
        position: RelativeRect.fromSize(
            Rect.fromLTRB(position.dx, position.dy, 0, 0),
            overlay.size),
        items: [
          PopupMenuItem(
              child: Text("拷贝$name到电脑"),
              onTap: () {
                _openFilePicker(imageItem);
              }),
          PopupMenuItem(
              child: Text("删除"),
              onTap: () {
                Future<void>.delayed(const Duration(), () => _deleteImage());
              }),
        ]);
  }

  void _showConfirmDialog(
      String content,
      String desc,
      String negativeText,
      String positiveText,
      Function(BuildContext context) onPositiveClick,
      Function(BuildContext context) onNegativeClick) {
    Dialog dialog = ConfirmDialogBuilder()
        .content(content)
        .desc(desc)
        .negativeBtnText(negativeText)
        .positiveBtnText(positiveText)
        .onPositiveClick(onPositiveClick)
        .onNegativeClick(onNegativeClick)
        .build();

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        },
        barrierDismissible: false);
  }

  void _deleteImage() {
    _showConfirmDialog("确定删除这个项目吗？", "注意：删除的文件无法恢复", "取消", "删除", (context) {
      Navigator.of(context, rootNavigator: true).pop();
      _tryToDeleteImages();
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _showErrorDialog(String error) {
    Alert alert =
        Alert(context: context, type: AlertType.error, desc: error, buttons: [
      DialogButton(
          child: Text(
            "我知道了",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          })
    ]);

    alert.show();
  }

  void _tryToDeleteImages() {
    var url = Uri.parse("${_URL_SERVER}/image/delete");
    http
        .post(url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({
              "paths": [_allImageItems[_currentImageIndex].path]
            }))
        .then((response) {
      if (response.statusCode != 200) {
        _showErrorDialog(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("Delete image: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          setState(() {
            _allImageItems.removeAt(_currentImageIndex);
            if (_currentImageIndex > _allImageItems.length - 1) {
              _currentImageIndex = _allImageItems.length - 1;
            }
          });
        } else {
          _showErrorDialog(httpResponseEntity.msg == null
              ? "Unknown error"
              : httpResponseEntity.msg!);
        }
      }
    }).catchError((error) {
      _showErrorDialog(error.toString());
    });
  }

  void _openFilePicker(ImageItem imageItem) async {
    String? dir = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "选择目录", lockParentWindow: true);

    if (null != dir) {
      debugPrint("Select directory: $dir");

      _showDownloadProgressDialog(imageItem);

      String name = "";
      int index = imageItem.path.indexOf("/");
      if (index != -1) {
        name = imageItem.path.substring(0, index);
      }

      _downloadImage(imageItem, dir, () {
        _progressIndicatorDialog?.dismiss();
      }, (error) {
        _progressIndicatorDialog?.dismiss();
        SmartDialog.showToast(error);
      }, (current, total) {
        if (_progressIndicatorDialog?.isShowing == true) {
          if (current > 0) {
            setState(() {
              _progressIndicatorDialog?.title = "正在导出图片 ${name}";
            });
          }

          setState(() {
            _progressIndicatorDialog?.subtitle =
                "${_convertToReadableSize(current)}/${_convertToReadableSize(total)}";
            _progressIndicatorDialog?.updateProgress(current / total);
          });
        }
      });
    }
  }

  String _convertToReadableSize(int size) {
    if (size < _KB_BOUND) {
      return "${size} bytes";
    }
    if (size >= _KB_BOUND && size < _MB_BOUND) {
      return "${(size / 1024).toStringAsFixed(1)} KB";
    }

    if (size >= _MB_BOUND && size <= _GB_BOUND) {
      return "${(size / 1024 / 1024).toStringAsFixed(1)} MB";
    }

    return "${(size / 1024 / 1024 / 1024).toStringAsFixed(1)} GB";
  }

  void _showDownloadProgressDialog(ImageItem imageItem) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _downloaderCore?.cancel();
        _progressIndicatorDialog?.dismiss();
      });
    }

    String title = "正在准备中，请稍后...";
    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  void _downloadImage(ImageItem imageItem, String dir, void onSuccess(),
      void onError(String error), void onDownload(current, total)) async {
    String name = imageItem.path;
    int index = name.lastIndexOf("/");
    if (index != -1) {
      name = name.substring(index + 1);
    }

    var options = DownloaderUtils(
        progress: ProgressImplementation(),
        file: File("$dir/$name"),
        onDone: () {
          debugPrint("Download ${imageItem.path} done");
          onSuccess.call();
        },
        progressCallback: (current, total) {
          debugPrint(
              "Downloading ${imageItem.path}, percent: ${current / total}");
          onDownload.call(current, total);
        });

    if (null == _downloaderCore) {
      _downloaderCore = await Flowder.download(
          "${_URL_SERVER}/stream/file?path=${imageItem.path}", options);
    } else {
      _downloaderCore?.download(
          "${_URL_SERVER}/stream/file?path=${imageItem.path}", options);
    }
  }

  void openImageDetail(List<ImageItem> images, ImageItem current) {
    setState(() {
      _allImageItems = images;
      _currentImageIndex = images.indexOf(current);
      _openImageDetail = true;
    });
  }

  void backToImageListPage() {
    setState(() {
      _openImageDetail = false;
    });
  }

  void _setImageScale(bool isEnlarge) {
    _seekClosestSize(isEnlarge);

    _updateImageSliderValue();
  }

  // 寻找最接近的图片Scale，以0.5为一个档位
  void _seekClosestSize(bool isEnlarge) {
    if (isEnlarge) {
      double targetScale = 1.5;
      for (int i = 0; i <= Constant.IMAGE_MAX_SCALE ~/ 0.5; i++) {
        double value = Constant.IMAGE_MAX_SCALE - 0.5 * i;

        debugPrint("value: $value, _currentImageScale: $_currentImageScale");

        if (value - _currentImageScale <= 0.5) {
          targetScale = value;

          if (targetScale < 1.5) targetScale = 1.5;

          break;
        }
      }

      setState(() {
        _currentImageScale = targetScale;
      });
    } else {
      double targetScale = 1.0;
      for (int i = 0; i <= Constant.IMAGE_MAX_SCALE ~/ 0.5; i++) {
        double value = i * 0.5 + 1.0;
        if (_currentImageScale - value <= 0.5) {
          targetScale = value;
          break;
        }
      }

      setState(() {
        _currentImageScale = targetScale;
      });
    }
  }

  void _updateImageSliderValue() {
    setState(() {
      // 设置Slider的值
      _imageSizeSliderValue = (_currentImageScale - 1.0) / 1.0 * 100;

      debugPrint("Image slider value: ${_imageSizeSliderValue}");
    });
  }

  void _openPreImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  void _openNextImage() {
    if (_currentImageIndex < _allImageItems.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  void _updateDeleteBtnStatus() {
    if (_currentIndex == INDEX_ALL_IMAGE) {
      _allImageManagerPage.state?.updateDeleteBtnStatus();
    } else if (_currentIndex == INDEX_CAMERA_ALBUM) {
      _albumImageManagerPage.state?.updateDeleteBtnStatus();
    } else {
      _allAlbumManagerPage.state?.updateDeleteBtnStatus();
    }
  }

  void setDeleteBtnEnabled(bool enable) {
    setState(() {
      _isDeleteBtnEnabled = enable;
    });
  }

  void updateBottomItemNumber(int allItemNum, int selectedItemNum) {
    setState(() {
      _allItemNum = allItemNum;
      _selectedItemNum = selectedItemNum;
    });
  }

  int selectedIndex() {
    return _currentIndex;
  }

  @override
  void dispose() {
    super.dispose();

    _downloaderCore?.cancel();
    _unRegisterEventBus();
    _imageDetailFocusNode?.unfocus();
  }
}
