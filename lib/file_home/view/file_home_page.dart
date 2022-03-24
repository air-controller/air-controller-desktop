import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mobile_assistant_client/ext/string-ext.dart';
import 'package:mobile_assistant_client/file_home/bloc/file_home_bloc.dart';
import 'package:mobile_assistant_client/grid_mode_files/view/grid_mode_files_page.dart';
import 'package:mobile_assistant_client/l10n/l10n.dart';
import 'package:mobile_assistant_client/list_mode_files/list_mode_files.dart';
import 'package:mobile_assistant_client/repository/file_repository.dart';

import '../../constant.dart';
import '../../model/FileNode.dart';
import '../../util/common_util.dart';
import '../../util/system_app_launcher.dart';
import '../../widget/overlay_menu_item.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../../widget/unified_delete_button.dart';

class FileHomePage extends StatelessWidget {
  final bool isOnlyDownloadDir;

  FileHomePage(this.isOnlyDownloadDir, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FileHomeBloc>(
      create: (context) => FileHomeBloc(
          context.read<FileRepository>(),
        this.isOnlyDownloadDir
      )..add(FileHomeSubscriptionRequested()),
      child: FileHomeView(this.isOnlyDownloadDir),
    );
  }
}

class FileHomeView extends StatelessWidget {
  final bool isOnlyDownloadDir;

  bool _isBackBtnDown = false;
  FocusNode? _rootFocusNode;

  bool _isControlPressed = false;
  bool _isShiftPressed = false;

  ProgressIndicatorDialog? _progressIndicatorDialog;

  FileHomeView(this.isOnlyDownloadDir, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<FileNode> files =
        context.select((FileHomeBloc bloc) => bloc.state.files);
    List<FileNode> checkedFiles =
        context.select((FileHomeBloc bloc) => bloc.state.checkedFiles);
    FileHomeTab currentTab =
        context.select((FileHomeBloc bloc) => bloc.state.tab);
    FileHomeStatus status =
        context.select((FileHomeBloc bloc) => bloc.state.status);
    List<FileNode> dirStack =
        context.select((FileHomeBloc bloc) => bloc.state.dirStack);

    Widget content = _createContent(
        context, currentTab, files, checkedFiles, dirStack);

    const color = Color(0xff85a8d0);
    const spinKit = SpinKitCircle(color: color, size: 60.0);

    _rootFocusNode = FocusNode();
    _rootFocusNode?.canRequestFocus = true;
    _rootFocusNode?.requestFocus();

    return Scaffold(
      body: MultiBlocListener(
          listeners: [
            BlocListener<FileHomeBloc, FileHomeState>(
              listener: (context, state) {
                if (state.openDirStatus == FileHomeOpenDirStatus.loading) {
                  SmartDialog.showLoading();
                }

                if (state.openDirStatus == FileHomeOpenDirStatus.success) {
                  SmartDialog.dismiss();
                }

                if (state.openDirStatus == FileHomeOpenDirStatus.failure) {
                  SmartDialog.dismiss();

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
                FileHomeTab tab = context.read<FileHomeBloc>().state.tab;
                bool isRenamingMode =
                    context.read<FileHomeBloc>().state.isRenamingMode;

                if (tab == FileHomeTab.gridMode) {
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

                        title = context.l10n.placeholderExporting.replaceFirst(
                            "%s", name);
                      }

                      if (checkedFiles.length > 1) {
                        String itemStr = context.l10n.placeHolderItemCount03.replaceFirst("%d",
                            "${checkedFiles.length}");
                        title = context.l10n.placeholderExporting.replaceFirst("%s", itemStr);
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
                        content:
                            Text(state.copyStatus.error ?? context.l10n.copyFileFailure)));
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
                  SmartDialog.showLoading();
                }

                if (state.deleteStatus == FileHomeDeleteStatus.failure) {
                  SmartDialog.dismiss();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            state.failureReason ?? "Delete files failure.")));
                }

                if (state.deleteStatus == FileHomeDeleteStatus.success) {
                  SmartDialog.dismiss();
                }
              },
              listenWhen: (previous, current) =>
                  previous.deleteStatus != current.deleteStatus &&
                  current.deleteStatus == FileHomeDeleteStatus.initial,
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
                  bool isRenamingMode = context.read<FileHomeBloc>().state.isRenamingMode;

                  if (isRenamingMode) {
                    FileNode? file =
                        context
                            .read<FileHomeBloc>()
                            .state
                            .currentRenamingFile;
                    String? newFileName =
                        context
                            .read<FileHomeBloc>()
                            .state
                            .newFileName;

                    if (null != file && newFileName != null) {
                      context.read<FileHomeBloc>().add(
                          FileHomeRenameSubmitted(file, newFileName));
                    }
                  } else {
                    List<FileNode> checkedFiles = context.read<FileHomeBloc>().state.checkedFiles;

                    if (checkedFiles.length == 1) {
                      context.read<FileHomeBloc>().add(FileHomeRenameEnter(checkedFiles.single));
                    }
                  }

                  return KeyEventResult.handled;
                }

