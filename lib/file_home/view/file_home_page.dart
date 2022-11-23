import 'dart:developer';
import 'dart:io';

import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constant.dart';
import '../../grid_mode_files/view/grid_mode_files_page.dart';
import '../../home/bloc/home_bloc.dart';
import '../../list_mode_files/view/list_mode_files_page.dart';
import '../../model/display_type.dart';
import '../../model/file_node.dart';
import '../../repository/file_repository.dart';
import '../../util/common_util.dart';
import '../../util/context_menu_helper.dart';
import '../../util/sound_effect.dart';
import '../../util/system_app_launcher.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../../widget/unified_delete_button.dart';
import '../bloc/file_home_bloc.dart';
import '../widget/display_type_segmented_control.dart';

class FileHomePage extends StatelessWidget {
  final bool isOnlyDownloadDir;

  FileHomePage(this.isOnlyDownloadDir, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileHomeBloc>(
      create: (context) =>
          FileHomeBloc(context.read<FileRepository>(), this.isOnlyDownloadDir)
            ..add(FileHomeSubscriptionRequested()),
      child: FileHomeView(this.isOnlyDownloadDir),
    );
  }
}

class FileHomeView extends StatefulWidget {
  final bool isOnlyDownloadDir;

  FileHomeView(this.isOnlyDownloadDir, {Key? key}) : super(key: key);

  @override
  State<FileHomeView> createState() {
    return FileHomeViewState();
  }
}

