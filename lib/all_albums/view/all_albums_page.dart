import 'dart:io';

import 'package:air_controller/ext/filex.dart';
import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/util/sound_effect.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../all_images/model/image_detail_arguments.dart';
import '../../constant.dart';
import '../../enter/view/enter_page.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home_image/bloc/home_image_bloc.dart';
import '../../model/album_item.dart';
import '../../model/arrangement_mode.dart';
import '../../model/image_item.dart';
import '../../network/device_connection_manager.dart';
import '../../repository/file_repository.dart';
import '../../repository/image_repository.dart';
import '../../util/common_util.dart';
import '../../util/context_menu_helper.dart';
import '../../widget/image_flow_widget.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../../widget/simple_gesture_detector.dart';
import '../bloc/all_albums_bloc.dart';

class AllAlbumsPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AllAlbumsPage({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllAlbumsBloc>(
      create: (context) => AllAlbumsBloc(
          imageRepository: context.read<ImageRepository>(),
          fileRepository: context.read<FileRepository>())
        ..add(AllAlbumSubscriptionRequested()),
      child: AllAlbumsView(navigatorKey: navigatorKey),
    );
  }
}

class AllAlbumsView extends StatelessWidget {
  FocusNode? _rootFocusNode = null;
  final _OUT_PADDING = 20.0;
  final _IMAGE_SPACE = 15.0;

  bool _isControlPressed = false;
  bool _isShiftPressed = false;

  ProgressIndicatorDialog? _progressIndicatorDialog;

  final GlobalKey<NavigatorState> navigatorKey;

