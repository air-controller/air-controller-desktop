import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:mobile_assistant_client/widget/confirm_dialog_builder.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../../model/ImageItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/ResponseEntity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllImageManagerPage extends StatefulWidget {
  _AllImageManagerPageState? state;
  // ImageManagerState imageManagerState;

  AllImageManagerPage();

  @override
  State<StatefulWidget> createState() {
    state = _AllImageManagerPageState();
    return state!;
  }

  void setArrangeMode(int arrangeMode) {
    state?.setArrangeMode(arrangeMode);
  }
}

class _AllImageManagerPageState extends State<AllImageManagerPage> with AutomaticKeepAliveClientMixin {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER = "http://192.168.0.101:8080";

  List<ImageItem> _allImages = [];

  int _arrangeMode = ImageManagerPage.ARRANGE_MODE_GRID;
  // String? _selectedImageId;
  ImageItem? _selectedImage;

  final _IMAGE_GRID_RADIUS_SELECTED = 5.0;
  final _IMAGE_GRID_RADIUS = 1.0;

  final _IMAGE_GRID_BORDER_WIDTH_SELECTED = 4.0;
  final _IMAGE_GRID_BORDER_WIDTH = 1.0;
  bool _isLoadingCompleted = false;

  _AllImageManagerPageState();

  @override
  void initState() {
    super.initState();

    _getAllImages((images) {
      setState(() {
        _allImages = images;
        _isLoadingCompleted = true;
      });
    }, (error) {
      print("Get all images error: $error");
      setState(() {
        _isLoadingCompleted = true;
      });
    });


  }