                if (Platform.isMacOS) {
                  if (event.isMetaPressed &&
                      event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                    // _onControlAndAPressed();
                    return KeyEventResult.handled;
                  }
                } else {
                  if (event.isControlPressed &&
                      event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                    // _onControlAndAPressed();
                    return KeyEventResult.handled;
                  }
                }

                return KeyEventResult.ignored;
              })),
    );
  }

  Widget _createContent(BuildContext context, FileHomeTab currentTab,
      List<FileNode> files, List<FileNode> checkedFiles, List<FileNode> dirStack) {
    final _icon_display_mode_size = 10.0;
    final _segment_control_radius = 4.0;
    final _segment_control_height = 26.0;
    final _segment_control_width = 32.0;
    final _segment_control_padding_hor = 8.0;
    final _segment_control_padding_vertical = 6.0;
    final _divider_line_color = Color(0xffe0e0e0);

    String itemNumStr = context.l10n.placeHolderItemCount01.replaceFirst("%d", "${files.length}");
    if (checkedFiles.length > 0) {
      itemNumStr = context.l10n.placeHolderItemCount02.replaceFirst("%d", "${checkedFiles.length}")
          .replaceFirst("%d", "${files.length}");
    }

    String getIconModeIcon() {
      if (currentTab == FileHomeTab.gridMode) {
        return "assets/icons/icon_image_text_selected.png";
      }

      return "assets/icons/icon_image_text_normal.png";
    }

    String getListModeIcon() {
      if (currentTab == FileHomeTab.listMode) {
        return "assets/icons/icon_list_selected.png";
      }

      return "assets/icons/icon_list_normal.png";
    }

    Color getModeBtnBgColor(FileHomeTab tab) {
      if (tab == FileHomeTab.gridMode) {
        if (currentTab == FileHomeTab.gridMode) {
          return Color(0xffc1c1c1);
        }

        return Color(0xfff5f6f5);
      }

      if (currentTab == FileHomeTab.listMode) {
        return Color(0xffc1c1c1);
      }

      return Color(0xfff5f6f5);
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
                child: Text(this.isOnlyDownloadDir ? context.l10n.downloads : context.l10n.files,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Color(0xff616161), fontSize: 16.0))),
            Align(
                child: Container(
                    child: Row(
                        children: [
                          GestureDetector(
                            child: Container(
                                child: Image.asset(getIconModeIcon(),
                                    width: _icon_display_mode_size,
                                    height: _icon_display_mode_size),
                                decoration: BoxDecoration(
                                    color:
                                        getModeBtnBgColor(FileHomeTab.gridMode),
                                    border: new Border.all(
                                        color: Color(0xffababab), width: 1.0),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                            _segment_control_radius),
                                        bottomLeft: Radius.circular(
                                            _segment_control_radius))),
                                height: _segment_control_height,
                                width: _segment_control_width,
                                padding: EdgeInsets.fromLTRB(
                                    _segment_control_padding_hor,
                                    _segment_control_padding_vertical,
                                    _segment_control_padding_hor,
                                    _segment_control_padding_vertical)),
                            onTap: () {
                              context.read<FileHomeBloc>().add(
                                  FileHomeTabChanged(FileHomeTab.gridMode));
                            },
                          ),
                          GestureDetector(
                            child: Container(
                                child: Image.asset(getListModeIcon(),
                                    width: _icon_display_mode_size,
                                    height: _icon_display_mode_size),
                                decoration: BoxDecoration(
                                    color:
                                        getModeBtnBgColor(FileHomeTab.listMode),
                                    border: new Border.all(
                                        color: Color(0xffdededd), width: 1.0),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(
                                            _segment_control_radius),
                                        bottomRight: Radius.circular(
                                            _segment_control_radius))),
                                height: _segment_control_height,
                                width: _segment_control_width,
                                padding: EdgeInsets.fromLTRB(
                                    _segment_control_padding_hor,
                                    _segment_control_padding_vertical,
                                    _segment_control_padding_hor,
                                    _segment_control_padding_vertical)),
                            onTap: () {
                              context.read<FileHomeBloc>().add(
                                  FileHomeTabChanged(FileHomeTab.listMode));
                            },
                          ),
                          UnifiedDeleteButton(
                            isEnable: isDeleteEnabled,
                            onTap: () {
                              if (isDeleteEnabled) {
                                _tryToDeleteFiles(context, checkedFiles);
                              }
                            },
                            margin: EdgeInsets.fromLTRB(20, 0, 10, 0),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center),
                    width: 135),
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
        index: currentTab.index,
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

      copyTitle = pageContext.l10n.placeHolderCopyToComputer.replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = pageContext.l10n.placeHolderItemCount03.replaceFirst("%d", "${checkedFiles.length}");
      copyTitle = pageContext.l10n.placeHolderCopyToComputer.replaceFirst("%s", itemStr)
          .adaptForOverflow();
    }

    double width = 320;
    double itemHeight = 25;
    EdgeInsets itemPadding = EdgeInsets.only(left: 8, right: 8);
    EdgeInsets itemMargin = EdgeInsets.only(top: 6, bottom: 6);
    BorderRadius itemBorderRadius = BorderRadius.all(Radius.circular(3));
    Color defaultItemBgColor = Color(0xffd8d5d3);
    Divider divider = Divider(
        height: 1,
        thickness: 1,
        indent: 6,
        endIndent: 6,
        color: Color(0xffbabebf));

    showDialog(
        context: pageContext,
        barrierColor: Colors.transparent,
        builder: (dialogContext) {
          return Stack(
            children: [
              Positioned(
                  child: Container(
                    child: Column(
                      children: [
                        OverlayMenuItem(
                          width: width,
                          height: itemHeight,
                          padding: itemPadding,
                          margin: itemMargin,
                          borderRadius: itemBorderRadius,
                          defaultBackgroundColor: defaultItemBgColor,
                          title: pageContext.l10n.open,
                          onTap: () {
                            Navigator.of(pageContext).pop();

                            if (current.data.isDir) {
                              pageContext
                                  .read<FileHomeBloc>()
                                  .add(FileHomeOpenDir(current));
                            } else {
                              SystemAppLauncher.openFile(current.data);
                            }
                          },
                        ),
                        divider,
                        OverlayMenuItem(
                          width: width,
                          height: itemHeight,
                          padding: itemPadding,
                          margin: itemMargin,
                          borderRadius: itemBorderRadius,
                          defaultBackgroundColor: defaultItemBgColor,
                          title: pageContext.l10n.rename,
                          onTap: () {
                            Navigator.of(pageContext).pop();

                            pageContext
                                .read<FileHomeBloc>()
                                .add(FileHomeRenameEnter(current));
                          },
                        ),
                        divider,
                        OverlayMenuItem(
                          width: width,
                          height: itemHeight,
                          padding: itemPadding,
                          margin: itemMargin,
                          borderRadius: itemBorderRadius,
                          defaultBackgroundColor: defaultItemBgColor,
                          title: copyTitle,
                          onTap: () {
                            Navigator.of(pageContext).pop();

                            CommonUtil.openFilePicker(pageContext.l10n.chooseDir, (dir) {
                              _startCopyFiles(pageContext, checkedFiles, dir);
                            }, (error) {
                              debugPrint("_openFilePicker, error: $error");
                            });
                          },
                        ),
                        divider,
                        OverlayMenuItem(
                          width: width,
                          height: itemHeight,
                          padding: itemPadding,
                          margin: itemMargin,
                          borderRadius: itemBorderRadius,
                          defaultBackgroundColor: defaultItemBgColor,
                          title: pageContext.l10n.delete,
                          onTap: () {
                            Navigator.of(pageContext).pop();

                            _tryToDeleteFiles(pageContext, checkedFiles);
                          },
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Color(0xffd8d5d3),
                        borderRadius: BorderRadius.all(Radius.circular(6))),
                    padding: EdgeInsets.all(5),
                  ),
                  left: position.dx,
                  top: position.dy,
                  width: width)
            ],
          );
        });
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

  void _tryToDeleteFiles(BuildContext pageContext, List<FileNode> checkedFiles) {
    CommonUtil.showConfirmDialog(
      pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedFiles.length}")}",
        pageContext.l10n.tipDeleteDesc, pageContext.l10n.cancel, pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext.read<FileHomeBloc>().add(FileHomeDeleteSubmitted(checkedFiles));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }
}