class FileHomeViewState extends State<FileHomeView>
    with AutomaticKeepAliveClientMixin {
  bool _isBackBtnDown = false;
  FocusNode? _rootFocusNode;

  bool _isControlPressed = false;
  bool _isShiftPressed = false;

  ProgressIndicatorDialog? _progressIndicatorDialog;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<FileNode> files =
        context.select((FileHomeBloc bloc) => bloc.state.files);
    List<FileNode> checkedFiles =
        context.select((FileHomeBloc bloc) => bloc.state.checkedFiles);
    DisplayType displayType =
        context.select((FileHomeBloc bloc) => bloc.state.displayType);
    FileHomeStatus status =
        context.select((FileHomeBloc bloc) => bloc.state.status);
    List<FileNode> dirStack =
        context.select((FileHomeBloc bloc) => bloc.state.dirStack);
    final homeTab = context.select((HomeBloc bloc) => bloc.state.tab);

    Widget content =
        _createContent(context, displayType, files, checkedFiles, dirStack);

    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    _rootFocusNode = FocusNode();
    _rootFocusNode?.canRequestFocus = true;

    if ((homeTab == HomeTab.allFile && !widget.isOnlyDownloadDir) ||
        (homeTab == HomeTab.download && widget.isOnlyDownloadDir)) {
      _rootFocusNode?.requestFocus();
    }

    return Scaffold(
      body: MultiBlocListener(
          listeners: [
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                if (state.openDirStatus == FileHomeOpenDirStatus.loading) {
                  BotToast.showLoading(clickClose: true);
                }

                if (state.openDirStatus == FileHomeOpenDirStatus.success) {
                  BotToast.closeAllLoading();
                }

                if (state.openDirStatus == FileHomeOpenDirStatus.failure) {
                  BotToast.closeAllLoading();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            state.failureReason ?? "Open directory failure.")));
                }
              },
              listenWhen: (previous, current) =>
                  previous.openDirStatus != current.openDirStatus,
            ),
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                List<FileNode> files = context.read<FileHomeBloc>().state.files;
                List<FileNode> checkedFiles =
                    context.read<FileHomeBloc>().state.checkedFiles;

                _openMenu(
                    pageContext: context,
                    position: state.menuStatus.position!,
                    files: files,
                    checkedFiles: checkedFiles,
                    current: state.menuStatus.current!);
              },
              listenWhen: (previous, current) =>
                  previous.menuStatus != current.menuStatus &&
                  current.menuStatus.isOpened,
            ),
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                if (state.renameStatus == FileHomeRenameStatus.failure) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            state.failureReason ?? "Rename file failure.")));
                }

                if (state.renameStatus == FileHomeRenameStatus.success) {
                  context.read<FileHomeBloc>().add(FileHomeRenameExit());
                }
              },
              listenWhen: (previous, current) =>
                  previous.renameStatus != current.renameStatus,
            ),
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                DisplayType displayType =
                    context.read<FileHomeBloc>().state.displayType;
                bool isRenamingMode =
                    context.read<FileHomeBloc>().state.isRenamingMode;

                if (displayType == DisplayType.icon) {
                  if (isRenamingMode) {
                    FileNode? file =
                        context.read<FileHomeBloc>().state.currentRenamingFile;
                    String? newFileName =
                        context.read<FileHomeBloc>().state.newFileName;

                    if (null != file && null != newFileName) {
                      context
                          .read<FileHomeBloc>()
                          .add(FileHomeRenameSubmitted(file, newFileName));
                    }
                  } else {
                    List<FileNode> checkedFiles = state.checkedFiles;

                    if (checkedFiles.length == 1) {
                      context
                          .read<FileHomeBloc>()
                          .add(FileHomeRenameEnter(checkedFiles.single));
                    }
                  }
                }
              },
              listenWhen: (previous, current) =>
                  previous.enterTapStatus != current.enterTapStatus &&
                  current.enterTapStatus == FileHomeEnterTapStatus.tap,
            ),
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                if (state.copyStatus.status == FileHomeCopyStatus.start) {
                  final checkedFiles =
                      context.read<FileHomeBloc>().state.checkedFiles;
                  _showDownloadProgressDialog(context, checkedFiles);
                }

                if (state.copyStatus.status == FileHomeCopyStatus.copying) {
                  if (_progressIndicatorDialog?.isShowing == true) {
                    int current = state.copyStatus.current;
                    int total = state.copyStatus.total;

                    if (current > 0) {
                      String title = context.l10n.exporting;

                      List<FileNode> checkedFiles = state.checkedFiles;

                      if (checkedFiles.length == 1) {
                        String name = checkedFiles.single.data.name;

                        title = context.l10n.placeholderExporting
                            .replaceFirst("%s", name);
                      }

                      if (checkedFiles.length > 1) {
                        String itemStr = context.l10n.placeHolderItemCount03
                            .replaceFirst("%d", "${checkedFiles.length}");
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

                if (state.copyStatus.status == FileHomeCopyStatus.failure) {
                  _progressIndicatorDialog?.dismiss();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(state.copyStatus.error ??
                            context.l10n.copyFileFailure)));
                }

                if (state.copyStatus.status == FileHomeCopyStatus.success) {
                  _progressIndicatorDialog?.dismiss();
                }
              },
              listenWhen: (previous, current) =>
                  previous.copyStatus != current.copyStatus &&
                  current.copyStatus.status != FileHomeCopyStatus.initial,
            ),
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                if (state.deleteStatus == FileHomeDeleteStatus.loading) {
                  BotToast.showLoading(clickClose: true);
                }

                if (state.deleteStatus == FileHomeDeleteStatus.failure) {
                  BotToast.closeAllLoading();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            state.failureReason ?? "Delete files failure.")));
                }

                if (state.deleteStatus == FileHomeDeleteStatus.success) {
                  BotToast.closeAllLoading();
                }
              },
              listenWhen: (previous, current) =>
                  previous.deleteStatus != current.deleteStatus &&
                  current.deleteStatus == FileHomeDeleteStatus.initial,
            ),
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                if (state.uploadStatus.status == FileHomeUploadStatus.start) {
                  context.read<HomeBloc>().add(
                      HomeProgressIndicatorStatusChanged(
                          HomeLinearProgressIndicatorStatus(visible: true)));
                }

                if (state.uploadStatus.status ==
                    FileHomeUploadStatus.uploading) {
                  context.read<HomeBloc>().add(
                          HomeProgressIndicatorStatusChanged(
                              HomeLinearProgressIndicatorStatus(
                        visible: true,
                        current: state.uploadStatus.current,
                        total: state.uploadStatus.total,
                      )));
                }

                if (state.uploadStatus.status == FileHomeUploadStatus.failure) {
                  context.read<HomeBloc>().add(
                      HomeProgressIndicatorStatusChanged(
                          HomeLinearProgressIndicatorStatus(visible: false)));

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(state.uploadStatus.failureReason ??
                            context.l10n.unknownError)));
                }

                if (state.uploadStatus.status == FileHomeUploadStatus.success) {
                  context.read<HomeBloc>().add(
                      HomeProgressIndicatorStatusChanged(
                          HomeLinearProgressIndicatorStatus(visible: false)));
                  SoundEffect.play(SoundType.done);
                }
              },
              listenWhen: (previous, current) =>
                  previous.uploadStatus != current.uploadStatus &&
                  current.uploadStatus.status != FileHomeUploadStatus.initial,
            )
          ],
          child: Focus(
              focusNode: _rootFocusNode,
              autofocus: true,
              canRequestFocus: true,
              child: Stack(
                children: [
                  content,
                  Visibility(
                    child: Container(child: spinKit, color: Colors.white),
                    maintainSize: false,
                    visible: status == FileHomeStatus.loading,
                  )
                ],
              ),
              onKey: (node, event) {
                _isControlPressed = Platform.isMacOS
                    ? event.isMetaPressed
                    : event.isControlPressed;
                _isShiftPressed = event.isShiftPressed;

                FileHomeKeyStatus status = FileHomeKeyStatus.none;

                if (_isControlPressed) {
                  status = FileHomeKeyStatus.ctrlDown;
                } else if (_isShiftPressed) {
                  status = FileHomeKeyStatus.shiftDown;
                }

                context
                    .read<FileHomeBloc>()
                    .add(FileHomeKeyStatusChanged(status));

                if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                  bool isRenamingMode =
                      context.read<FileHomeBloc>().state.isRenamingMode;

                  if (isRenamingMode) {
                    FileNode? file =
                        context.read<FileHomeBloc>().state.currentRenamingFile;
                    String? newFileName =
                        context.read<FileHomeBloc>().state.newFileName;

                    if (null != file && newFileName != null) {
                      context
                          .read<FileHomeBloc>()
                          .add(FileHomeRenameSubmitted(file, newFileName));
                    }
                  } else {
                    List<FileNode> checkedFiles =
                        context.read<FileHomeBloc>().state.checkedFiles;

                    if (checkedFiles.length == 1) {
                      context
                          .read<FileHomeBloc>()
                          .add(FileHomeRenameEnter(checkedFiles.single));
                    }
                  }

                  return KeyEventResult.handled;
                }

                if (Platform.isMacOS) {
                  if (event.isMetaPressed &&
                      event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                    context.read<FileHomeBloc>().add(FileHomeSelectAll());
                    return KeyEventResult.handled;
                  }
                } else {
                  if (event.isControlPressed &&
                      event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                    context.read<FileHomeBloc>().add(FileHomeSelectAll());
                    return KeyEventResult.handled;
                  }
                }

                return KeyEventResult.ignored;
              })),
    );
  }

  Widget _createContent(
      BuildContext context,
      DisplayType displayType,
      List<FileNode> files,
      List<FileNode> checkedFiles,
      List<FileNode> dirStack) {
    final _divider_line_color = Color(0xffe0e0e0);

    String itemNumStr = context.l10n.placeHolderItemCount01
        .replaceFirst("%d", "${files.length}");
    if (checkedFiles.length > 0) {
      itemNumStr = context.l10n.placeHolderItemCount02
          .replaceFirst("%d", "${checkedFiles.length}")
          .replaceFirst("%d", "${files.length}");
    }

    bool isDeleteEnabled = checkedFiles.length > 0;

    return Column(children: [
      Container(
          child: Stack(children: [
            StatefulBuilder(
                builder: (context, setState) => GestureDetector(
                    child: Visibility(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          child: Row(
                            children: [
                              Image.asset("assets/icons/icon_right_arrow.png",
                                  width: 12, height: 12),
                              Container(
                                child: Text(context.l10n.back,
                                    style: TextStyle(
                                        color: Color(0xff5c5c62),
                                        fontSize: 13)),
                                margin: EdgeInsets.only(left: 3),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              color: _isBackBtnDown
                                  ? Color(0xffe8e8e8)
                                  : Color(0xfff3f3f4),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(3.0)),
                              border: Border.all(
                                  color: Color(0xffdedede), width: 1.0)),
                          height: 25,
                          width: 50,
                          margin: EdgeInsets.only(left: 15),
                        ),
                      ),
                      visible: dirStack.isNotEmpty,
                    ),
                    onTap: () {
                      context.read<FileHomeBloc>().add(FileHomeBackToLastDir());
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
                    })),
            Align(
                alignment: Alignment.center,
                child: Text(
                    widget.isOnlyDownloadDir
                        ? context.l10n.downloads
                        : context.l10n.files,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Color(0xff616161), fontSize: 16.0))),
            Align(
                child: Container(
                    child: Row(
                        children: [
                          DisplayTypeSegmentedControl(
                            displayType: displayType,
                            onChange: ((displayType) {
                              context
                                  .read<FileHomeBloc>()
                                  .add(FileHomeDisplayTypeChanged(displayType));
                            }),
                          ),
                          UnifiedDeleteButton(
                            isEnable: isDeleteEnabled,
                            contentDescription: context.l10n.delete,
                            onTap: () {
                              if (isDeleteEnabled) {
                                _tryToDeleteFiles(context, checkedFiles);
                              }
                            },
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center),
                    width: 133),
                alignment: Alignment.centerRight)
          ]),
          color: Color(0xfff4f4f4),
          height: Constant.HOME_NAVI_BAR_HEIGHT),
      Divider(
        color: _divider_line_color,
        height: 1.0,
        thickness: 1.0,
      ),
      Expanded(
          child: IndexedStack(
        index: displayType.index,
        children: [GridModeFilesPage(), ListModeFilesPage()],
      )),
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
      Container(
          child: Align(
              alignment: Alignment.center,
              child: Text(itemNumStr,
                  style: TextStyle(color: Color(0xff646464), fontSize: 12))),
          height: 20,
          color: Color(0xfffafafa)),
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
    ], mainAxisSize: MainAxisSize.max);
  }

  void _openMenu(
      {required BuildContext pageContext,
      required Offset position,
      required List<FileNode> files,
      required List<FileNode> checkedFiles,
      required FileNode current}) {
    String copyTitle = "";

    if (checkedFiles.length == 1) {
      FileNode file = checkedFiles.single;

      String name = file.data.name;

      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = pageContext.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedFiles.length}");
      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    ContextMenuHelper()
        .showContextMenu(context: pageContext, globalOffset: position, items: [
      ContextMenuItem(
        title: pageContext.l10n.open,
        onTap: () {
          ContextMenuHelper().hideContextMenu();
          if (current.data.isDir) {
            pageContext.read<FileHomeBloc>().add(FileHomeOpenDir(current));
          } else {
            SystemAppLauncher.openFile(current.data);
          }
        },
      ),
      ContextMenuItem(
        title: pageContext.l10n.rename,
        onTap: () {
          ContextMenuHelper().hideContextMenu();
          pageContext.read<FileHomeBloc>().add(FileHomeRenameEnter(current));
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          CommonUtil.openFilePicker(pageContext.l10n.chooseDir, (dir) {
            _startCopyFiles(pageContext, checkedFiles, dir);
          }, (error) {
            debugPrint("_openFilePicker, error: $error");
          });
        },
      ),
      ContextMenuItem(
        title: pageContext.l10n.delete,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          _tryToDeleteFiles(pageContext, checkedFiles);
        },
      )
    ]);
  }

  void _startCopyFiles(BuildContext context, List<FileNode> files, String dir) {
    context.read<FileHomeBloc>().add(FileHomeCopySubmitted(files, dir));
  }

  void _showDownloadProgressDialog(BuildContext context, List<FileNode> files) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _progressIndicatorDialog?.dismiss();
        context.read<FileHomeBloc>().add(FileHomeCancelCopySubmitted());
      });
    }

    String title = context.l10n.preparing;

    if (files.length > 1) {
      title = context.l10n.compressing;
    }

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  void _tryToDeleteFiles(
      BuildContext pageContext, List<FileNode> checkedFiles) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedFiles.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<FileHomeBloc>()
          .add(FileHomeDeleteSubmitted(checkedFiles));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  bool get wantKeepAlive => true;
}
