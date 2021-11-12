import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:mobile_assistant_client/constant.dart';
import '../../model/ImageItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/ResponseEntity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllImageManagerPage extends StatefulWidget {
  AllImageManagerPage();

  @override
  State<StatefulWidget> createState() {
    return _AllImageManagerPageState();
  }
}

class _AllImageManagerPageState extends State<AllImageManagerPage> {
  static final _INDEX_ALL_IMAGE = 0;
  static final _INDEX_CAMERA_ALBUM = 1;
  static final _INDEX_ALL_ALBUM = 2;

  int _currentIndex = _INDEX_ALL_IMAGE;
  final _divider_line_color = Color(0xffe0e0e0);

  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER = "http://192.168.0.103:8080";

  List<ImageItem> _allImages = [];

  @override
  void initState() {
    super.initState();

    _getAllImages((images) {
      setState(() {
        _allImages = images;
      });
    }, (error) => print("Get all images error: $error"));
  }

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

    return Expanded(
        child: Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          ImageItem image = _allImages[index];
          return Container(
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
            decoration: BoxDecoration(
                border: new Border.all(color: Color(0xffdedede), width: 1.0)),
          );
        },
        itemCount: _allImages.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    ));
  }

  List<String> getDataList() {
    List<String> list = [];
    for (int i = 0; i < 100; i++) {
      list.add(i.toString());
    }
    return list;
  }

  List<Widget> getWidgetList() {
    return getDataList().map((item) => getItemContainer(item)).toList();
  }

  Widget getItemContainer(String item) {
    return Container(
      width: 100.0,
      height: 100.0,
      alignment: Alignment.center,
      child: Text(
        item,
        style: TextStyle(color: Colors.white, fontSize: 40),
      ),
      color: Colors.blue,
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
}