  AllAlbumsView({Key? key, required this.navigatorKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = _createGridContent(context);
    Widget albumImagesWidget = _createAlbumImagesWidget(context);

    final color = Color(0xff85a8d0);
    final spinKit = SpinKitCircle(color: color, size: 60.0);

    bool isAlbumImagesOpened = context
        .select((AllAlbumsBloc bloc) => bloc.state.albumOpenStatus.isOpened);
    AllAlbumsStatus allAlbumsStatus =
        context.select((AllAlbumsBloc bloc) => bloc.state.status);
    AlbumItem? currentAlbum = context
        .select((AllAlbumsBloc bloc) => bloc.state.albumOpenStatus.current);
    LoadImagesInAlbumStatusUnit loadImagesInAlbumStatusUnit = context
        .select((AllAlbumsBloc bloc) => bloc.state.loadImagesInAlbumStatus);

    HomeImageTab currentTab =
        context.select((HomeImageBloc bloc) => bloc.state.tab);

    _rootFocusNode = FocusNode();
    _rootFocusNode?.canRequestFocus = true;

    if (currentTab == HomeImageTab.allAlbums) {
      _rootFocusNode?.requestFocus();
    }

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AllAlbumsBloc, AllAlbumsState>(
            listener: (context, state) {
              if (state.albumOpenStatus.isOpened) {
                context.read<HomeImageBloc>().add(HomeImageCountChanged(
                    HomeImageCount(
                        totalCount: state.loadImagesInAlbumStatus.images.length,
                        checkedCount: state
                            .loadImagesInAlbumStatus.checkedImages.length)));

                context.read<HomeImageBloc>().add(HomeImageDeleteStatusChanged(
                    isDeleteEnabled:
                        state.loadImagesInAlbumStatus.checkedImages.length >
                            0));

                context
                    .read<HomeImageBloc>()
                    .add(HomeImageBackVisibilityChanged(true));
              } else {
                context.read<HomeImageBloc>().add(HomeImageCountChanged(
                    HomeImageCount(
                        totalCount: state.albums.length,
                        checkedCount: state.checkedAlbums.length)));

                context.read<HomeImageBloc>().add(HomeImageDeleteStatusChanged(
                    isDeleteEnabled: state.checkedAlbums.length > 0));

                context
                    .read<HomeImageBloc>()
                    .add(HomeImageBackVisibilityChanged(false));
              }
            },
            listenWhen: (previous, current) =>
                _needListenItemCountChange(previous, current),
          ),
          BlocListener<AllAlbumsBloc, AllAlbumsState>(
            listener: (context, state) {
              dynamic current = state.openMenuStatus.target;

              if (current is AlbumItem) {
                _openMenu(
                    context: context,
                    position: state.openMenuStatus.position!,
                    current: state.openMenuStatus.target!);
              } else {
                _openMenuForImages(
                    context: context,
                    position: state.openMenuStatus.position!,
                    current: state.openMenuStatus.target!);
              }
            },
            listenWhen: (previous, current) =>
                previous.openMenuStatus != current.openMenuStatus &&
                current.openMenuStatus.isOpened,
          ),
          BlocListener<AllAlbumsBloc, AllAlbumsState>(
            listener: (context, state) {
              if (state.albumOpenStatus.isOpened) {
                context.read<AllAlbumsBloc>().add(
                    AllAlbumsImagesRequested(state.albumOpenStatus.current!));
              }

              context.read<HomeImageBloc>().add(
                  HomeImageArrangementVisibilityChanged(
                      state.albumOpenStatus.isOpened));
            },
            listenWhen: (previous, current) =>
                previous.albumOpenStatus != current.albumOpenStatus,
          ),
          BlocListener<AllAlbumsBloc, AllAlbumsState>(
            listener: (context, state) {
              if (state.deleteAlbumStatus == AllAlbumsDeleteStatus.loading ||
                  state.deleteAlbumStatus == AllAlbumsDeleteStatus.success) {
                SmartDialog.showLoading();
              }

              if (state.deleteAlbumStatus == AllAlbumsDeleteStatus.failure) {
                SmartDialog.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content:
                          Text(state.failureReason ?? "Delete image fail")));
              }
            },
            listenWhen: (previous, current) =>
                previous.deleteAlbumStatus != current.deleteAlbumStatus &&
                current.deleteAlbumStatus != AllAlbumsDeleteStatus.initial,
          ),
          BlocListener<AllAlbumsBloc, AllAlbumsState>(
            listener: (context, state) {
              if (state.copyStatus.status == AllAlbumsCopyStatus.start) {
                _showDownloadProgressDialog(context, state.checkedAlbums);
              }

              if (state.copyStatus.status == AllAlbumsCopyStatus.copying) {
                if (_progressIndicatorDialog?.isShowing == true) {
                  int current = state.copyStatus.current;
                  int total = state.copyStatus.total;

                  String title = "";

                  List<AlbumItem> checkedAlbums = state.checkedAlbums;

                  if (checkedAlbums.length == 1) {
                    title = context.l10n.placeholderExporting
                        .replaceFirst("%s", checkedAlbums.single.name);
                  } else {
                    String itemStr = context.l10n.placeHolderItemCount03
                        .replaceFirst("%d", "${state.checkedAlbums.length}");
                    title = context.l10n.placeholderExporting
                        .replaceFirst("%s", itemStr);
                  }

                  _progressIndicatorDialog?.title = title;

                  _progressIndicatorDialog?.subtitle =
                      "${CommonUtil.convertToReadableSize(current)}/${CommonUtil.convertToReadableSize(total)}";
                  _progressIndicatorDialog?.updateProgress(current / total);
                }
              }

              if (state.copyStatus.status == AllAlbumsCopyStatus.failure) {
                _progressIndicatorDialog?.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.copyStatus.error ??
                          context.l10n.copyFileFailure)));
              }

              if (state.copyStatus.status == AllAlbumsCopyStatus.success) {
                _progressIndicatorDialog?.dismiss();
              }
            },
            listenWhen: (previous, current) =>
                previous.copyStatus != current.copyStatus &&
                current.copyStatus.status != AllAlbumsCopyStatus.initial,
          ),
          BlocListener<HomeImageBloc, HomeImageState>(
              listener: (context, state) {
                if (state.tab == HomeImageTab.allAlbums) {
                  if (isAlbumImagesOpened) {
                    List<ImageItem> images = context
                        .read<AllAlbumsBloc>()
                        .state
                        .loadImagesInAlbumStatus
                        .images;
                    List<ImageItem> checkedImages = context
                        .read<AllAlbumsBloc>()
                        .state
                        .loadImagesInAlbumStatus
                        .checkedImages;

                    context.read<HomeImageBloc>().add(HomeImageCountChanged(
                        HomeImageCount(
                            checkedCount: checkedImages.length,
                            totalCount: images.length)));

                    context.read<HomeImageBloc>().add(
                        HomeImageDeleteStatusChanged(
                            isDeleteEnabled: checkedImages.length > 0));

                    context
                        .read<HomeImageBloc>()
                        .add(HomeImageArrangementVisibilityChanged(true));
                  } else {
                    List<AlbumItem> albums =
                        context.read<AllAlbumsBloc>().state.albums;
                    List<AlbumItem> checkedAlbums =
                        context.read<AllAlbumsBloc>().state.checkedAlbums;

                    context.read<HomeImageBloc>().add(HomeImageCountChanged(
                        HomeImageCount(
                            checkedCount: checkedAlbums.length,
                            totalCount: albums.length)));
                    context.read<HomeImageBloc>().add(
                        HomeImageDeleteStatusChanged(
                            isDeleteEnabled: checkedAlbums.length > 0));

                    context
                        .read<HomeImageBloc>()
                        .add(HomeImageArrangementVisibilityChanged(false));
                  }

                  context
                      .read<HomeImageBloc>()
                      .add(HomeImageBackVisibilityChanged(isAlbumImagesOpened));

                  _rootFocusNode?.requestFocus();
                }
              },
              listenWhen: (previous, current) => previous.tab != current.tab),
          BlocListener<HomeImageBloc, HomeImageState>(
            listener: (context, state) {
              context
                  .read<AllAlbumsBloc>()
                  .add(AllAlbumsOpenStatusChanged(isOpened: false));
            },
            listenWhen: (previous, current) =>
                previous.backTapStatus != current.backTapStatus &&
                current.backTapStatus == HomeImageBackTapStatus.tap,
          ),
          BlocListener<HomeImageBloc, HomeImageState>(
            listener: (context, state) {
              bool isAlbumImagesOpened =
                  context.read<AllAlbumsBloc>().state.albumOpenStatus.isOpened;
              if (isAlbumImagesOpened) {
                List<ImageItem> checkedImages = context
                    .read<AllAlbumsBloc>()
                    .state
                    .loadImagesInAlbumStatus
                    .checkedImages;
                _tryToDeleteImages(context, checkedImages);
              } else {
                List<AlbumItem> checkedAlbums =
                    context.read<AllAlbumsBloc>().state.checkedAlbums;
                _tryToDeleteAlbums(context, checkedAlbums);
              }
            },
            listenWhen: (previous, current) =>
                previous.deleteTapStatus != current.deleteTapStatus &&
                current.deleteTapStatus.tab == HomeImageTab.allAlbums &&
                current.deleteTapStatus.status == HomeImageDeleteTapStatus.tap,
          ),
          BlocListener<AllAlbumsBloc, AllAlbumsState>(
            listener: (context, state) {
              if (state.uploadStatus.status == AllAlbumsUploadStatus.start) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: true)));
              }

              if (state.uploadStatus.status ==
                  AllAlbumsUploadStatus.uploading) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                        HomeLinearProgressIndicatorStatus(
                      visible: true,
                      current: state.uploadStatus.current,
                      total: state.uploadStatus.total,
                    )));
              }

              if (state.uploadStatus.status == AllAlbumsUploadStatus.failure) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.uploadStatus.failureReason ??
                          context.l10n.unknownError)));
              }

              if (state.uploadStatus.status == AllAlbumsUploadStatus.success) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));
                SoundEffect.play(SoundType.done);
              }
            },
            listenWhen: (previous, current) =>
                previous.uploadStatus != current.uploadStatus &&
                current.uploadStatus.status != AllAlbumsUploadStatus.initial,
          )
        ],
        child: Focus(
          autofocus: true,
          focusNode: _rootFocusNode,
          child: Stack(
            children: [
              Visibility(
                child: GestureDetector(
                  child: Stack(children: [
                    content,
                    Visibility(
                      child: Container(child: spinKit, color: Colors.white),
                      maintainSize: false,
                      visible: allAlbumsStatus == AllAlbumsStatus.loading,
                    )
                  ]),
                  onTap: () {
                    context.read<AllAlbumsBloc>().add(AllAlbumsClearChecked());
                  },
                ),
                visible: !isAlbumImagesOpened,
              ),
              Visibility(
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        children: [
                          GestureDetector(
                            child: Container(
                              child: Text(context.l10n.galleries,
                                  style: TextStyle(
                                      color: Color(0xff5b5c62), fontSize: 14)),
                              padding: EdgeInsets.only(left: 10),
                            ),
                            onTap: () {
                              context.read<AllAlbumsBloc>().add(
                                  AllAlbumsOpenStatusChanged(isOpened: false));
                            },
                          ),
                          Image.asset("assets/icons/ic_right_arrow.png",
                              height: 20),
                          Text(currentAlbum?.name ?? "",
                              style: TextStyle(
                                  color: Color(0xff5b5c62), fontSize: 14))
                        ],
                      ),
                      color: Color(0xfffafafa),
                      height: 30,
                    ),
                    Divider(
                        color: Color(0xffe0e0e0), height: 1.0, thickness: 1.0),
                    Expanded(
                        child: Stack(
                      children: [
                        Container(
                          child: albumImagesWidget,
                          color: Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Visibility(
                          child: Container(child: spinKit, color: Colors.white),
                          maintainSize: false,
                          visible: loadImagesInAlbumStatusUnit.status ==
                              LoadImagesInAlbumStatus.loading,
                        )
                      ],
                    ))
                  ],
                ),
                visible: isAlbumImagesOpened,
              )
            ],
          ),
          onKey: (node, event) {
            _isControlPressed =
                Platform.isMacOS ? event.isMetaPressed : event.isControlPressed;
            _isShiftPressed = event.isShiftPressed;

            AllAlbumsBoardKeyStatus status = AllAlbumsBoardKeyStatus.none;

            if (_isControlPressed) {
              status = AllAlbumsBoardKeyStatus.ctrlDown;
            } else if (_isShiftPressed) {
              status = AllAlbumsBoardKeyStatus.shiftDown;
            }

            context
                .read<AllAlbumsBloc>()
                .add(AllAlbumsKeyStatusChanged(status));

            if (Platform.isMacOS) {
              if (event.isMetaPressed &&
                  event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                context
                    .read<AllAlbumsBloc>()
                    .add(AllAlbumsShortcutKeyTriggered(ShortcutKey.ctrlAndA));
                return KeyEventResult.handled;
              }
            } else {
              if (event.isControlPressed &&
                  event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                context
                    .read<AllAlbumsBloc>()
                    .add(AllAlbumsShortcutKeyTriggered(ShortcutKey.ctrlAndA));
                return KeyEventResult.handled;
              }
            }

            return KeyEventResult.ignored;
          },
        ),
      ),
    );
  }

  void _showDownloadProgressDialog(
      BuildContext context, List<AlbumItem> albums) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _progressIndicatorDialog?.dismiss();
        context.read<AllAlbumsBloc>().add(AllAlbumsCancelCopySubmitted());
      });
    }

    String title = context.l10n.preparing;

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  bool _needListenItemCountChange(
      AllAlbumsState previous, AllAlbumsState current) {
    if (previous.albums.length != current.albums.length) return true;

    if (previous.checkedAlbums.length != current.checkedAlbums.length)
      return true;

    if (previous.loadImagesInAlbumStatus.images.length !=
        current.loadImagesInAlbumStatus.images.length) return true;

    if (previous.loadImagesInAlbumStatus.checkedImages.length !=
        current.loadImagesInAlbumStatus.checkedImages.length) return true;

    return false;
  }

  void _openMenu(
      {required BuildContext context,
      required Offset position,
      required AlbumItem current}) {
    final checkedAlbums = context.read<AllAlbumsBloc>().state.checkedAlbums;
    String copyTitle = "";

    if (checkedAlbums.length == 1) {
      AlbumItem albumItem = checkedAlbums.single;

      String name = albumItem.name;

      copyTitle = context.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = context.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedAlbums.length}");
      copyTitle = context.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    ContextMenuHelper()
        .showContextMenu(context: context, globalOffset: position, items: [
      ContextMenuItem(
        title: context.l10n.open,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          context.read<AllAlbumsBloc>().add(
              AllAlbumsOpenStatusChanged(isOpened: true, current: current));
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          CommonUtil.openFilePicker(context.l10n.chooseDir, (dir) {
            _startCopy(context, checkedAlbums, dir);
          }, (error) {
            debugPrint("_openFilePicker, error: $error");
          });
        },
      ),
      ContextMenuItem(
        title: context.l10n.delete,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          _tryToDeleteAlbums(context, checkedAlbums);
        },
      )
    ]);
  }

  void _openMenuForImages(
      {required BuildContext context,
      required Offset position,
      required ImageItem current}) {
    String copyTitle = "";

    final images =
        context.read<AllAlbumsBloc>().state.loadImagesInAlbumStatus.images;
    final checkedImages = context
        .read<AllAlbumsBloc>()
        .state
        .loadImagesInAlbumStatus
        .checkedImages;

    if (checkedImages.length == 1) {
      ImageItem imageItem = checkedImages.single;

      String name = "";

      int index = imageItem.path.lastIndexOf("/");
      if (index != -1) {
        name = imageItem.path.substring(index + 1);
      }

      copyTitle = context.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = context.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedImages.length}");
      copyTitle = context.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    ContextMenuHelper()
        .showContextMenu(context: context, globalOffset: position, items: [
      ContextMenuItem(
        title: context.l10n.open,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          _openImageDetailPage(context, images, images.indexOf(current));
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          CommonUtil.openFilePicker(context.l10n.chooseDir, (dir) {
            _startCopyImages(context, checkedImages, dir);
          }, (error) {
            debugPrint("_openFilePicker, error: $error");
          });
        },
      ),
      ContextMenuItem(
        title: context.l10n.delete,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          _tryToDeleteImages(context, checkedImages);
        },
      )
    ]);
  }

  void _startCopy(BuildContext context, List<AlbumItem> albums, String dir) {
    context.read<AllAlbumsBloc>().add(AllAlbumsCopySubmitted(albums, dir));
  }

  void _startCopyImages(
      BuildContext context, List<ImageItem> images, String dir) {
    context
        .read<AllAlbumsBloc>()
        .add(AllAlbumsCopyImagesSubmitted(images, dir));
  }

  void _tryToDeleteAlbums(
      BuildContext pageContext, List<AlbumItem> checkedAlbums) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedAlbums.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<AllAlbumsBloc>()
          .add(AllAlbumsDeleteSubmitted(checkedAlbums));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _tryToDeleteImages(
      BuildContext pageContext, List<ImageItem> checkedImages) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedImages.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<AllAlbumsBloc>()
          .add(AllAlbumsDeleteImagesSubmitted(checkedImages));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  Widget _createGridContent(BuildContext context) {
    List<AlbumItem> albums =
        context.select((AllAlbumsBloc bloc) => bloc.state.albums);
    List<AlbumItem> checkedAlbums =
        context.select((AllAlbumsBloc bloc) => bloc.state.checkedAlbums);

    bool isChecked(AlbumItem album) {
      return checkedAlbums.contains(album);
    }

    return Container(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            crossAxisSpacing: _IMAGE_SPACE,
            childAspectRatio: 1.0,
            mainAxisSpacing: _IMAGE_SPACE),
        itemBuilder: (BuildContext context, int index) {
          AlbumItem album = albums[index];

          return _AlbumsListItem(
            album: album,
            isChecked: isChecked(album),
            onTap: () {
              context.read<AllAlbumsBloc>().add(AllAlbumsCheckedChanged(album));
            },
            onDoubleTap: () {
              context.read<AllAlbumsBloc>().add(
                  AllAlbumsOpenStatusChanged(isOpened: true, current: album));
            },
            onRightMouseClick: (position, album) {
              if (!checkedAlbums.contains(album)) {
                context
                    .read<AllAlbumsBloc>()
                    .add(AllAlbumsCheckedChanged(album));
              }

              context.read<AllAlbumsBloc>().add(AllAlbumsMenuStatusChanged(
                  AllAlbumsOpenMenuStatus(
                      isOpened: true, position: position, target: album)));
            },
            onDragDone: (details) {
              final photos = details.files
                  .map((e) => File(e.path))
                  .where((element) => element.isImage)
                  .toList();
              if (photos.isEmpty) return;

              context
                  .read<AllAlbumsBloc>()
                  .add(AllAlbumsUploadPhotos(album: album, photos: photos));
            },
          );
        },
        itemCount: albums.length,
        shrinkWrap: true,
        primary: false,
      ),
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(_OUT_PADDING, _OUT_PADDING, _OUT_PADDING, 0),
    );
  }

  Widget _createAlbumImagesWidget(BuildContext context) {
    ArrangementMode arrangementMode =
        context.select((HomeImageBloc bloc) => bloc.state.arrangement);
    List<ImageItem> images = context.select(
        (AllAlbumsBloc bloc) => bloc.state.loadImagesInAlbumStatus.images);
    List<ImageItem> checkedImages = context.select((AllAlbumsBloc bloc) =>
        bloc.state.loadImagesInAlbumStatus.checkedImages);

    final enterContext = EnterPage.enterKey.currentContext;
    String languageCode = "en";

    if (null != enterContext) {
      languageCode = Localizations.localeOf(enterContext).languageCode;
    }

    return DropTarget(
      child: ImageFlowWidget(
        languageCode: languageCode,
        rootUrl: DeviceConnectionManager.instance.rootURL,
        arrangeMode: arrangementMode,
        images: images,
        checkedImages: checkedImages,
        onImageDoubleTap: (image) {
          _openImageDetailPage(context, images, images.indexOf(image));

          context
              .read<AllAlbumsBloc>()
              .add(AllAlbumsImageCheckedChanged(image));
        },
        onImageSelected: (image) {
          context
              .read<AllAlbumsBloc>()
              .add(AllAlbumsImageCheckedChanged(image));
        },
        onOutsideTap: () {
          context.read<AllAlbumsBloc>().add(AllAlbumsImageClearChecked());
        },
        onRightMouseClick: (position, image) {
          if (!checkedImages.contains(image)) {
            context
                .read<AllAlbumsBloc>()
                .add(AllAlbumsImageCheckedChanged(image));
          }

          context.read<AllAlbumsBloc>().add(AllAlbumsMenuStatusChanged(
              AllAlbumsOpenMenuStatus(
                  isOpened: true, position: position, target: image)));
        },
      ),
      onDragDone: (details) {
        final photos = details.files
            .map((e) => File(e.path))
            .where((element) => element.isImage)
            .toList();
        if (photos.isEmpty) return;

        final album =
            context.read<AllAlbumsBloc>().state.albumOpenStatus.current;

        if (album != null) {
          context
              .read<AllAlbumsBloc>()
              .add(AllAlbumsUploadPhotos(album: album, photos: photos));
        }
      },
      onDragEntered: (details) {
        SoundEffect.play(SoundType.bubble);
      },
    );
  }

  void _openImageDetailPage(
      BuildContext context, List<ImageItem> images, int currentIndex) {
    final arguments = ImageDetailArguments(
        index: currentIndex,
        images: images,
        source: Source.albums,
        extra: context.read<AllAlbumsBloc>());
    navigatorKey.currentState
        ?.pushNamed(ImagePageRoute.IMAGE_DETAIL, arguments: arguments);
  }
}

