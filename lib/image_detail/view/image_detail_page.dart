import 'package:air_controller/ext/build_context_x.dart';
import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';

import '../../all_albums/bloc/all_albums_bloc.dart';
import '../../all_images/bloc/all_images_bloc.dart';
import '../../all_images/model/image_detail_arguments.dart';
import '../../bootstrap.dart';
import '../../constant.dart';
import '../../model/image_item.dart';
import '../../network/device_connection_manager.dart';
import '../../repository/image_repository.dart';
import '../../util/common_util.dart';
import '../../util/context_menu_helper.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../../widget/upward_triangle.dart';
import '../bloc/image_detail_bloc.dart';
import '../model/delete_images_result.dart';
import '../model/image_detail_copy_status.dart';

class ImageDetailPage extends StatelessWidget {
  final GlobalKey<NavigatorState> _navigatorKey;
  final List<ImageItem> _images;
  final int _index;
  final Source? source;
  final dynamic extra;

  ImageDetailPage(
      {required GlobalKey<NavigatorState> navigatorKey,
      required List<ImageItem> images,
      required int index,
      this.source,
      this.extra})
      : _navigatorKey = navigatorKey,
        _images = images,
        _index = index;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImageDetailBloc>(
      create: (context) => ImageDetailBloc(_images, _index,
          imageRepository: context.read<ImageRepository>()),
      child: ImageDetailView(
        navigatorKey: _navigatorKey,
        source: source,
        extra: extra,
      ),
    );
  }
}

class ImageDetailView extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Source? source;
  final dynamic extra;

  const ImageDetailView(
      {Key? key,
      required this.navigatorKey,
      required this.source,
      required this.extra})
      : super(key: key);

  @override
  State<ImageDetailView> createState() => _ImageDetailViewState();
}

class _ImageDetailViewState extends State<ImageDetailView> {
  bool _isAboutIconTapDown = false;
  bool _isBackBtnDown = false;
  ExtendedPageController? _extendedPageController;
  FocusNode? _imageDetailFocusNode;
  ProgressIndicatorDialog? _progressIndicatorDialog;

  final _URL_SERVER =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";
  final GlobalKey _aboutIconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    int currentIndex =
        context.select((ImageDetailBloc bloc) => bloc.state.currentIndex);
    List<ImageItem> images =
        context.select((ImageDetailBloc bloc) => bloc.state.images);
    double imageScale =
        context.select((ImageDetailBloc bloc) => bloc.state.imageScale);

    String imageIndicatorStr = "${currentIndex + 1} / ${images.length}";
    String imageScaleStr = "${(imageScale * 100).toInt()}%";

    final _divider_line_color = Color(0xffe0e0e0);

    _extendedPageController = ExtendedPageController(initialPage: currentIndex);

    _imageDetailFocusNode = FocusNode();
    _imageDetailFocusNode?.canRequestFocus = true;
    _imageDetailFocusNode?.requestFocus();

    final pageContext = context;

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<ImageDetailBloc, ImageDetailState>(
            listener: (context, state) {
              if (state.deleteStatus.status == DeleteImagesStatus.loading) {
                SmartDialog.showLoading();
              }

              if (state.deleteStatus.status == DeleteImagesStatus.failure) {
                SmartDialog.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.deleteStatus.failureReason ??
                          "Delete image fail")));

