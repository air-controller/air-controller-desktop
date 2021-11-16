import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:mobile_assistant_client/model/AlbumItem.dart';
import 'package:sticky_headers/sticky_headers.dart';
import '../../model/AlbumItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/ResponseEntity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../image_preview/image_preview_page.dart';

class AllAlbumManagerPage extends StatefulWidget {
  _AllAlbumManagerPageState? _allImageManagerPageState;
  // ImageManagerState imageManagerState;

  AllAlbumManagerPage();

  @override
  State<StatefulWidget> createState() {
    _allImageManagerPageState = _AllAlbumManagerPageState();
    return _allImageManagerPageState!;
  }

  void setArrangeMode(int arrangeMode) {
    _allImageManagerPageState?.setArrangeMode(arrangeMode);
  }
}

class _AllAlbumManagerPageState extends State<AllAlbumManagerPage> with AutomaticKeepAliveClientMixin {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER = "http://192.168.0.102:8080";

  List<AlbumItem> _allAlbums = [];

  int _arrangeMode = ImageManagerPage.ARRANGE_MODE_GRID;
  String? _selectedImageId;

  final _IMAGE_GRID_RADIUS_SELECTED = 5.0;
  final _IMAGE_GRID_RADIUS = 1.0;

  final _IMAGE_GRID_BORDER_WIDTH_SELECTED = 4.0;
  final _IMAGE_GRID_BORDER_WIDTH = 1.0;
  bool _isLoadingCompleted = false;

  _AllAlbumManagerPageState();

  @override
  void initState() {
    super.initState();

    _getAllAlbums((images) {
      setState(() {
        _allAlbums = images;
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
          AlbumItem image = _allAlbums[index];
          return Container(
            child: GestureDetector(
              child: CachedNetworkImage(
                imageUrl: "${_URL_SERVER}/stream/image/thumbnail/${image.coverImageId}/400/400"
                    .replaceAll("storage/emulated/0/", ""),
                fit: BoxFit.cover,
                width: 200,
                height: 200,
                memCacheWidth: 400,
                fadeOutDuration: Duration.zero,
                fadeInDuration: Duration.zero,
              ),
              onTap: () {
                setState(() {
                  _selectedImageId = image.id;
                });
              },
              onDoubleTap: () {
                debugPrint("双击");
                _openImageDetail(_allAlbums, image);
              },
            ),
            decoration: BoxDecoration(
                border: new Border.all(
                    color: _selectedImageId == image.id ? Color(0xff5d86ec) : Color(0xffdedede),
                    width: _selectedImageId == image.id ? _IMAGE_GRID_BORDER_WIDTH_SELECTED : _IMAGE_GRID_BORDER_WIDTH
                ),
                borderRadius: new BorderRadius.all(
                    Radius.circular(_selectedImageId == image.id ? _IMAGE_GRID_RADIUS_SELECTED : _IMAGE_GRID_RADIUS)
                )
            ),
          );
        },
        itemCount: _allAlbums.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  void _getAllAlbums(Function(List<AlbumItem> albums) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/image/albums");
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
              .map((e) => AlbumItem.fromJson(e as Map<String, dynamic>))
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

  void _openImageDetail(List<AlbumItem> images, AlbumItem current) {
  }

  @override
  bool get wantKeepAlive => true;
}
