import 'dart:io';
import 'dart:js';

import 'package:air_controller/ext/filex.dart';
import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/util/context_menu_helper.dart';
import 'package:air_controller/util/sound_effect.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../home/bloc/home_bloc.dart';
import '../../model/video_item.dart';
import '../../model/video_order_type.dart';
import '../../network/device_connection_manager.dart';
import '../../repository/file_repository.dart';
import '../../repository/video_repository.dart';
import '../../util/common_util.dart';
import '../../util/system_app_launcher.dart';
import '../../video_home/bloc/video_home_bloc.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../../widget/video_flow_widget.dart';
import '../bloc/all_videos_bloc.dart';

class AllVideosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AllVideosBloc>(
      create: (context) => AllVideosBloc(
          fileRepository: context.read<FileRepository>(),
          videoRepository: context.read<VideoRepository>())
        ..add(AllVideosSubscriptionRequested()),
      child: AllVideosView(),
    );
  }
}

class AllVideosView extends StatelessWidget {
  FocusNode? _rootFocusNode = null;
  bool _isControlPressed = false;
  bool _isShiftPressed = false;

  ProgressIndicatorDialog? _progressIndicatorDialog;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    AllVideosStatus status =
        context.select((AllVideosBloc bloc) => bloc.state.status);
    List<VideoItem> videos =
        context.select((AllVideosBloc bloc) => bloc.state.videos);
    List<VideoItem> checkedVideos =
        context.select((AllVideosBloc bloc) => bloc.state.checkedVideos);
    VideoOrderType orderType =
        context.select((VideoHomeBloc bloc) => bloc.state.orderType);
    final homeTab = context.select((HomeBloc bloc) => bloc.state.tab);
    final currentTab = context.select((VideoHomeBloc bloc) => bloc.state.tab);

    _rootFocusNode = FocusNode();
    _rootFocusNode?.canRequestFocus = true;