                Future.delayed(Duration(milliseconds: 500), () {
                  _imageDetailFocusNode?.requestFocus();
                });
              }

              if (state.deleteStatus.status == DeleteImagesStatus.success) {
                SmartDialog.dismiss();

                if (widget.source == Source.allImages) {
                  AllImagesBloc bloc = widget.extra;
                  bloc.add(AllImagesClearDeleted(state.deleteStatus.images));
                }

                if (widget.source == Source.albums) {
                  AllAlbumsBloc bloc = widget.extra;
                  bloc.add(AllAlbumsClearDeletedImage(
                      state.deleteStatus.images.single));
                }

                Future.delayed(Duration(milliseconds: 500), () {
                  _imageDetailFocusNode?.requestFocus();
                });
              }
            },
            listenWhen: (previous, current) =>
                previous.deleteStatus.status != DeleteImagesStatus.initial &&
                previous.deleteStatus.status != current.deleteStatus.status,
          ),
          BlocListener<ImageDetailBloc, ImageDetailState>(
            listener: (context, state) {
              if (state.copyStatus.status == ImageDetailCopyStatus.start) {
                _showDownloadProgressDialog(
                    context, state.images[state.currentIndex]);
              }

              if (state.copyStatus.status == ImageDetailCopyStatus.copying) {
                if (_progressIndicatorDialog?.isShowing == true) {
                  int current = state.copyStatus.current;
                  int total = state.copyStatus.total;

                  if (current > 0) {
                    String title = context.l10n.exporting;

                    ImageItem image = state.images[state.currentIndex];

                    String name = image.path;

                    int index = image.path.lastIndexOf("/");
                    if (index != -1) {
                      name = image.path.substring(index + 1);
                    }

                    title = context.l10n.placeholderExporting
                        .replaceFirst("%s", name);

                    _progressIndicatorDialog?.title = title;
                  }

                  _progressIndicatorDialog?.subtitle =
                      "${CommonUtil.convertToReadableSize(current)}/${CommonUtil.convertToReadableSize(total)}";
                  _progressIndicatorDialog?.updateProgress(current / total);
                }
              }

              if (state.copyStatus.status == ImageDetailCopyStatus.failure) {
                _progressIndicatorDialog?.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(
                          state.copyStatus.error ?? "Copy image failure.")));
              }

              if (state.copyStatus.status == ImageDetailCopyStatus.success) {
                _progressIndicatorDialog?.dismiss();
              }
            },
            listenWhen: (previous, current) =>
                previous.copyStatus != current.copyStatus &&
                current.copyStatus.status != ImageDetailCopyStatus.initial,
          ),
          BlocListener<ImageDetailBloc, ImageDetailState>(
            listener: (context, state) {
              if (state.showLoading) {
                BotToast.showLoading();
              } else {
                BotToast.closeAllLoading();
              }

              if (state.showError) {
                BotToast.showText(
                    text: state.errorMessage ?? context.l10n.unknownError);
              }
            },
            listenWhen: (previous, current) =>
                previous.showLoading != current.showLoading ||
                previous.showError != current.showError,
          ),
        ],
        child: Focus(
            autofocus: true,
            focusNode: _imageDetailFocusNode,
            canRequestFocus: true,
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
                _deleteImage(pageContext, images[currentIndex]);
                return KeyEventResult.handled;
              }

              if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
                _openPreImage(currentIndex, images);
                return KeyEventResult.handled;
              }

              if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
                _setImageScale(context, imageScale, true);
                return KeyEventResult.handled;
              }

              if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
                _setImageScale(context, imageScale, false);
                return KeyEventResult.handled;
              }

              if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
                _openNextImage(currentIndex, images);
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              // 返回按钮
                              StatefulBuilder(
                                  builder: (context, setState) =>
                                      GestureDetector(
                                        child: Container(
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                  "assets/icons/icon_right_arrow.png",
                                                  width: 12,
                                                  height: 12),
                                              Container(
                                                child: Text(context.l10n.back,
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff5c5c62),
                                                        fontSize: 13)),
                                                margin:
                                                    EdgeInsets.only(left: 3),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              color: _isBackBtnDown
                                                  ? Color(0xffe8e8e8)
                                                  : Color(0xfff3f3f4),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(3.0)),
                                              border: Border.all(
                                                  color: Color(0xffdedede),
                                                  width: 1.0)),
                                          height: 25,
                                          padding: EdgeInsets.only(
                                              right: 6, left: 2),
                                          margin: EdgeInsets.only(left: 15),
                                        ),
                                        onTap: () {
                                          widget.navigatorKey.currentState
                                              ?.pop();
                                        },
                                        onTapDown: (detail) {
                                          setState(() {
                                            _isBackBtnDown = true;
                                          });
                                        },
                                        onTapCancel: () {
                                          setState(() {
                                            _isBackBtnDown = false;
                                          });
                                        },
                                        onTapUp: (detail) {
                                          setState(() {
                                            _isBackBtnDown = false;
                                          });
                                        },
                                      )),

                              GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      "assets/icons/icon_image_size_minus_normal.png",
                                      width: 13,
                                      height: 60),
                                  // color: Colors.red,
                                  padding: EdgeInsets.all(5.0),
                                  margin: EdgeInsets.only(left: 15),
                                ),
                                onTap: () {
                                  _setImageScale(context, imageScale, false);
                                },
                              ),

                              // SeekBar
                              Container(
                                child: SliderTheme(
                                    data: SliderThemeData(
                                        thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: 7),
                                        overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: 7),
                                        activeTrackColor: Color(0xffe3e3e3),
                                        inactiveTrackColor: Color(0xffe3e3e3),
                                        trackHeight: 3,
                                        thumbColor: Colors.white),
                                    child: Material(
                                      child: Slider(
                                        value: (imageScale - 1.0) * 100,
                                        onChanged: (value) {
                                          context.read<ImageDetailBloc>().add(
                                              ImageDetailScaleChanged(
                                                  value / 100 + 1.0));
                                        },
                                        min: 0,
                                        max: 100.0 * Constant.IMAGE_MAX_SCALE -
                                            100.0,
                                      ),
                                    )),
                                width: 80,
                                margin: EdgeInsets.only(left: 0, right: 0),
                              ),

                              GestureDetector(
                                child: Container(
                                  child: Image.asset(
                                      "assets/icons/icon_image_size_plus_normal.png",
                                      width: 20,
                                      height: 20),
                                  margin: EdgeInsets.only(right: 15),
                                ),
                                onTap: () {
                                  _setImageScale(context, imageScale, true);
                                },
                              ),

                              Text(imageScaleStr,
                                  style: TextStyle(
                                      fontSize: 13, color: Color(0xff7a7a7a))),
                            ],
                          )),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              child: Container(
                                  child: Image.asset(
                                      "assets/icons/icon_image_pre_normal.png",
                                      width: 13,
                                      height: 13)),
                              onTap: () {
                                _openPreImage(currentIndex, images);
                              },
                            ),
                            Container(
                              child: Text(imageIndicatorStr,
                                  style: TextStyle(
                                      color: Color(0xff626160), fontSize: 16)),
                              padding: EdgeInsets.only(left: 20, right: 20),
                            ),
                            GestureDetector(
                              child: Container(
                                child: Image.asset(
                                    "assets/icons/icon_image_next_normal.png",
                                    width: 13,
                                    height: 13),
                              ),
                              onTap: () {
                                _openNextImage(currentIndex, images);
                              },
                            )
                          ],
                        ),
                      ),
                      Align(
                          alignment: Alignment.centerRight,
                          child: StatefulBuilder(
                              builder: (context, setState) => GestureDetector(
                                    child: Container(
                                      key: _aboutIconKey,
                                      child: Image.asset(
                                          "assets/icons/icon_about_image.png",
                                          width: 14,
                                          height: 14),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0xffd5d5d5),
                                              width: 1.0),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                          color: _isAboutIconTapDown
                                              ? Color(0xffe7e7e7)
                                              : Color(0xfff4f4f4)),
                                      padding:
                                          EdgeInsets.fromLTRB(12, 4, 12, 4),
                                      margin: EdgeInsets.only(right: 15),
                                    ),
                                    onTap: () {
                                      _showImageInfoDialog(
                                          context, images[currentIndex]);
                                    },
                                    onTapDown: (event) {
                                      setState(() {
                                        _isAboutIconTapDown = true;
                                      });
                                    },
                                    onTapUp: (event) {
                                      setState(() {
                                        _isAboutIconTapDown = false;
                                      });
                                    },
                                    onTapCancel: () {
                                      setState(() {
                                        _isAboutIconTapDown = false;
                                      });
                                    },
                                  ))),
                    ],
                  ),
                  height: Constant.HOME_NAVI_BAR_HEIGHT,
                  color: Color(0xfff6f6f6),
                ),
                Divider(
                    color: _divider_line_color, height: 1.0, thickness: 1.0),
                Expanded(
                    child: Container(
                  child: ExtendedImageGesturePageView.builder(
                    controller: _extendedPageController,
                    itemBuilder: (context, index) {
                      return Listener(
                        child: ExtendedImage.network(
                            "${_URL_SERVER}/stream/file?path=${images[index].path}",
                            mode: ExtendedImageMode.gesture,
                            fit: BoxFit.contain,
                            cache: true, initGestureConfigHandler: (state) {
                          return GestureConfig(
                              minScale: 1.0,
                              animationMinScale: 1.0,
                              maxScale: Constant.IMAGE_MAX_SCALE.toDouble(),
                              animationMaxScale:
                                  Constant.IMAGE_MAX_SCALE.toDouble(),
                              speed: 1.0,
                              inertialSpeed: 100.0,
                              initialScale: imageScale,
                              inPageView: false,
                              initialAlignment: InitialAlignment.center,
                              gestureDetailsIsChanged: (detail) {
                                context.read<ImageDetailBloc>().add(
                                    ImageDetailScaleChanged(
                                        detail?.totalScale ?? 1.0));
                              });
                        }, loadStateChanged: (state) {
                          if (state.extendedImageLoadState ==
                              LoadState.failed) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              alignment: Alignment.center,
                              child: Text(context.l10n.loadImageFailure,
                                  style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
                            );
                          }

                          return null;
                        }, onDoubleTap: (event) {
                          _setImageScale(context, imageScale, true);
                        }),
                        onPointerDown: (event) {
                          if (event.isRightMouseClick()) {
                            _openMenu(
                                context: pageContext,
                                position: event.position,
                                image: images[currentIndex]);
                          }
                        },
                      );
                    },
                    onPageChanged: (index) {
                      context
                          .read<ImageDetailBloc>()
                          .add(ImageDetailIndexChanged(index));
                      _imageDetailFocusNode?.requestFocus();
                    },
                    itemCount: images.length,
                  ),
                  color: Colors.white,
                ))
              ],
            )),
      ),
    );
  }

  void _showDownloadProgressDialog(BuildContext context, ImageItem image) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _progressIndicatorDialog?.dismiss();
        context.read<AllImagesBloc>().add(AllImagesCancelCopySubmitted());
      });
    }

    String title = context.l10n.preparing;

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  void _openMenu(
      {required BuildContext context,
      required Offset position,
      required ImageItem image}) {
    String copyTitle = "";

    String name = "";

    int index = image.path.lastIndexOf("/");
    if (index != -1) {
      name = image.path.substring(index + 1);
    }

    copyTitle = context.l10n.placeHolderCopyToComputer
        .replaceFirst("%s", name)
        .adaptForOverflow();

    if (kIsWeb) {
      copyTitle = context.l10n.downloadToLocal;
    }

    ContextMenuHelper()
        .showContextMenu(context: context, globalOffset: position, items: [
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          if (!kIsWeb) {
            CommonUtil.openFilePicker(context.l10n.chooseDir, (dir) {
              _startCopy(context, image, dir);
            }, (error) {
              logger.d("_openFilePicker, error: $error");
            });
          } else {
            context
                .read<ImageDetailBloc>()
                .add(ImageDetailDownloadToLocal(image));
          }
        },
      ),
      ContextMenuItem(
        title: context.l10n.delete,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          _deleteImage(context, image);
        },
      )
    ]);
  }

  void _startCopy(BuildContext context, ImageItem image, String dir) {
    context.read<ImageDetailBloc>().add(ImageDetailCopySubmitted(image, dir));
  }

  void _deleteImage(BuildContext context, ImageItem image) {
    final pageContext = context;

    CommonUtil.showConfirmDialog(
        context,
        "${context.l10n.tipDeleteTitle.replaceFirst("%s", "1")}",
        context.l10n.tipDeleteDesc,
        context.l10n.cancel,
        context.l10n.delete, (context) {
      Navigator.of(pageContext, rootNavigator: true).pop();

      pageContext
          .read<ImageDetailBloc>()
          .add(ImageDetailDeleteSubmitted(image));
    }, (context) {
      Navigator.of(pageContext, rootNavigator: true).pop();
    });
  }

  void _setImageScale(
      BuildContext context, double currentScale, bool isEnlarge) {
    if (isEnlarge) {
      double targetScale = 1.5;
      for (int i = 0; i <= Constant.IMAGE_MAX_SCALE ~/ 0.5; i++) {
        double value = Constant.IMAGE_MAX_SCALE - 0.5 * i;

        if (value - currentScale <= 0.5) {
          targetScale = value;

          if (targetScale < 1.5) targetScale = 1.5;

          break;
        }
      }
      context.read<ImageDetailBloc>().add(ImageDetailScaleChanged(targetScale));
    } else {
      double targetScale = 1.0;
      for (int i = 0; i <= Constant.IMAGE_MAX_SCALE ~/ 0.5; i++) {
        double value = i * 0.5 + 1.0;
        if (currentScale - value <= 0.5) {
          targetScale = value;
          break;
        }
      }
      context.read<ImageDetailBloc>().add(ImageDetailScaleChanged(targetScale));
    }
  }

  void _openPreImage(int currentIndex, List<ImageItem> images) {
    if (currentIndex > 0 && currentIndex < images.length) {
      _extendedPageController?.jumpToPage(currentIndex - 1);
    }
  }

  void _openNextImage(int currentIndex, List<ImageItem> images) {
    if (currentIndex < images.length - 1 && currentIndex + 1 >= 0) {
      _extendedPageController?.jumpToPage(currentIndex + 1);
    }
  }

  void _showImageInfoDialog(BuildContext context, ImageItem imageItem) {
    TextStyle textStyle = TextStyle(color: Color(0xff636363), fontSize: 13);

    String name = "";
    String path = "";
    int index = imageItem.path.lastIndexOf("/");
    if (index != -1) {
      path = imageItem.path.substring(0, index);
      name = imageItem.path.substring(index + 1);
    }

    String extension = "";
    int pointIndex = imageItem.path.lastIndexOf(".");
    if (pointIndex != -1) {
      extension = imageItem.path.substring(pointIndex + 1);
    }

    double labelWidth = 100;
    double contentWidth = 200;
    double dialogWidth = 380;
    double triangleWidth = 15;

    RenderBox renderBox =
        _aboutIconKey.currentContext?.findRenderObject() as RenderBox;

    var offset = renderBox.localToGlobal(Offset.zero);
    var width = renderBox.size.width;
    var height = renderBox.size.height;

    var screenWidth = MediaQuery.of(context).size.width;

    var left = screenWidth - dialogWidth - 10;
    var top = offset.dy + height + 5;

    var triangleLeft = offset.dx + width / 2 - left - triangleWidth / 2 - 8;

    showDialog(
        context: context,
        builder: (context) {
          return Stack(
            children: [
              Positioned(
                  left: left,
                  top: top,
                  child: Stack(
                    children: [
                      Container(
                        child: Wrap(
                          direction: Axis.vertical,
                          children: [
                            Container(
                              child: Text(
                                context.l10n.generalLabel,
                                style: TextStyle(
                                    color: Color(0xff313237), fontSize: 16),
                              ),
                              margin: EdgeInsets.only(
                                  top: 10, left: 15, bottom: 15),
                            ),
                            Wrap(
                              children: [
                                Container(
                                  child: Text(
                                    context.l10n.nameLabel,
                                    style: textStyle,
                                    textAlign: TextAlign.right,
                                  ),
                                  width: labelWidth,
                                  padding: EdgeInsets.only(right: 5),
                                ),
                                Container(
                                  child: Text("$name", style: textStyle),
                                  width: contentWidth,
                                )
                              ],
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      context.l10n.pathLabel,
                                      textAlign: TextAlign.right,
                                      style: textStyle,
                                    ),
                                    width: labelWidth,
                                    padding: EdgeInsets.only(right: 5),
                                  ),
                                  Container(
                                    child: Text(
                                      "$path",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      context.l10n.kindLabel,
                                      textAlign: TextAlign.right,
                                      style: textStyle,
                                    ),
                                    width: labelWidth,
                                    padding: EdgeInsets.only(right: 5),
                                  ),
                                  Container(
                                    child: Text(
                                      "$extension",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      context.l10n.sizeLabel,
                                      textAlign: TextAlign.right,
                                      style: textStyle,
                                    ),
                                    width: labelWidth,
                                    padding: EdgeInsets.only(right: 5),
                                  ),
                                  Container(
                                    child: Text(
                                      "${CommonUtil.convertToReadableSize(imageItem.size)}",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  ),
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      context.l10n.dimensionsLabel,
                                      style: textStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                    width: labelWidth,
                                    padding: EdgeInsets.only(right: 5),
                                  ),
                                  Container(
                                    child: Text(
                                      "${imageItem.width} x ${imageItem.height}",
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      context.l10n.createdLabel,
                                      style: textStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                    width: labelWidth,
                                    padding: EdgeInsets.only(right: 5),
                                  ),
                                  Container(
                                    child: Text(
                                      _convertToIntlTime(
                                          context, imageItem.createTime),
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            ),
                            Container(
                              child: Wrap(
                                children: [
                                  Container(
                                    child: Text(
                                      context.l10n.modifiedLabel,
                                      style: textStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                    width: labelWidth,
                                    padding: EdgeInsets.only(right: 5),
                                  ),
                                  Container(
                                    child: Text(
                                      _convertToIntlTime(
                                          context, imageItem.modifyTime * 1000),
                                      style: textStyle,
                                    ),
                                    width: contentWidth,
                                  )
                                ],
                              ),
                              margin: EdgeInsets.only(top: 10),
                            )
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xfffdfdfc),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black54,
                                offset: Offset(0, 0),
                                blurRadius: 1),
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 30),
                        margin: EdgeInsets.only(top: 10),
                        width: dialogWidth,
                      ),
                      Container(
                        child: Triangle(
                          key: Key("upward_triangle"),
                          width: triangleWidth,
                          height: 10,
                          color: Colors.white,
                          dividerColor: Colors.black26,
                        ),
                        margin: EdgeInsets.only(left: triangleLeft),
                      )
                    ],
                  ))
            ],
          );
        },
        barrierColor: Colors.transparent);
  }

  String _convertToIntlTime(BuildContext context, int time) {
    final df = DateFormat.yMMMd(context.currentAppLocale.toString())
        .addPattern("HH:mm:ss");
    return df.format(DateTime.fromMillisecondsSinceEpoch(time));
  }
}
