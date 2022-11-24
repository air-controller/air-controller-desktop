import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/widget/simple_gesture_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../model/arrangement_mode.dart';
import '../model/image_item.dart';

/**
 * 图片瀑布流，用于首页不同类型排列图片列表展示.
 *
 * @author Scott Smith 2021/11/23 22:52
 */
class ImageFlowWidget extends StatefulWidget {
  final String languageCode;
  final ArrangementMode arrangeMode;
  final List<ImageItem> images;
  final Function(ImageItem imageItem) onImageDoubleTap;
  final Function(ImageItem imageItem) onImageSelected;
  final Function() onOutsideTap;
  final String rootUrl;
  final Color backgroundColor;
  final List<ImageItem> checkedImages;
  final Function(Offset, ImageItem)? onRightMouseClick;

  ImageFlowWidget(
      {required this.languageCode,
      this.arrangeMode = ArrangementMode.grid,
      required this.images,
      this.checkedImages = const [],
      required this.onImageDoubleTap,
      required this.onImageSelected,
      required this.onOutsideTap,
      this.onRightMouseClick,
      required this.rootUrl,
      this.backgroundColor = Colors.white});

  @override
  State<StatefulWidget> createState() {
    return _ImageFlowState();
  }
}

class _ImageFlowState extends State<ImageFlowWidget> {
  final _outPadding = 20.0;
  final _imageSpace = 10.0;

  Widget _createDailyContent(BuildContext context) {
    final map = LinkedHashMap<String, List<ImageItem>>();

    for (ImageItem imageItem in widget.images) {
      int createTime = imageItem.createTime;

      Locale locale = Localizations.localeOf(context);

      final df = DateFormat.yMMMMd(locale.toString());

      final createTimeStr =
          df.format(DateTime.fromMillisecondsSinceEpoch(createTime));

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

    return Container(
      color: widget.backgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final entry = map.entries.toList()[index];
          String dateTime = entry.key;
          List<ImageItem> images = entry.value;

          return Container(
              child: StickyHeader(
                  header: Container(
                    child: Text(dateTime,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff515151))),
                    color: Colors.white,
                  ),
                  content: Container(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 100,
                          crossAxisSpacing: _imageSpace,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: _imageSpace),
                      itemBuilder: (BuildContext context, int index) {
                        ImageItem image = images[index];

                        return _ImageGridItem(
                            rootUrl: widget.rootUrl,
                            width: 100,
                            height: 100,
                            image: image,
                            isChecked: _isChecked(image),
                            onRightMenuClick: (position) {
                              widget.onRightMouseClick?.call(position, image);
                            },
                            onTap: (image) {
                              widget.onImageSelected.call(image);
                            },
                            onDoubleTap: (image) {
                              widget.onImageDoubleTap.call(image);
                            });
                      },
                      itemCount: images.length,
                      shrinkWrap: true,
                      primary: false,
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  )),
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 15, 20, 0));
        },
        itemCount: map.length,
        primary: false,
      ),
    );
  }

  Widget _createMonthlyContent(BuildContext context) {
    final map = LinkedHashMap<String, List<ImageItem>>();

    for (ImageItem imageItem in widget.images) {
      int createTime = imageItem.createTime;

      Locale locale = Localizations.localeOf(context);

      final df = DateFormat.MMMMd(locale.toString());

      String createTimeStr = df.format(new DateTime.fromMillisecondsSinceEpoch(createTime));

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

    return Container(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          final entry = map.entries.toList()[index];
          String dateTime = entry.key;
          List<ImageItem> images = entry.value;

          return Container(
              child: StickyHeader(
                  header: Container(
                    child: Text(dateTime,
                        style:
                            TextStyle(fontSize: 14, color: Color(0xff515151))),
                    color: Colors.white,
                  ),
                  content: Container(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 80,
                          crossAxisSpacing: _imageSpace,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: _imageSpace),
                      itemBuilder: (BuildContext context, int index) {
                        ImageItem image = images[index];

                        return _ImageGridItem(
                            rootUrl: widget.rootUrl,
                            width: 80,
                            height: 80,
                            image: image,
                            isChecked: _isChecked(image),
                            onRightMenuClick: (position) {
                              widget.onRightMouseClick?.call(position, image);
                            },
                            onTap: (image) {
                              widget.onImageSelected.call(image);
                            },
                            onDoubleTap: (image) {
                              widget.onImageDoubleTap.call(image);
                            });
                      },
                      itemCount: images.length,
                      shrinkWrap: true,
                      primary: false,
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  )),
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(20, 15, 20, 0));
        },
        itemCount: map.length,
        primary: false,
      ),
      width: double.infinity,
      height: double.infinity,
      color: widget.backgroundColor,
    );
  }

  Widget _createGridContent() {
    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            crossAxisSpacing: _imageSpace,
            childAspectRatio: 1.0,
            mainAxisSpacing: _imageSpace),
        itemBuilder: (BuildContext context, int index) {
          ImageItem image = widget.images[index];

          return _ImageGridItem(
              rootUrl: widget.rootUrl,
              width: 160,
              height: 160,
              image: image,
              isChecked: _isChecked(image),
              onRightMenuClick: (position) {
                widget.onRightMouseClick?.call(position, image);
              },
              onTap: (image) {
                widget.onImageSelected.call(image);
              },
              onDoubleTap: (image) {
                widget.onImageDoubleTap.call(image);
              });
        },
        itemCount: widget.images.length,
        shrinkWrap: true,
        primary: false,
      ),
      color: widget.backgroundColor,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.fromLTRB(_outPadding, _outPadding, _outPadding, 0),
    );
  }

  bool _isChecked(ImageItem image) {
    return widget.checkedImages.contains(image);
  }

  Widget _createContent(BuildContext context, ArrangementMode arrangeMode) {
    if (arrangeMode == ArrangementMode.groupByDay) {
      return _createDailyContent(context);
    }

    if (arrangeMode == ArrangementMode.groupByMonth) {
      return _createMonthlyContent(context);
    }

    return _createGridContent();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _createContent(context, widget.arrangeMode);
    return Listener(
      child: GestureDetector(
        child: content,
        onTap: () {
          widget.onOutsideTap.call();
        },
      ),
      onPointerDown: (event) {
        // onOutsideTap.call();
      },
    );
  }
}

