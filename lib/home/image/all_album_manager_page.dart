import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/home/file_manager.dart';
import 'package:mobile_assistant_client/home/image_manager_page.dart';
import 'package:mobile_assistant_client/model/AlbumItem.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../model/AlbumItem.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../model/ResponseEntity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../image_preview/image_preview_page.dart';

class AllAlbumManagerPage extends StatefulWidget {
  _AllAlbumManagerPageState? state;

  AllAlbumManagerPage();

  @override
  State<StatefulWidget> createState() {
    state = _AllAlbumManagerPageState();
    return state!;
  }

  void setArrangeMode(int arrangeMode) {
    state?.setArrangeMode(arrangeMode);
  }
}

class _AllAlbumManagerPageState extends State<AllAlbumManagerPage> with AutomaticKeepAliveClientMixin {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  List<AlbumItem> _allAlbums = [];

  int _arrangeMode = ImageManagerPage.ARRANGE_MODE_GRID;
  
  List<AlbumItem> _selectedAlbums = [];
  
  bool _isLoadingCompleted = false;

  final _BACKGROUND_ALBUM_SELECTED = Color(0xffe6e6e6);
  final _BACKGROUND_ALBUM_NORMAL = Colors.white;

  final _ALBUM_NAME_TEXT_COLOR_NORMAL = Color(0xff515151);
  final _ALBUM_IMAGE_NUM_TEXT_COLOR_NORMAL = Color(0xff929292);

  final _ALBUM_NAME_TEXT_COLOR_SELECTED = Colors.white;
  final _ALBUM_IMAGE_NUM_TEXT_COLOR_SELECTED = Colors.white;

  final _BACKGROUND_ALBUM_NAME_NORMAL = Colors.white;
  final _BACKGROUND_ALBUM_NAME_SELECTED = Color(0xff5d87ed);

  late Function() _ctrlAPressedCallback;
  // 标记当前页面是否可见
  bool _isVisible = false;
  
  _AllAlbumManagerPageState();

  @override
  void initState() {
    super.initState();

    _ctrlAPressedCallback = () {
      if (_isFront()) {
        _setAllAlbumSelected();
      }
      debugPrint("Ctrl + A pressed...");
    };

    _addCtrlAPressedCallback(_ctrlAPressedCallback);

    _getAllAlbums((images) {
      setState(() {
        _allAlbums = images;
        _isLoadingCompleted = true;
      });
      updateBottomItemNum();
    }, (error) {
      print("Get all images error: $error");
      setState(() {
        _isLoadingCompleted = true;
      });
    });
  }