class _AlbumsListItem extends StatefulWidget {
  final AlbumItem album;
  final bool isChecked;
  final Function? onTap;
  final Function? onDoubleTap;
  final Function(Offset, AlbumItem)? onRightMouseClick;
  final Function(DropDoneDetails)? onDragDone;

  const _AlbumsListItem(
      {Key? key,
      required this.album,
      required this.isChecked,
      this.onTap,
      this.onDoubleTap,
      this.onRightMouseClick,
      this.onDragDone});

  @override
  State<StatefulWidget> createState() {
    return _AlbumsListItemState();
  }
}

class _AlbumsListItemState extends State<_AlbumsListItem> {
  bool _isDragEntered = false;

  @override
  Widget build(BuildContext context) {
    final imageWidth = 140.0;
    final imageHeight = 140.0;
    final imagePadding = 3.0;
    final albumSelectedColor = Color(0xffe6e6e6);
    final albumNormalColor = Colors.white;

    final albumNormalTextColor = Color(0xff515151);
    final albumImageNumTextColor = Color(0xff929292);

    final albumTextSelectedColor = Colors.white;
    final albumImageNumSelectedColor = Colors.white;

    final albumNameColor = Colors.white;
    final albumNameSelectedColor = Color(0xff5d87ed);

    final coverURL =
        "${DeviceConnectionManager.instance.rootURL}/stream/image/thumbnail/${widget.album.coverImageId}/400/400";

    return DropTarget(
        child: Listener(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SimpleGestureDetector(
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3.0))),
                              )),
                          visible: widget.album.photoNum > 1 ? true : false,
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(3.0))),
                              )),
                          visible: widget.album.photoNum > 2 ? true : false,
                        ),
                        Container(
                          child: CachedNetworkImage(
                              imageUrl: coverURL,
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
                        color: widget.isChecked || _isDragEntered
                            ? albumSelectedColor
                            : albumNormalColor,
                        borderRadius: BorderRadius.all(Radius.circular(4.0))),
                    padding: EdgeInsets.all(8),
                  ),
                  onTap: () {
                    widget.onTap?.call();
                  },
                  onDoubleTap: () {
                    widget.onDoubleTap?.call();
                  },
                ),
                GestureDetector(
                  child: Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.album.name,
                          style: TextStyle(
                              color: widget.isChecked || _isDragEntered
                                  ? albumTextSelectedColor
                                  : albumNormalTextColor),
                        ),
                        Container(
                          child: Text(
                            "(${widget.album.photoNum})",
                            style: TextStyle(
                                color: widget.isChecked || _isDragEntered
                                    ? albumImageNumSelectedColor
                                    : albumImageNumTextColor),
                          ),
                          margin: EdgeInsets.only(left: 3),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        color: widget.isChecked || _isDragEntered
                            ? albumNameSelectedColor
                            : albumNameColor),
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  ),
                  onTap: () {
                    widget.onTap?.call();
                  },
                )
              ],
            ),
            onPointerDown: (event) {
              if (event.isRightMouseClick()) {
                widget.onRightMouseClick?.call(event.position, widget.album);
              }
            }),
        onDragEntered: (details) {
          SoundEffect.play(SoundType.bubble);
          setState(() {
            _isDragEntered = true;
          });
        },
        onDragDone: (details) {
          widget.onDragDone?.call(details);
        },
        onDragExited: (details) {
          setState(() {
            _isDragEntered = false;
          });
        });
  }
}