class _ImageGridItem extends StatelessWidget {
  final String rootUrl;
  final double width;
  final double height;
  final ImageItem image;
  final bool isChecked;
  final Function(Offset position) onRightMenuClick;
  final Function(ImageItem) onTap;
  final Function(ImageItem) onDoubleTap;

  final _checkedBorderColor = const Color(0xff5d86ec);
  final _borderColor = const Color(0xffdedede);
  final _radiusChecked = 5.0;
  final _borderWidthChecked = 3.4;
  final _radius = 1.0;
  final _radiusBorderWidth = 1.0;

  const _ImageGridItem(
      {required this.rootUrl,
      required this.width,
      required this.height,
      required this.image,
      required this.isChecked,
      required this.onRightMenuClick,
      required this.onTap,
      required this.onDoubleTap});

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: Container(
        child: SimpleGestureDetector(
          child: Container(
              child: CachedNetworkImage(
                  imageUrl:
                      "$rootUrl/stream/image/thumbnail/${image.id}/${width.toInt() * 4}/${height.toInt() * 4}",
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                  memCacheWidth:
                      (width > height ? width * 2 : height * 2).toInt(),
                  fadeOutDuration: Duration.zero,
                  fadeInDuration: Duration.zero,
                  errorWidget: (context, url, error) {
                    return Image.asset("assets/icons/brokenImage.png",
                        width: width, height: height);
                  }),
              decoration: BoxDecoration(
                  border: new Border.all(
                      color: isChecked ? _checkedBorderColor : _borderColor,
                      width: _radiusBorderWidth),
                  borderRadius:
                      new BorderRadius.all(Radius.circular(_radius)))),
          onTap: () {
            onTap(image);
          },
          onDoubleTap: () {
            onDoubleTap(image);
          },
        ),
        decoration: BoxDecoration(
            border: new Border.all(
                color: isChecked ? Color(0xff5d86ec) : Colors.transparent,
                width: _borderWidthChecked - 2.0),
            borderRadius:
                new BorderRadius.all(Radius.circular(_radiusChecked / 3))),
      ),
      onPointerDown: (event) {
        if (event.isRightMouseClick()) {
          onRightMenuClick.call(event.position);
        }
      },
    );
  }
}
