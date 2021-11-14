import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../../model/ImageItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/ResponseEntity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AllImageManagerPage extends StatefulWidget {
  _AllImageManagerPageState? _allImageManagerPageState;

  AllImageManagerPage();

  @override
  State<StatefulWidget> createState() {
    _allImageManagerPageState = _AllImageManagerPageState();
    return _allImageManagerPageState!;
  }

  void setArrangeMode(int arrangeMode) {
    _allImageManagerPageState?.setArrangeMode(arrangeMode);
  }
}

class _AllImageManagerPageState extends State<AllImageManagerPage> with AutomaticKeepAliveClientMixin {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER = "http://192.168.0.102:8080";

  List<ImageItem> _allImages = [];

  int _arrangeMode = ImageManagerPage.ARRANGE_MODE_GRID;

  @override
  void initState() {
    super.initState();

    _getAllImages((images) {
      setState(() {
        _allImages = images;
      });
    }, (error) => print("Get all images error: $error"));
  }

  void setArrangeMode(int arrangeMode) {
    setState(() {
      _arrangeMode = arrangeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _createContent(_arrangeMode);
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
  
  Widget _createDailyContent() {
    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      return StickyHeader(
          header: Container(
            child: Text("测试标题"),
          ),
          content: Container(
            child: Text("按天排列",
          )
        )
      );
    });
  }

  Widget _createMonthlyContent() {
    return ListView.builder(itemBuilder: (BuildContext context, int index) {
      return StickyHeader(
          header: Container(
            child: Text("测试标题"),
          ),
          content: Container(
            child: Text("按月排列"),
          )
      );
    });
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

  @override
  bool get wantKeepAlive => true;
}
