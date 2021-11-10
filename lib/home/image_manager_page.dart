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

  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER = "http://192.168.0.101:8080";

  List<ImageItem> _allImages = [];

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
                child: Row(),
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
