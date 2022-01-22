import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_assistant_client/event/back_btn_pressed.dart';
import 'package:mobile_assistant_client/event/back_btn_visibility.dart';
import 'package:mobile_assistant_client/event/delete_op.dart';
import 'package:mobile_assistant_client/event/image_range_mode_visibility.dart';
import 'package:mobile_assistant_client/event/open_image_detail.dart';
import 'package:mobile_assistant_client/event/update_bottom_item_num.dart';
import 'package:mobile_assistant_client/event/update_delete_btn_status.dart';
import 'package:mobile_assistant_client/event/update_image_arrange_mode.dart';
import 'package:mobile_assistant_client/model/AlbumItem.dart';
import 'package:mobile_assistant_client/model/ImageItem.dart';
import 'package:mobile_assistant_client/model/UIModule.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/widget/confirm_dialog_builder.dart';
import 'package:mobile_assistant_client/widget/image_flow_widget.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../constant.dart';
import '../../model/AlbumItem.dart';
import '../../model/ResponseEntity.dart';
import '../../util/event_bus.dart';

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

class _AllAlbumManagerPageState extends State<AllAlbumManagerPage>
    with AutomaticKeepAliveClientMixin {
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  final _URL_SERVER =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  List<AlbumItem> _allAlbums = [];

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

  // 标记当前页面是否可见
  bool _isAlbumPageVisible = false;
  int _arrangeMode = ImageFlowWidget.ARRANGE_MODE_GRID;

  // 标记是否进入专辑图片列表页
  bool _openAlbumImagesPage = false;

  // 标记是否进入图片详情页
  bool _openImageDetailPage = false;

  // 当前专辑图片列表
  List<ImageItem> _allImages = [];

  // 当前专辑图片列表页选中的图片
  List<ImageItem> _selectedImages = [];

  // 当前专辑
  AlbumItem? _currentAlbum;

  DownloaderCore? _downloaderCore;

  StreamSubscription<BackBtnPressed>? _backBtnPressedStream;
  StreamSubscription<UpdateImageArrangeMode>? _updateImageArrangeModeStream;
  StreamSubscription<DeleteOp>? _deleteOpSubscription;

  FocusNode? _rootFocusNode = null;

  bool _isControlPressed = false;
  bool _isShiftPressed = false;

  _AllAlbumManagerPageState();

  @override
  void initState() {
    super.initState();

    _getAllAlbums((images) {
      setState(() {
        _allAlbums = images;
        _allAlbums.sort((albumA, albumB) {
          return albumA.name.toLowerCase().compareTo(albumB.name.toLowerCase());
        });
        _isLoadingCompleted = true;
      });
      updateBottomItemNum();
    }, (error) {
      print("Get all albums error: $error");
      setState(() {
        _isLoadingCompleted = true;
      });
    });
    updateDeleteBtnStatus();
    _registerEventBus();
  }

  void _registerEventBus() {
    _backBtnPressedStream = eventBus.on<BackBtnPressed>().listen((event) {
      _backToAlbumListPage();
    });

    _updateImageArrangeModeStream = eventBus.on<UpdateImageArrangeMode>().listen((event) {
      setState(() {
        _arrangeMode = event.mode;
      });
    });

    _deleteOpSubscription = eventBus.on<DeleteOp>().listen((event) {
      if (event.module == UIModule.Image) {
        if (_isAlbumPageVisible) {
          _tryToDeleteAlbums();
        }

        if (_openAlbumImagesPage) {
          _tryToDeleteImages();
        }
      }
    });
  }

  void _unRegisterEventBus() {
    _backBtnPressedStream?.cancel();
    _updateImageArrangeModeStream?.cancel();
    _deleteOpSubscription?.cancel();
  }

  void _setAllAlbumSelected() {
    setState(() {
      if (_openAlbumImagesPage) {
        _selectedImages.clear();
        _selectedImages.addAll(_allImages);
        updateBottomItemNum();
        _setDeleteBtnEnabled(true);
      }

      if (_isFront()) {
        _selectedAlbums.clear();
        _selectedAlbums.addAll(_allAlbums);
        updateBottomItemNum();
        _setDeleteBtnEnabled(true);
      }
    });
  }

  void setArrangeMode(int arrangeMode) {
    setState(() {
      _arrangeMode = arrangeMode;
    });
  }

  void _tryToDeleteAlbums() {
    _showConfirmDialog("确定删除这${_selectedAlbums.length}个项目吗？", "注意：删除的文件无法恢复", "取消", "删除",
            (context) {
          Navigator.of(context, rootNavigator: true).pop();

          SmartDialog.showLoading();

          _deleteFiles(_selectedAlbums.map((album) => album.path).toList(), () {
            SmartDialog.dismiss();

            setState(() {
              _allAlbums.removeWhere((album) => _selectedAlbums.contains(album));
              _selectedAlbums.clear();
              _setDeleteBtnEnabled(false);
            });
          }, (error) {
            SmartDialog.dismiss();

            SmartDialog.showToast(error);
          });
        }, (context) {
          Navigator.of(context, rootNavigator: true).pop();
        });
  }

  void _tryToDeleteImages() {
    _showConfirmDialog("确定删除这${_selectedImages.length}个项目吗？", "注意：删除的文件无法恢复", "取消", "删除",
            (context) {
          Navigator.of(context, rootNavigator: true).pop();

          SmartDialog.showLoading();

          _deleteFiles(_selectedImages.map((album) => album.path).toList(), () {
            SmartDialog.dismiss();

            setState(() {
              _allImages.removeWhere((album) => _selectedImages.contains(album));
              _selectedImages.clear();
              _setDeleteBtnEnabled(false);
            });
          }, (error) {
            SmartDialog.dismiss();

            SmartDialog.showToast(error);
          });
        }, (context) {
          Navigator.of(context, rootNavigator: true).pop();
        });
  }

  void _deleteFiles(List<String> paths, Function() onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/file/deleteMulti");
    http
        .post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "paths": paths
        }))
        .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("_deleteFiles, body: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          onSuccess.call();
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
  
  void _showConfirmDialog(
      String content,
      String desc,
      String negativeText,
      String positiveText,
      Function(BuildContext context) onPositiveClick,
      Function(BuildContext context) onNegativeClick) {
    Dialog dialog = ConfirmDialogBuilder()
        .content(content)
        .desc(desc)
        .negativeBtnText(negativeText)
        .positiveBtnText(positiveText)
        .onPositiveClick(onPositiveClick)
        .onNegativeClick(onNegativeClick)
        .build();

    showDialog(
        context: context,
        builder: (context) {
          return dialog;
        },
        barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    Widget content = _createContent(_arrangeMode);

    Widget albumImagesWidget = _createAlbumImagesWidget();

    _rootFocusNode = FocusNode();

    _rootFocusNode?.canRequestFocus = true;
    _rootFocusNode?.requestFocus();

    return Focus(
      autofocus: true,
      focusNode: _rootFocusNode,
      child: Stack(
        children: [
          Visibility(
            child: VisibilityDetector(
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
                    _isAlbumPageVisible = info.visibleFraction >= 1.0;

                    debugPrint("_isAlbumPageVisible: $_isAlbumPageVisible");

                    if (_isAlbumPageVisible) {
                      _rootFocusNode?.requestFocus();
                      _updateRangeMenuVisibility(false);
                    }
                  });
                }),
            visible: !_openAlbumImagesPage && !_openImageDetailPage,
          ),
          Visibility(
            child: VisibilityDetector(
              key: Key("videos_in_album_page"),
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        GestureDetector(
                          child: Container(
                            child: Text("所有相册",
                                style: TextStyle(
                                    color: Color(0xff5b5c62),
                                    fontSize: 14)),
                            padding: EdgeInsets.only(left: 10),
                          ),
                          onTap: () {
                            _backToAlbumListPage();
                          },
                        ),
                        Image.asset("icons/ic_right_arrow.png", height: 20),
                        Text(_currentAlbum?.name ?? "",
                            style: TextStyle(
                                color: Color(0xff5b5c62),
                                fontSize: 14))
                      ],
                    ),
                    color: Color(0xfffafafa),
                    height: 30,
                  ),
                  Divider(color: Color(0xffe0e0e0), height: 1.0, thickness: 1.0),
                  Expanded(child: Container(
                    child: albumImagesWidget,
                    color: Colors.white,
                  ))
                ],
              ),
              onVisibilityChanged: (info) {
                if (info.visibleFraction >= 1.0) {
                  _rootFocusNode?.requestFocus();
                  _updateRangeMenuVisibility(true);
                  _setBackBtnVisible(true);
                }
              },
            ),
            visible: _openAlbumImagesPage,
          )
        ],
      ),
      onKey: (node, event) {
        _isControlPressed =
            Platform.isMacOS ? event.isMetaPressed : event.isControlPressed;
        _isShiftPressed = event.isShiftPressed;

        if (Platform.isMacOS) {
          if (event.isMetaPressed &&
              event.isKeyPressed(LogicalKeyboardKey.keyA)) {
            _onControlAndAPressed();
            return KeyEventResult.handled;
          }
        } else {
          if (event.isControlPressed &&
              event.isKeyPressed(LogicalKeyboardKey.keyA)) {
            _onControlAndAPressed();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
    );
  }

  void _updateRangeMenuVisibility(bool visible) {
    eventBus.fire(ImageRangeModeVisibility(visible));
  }

  void _onControlAndAPressed() {
    debugPrint("_onControlAndAPressed.");
    _setAllSelected();
  }

  void _setAllSelected() {
    if (_openAlbumImagesPage) {
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(_allImages);
      });
    }
    
    if (_isAlbumPageVisible) {
      setState(() {
        _selectedAlbums.clear();
        _selectedAlbums.addAll(_allAlbums);
      });
    }
  }

  // 回到相册列表页面
  void _backToAlbumListPage() {
    setState(() {
      _openAlbumImagesPage = false;
      _allImages = [];
      _selectedImages = [];
      updateDeleteBtnStatus();
      updateBottomItemNum();
      _setBackBtnVisible(false);
    });
  }

  void _openImageDetail(List<ImageItem> images, ImageItem current) {
    eventBus.fire(OpenImageDetail(images, current));
  }

  void _openMenu(Offset position, dynamic item) {
    if (item! is AlbumItem && item! is ImageItem) {
      throw "item must be one of AlbumItem's instance or ImageItem's instance";
    }

    // 为什么这样可以？值得思考
    RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox;

    String name = "";
    if (item is ImageItem) {
      name = item.path;
      int index = name.lastIndexOf("/");
      if (index != -1) {
        name = name.substring(index + 1);
      }
    } else {
      name = item.name;
    }

    showMenu(
        context: context,
        position: RelativeRect.fromSize(
            Rect.fromLTRB(position.dx, position.dy, 0, 0),
            overlay.size ?? Size(0, 0)),
        items: [
          PopupMenuItem(
              child: Text("打开"),
              onTap: () {
                if (item is AlbumItem) {
                  _currentAlbum = item;
                  _tryToOpenAlbumImages(item.id);
                } else {
                  _openImageDetail(_selectedImages, item);
                }
              }),
          PopupMenuItem(
              child: Text("拷贝$name到电脑"),
              onTap: () {
                _openFilePicker(item);
              }),
          PopupMenuItem(child: Text("删除"), onTap: () {
            Future<void>.delayed(const Duration(), () {
              if (_isAlbumPageVisible) {
                _tryToDeleteAlbums();
              }

              if (_openAlbumImagesPage) {
                _tryToDeleteImages();
              }
            });
          }),
        ]);
  }

  void _openFilePicker(AlbumItem albumItem) async {
    String? dir = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "选择目录", lockParentWindow: true);

    if (null != dir) {
      debugPrint("Select directory: $dir");

      SmartDialog.showLoading(msg: "请稍后");

      _download(albumItem, dir, () {
        SmartDialog.dismiss();
        // SmartDialog.showToast("图片已保存至${dir}");
      }, (error) {
        SmartDialog.dismiss();
        SmartDialog.showToast(error);
      }, (current, total) {});
    }
  }

  void _download(AlbumItem albumItem, String dir, void onSuccess(),
      void onError(String error), void onDownload(current, total)) async {
    String name = "${albumItem.name}.zip";

    var options = DownloaderUtils(
        progress: ProgressImplementation(),
        file: File("$dir/$name"),
        onDone: () {
          debugPrint("Download ${albumItem.path} done");
          onSuccess.call();
        },
        progressCallback: (current, total) {
          debugPrint(
              "Downloading ${albumItem.path}, percent: ${current / total}");
          onDownload.call(current, total);
        });

    if (null == _downloaderCore) {
      _downloaderCore = await Flowder.download(
          "${_URL_SERVER}/stream/dir?path=${albumItem.path}", options);
    } else {
      _downloaderCore?.download(
          "${_URL_SERVER}/stream/file?path=${albumItem.path}", options);
    }
  }

  Widget _createAlbumImagesWidget() {
    return ImageFlowWidget(
      arrangeMode: _arrangeMode,
      images: _allImages,
      selectedImages: _selectedImages,
      onImageDoubleTap: (image) {
        _openImageDetail(_allImages, image);
      },
      onImageSelected: (image) {
        _setImageSelected(image);
      },
      onOutsideTap: () {
        _clearSelectedImages();
      },
      onPointerDown: (event, image) {
        if (_isMouseRightClicked(event)) {
          _openMenu(event.position, image);
        }
      },
    );
  }

  bool _isContainsImage(List<ImageItem> images, ImageItem current) {
    for (ImageItem imageItem in images) {
      if (imageItem.id == current.id) return true;
    }

    return false;
  }

  void _setImageSelected(ImageItem image) {
    debugPrint("Shift key down status: ${_isShiftDown()}");
    debugPrint("Control key down status: ${_isControlDown()}");

    if (!_isContainsImage(_selectedImages, image)) {
      if (_isControlDown()) {
        setState(() {
          _selectedImages.add(image);
        });
      } else if (_isShiftDown()) {
        if (_selectedImages.length == 0) {
          setState(() {
            _selectedImages.add(image);
          });
        } else if (_selectedImages.length == 1) {
          int index = _allImages.indexOf(_selectedImages[0]);

          int current = _allImages.indexOf(image);

          if (current > index) {
            setState(() {
              _selectedImages = _allImages.sublist(index, current + 1);
            });
          } else {
            setState(() {
              _selectedImages = _allImages.sublist(current, index + 1);
            });
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < _selectedImages.length; i++) {
            ImageItem current = _selectedImages[i];
            int index = _allImages.indexOf(current);
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

          int current = _allImages.indexOf(image);

          if (current >= minIndex && current <= maxIndex) {
            setState(() {
              _selectedImages = _allImages.sublist(current, maxIndex + 1);
            });
          } else if (current < minIndex) {
            setState(() {
              _selectedImages = _allImages.sublist(current, maxIndex + 1);
            });
          } else if (current > maxIndex) {
            setState(() {
              _selectedImages = _allImages.sublist(minIndex, current + 1);
            });
          }
        }
      } else {
        setState(() {
          _selectedImages.clear();
          _selectedImages.add(image);
        });
      }
    } else {
      debugPrint("It's already contains this image, id: ${image.id}");

      if (_isControlDown()) {
        setState(() {
          _selectedImages.remove(image);
        });
      } else if (_isShiftDown()) {
        setState(() {
          _selectedImages.remove(image);
        });
      } else {
        setState(() {
          _selectedImages.clear();
          _selectedImages.add(image);
        });
      }
    }

    _setDeleteBtnEnabled(_selectedImages.length > 0);
    updateBottomItemNum();
  }

  void _tryToOpenAlbumImages(String albumId) {
    SmartDialog.showLoading(background: Colors.red);
    _getImagesOfAlbum(albumId, (images) {
      debugPrint("_tryToOpenAlbumImages, image size: ${images.length}");
      setState(() {
        _allImages = images;
        _openAlbumImagesPage = true;
        updateBottomItemNum();
        updateDeleteBtnStatus();
        _setBackBtnVisible(true);
        SmartDialog.dismiss();
      });
    }, (error) {
      debugPrint("_tryToOpenAlbumImages: $error");
      SmartDialog.dismiss();
    });
  }

  void _clearSelectedAlbums() {
    setState(() {
      _selectedAlbums.clear();
      updateBottomItemNum();
      _setDeleteBtnEnabled(false);
    });
  }

  void _clearSelectedImages() {
    setState(() {
      _selectedImages.clear();
      updateBottomItemNum();
      _setDeleteBtnEnabled(false);
    });
  }

  void updateDeleteBtnStatus() {
    if (!_openAlbumImagesPage && !_openImageDetailPage) {
      debugPrint(
          "All album page: updateDeleteBtnStatus, ${_selectedAlbums.length > 0}");
      _setDeleteBtnEnabled(_selectedAlbums.length > 0);
    }

    if (_openAlbumImagesPage) {
      debugPrint(
          "All album page: updateDeleteBtnStatus, ${_selectedImages.length > 0}");
      _setDeleteBtnEnabled(_selectedImages.length > 0);
    }
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

          return Listener(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
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
                                      border: Border.all(
                                          color: Color(0xffdddddd), width: 1.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(3.0))),
                                )),
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
                                      border: Border.all(
                                          color: Color(0xffdddddd), width: 1.0),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(3.0))),
                                )),
                            visible: album.photoNum > 2 ? true : false,
                          ),
                          Container(
                            child: CachedNetworkImage(
                                imageUrl:
                                    "${_URL_SERVER}/stream/image/thumbnail/${album.coverImageId}/400/400"
                                        .replaceAll("storage/emulated/0/", ""),
                                fit: BoxFit.cover,
                                width: imageWidth,
                                height: imageWidth,
                                memCacheWidth: 400,
                                fadeOutDuration: Duration.zero,
                                fadeInDuration: Duration.zero),
                            padding: EdgeInsets.all(imagePadding),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    color: Color(0xffdddddd), width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(3.0))),
                          )
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: _isContainsAlbum(_selectedAlbums, album)
                              ? _BACKGROUND_ALBUM_SELECTED
                              : _BACKGROUND_ALBUM_NORMAL,
                          borderRadius: BorderRadius.all(Radius.circular(4.0))),
                      padding: EdgeInsets.all(8),
                    ),
                    onTap: () {
                      setState(() {
                        _setAlbumSelected(album);
                      });
                    },
                    onDoubleTap: () {
                      _currentAlbum = album;
                      _tryToOpenAlbumImages(album.id);
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
                                color: _isContainsAlbum(_selectedAlbums, album)
                                    ? _ALBUM_NAME_TEXT_COLOR_SELECTED
                                    : _ALBUM_NAME_TEXT_COLOR_NORMAL),
                          ),
                          Container(
                            child: Text(
                              "(${album.photoNum})",
                              style: TextStyle(
                                  color:
                                      _isContainsAlbum(_selectedAlbums, album)
                                          ? _ALBUM_IMAGE_NUM_TEXT_COLOR_SELECTED
                                          : _ALBUM_IMAGE_NUM_TEXT_COLOR_NORMAL),
                            ),
                            margin: EdgeInsets.only(left: 3),
                          )
                        ],
                      ),
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          color: _isContainsAlbum(_selectedAlbums, album)
                              ? _BACKGROUND_ALBUM_NAME_SELECTED
                              : _BACKGROUND_ALBUM_NAME_NORMAL),
                      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    ),
                    onTap: () {
                      setState(() {
                        _setAlbumSelected(album);
                      });
                    },
                  )
                ],
              ),
              onPointerDown: (event) {
                debugPrint(
                    "Mouse clicked, is right key: ${_isMouseRightClicked(event)}");

                if (_isMouseRightClicked(event)) {
                  _openMenu(event.position, album);

                  if (!_selectedAlbums.contains(album)) {
                    _setAlbumSelected(album);
                  }
                }
              });
        },
        itemCount: _allAlbums.length,
        shrinkWrap: true,
      ),
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  bool _isMouseRightClicked(PointerDownEvent event) {
    return event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton;
  }

  void _setAlbumSelected(AlbumItem album) {
    debugPrint("Shift key down status: $_isShiftDown");
    debugPrint("Control key down status: $_isControlDown");

    if (!_isContainsAlbum(_selectedAlbums, album)) {
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
    eventBus.fire(UpdateDeleteBtnStatus(enable));
  }

  bool _isContainsAlbum(List<AlbumItem> albums, AlbumItem current) {
    for (AlbumItem albumItem in albums) {
      if (albumItem.id == current.id) return true;
    }

    return false;
  }

  bool _isControlDown() {
    return _isControlPressed;
  }

  bool _isShiftDown() {
    return _isShiftPressed;
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

  // 获取相册图片列表
  void _getImagesOfAlbum(
      String albumId,
      Function(List<ImageItem> images) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/image/imagesOfAlbum");
    http
        .post(url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({"id": albumId}))
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

  void updateBottomItemNum() {
    if (!_openAlbumImagesPage && !_openImageDetailPage) {
      eventBus
          .fire(UpdateBottomItemNum(_allAlbums.length, _selectedAlbums.length));
    }

    if (_openAlbumImagesPage) {
      eventBus
          .fire(UpdateBottomItemNum(_allImages.length, _selectedImages.length));
    }
  }

  void _setBackBtnVisible(bool visible) {
    eventBus.fire(BackBtnVisibility(visible, module: UIModule.Image));
  }

  // 判断当前页面是否在前台显示
  bool _isFront() {
    return _isAlbumPageVisible;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    _unRegisterEventBus();
  }
}
