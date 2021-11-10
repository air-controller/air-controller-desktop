import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/home/image/album_image_manager_page.dart';
import 'package:mobile_assistant_client/home/image/all_album_manager_page.dart';
import 'package:mobile_assistant_client/home/image/all_image_manager_page.dart';
import '../model/ImageItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/ResponseEntity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageManagerPage extends StatefulWidget {
  ImageManagerPage();

  @override
  State<StatefulWidget> createState() {
    return _ImageManagerState();
  }
}

class _ImageManagerState extends State<ImageManagerPage> {
  static final _INDEX_ALL_IMAGE = 0;
  static final _INDEX_CAMERA_ALBUM = 1;
  static final _INDEX_ALL_ALBUM = 2;

  int _currentIndex = _INDEX_ALL_IMAGE;
  final _divider_line_color = Color(0xffe0e0e0);

  List<ImageItem> _allImages = [];

  static final _ARRANGE_MODE_GRID = 0;
  static final _ARRANGE_MODE_WEEKLY = 1;
  static final _ARRANGE_MODE_MONTHLY = 2;

  int _arrange_mode = _ARRANGE_MODE_GRID;

  @override
  Widget build(BuildContext context) {
    Color getSegmentBtnColor(int index) {
      if (index == _currentIndex) {
        return Color(0xffffffff);
      } else {
        return Color(0xff5b5c62);
      }
    }

    String itemStr = "共${_allImages.length}项";
    final pageController = PageController(initialPage: _currentIndex);


    String _getArrangeModeIcon(int mode) {
      if (mode == _ARRANGE_MODE_GRID) {
        if (_arrange_mode == mode) {
          return "icons/icon_grid_selected.png";
        } else {
          return "icons/icon_grid_normal.png";
        }
      }

      if (mode == _ARRANGE_MODE_WEEKLY) {
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

    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              Align(
                  alignment: Alignment.center,
                  child: Container(
                    child: MaterialSegmentedControl<int>(
                      children: {
                        _INDEX_ALL_IMAGE: Container(
                          child: Text("所有图片",
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color: getSegmentBtnColor(_INDEX_ALL_IMAGE))),
                          padding: EdgeInsets.only(left: 10, right: 10),
                        ),
                        _INDEX_CAMERA_ALBUM: Container(
                          child: Text("相机相册",
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 12,
                                  color:
                                  getSegmentBtnColor(_INDEX_CAMERA_ALBUM))),
                        ),
                        _INDEX_ALL_ALBUM: Container(
                            child: Text("所有相册",
                                style: TextStyle(
                                    inherit: false,
                                    fontSize: 12,
                                    color:
                                    getSegmentBtnColor(_INDEX_ALL_ALBUM))))
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
                      GestureDetector(
                        child: Container(
                          child: Image.asset(_getArrangeModeIcon(_ARRANGE_MODE_GRID), width: 20, height: 20),
                          padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xffdddedf),
                                width: 1.0
                            ),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4.0),
                                bottomLeft: Radius.circular(4.0)
                            ),
                            color: _getArrangeModeBgColor(_ARRANGE_MODE_GRID),
                          ),
                        ),
                        onTap: () {
                          if (_arrange_mode != _ARRANGE_MODE_GRID) {
                            setState(() {
                              _arrange_mode = _ARRANGE_MODE_GRID;
                            });
                          }
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          child: Image.asset(_getArrangeModeIcon(_ARRANGE_MODE_WEEKLY), width: 20, height: 20),
                          padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xffdddedf),
                                width: 1.0
                            ),
                            color: _getArrangeModeBgColor(_ARRANGE_MODE_WEEKLY),
                          ),
                        ),
                        onTap: () {
                          if (_arrange_mode != _ARRANGE_MODE_WEEKLY) {
                            setState(() {
                              _arrange_mode = _ARRANGE_MODE_WEEKLY;
                            });
                          }
                        },
                      ),
                      GestureDetector(
                        child: Container(
                          child: Image.asset(_getArrangeModeIcon(_ARRANGE_MODE_MONTHLY), width: 20, height: 20),
                          padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xffdddedf),
                                width: 1.0
                            ),
                            color: _getArrangeModeBgColor(_ARRANGE_MODE_MONTHLY),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4.0),
                                bottomRight: Radius.circular(4.0)
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_arrange_mode != _ARRANGE_MODE_MONTHLY) {
                            setState(() {
                              _arrange_mode = _ARRANGE_MODE_MONTHLY;
                            });
                          }
                        },
                      ),

                      Container(
                          child: Image.asset("icons/icon_delete.png",
                              width: 10,
                              height: 10),
                          decoration: BoxDecoration(
                              color: Color(0xffcb6357),
                              border: new Border.all(
                                  color: Color(0xffb43f32), width: 1.0),
                              borderRadius:
                              BorderRadius.all(Radius.circular(4.0))),
                          width: 40,
                          height: 25,
                          padding: EdgeInsets.fromLTRB(6.0, 4.0, 6.0, 4.0),
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
                AllImageManagerPage(),
                AlbumImageManagerPage(),
                AllAlbumManagerPage()
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
            child: Text(itemStr, style: TextStyle(
                inherit: false,
                fontSize: 12,
                color: Color(0xff646464)
            )),
          ),
          height: 20,
          color: Color(0xfffafafa),
        )
      ],
    );
  }

}