    if (homeTab == HomeTab.video && currentTab == VideoHomeTab.allVideos) {
      _rootFocusNode?.requestFocus();
    }

    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AllVideosBloc, AllVideosState>(
              listener: (context, state) {
                VideoHomeTab currentTab =
                    context.read<VideoHomeBloc>().state.tab;

                if (currentTab == VideoHomeTab.allVideos) {
                  context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                      VideoHomeItemCount(
                          state.videos.length, state.checkedVideos.length)));

                  context.read<VideoHomeBloc>().add(
                      VideoHomeDeleteStatusChanged(
                          state.checkedVideos.length > 0));
                }
              },
              listenWhen: (previous, current) =>
                  previous.videos.length != current.videos.length ||
                  previous.checkedVideos.length !=
                      current.checkedVideos.length),
          BlocListener<AllVideosBloc, AllVideosState>(
              listener: (context, state) {
                _openMenu(
                    pageContext: context,
                    position: state.openMenuStatus.position!,
                    current: state.openMenuStatus.target);
              },
              listenWhen: (previous, current) =>
                  previous.openMenuStatus != current.openMenuStatus &&
                  current.openMenuStatus.isOpened),
          BlocListener<AllVideosBloc, AllVideosState>(
              listener: (context, state) {
                if (state.deleteStatus.status ==
                    AllVideosDeleteStatus.loading) {
                  SmartDialog.showLoading();
                }

                if (state.deleteStatus.status ==
                    AllVideosDeleteStatus.failure) {
                  SmartDialog.dismiss();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(state.deleteStatus.failureReason ??
                            "Delete videos failure.")));
                }

                if (state.deleteStatus.status ==
                    AllVideosDeleteStatus.success) {
                  SmartDialog.dismiss();
                }
              },
              listenWhen: (previous, current) =>
                  previous.deleteStatus != current.deleteStatus &&
                  current.deleteStatus.status != AllVideosDeleteStatus.initial),
          BlocListener<AllVideosBloc, AllVideosState>(
            listener: (context, state) {
              if (state.copyStatus.status == AllVideosCopyStatus.start) {
                _showDownloadProgressDialog(context, state.checkedVideos);
              }

              if (state.copyStatus.status == AllVideosCopyStatus.copying) {
                if (_progressIndicatorDialog?.isShowing == true) {
                  int current = state.copyStatus.current;
                  int total = state.copyStatus.total;

                  if (current > 0) {
                    String title = context.l10n.exporting;

                    List<VideoItem> checkedVideos = state.checkedVideos;

                    if (checkedVideos.length == 1) {
                      String name = checkedVideos.single.name;

                      title = context.l10n.placeholderExporting
                          .replaceFirst("%s", name);
                    }

                    if (checkedVideos.length > 1) {
                      String itemStr = context.l10n.placeHolderItemCount03
                          .replaceFirst("%d", "${checkedVideos.length}");
                      title = context.l10n.placeholderExporting
                          .replaceFirst("%s", itemStr);
                    }

                    _progressIndicatorDialog?.title = title;
                  }

                  _progressIndicatorDialog?.subtitle =
                      "${CommonUtil.convertToReadableSize(current)}/${CommonUtil.convertToReadableSize(total)}";
                  _progressIndicatorDialog?.updateProgress(current / total);
                }
              }

              if (state.copyStatus.status == AllVideosCopyStatus.failure) {
                _progressIndicatorDialog?.dismiss();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.copyStatus.error ??
                          context.l10n.copyFileFailure)));
              }

              if (state.copyStatus.status == AllVideosCopyStatus.success) {
                _progressIndicatorDialog?.dismiss();
              }
            },
            listenWhen: (previous, current) =>
                previous.copyStatus != current.copyStatus &&
                current.copyStatus.status != AllVideosCopyStatus.initial,
          ),
          BlocListener<VideoHomeBloc, VideoHomeState>(
              listener: (context, state) {
                context
                    .read<VideoHomeBloc>()
                    .add(VideoHomeOderTypeVisibilityChanged(true));
                context
                    .read<VideoHomeBloc>()
                    .add(VideoHomeBackVisibilityChanged(false));

                List<VideoItem> videos =
                    context.read<AllVideosBloc>().state.videos;
                List<VideoItem> checkedVideos =
                    context.read<AllVideosBloc>().state.checkedVideos;

                context.read<VideoHomeBloc>().add(VideoHomeItemCountChanged(
                    VideoHomeItemCount(videos.length, checkedVideos.length)));
                context.read<VideoHomeBloc>().add(
                    VideoHomeDeleteStatusChanged(checkedVideos.length > 0));
              },
              listenWhen: (previous, current) =>
                  previous.tab != current.tab &&
                  current.tab == VideoHomeTab.allVideos),
          BlocListener<VideoHomeBloc, VideoHomeState>(
              listener: (context, state) {
                if (state.tab == VideoHomeTab.allVideos) {
                  _tryToDeleteVideos(context,
                      context.read<AllVideosBloc>().state.checkedVideos);
                }
              },
              listenWhen: (previous, current) =>
                  previous.deleteTapStatus != current.deleteTapStatus &&
                  current.deleteTapStatus == VideoHomeDeleteTapStatus.tap),
          BlocListener<AllVideosBloc, AllVideosState>(
            listener: (context, state) {
              if (state.uploadStatus.status == AllVideosUploadStatus.start) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: true)));
              }

              if (state.uploadStatus.status ==
                  AllVideosUploadStatus.uploading) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                        HomeLinearProgressIndicatorStatus(
                      visible: true,
                      current: state.uploadStatus.current,
                      total: state.uploadStatus.total,
                    )));
              }

              if (state.uploadStatus.status == AllVideosUploadStatus.failure) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content: Text(state.uploadStatus.failureReason ??
                          context.l10n.unknownError)));
              }

              if (state.uploadStatus.status == AllVideosUploadStatus.success) {
                context.read<HomeBloc>().add(HomeProgressIndicatorStatusChanged(
                    HomeLinearProgressIndicatorStatus(visible: false)));
                SoundEffect.play(SoundType.done);
              }
            },
            listenWhen: (previous, current) =>
                previous.uploadStatus != current.uploadStatus &&
                current.uploadStatus.status != AllVideosUploadStatus.initial,
          ),
          BlocListener<AllVideosBloc, AllVideosState>(
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
                  previous.showLoading != current.showLoading &&
                  current.showError == current.showError),
        ],
        child: DropTarget(
            enable: _isShowing(context),
            onDragEntered: (details) {
              SoundEffect.play(SoundType.bubble);
            },
            onDragDone: (details) {
              final homeTab = context.read<HomeBloc>().state.tab;

              if (homeTab != HomeTab.video) {
                return;
              }

              final videoTab = context.read<VideoHomeBloc>().state.tab;
              if (videoTab != VideoHomeTab.allVideos) {
                return;
              }

              final videos = details.files
                  .map((xFile) => File(xFile.path))
                  .where((file) => file.isVideo)
                  .toList();

              if (videos.isEmpty) return;

              context.read<AllVideosBloc>().add(AllVideosUploadVideos(videos));
            },
            child: Stack(
              children: [
                Focus(
                    autofocus: true,
                    focusNode: _rootFocusNode,
                    child: VideoFlowWidget(
                      rootUrl: DeviceConnectionManager.instance.rootURL,
                      sortOrder: orderType,
                      videos: videos,
                      selectedVideos: checkedVideos,
                      onVisibleChange: (isTotalVisible, isPartOfVisible) {},
                      onPointerDown: (event, video) {
                        if (event.isRightMouseClick()) {
                          List<VideoItem> checkedVideos =
                              context.read<AllVideosBloc>().state.checkedVideos;

                          if (!checkedVideos.contains(video)) {
                            context
                                .read<AllVideosBloc>()
                                .add(AllVideosCheckedChanged(video));
                          }

                          context.read<AllVideosBloc>().add(
                              AllVideosOpenMenuStatusChanged(
                                  AllVideosOpenMenuStatus(
                                      isOpened: true,
                                      position: event.position,
                                      target: video)));
                        }
                      },
                      onVideoTap: (video) {
                        context
                            .read<AllVideosBloc>()
                            .add(AllVideosCheckedChanged(video));
                      },
                      onVideoDoubleTap: (video) {
                        context
                            .read<AllVideosBloc>()
                            .add(AllVideosCheckedChanged(video));

                        SystemAppLauncher.openVideo(video);
                      },
                      onOutsideTap: () {
                        context
                            .read<AllVideosBloc>()
                            .add(AllVideosClearChecked());
                      },
                    ),
                    onKey: (node, event) {
                      _isControlPressed = !kIsWeb && Platform.isMacOS
                          ? event.isMetaPressed
                          : event.isControlPressed;
                      _isShiftPressed = event.isShiftPressed;

                      AllVideosBoardKeyStatus status =
                          AllVideosBoardKeyStatus.none;

                      if (_isControlPressed) {
                        status = AllVideosBoardKeyStatus.ctrlDown;
                      } else if (_isShiftPressed) {
                        status = AllVideosBoardKeyStatus.shiftDown;
                      }

                      context
                          .read<AllVideosBloc>()
                          .add(AllVideosKeyStatusChanged(status));

                      if (!kIsWeb && Platform.isMacOS) {
                        if (event.isMetaPressed &&
                            event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                          context
                              .read<AllVideosBloc>()
                              .add(AllVideosCheckAll());
                          return KeyEventResult.handled;
                        }
                      } else {
                        if (event.isControlPressed &&
                            event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                          context
                              .read<AllVideosBloc>()
                              .add(AllVideosCheckAll());
                          return KeyEventResult.handled;
                        }
                      }

                      return KeyEventResult.ignored;
                    }),
                Visibility(
                  child: Container(child: spinKit, color: Colors.white),
                  maintainSize: false,
                  visible: status == AllVideosStatus.loading,
                )
              ],
            )),
      ),
    );
  }

  bool _isShowing(BuildContext context) {
    final homeTab = context.read<HomeBloc>().state.tab;

    if (homeTab != HomeTab.video) {
      return false;
    }

    final videoTab = context.read<VideoHomeBloc>().state.tab;
    if (videoTab != VideoHomeTab.allVideos) {
      return false;
    }
    return true;
  }

  void _openMenu(
      {required BuildContext pageContext,
      required Offset position,
      required VideoItem current}) {
    String copyTitle = "";

    final checkedVideos = pageContext.read<AllVideosBloc>().state.checkedVideos;

    if (checkedVideos.length == 1) {
      VideoItem videoItem = checkedVideos.single;

      String name = videoItem.name;

      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = pageContext.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedVideos.length}");
      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    if (kIsWeb) {
      copyTitle = pageContext.l10n.downloadToLocal;
    }

    ContextMenuHelper()
        .showContextMenu(context: pageContext, globalOffset: position, items: [
      ContextMenuItem(
        title: pageContext.l10n.open,
        onTap: () {
          ContextMenuHelper().hideContextMenu();
          SystemAppLauncher.openVideo(current);
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          if (!kIsWeb) {
            CommonUtil.openFilePicker(pageContext.l10n.chooseDir, (dir) {
              _startCopy(pageContext, checkedVideos, dir);
            }, (error) {
              debugPrint("_openFilePicker, error: $error");
            });
          } else {
            pageContext
                .read<AllVideosBloc>()
                .add(AllVideosDownloadToLocal(checkedVideos));
          }
        },
      ),
      ContextMenuItem(
        title: pageContext.l10n.delete,
        onTap: () {
          ContextMenuHelper().hideContextMenu();
          _tryToDeleteVideos(pageContext, checkedVideos);
        },
      )
    ]);
  }

  void _showDownloadProgressDialog(
      BuildContext context, List<VideoItem> videos) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _progressIndicatorDialog?.dismiss();
        context.read<AllVideosBloc>().add(AllVideosCancelCopy());
      });
    }

    String title = context.l10n.preparing;

    if (videos.length > 1) {
      title = context.l10n.compressing;
    }

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  void _startCopy(
      BuildContext context, List<VideoItem> checkedVideos, String dir) {
    context
        .read<AllVideosBloc>()
        .add(AllVideosCopySubmitted(checkedVideos, dir));
  }

  void _tryToDeleteVideos(
      BuildContext pageContext, List<VideoItem> checkedVideos) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedVideos.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<AllVideosBloc>()
          .add(AllVideosDeleteSubmitted(checkedVideos));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }
}