  void _setAllAlbumSelected() {
    setState(() {
      _selectedAlbums.clear();
      _selectedAlbums.addAll(_allAlbums);
      updateBottomItemNum();
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

    return VisibilityDetector(
        key: Key("all_album_manager"),
        child: GestureDetector(
          child: Stack(children: [
            content,
            Visibility(
              child: Container(child: spinKit, color: Colors.white),
              maintainSize: false,
              visible: !_isLoadingCompleted,
            )
          ]),
          onTap: () {
            _clearSelectedAlbums();
          },
        ),
        onVisibilityChanged: (info) {
          setState(() {
            _isVisible = info.visibleFraction * 100 >= 100.0;
          });
        });
  }

  void _clearSelectedAlbums() {
    setState(() {
      _selectedAlbums.clear();
      updateBottomItemNum();
    });
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
                      color:  _isContainsImage(_selectedAlbums, album) ? _BACKGROUND_ALBUM_SELECTED : _BACKGROUND_ALBUM_NORMAL,
                      borderRadius: BorderRadius.all(Radius.circular(4.0))
                  ),
                  padding: EdgeInsets.all(8),
                ),
                onTap: () {
                  setState(() {
                    _setAlbumSelected(album);
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
                            color: _isContainsImage(_selectedAlbums, album) ? _ALBUM_NAME_TEXT_COLOR_SELECTED : _ALBUM_NAME_TEXT_COLOR_NORMAL
                        ),
                      ),
                      Container(
                        child: Text(
                          "(${album.photoNum})",
                          style: TextStyle(
                              inherit: false,
                              color: _isContainsImage(_selectedAlbums, album) ? _ALBUM_IMAGE_NUM_TEXT_COLOR_SELECTED : _ALBUM_IMAGE_NUM_TEXT_COLOR_NORMAL
                          ),
                        ),
                        margin: EdgeInsets.only(left: 3),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(top: 10),

                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                      color: _isContainsImage(_selectedAlbums, album) ? _BACKGROUND_ALBUM_NAME_SELECTED : _BACKGROUND_ALBUM_NAME_NORMAL
                  ),
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                ),
                onTap: () {
                  setState(() {
                    _setAlbumSelected(album);
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

  void _setAlbumSelected(AlbumItem album) {
    debugPrint("Shift key down status: $_isShiftDown");
    debugPrint("Control key down status: $_isControlDown");

    if (!_isContainsImage(_selectedAlbums, album)) {
      if (_isControlDown()) {
        setState(() {
          _selectedAlbums.add(album);
        });
      } else if (_isShiftDown()) {
        if (_selectedAlbums.length == 0) {
          setState(() {
            _selectedAlbums.add(album);
          });
        } else if (_selectedAlbums.length == 1) {
          int index = _selectedAlbums.indexOf(_selectedAlbums[0]);

          int current = _allAlbums.indexOf(album);

          if (current > index) {
            setState(() {
              _selectedAlbums = _allAlbums.sublist(index, current + 1);
            });
          } else {
            setState(() {
              _selectedAlbums = _allAlbums.sublist(current, index + 1);
            });
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < _selectedAlbums.length; i++) {
            AlbumItem current = _selectedAlbums[i];
            int index = _allAlbums.indexOf(current);
            if (index < 0) {
              debugPrint("Error image");
              continue;
            }

            if (index > maxIndex) {
              maxIndex = index;
            }

            if (index < minIndex) {
              minIndex = index;
            }
          }

          debugPrint("minIndex: $minIndex, maxIndex: $maxIndex");

          int current = _allAlbums.indexOf(album);

          if (current >= minIndex && current <= maxIndex) {
            setState(() {
              _selectedAlbums = _allAlbums.sublist(current, maxIndex + 1);
            });
          } else if (current < minIndex) {
            setState(() {
              _selectedAlbums = _allAlbums.sublist(current, maxIndex + 1);
            });
          } else if (current > maxIndex) {
            setState(() {
              _selectedAlbums = _allAlbums.sublist(minIndex, current + 1);
            });
          }
        }
      } else {
        setState(() {
          _selectedAlbums.clear();
          _selectedAlbums.add(album);
        });
      }
    } else {
      debugPrint("It's already contains this image, id: ${album.id}");

      if (_isControlDown()) {
        setState(() {
          _selectedAlbums.remove(album);
        });
      } else if (_isShiftDown()) {
        setState(() {
          _selectedAlbums.remove(album);
        });
      }
    }

    _setDeleteBtnEnabled(_selectedAlbums.length > 0);
    updateBottomItemNum();
  }

  void _setDeleteBtnEnabled(bool enable) {
    ImageManagerPage? imageManagerPage = context.findAncestorWidgetOfExactType<ImageManagerPage>();
    imageManagerPage?.state?.setDeleteBtnEnabled(enable);
  }

  bool _isContainsImage(List<AlbumItem> albums, AlbumItem current) {
    for (AlbumItem albumItem in albums) {
      if (albumItem.id == current.id) return true;
    }

    return false;
  }

  bool _isControlDown() {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    return fileManagerPage?.state?.isControlDown() == true;
  }

  bool _isShiftDown() {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    return fileManagerPage?.state?.isShiftDown() == true;
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

  void _addCtrlAPressedCallback(Function() callback) {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    fileManagerPage?.state?.addCtrlAPressedCallback(callback);
  }

  void _removeCtrlAPressedCallback(Function() callback) {
    FileManagerPage? fileManagerPage =
    context.findAncestorWidgetOfExactType<FileManagerPage>();
    fileManagerPage?.state?.addCtrlAPressedCallback(callback);
  }

  void updateBottomItemNum() {
    ImageManagerPage? imageManagerPage = context.findAncestorWidgetOfExactType<ImageManagerPage>();
    imageManagerPage?.state?.updateBottomItemNumber(_allAlbums.length, 0);
  }

  // 判断当前页面是否在前台显示
  bool _isFront() {
    return _isVisible;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    _removeCtrlAPressedCallback(_ctrlAPressedCallback);
  }
}