  void setArrangeMode(int arrangeMode) {
    setState(() {
      _arrangeMode = arrangeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    Widget content = _createContent(_arrangeMode);

    return Stack(children: [
      content,
      Visibility(
        child: Container(child: spinKit, color: Colors.white),
        maintainSize: false,
        visible: !_isLoadingCompleted,
      )
    ]);
  }

  Widget _createContent(int arrangeMode) {
    if (_arrangeMode == ImageManagerPage.ARRANGE_MODE_DAILY) {
      return _createDailyContent();
    }

    if (_arrangeMode == ImageManagerPage.ARRANGE_MODE_MONTHLY) {
      return _createMonthlyContent();
    }

    return _createGridContent();
  }

  Widget _createGridContent() {
    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          ImageItem image = _allImages[index];
          return Container(
            child: GestureDetector(
              child: CachedNetworkImage(
                imageUrl: "${_URL_SERVER}/stream/image/thumbnail/${image.id}/200/200"
                    .replaceAll("storage/emulated/0/", ""),
                fit: BoxFit.cover,
                width: 200,
                height: 200,
                memCacheWidth: 400,
                fadeOutDuration: Duration.zero,
                fadeInDuration: Duration.zero,
              ),
              onTap: () {
                _setImageSelected(image);
              },
              onDoubleTap: () {
                debugPrint("双击");
                _openImageDetail(_allImages, image);
              },
            ),
            decoration: BoxDecoration(
                border: new Border.all(
                    color: _selectedImage?.id == image.id ? Color(0xff5d86ec) : Color(0xffdedede),
                    width: _selectedImage?.id == image.id ? _IMAGE_GRID_BORDER_WIDTH_SELECTED : _IMAGE_GRID_BORDER_WIDTH
                ),
                borderRadius: new BorderRadius.all(
                    Radius.circular(_selectedImage?.id == image.id ? _IMAGE_GRID_RADIUS_SELECTED : _IMAGE_GRID_RADIUS)
                )
            ),
          );
        },
        itemCount: _allImages.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }
  
  Widget _createDailyContent() {
    final map = LinkedHashMap<String, List<ImageItem>>();

    final timeFormat = "yyyy年M月d日";

    for (ImageItem imageItem in _allImages) {
      int createTime = imageItem.createTime;

      final df = DateFormat(timeFormat);
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

    List<String> keys = map.keys.toList();
    keys.sort((String a, String b) {
      final df = DateFormat(timeFormat);
      DateTime dateTimeA = df.parse(a);
      DateTime dateTimeB = df.parse(b);

      return dateTimeB.millisecondsSinceEpoch - dateTimeA.millisecondsSinceEpoch;
    });

    Map<String, List<ImageItem>> sortedMap = LinkedHashMap();

    keys.forEach((key) {
      sortedMap[key] = map[key]!;
    });

    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      final entry = sortedMap.entries.toList()[index];
      String dateTime = entry.key;
      List<ImageItem> images = entry.value;

      return Container(
        child: StickyHeader(
            header: Container(
              child: Text(
                  dateTime,
                  style: TextStyle(
                      inherit: false,
                      fontSize: 14,
                      color: Color(0xff515151)
                  )
              ),
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
                  return Container(
                    child: GestureDetector(
                      child: CachedNetworkImage(
                        imageUrl: "${_URL_SERVER}/stream/image/thumbnail/${image.id}/200/200"
                            .replaceAll("storage/emulated/0/", ""),
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        memCacheWidth: 200,
                        fadeOutDuration: Duration.zero,
                        fadeInDuration: Duration.zero,
                      ),
                      onTap: () {
                        _setImageSelected(image);
                      },
                      onDoubleTap: () {
                        _openImageDetail(_allImages, image);
                      },
                    ),
                    decoration: BoxDecoration(
                        border: new Border.all(
                            color: _selectedImage?.id == image.id ? Color(0xff5d86ec) : Color(0xffdedede),
                            width: _selectedImage?.id == image.id ? _IMAGE_GRID_BORDER_WIDTH_SELECTED : _IMAGE_GRID_BORDER_WIDTH
                        ),
                        borderRadius: new BorderRadius.all(
                            Radius.circular(_selectedImage?.id == image.id ? _IMAGE_GRID_RADIUS_SELECTED : _IMAGE_GRID_RADIUS)
                        )
                    ),
                  );
                },
                itemCount: images.length,
                shrinkWrap: true,
              ),
              color: Colors.white,
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            )
        ),
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(20, 15, 20, 0)
      );
    },
      itemCount: map.length,
    );
  }

  Widget _createMonthlyContent() {
    final map = LinkedHashMap<String, List<ImageItem>>();

    final timeFormat = "yyyy年M月";

    for (ImageItem imageItem in _allImages) {
      int createTime = imageItem.createTime;

      final df = DateFormat(timeFormat);
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

    List<String> keys = map.keys.toList();
    keys.sort((String a, String b) {
      final df = DateFormat(timeFormat);
      DateTime dateTimeA = df.parse(a);
      DateTime dateTimeB = df.parse(b);

      return dateTimeB.millisecondsSinceEpoch - dateTimeA.millisecondsSinceEpoch;
    });

    Map<String, List<ImageItem>> sortedMap = LinkedHashMap();

    keys.forEach((key) {
      sortedMap[key] = map[key]!;
    });

    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      final entry = sortedMap.entries.toList()[index];
      String dateTime = entry.key;
      List<ImageItem> images = entry.value;

      return Container(
          child: StickyHeader(
              header: Container(
                child: Text(
                    dateTime,
                    style: TextStyle(
                        inherit: false,
                        fontSize: 14,
                        color: Color(0xff515151)
                    )
                ),
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
                    return Container(
                      child: GestureDetector(
                        child: CachedNetworkImage(
                          imageUrl: "${_URL_SERVER}/stream/image/thumbnail/${image.id}/200/200"
                              .replaceAll("storage/emulated/0/", ""),
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          memCacheWidth: 200,
                          fadeOutDuration: Duration.zero,
                          fadeInDuration: Duration.zero,
                        ),
                        onTap: () {
                          _setImageSelected(image);
                        },
                        onDoubleTap: () {
                          _openImageDetail(_allImages, image);
                        },
                      ),
                      decoration: BoxDecoration(
                          border: new Border.all(
                              color: _selectedImage?.id == image.id ? Color(0xff5d86ec) : Color(0xffdedede),
                              width: _selectedImage?.id == image.id ? _IMAGE_GRID_BORDER_WIDTH_SELECTED : _IMAGE_GRID_BORDER_WIDTH
                          ),
                          borderRadius: new BorderRadius.all(
                              Radius.circular(_selectedImage?.id == image.id ? _IMAGE_GRID_RADIUS_SELECTED : _IMAGE_GRID_RADIUS)
                          )
                      ),
                    );
                  },
                  itemCount: images.length,
                  shrinkWrap: true,
                ),
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              )
          ),
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, 15, 20, 0)
      );
    },
      itemCount: map.length,
    );
  }

  void _getAllImages(Function(List<ImageItem> images) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/image/all");
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
        debugPrint("Get all image list, body: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          onSuccess.call(data
              .map((e) => ImageItem.fromJson(e as Map<String, dynamic>))
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

  void _setImageSelected(ImageItem? image) {
    setState(() {
      _selectedImage = image;
    });

    _setDeleteBtnEnabled(null != _selectedImage);
  }

  void _openImageDetail(List<ImageItem> images, ImageItem current) {
    ImageManagerPage? imageManagerPage = context.findAncestorWidgetOfExactType<ImageManagerPage>();
    imageManagerPage?.state?.openImageDetail(images, current);
  }

  void _setDeleteBtnEnabled(bool enable) {
    ImageManagerPage? imageManagerPage = context.findAncestorWidgetOfExactType<ImageManagerPage>();
    imageManagerPage?.state?.setDeleteBtnEnabled(enable);
  }
  
  void _showConfirmDialog(String content, String desc, String negativeText, String positiveText,
      Function(BuildContext context) onPositiveClick, Function(BuildContext context) onNegativeClick) {
      Dialog dialog = ConfirmDialogBuilder().content(content)
          .desc(desc)
          .negativeBtnText(negativeText)
          .positiveBtnText(positiveText)
          .onPositiveClick(onPositiveClick)
          .onNegativeClick(onNegativeClick)
          .build();

      showDialog(context: context, builder: (context) {
        return dialog;
      },
        barrierDismissible: false
      );
  }
  
  void deleteImage() {
    _showConfirmDialog("确定删除该图片吗？", "注意：删除的文件无法恢复", "取消", "删除", (context) {
      Navigator.of(context, rootNavigator: true).pop();
      _deleteSingleImage();
    }, (context) {
        Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _deleteSingleImage() {
    if (null == _selectedImage) {
      debugPrint("Selected image is null");
      return;
    }

    var url = Uri.parse("${_URL_SERVER}/image/delete");
    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "paths": [_selectedImage?.path]
        }))
        .then((response) {
      if (response.statusCode != 200) {
        _showErrorDialog(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("Delete single image: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          setState(() {
            _allImages.removeWhere((image) => image.id == _selectedImage?.id);
            _setImageSelected(null);
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
  
  void _showErrorDialog(String error) {
    Alert alert = Alert(
      context: context,
      type: AlertType.error,
      desc: error,
      buttons: [
        DialogButton(
            child: Text(
              "我知道了",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            })
      ]
    );

    alert.show();
  }

  @override
  bool get wantKeepAlive => true;
}
