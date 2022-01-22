import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_assistant_client/model/Device.dart';
import 'package:mobile_assistant_client/model/ImageItem.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../constant.dart';

/**
 * 图片瀑布流，用于首页不同类型排列图片列表展示.
 *
 * @author Scott Smith 2021/11/23 22:52
 */
class ImageFlowWidget extends StatelessWidget {
  static final int ARRANGE_MODE_GRID = 1;
  static final int ARRANGE_MODE_DAILY = 2;
  static final int ARRANGE_MODE_MONTHLY = 3;

  int arrangeMode = ARRANGE_MODE_GRID;
  List<ImageItem> images = [];
  Function(ImageItem imageItem) onImageDoubleTap;
  Function(ImageItem imageItem) onImageSelected;
  Function() onOutsideTap;

  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 10.0;

  final _URL_SERVER =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  List<ImageItem> selectedImages = [];

  final _IMAGE_GRID_RADIUS_SELECTED = 5.0;
  final _IMAGE_GRID_RADIUS = 1.0;

  final _IMAGE_GRID_BORDER_WIDTH_SELECTED = 4.0;
  final _IMAGE_GRID_BORDER_WIDTH = 1.0;

  Function(PointerDownEvent event, ImageItem imageItem)? onPointerDown;

  ImageFlowWidget({required this.arrangeMode, required this.images,
    required this.selectedImages, required this.onImageDoubleTap,
    required this.onImageSelected, required this.onOutsideTap, this.onPointerDown});

  Widget _createContent(int arrangeMode) {
    if (arrangeMode == ARRANGE_MODE_DAILY) {
      return _createDailyContent();
    }

    if (arrangeMode == ARRANGE_MODE_MONTHLY) {
      return _createMonthlyContent();
    }

    return _createGridContent();
  }

