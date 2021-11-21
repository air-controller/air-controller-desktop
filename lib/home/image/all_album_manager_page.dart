import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:mobile_assistant_client/model/AlbumItem.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
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

  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  List<AlbumItem> _allAlbums = [];

  int _arrangeMode = ImageManagerPage.ARRANGE_MODE_GRID;
  String? _selectedAlbumId;
  
  bool _isLoadingCompleted = false;

  final _BACKGROUND_ALBUM_SELECTED = Color(0xffe6e6e6);
  final _BACKGROUND_ALBUM_NORMAL = Colors.white;

  final _ALBUM_NAME_TEXT_COLOR_NORMAL = Color(0xff515151);
  final _ALBUM_IMAGE_NUM_TEXT_COLOR_NORMAL = Color(0xff929292);

  final _ALBUM_NAME_TEXT_COLOR_SELECTED = Colors.white;
  final _ALBUM_IMAGE_NUM_TEXT_COLOR_SELECTED = Colors.white;

  final _BACKGROUND_ALBUM_NAME_NORMAL = Colors.white;
  final _BACKGROUND_ALBUM_NAME_SELECTED = Color(0xff5d87ed);

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
    final imageWidth = 140.0;
    final imageHeight = 140.0;
    final imagePadding = 3.0;

    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          AlbumItem album = _allAlbums[index];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child:  Container(
                  child: Stack(
                    children: [
                      Visibility(
                        child: RotationTransition(
                            turns: AlwaysStoppedAnimation(5 / 360),
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              padding: EdgeInsets.all(imagePadding),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0xffdddddd), width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(3.0))
                              ),
                            )
                        ),
                        visible: album.photoNum > 1 ? true : false,
                      ),

                      Visibility(
                        child: RotationTransition(
                            turns: AlwaysStoppedAnimation(-5 / 360),
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              padding: EdgeInsets.all(imagePadding),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0xffdddddd), width: 1.0),
                                  borderRadius: BorderRadius.all(Radius.circular(3.0))
                              ),
                            )
                        ),
                        visible: album.photoNum > 2 ? true : false,
                      ),

                      Container(
                        child: CachedNetworkImage(
                            imageUrl: "${_URL_SERVER}/stream/image/thumbnail/${album.coverImageId}/400/400"
                                .replaceAll("storage/emulated/0/", ""),
                            fit: BoxFit.cover,
                            width: imageWidth,
                            height: imageWidth,
                            memCacheWidth: 400,
                            fadeOutDuration: Duration.zero,
                            fadeInDuration: Duration.zero
                        ),
                        padding: EdgeInsets.all(imagePadding),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xffdddddd), width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(3.0))
                        ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: _selectedAlbumId == album.id ? _BACKGROUND_ALBUM_SELECTED : _BACKGROUND_ALBUM_NORMAL,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  padding: EdgeInsets.all(8),
                ),
                onTap: () {
                  setState(() {
                    _selectedAlbumId = album.id;
                  });
                },
              ),

              GestureDetector(
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        album.name,
                        style: TextStyle(
                            inherit: false,
                            color: _selectedAlbumId == album.id ? _ALBUM_NAME_TEXT_COLOR_SELECTED : _ALBUM_NAME_TEXT_COLOR_NORMAL
                        ),
                      ),
                      Container(
                        child: Text(
                          "(${album.photoNum})",
                          style: TextStyle(
                              inherit: false,
                              color: _selectedAlbumId == album.id ? _ALBUM_IMAGE_NUM_TEXT_COLOR_SELECTED : _ALBUM_IMAGE_NUM_TEXT_COLOR_NORMAL
                          ),
                        ),
                        margin: EdgeInsets.only(left: 3),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(top: 10),

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: _selectedAlbumId == album.id ? _BACKGROUND_ALBUM_NAME_SELECTED : _BACKGROUND_ALBUM_NAME_NORMAL
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                ),
                onTap: () {
                  setState(() {
                    _selectedAlbumId = album.id;
                  });
                },
              )
            ],
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
