import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/event/back_btn_pressed.dart';
import 'package:mobile_assistant_client/event/back_btn_visibility.dart';
import 'package:mobile_assistant_client/event/open_image_detail.dart';
import 'package:mobile_assistant_client/event/update_delete_btn_status.dart';
import 'package:mobile_assistant_client/event/update_image_arrange_mode.dart';
import 'package:mobile_assistant_client/home/image/album_image_manager_page.dart';
import 'package:mobile_assistant_client/home/image/all_album_manager_page.dart';
import 'package:mobile_assistant_client/home/image/all_image_manager_page.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';
import '../event/update_bottom_item_num.dart';
import '../model/ImageItem.dart';

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

  int _arrange_mode = _ARRANGE_MODE_GRID;

  AllImageManagerPage _allImageManagerPage = AllImageManagerPage();
  final _albumImageManagerPage = AlbumImageManagerPage();
  final _allAlbumManagerPage = AllAlbumManagerPage();

  bool _isBackBtnDown = false;
  double _imageSizeSliderValue = 0.0;

  int _currentImageIndex = -1;
  List<ImageItem> _allImageItems = <ImageItem>[];

  bool _openImageDetail = false;

  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  double _currentImageScale = 1.0;
  // 标记删除按钮是否可以点击
  bool _isDeleteBtnEnabled = false;
  int _allItemNum = 0;
  int _selectedItemNum = 0;
  bool _isBackBtnVisible = false;

  StreamSubscription<UpdateDeleteBtnStatus>? _updateDeleteBtnStream;
  StreamSubscription<UpdateBottomItemNum>? _updateBottomItemNumStream;
  StreamSubscription<OpenImageDetail>? _openImageDetailStream;
  StreamSubscription<BackBtnVisibility>? _backBtnVisibilityStream;


  @override
  void initState() {
    super.initState();
    _registerEventBus();
  }

  void _registerEventBus() {
    _updateDeleteBtnStream = eventBus.on<UpdateDeleteBtnStatus>().listen((event) {
      setDeleteBtnEnabled(event.isEnable);
    });

    _updateBottomItemNumStream = eventBus.on<UpdateBottomItemNum>().listen((event) {
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
  }

  void _unRegisterEventBus() {
    _updateDeleteBtnStream?.cancel();
    _updateBottomItemNumStream?.cancel();
    _openImageDetailStream?.cancel();
    _backBtnVisibilityStream?.cancel();
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
        Visibility(
          child: previewWidget,
          visible: _openImageDetail ? true : false,
        )
      ],
    );
  }

  void _updateArrangeMode(int rangeModeIndex) {
    switch (rangeModeIndex) {
      case _ARRANGE_MODE_DAILY: {
          eventBus.fire(UpdateImageArrangeMode(ImageManagerPage.ARRANGE_MODE_DAILY));
          break;
        }
      case _ARRANGE_MODE_MONTHLY: {
          eventBus.fire(UpdateImageArrangeMode(ImageManagerPage.ARRANGE_MODE_MONTHLY));
          break;
        }
      default: {
          eventBus.fire(UpdateImageArrangeMode(ImageManagerPage.ARRANGE_MODE_GRID));
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

    return Column(
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
                                    color: Color(0xff5c5c62),
                                    fontSize: 13,
                                    inherit: false)),
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
                                  inherit: false,
                                  fontSize: 12,
                                  color: getSegmentBtnColor(INDEX_ALL_IMAGE))),
                          padding: EdgeInsets.only(left: 10, right: 10),
                        ),
                        INDEX_CAMERA_ALBUM: Container(
                          child: Text("相机相册",
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color:
                                      getSegmentBtnColor(INDEX_CAMERA_ALBUM))),
                        ),
                        INDEX_ALL_ALBUM: Container(
                            child: Text("所有相册",
                                style: TextStyle(
                                    inherit: false,
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
                            _albumImageManagerPage.state?.updateBottomItemNum();
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
                                    _getArrangeModeIcon(_ARRANGE_MODE_MONTHLY),
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
                        visible: _currentIndex != INDEX_ALL_ALBUM,
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0))),
                                width: 40,
                                height: 25,
                                padding:
                                    EdgeInsets.fromLTRB(6.0, 4.0, 6.0, 4.0),
                              ),
                            ),
                            onTap: () {
                              debugPrint("当前删除按钮点击状态: $_isDeleteBtnEnabled");

                              if (_isDeleteBtnEnabled) {
                                if (_currentIndex == INDEX_ALL_IMAGE) {
                                  _allImageManagerPage.state?.deleteImage();
                                  return;
                                }
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
                style: TextStyle(
                    inherit: false, fontSize: 12, color: Color(0xff646464))),
          ),
          height: 20,
          color: Color(0xfffafafa),
        )
      ],
    );
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
                                        fontSize: 13,
                                        inherit: false)),
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
                                    _currentImageScale = _imageSizeSliderValue / 100 + 1.0;
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
                              fontSize: 13,
                              color: Color(0xff7a7a7a),
                              inherit: false)),
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
                              inherit: false,
                              color: Color(0xff626160),
                              fontSize: 16)),
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
                child: Container(
                  child: Image.asset("icons/icon_about_image.png",
                      width: 14, height: 14),
                  decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffd5d5d5), width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      color: Color(0xfff4f4f4)),
                  padding: EdgeInsets.fromLTRB(12, 4, 12, 4),
                  margin: EdgeInsets.only(right: 15),
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
              return ExtendedImage.network(
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
    // if (isEnlarge) {
    //   if (_currentImageScale < 1.5) {
    //     setState(() {
    //       _currentImageScale = 1.5;
    //     });
    //   } else if (_currentImageScale < 2.0) {
    //     setState(() {
    //       _currentImageScale = 2.0;
    //     });
    //   }
    // } else {
    //   if (_currentImageScale <= 1.5) {
    //     setState(() {
    //       _currentImageScale = 1.0;
    //     });
    //   } else {
    //     setState(() {
    //       _currentImageScale = 1.5;
    //     });
    //   }
    // }

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

  void _updateDeleteBtnStatus () {
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

    _unRegisterEventBus();
  }
}