  Widget _createDailyContent() {
    final map = LinkedHashMap<String, List<ImageItem>>();

    final timeFormat = "yyyy年M月d日";

    for (ImageItem imageItem in images) {
      int createTime = imageItem.createTime;

      final df = DateFormat(timeFormat);
      String createTimeStr =
          df.format(new DateTime.fromMillisecondsSinceEpoch(createTime));

      List<ImageItem>? images = map[createTimeStr];
      if (null == images) {
        images = <ImageItem>[];
        images.add(imageItem);
        map[createTimeStr] = images;
      } else {
        images.add(imageItem);
        map[createTimeStr] = images;
      }
    }

    List<String> keys = map.keys.toList();
    keys.sort((String a, String b) {
      final df = DateFormat(timeFormat);
      DateTime dateTimeA = df.parse(a);
      DateTime dateTimeB = df.parse(b);

      return dateTimeB.millisecondsSinceEpoch -
          dateTimeA.millisecondsSinceEpoch;
    });

    Map<String, List<ImageItem>> sortedMap = LinkedHashMap();

    keys.forEach((key) {
      sortedMap[key] = map[key]!;
    });

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        final entry = sortedMap.entries.toList()[index];
        String dateTime = entry.key;
        List<ImageItem> images = entry.value;

        return Container(
            child: StickyHeader(
                header: Container(
                  child: Text(dateTime,
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff515151))),
                  color: Colors.white,
                ),
                content: Container(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 100,
                        crossAxisSpacing: _IMAGE_SPACE,
                        childAspectRatio: 1.0,
                        mainAxisSpacing: _IMAGE_SPACE),
                    itemBuilder: (BuildContext context, int index) {
                      ImageItem image = images[index];
                      return Listener(
                        child: Container(
                          child: GestureDetector(
                            child: CachedNetworkImage(
                              imageUrl:
                              "${_URL_SERVER}/stream/image/thumbnail/${image.id}/200/200"
                                  .replaceAll("storage/emulated/0/", ""),
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              memCacheWidth: 200,
                              fadeOutDuration: Duration.zero,
                              fadeInDuration: Duration.zero,
                            ),
                            onTap: () {
                              onImageSelected.call(image);
                            },
                            onDoubleTap: () {
                              onImageDoubleTap.call(image);
                            },
                          ),
                          decoration: BoxDecoration(
                              border: new Border.all(
                                  color: _isContainsImage(selectedImages, image)
                                      ? Color(0xff5d86ec)
                                      : Color(0xffdedede),
                                  width: _isContainsImage(selectedImages, image)
                                      ? _IMAGE_GRID_BORDER_WIDTH_SELECTED
                                      : _IMAGE_GRID_BORDER_WIDTH),
                              borderRadius: new BorderRadius.all(Radius.circular(
                                  _isContainsImage(selectedImages, image)
                                      ? _IMAGE_GRID_RADIUS_SELECTED
                                      : _IMAGE_GRID_RADIUS))),
                        ),
                        onPointerDown: (event) {
                          onPointerDown?.call(event, image);
                        },
                      );
                    },
                    itemCount: images.length,
                    shrinkWrap: true,
                  ),
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                )),
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 0));
      },
      itemCount: map.length,
    );
  }

  Widget _createMonthlyContent() {
    final map = LinkedHashMap<String, List<ImageItem>>();

    final timeFormat = "yyyy年M月";

    for (ImageItem imageItem in images) {
      int createTime = imageItem.createTime;

      final df = DateFormat(timeFormat);
      String createTimeStr =
          df.format(new DateTime.fromMillisecondsSinceEpoch(createTime));

      List<ImageItem>? images = map[createTimeStr];
      if (null == images) {
        images = <ImageItem>[];
        images.add(imageItem);
        map[createTimeStr] = images;
      } else {
        images.add(imageItem);
        map[createTimeStr] = images;
      }
    }

    List<String> keys = map.keys.toList();
    keys.sort((String a, String b) {
      final df = DateFormat(timeFormat);
      DateTime dateTimeA = df.parse(a);
      DateTime dateTimeB = df.parse(b);

      return dateTimeB.millisecondsSinceEpoch -
          dateTimeA.millisecondsSinceEpoch;
    });

    Map<String, List<ImageItem>> sortedMap = LinkedHashMap();

    keys.forEach((key) {
      sortedMap[key] = map[key]!;
    });

    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        final entry = sortedMap.entries.toList()[index];
        String dateTime = entry.key;
        List<ImageItem> images = entry.value;

        return Container(
            child: StickyHeader(
                header: Container(
                  child: Text(dateTime,
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff515151))),
                  color: Colors.white,
                ),
                content: Container(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 80,
                        crossAxisSpacing: _IMAGE_SPACE,
                        childAspectRatio: 1.0,
                        mainAxisSpacing: _IMAGE_SPACE),
                    itemBuilder: (BuildContext context, int index) {
                      ImageItem image = images[index];
                      return Listener(
                        child: Container(
                          child: GestureDetector(
                            child: CachedNetworkImage(
                              imageUrl:
                              "${_URL_SERVER}/stream/image/thumbnail/${image.id}/200/200"
                                  .replaceAll("storage/emulated/0/", ""),
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              memCacheWidth: 200,
                              fadeOutDuration: Duration.zero,
                              fadeInDuration: Duration.zero,
                            ),
                            onTap: () {
                              onImageSelected.call(image);
                            },
                            onDoubleTap: () {
                              onImageDoubleTap.call(image);
                            },
                          ),
                          decoration: BoxDecoration(
                              border: new Border.all(
                                  color: _isContainsImage(selectedImages, image)
                                      ? Color(0xff5d86ec)
                                      : Color(0xffdedede),
                                  width: _isContainsImage(selectedImages, image)
                                      ? _IMAGE_GRID_BORDER_WIDTH_SELECTED
                                      : _IMAGE_GRID_BORDER_WIDTH),
                              borderRadius: new BorderRadius.all(Radius.circular(
                                  _isContainsImage(selectedImages, image)
                                      ? _IMAGE_GRID_RADIUS_SELECTED
                                      : _IMAGE_GRID_RADIUS))),
                        ),
                        onPointerDown: (event) {
                          onPointerDown?.call(event, image);
                        },
                      );
                    },
                    itemCount: images.length,
                    shrinkWrap: true,
                  ),
                  color: Colors.white,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                )),
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(20, 15, 20, 0));
      },
      itemCount: map.length,
    );
  }

  Widget _createGridContent() {
    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          ImageItem image = images[index];
          return Listener(
            child: Container(
              child: GestureDetector(
                child: CachedNetworkImage(
                  imageUrl:
                  "${_URL_SERVER}/stream/image/thumbnail/${image.id}/400/400"
                      .replaceAll("storage/emulated/0/", ""),
                  fit: BoxFit.cover,
                  width: 160,
                  height: 160,
                  memCacheWidth: 400,
                  fadeOutDuration: Duration.zero,
                  fadeInDuration: Duration.zero,
                ),
                onTap: () {
                  onImageSelected.call(image);
                },
                onDoubleTap: () {
                  onImageDoubleTap.call(image);
                },
              ),
              decoration: BoxDecoration(
                  border: new Border.all(
                      color: _isContainsImage(selectedImages, image)
                          ? Color(0xff5d86ec)
                          : Color(0xffdedede),
                      width: _isContainsImage(selectedImages, image)
                          ? _IMAGE_GRID_BORDER_WIDTH_SELECTED
                          : _IMAGE_GRID_BORDER_WIDTH),
                  borderRadius: new BorderRadius.all(Radius.circular(
                      _isContainsImage(selectedImages, image)
                          ? _IMAGE_GRID_RADIUS_SELECTED
                          : _IMAGE_GRID_RADIUS))),
            ),
            onPointerDown: (event) {
              onPointerDown?.call(event, image);
            },
          );
        },
        itemCount: images.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  bool _isContainsImage(List<ImageItem> images, ImageItem current) {
    for (ImageItem imageItem in images) {
      if (imageItem.id == current.id) return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = _createContent(arrangeMode);
    return GestureDetector(
      child: widget,
      onTap: () {
        onOutsideTap.call();
      },
    );
  }
}
