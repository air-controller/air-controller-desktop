import 'dart:io';

import 'package:air_controller/ext/filex.dart';
import 'package:air_controller/ext/pointer_down_event_x.dart';
import 'package:air_controller/ext/string-ext.dart';
import 'package:air_controller/l10n/l10n.dart';
import 'package:air_controller/util/context_menu_helper.dart';
import 'package:air_controller/util/sound_effect.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../constant.dart';
import '../../home/bloc/home_bloc.dart';
import '../../model/audio_item.dart';
import '../../repository/audio_repository.dart';
import '../../repository/file_repository.dart';
import '../../util/common_util.dart';
import '../../util/system_app_launcher.dart';
import '../../widget/progress_indictor_dialog.dart';
import '../bloc/music_home_bloc.dart';

class MusicHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<MusicHomeBloc>(
      create: (context) => MusicHomeBloc(
          audioRepository: context.read<AudioRepository>(),
          fileRepository: context.read<FileRepository>())
        ..add(MusicHomeSubscriptionRequested()),
      child: MusicHomeView(),
    );
  }
}

class MusicHomeView extends StatelessWidget {
  FocusNode? _rootFocusNode;
  bool _isControlPressed = false;
  bool _isShiftPressed = false;
  final _divider_line_color = Color(0xffe0e0e0);
  final _icon_delete_btn_size = 10.0;
  final _delete_btn_padding_hor = 8.0;
  final _delete_btn_padding_vertical = 4.5;
  final _delete_btn_width = 40.0;
  final _delete_btn_height = 25.0;
  bool _isDeleteBtnTapDown = false;

  ProgressIndicatorDialog? _progressIndicatorDialog;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);

    const spinKit = SpinKitCircle(color: color, size: 60.0);

    _rootFocusNode = FocusNode();
    _rootFocusNode?.canRequestFocus = true;
    _rootFocusNode?.requestFocus();

    MusicHomeStatus status =
        context.select((MusicHomeBloc bloc) => bloc.state.status);
    List<AudioItem> musics =
        context.select((MusicHomeBloc bloc) => bloc.state.musics);
    List<AudioItem> checkedMusics =
        context.select((MusicHomeBloc bloc) => bloc.state.checkedMusics);
    MusicHomeSortColumn sortColumn =
        context.select((MusicHomeBloc bloc) => bloc.state.sortColumn);
    MusicHomeSortDirection sortDirection =
        context.select((MusicHomeBloc bloc) => bloc.state.sortDirection);

    bool isDeleteEnabled = checkedMusics.length > 0;

    String itemNumStr = context.l10n.placeHolderItemCount01
        .replaceFirst("%d", "${musics.length}");
    if (checkedMusics.length > 0) {
      itemNumStr = context.l10n.placeHolderItemCount02
          .replaceFirst("%d", "${checkedMusics.length}")
          .replaceFirst("%d", "${musics.length}");
    }

    TextStyle headerStyle = TextStyle(fontSize: 14, color: Colors.black);

    return Scaffold(
      body: MultiBlocListener(
          listeners: [
            BlocListener<MusicHomeBloc, MusicHomeState>(
              listener: (context, state) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                      content:
                          Text(state.failureReason ?? "Load musics failure.")));
              },
              listenWhen: (previous, current) =>
                  previous.status != current.status &&
                  current.status == MusicHomeStatus.failure,
            ),
            BlocListener<MusicHomeBloc, MusicHomeState>(
              listener: (context, state) {
                _openMenu(
                    pageContext: context,
                    position: state.openMenuStatus.position!,
                    current: state.openMenuStatus.target);
              },
              listenWhen: (previous, current) =>
                  previous.openMenuStatus != current.openMenuStatus &&
                  current.openMenuStatus.isOpened,
            ),
            BlocListener<MusicHomeBloc, MusicHomeState>(
              listener: (context, state) {
                if (state.deleteStatus.status ==
                    MusicHomeDeleteStatus.loading) {
                  SmartDialog.showLoading();
                }

                if (state.deleteStatus.status ==
                    MusicHomeDeleteStatus.failure) {
                  SmartDialog.dismiss();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            state.failureReason ?? "Delete musics failure.")));
                }

                if (state.deleteStatus.status ==
                    MusicHomeDeleteStatus.success) {
                  SmartDialog.dismiss();
                }
              },
              listenWhen: (previous, current) =>
                  previous.deleteStatus != current.deleteStatus,
            ),
            BlocListener<MusicHomeBloc, MusicHomeState>(
              listener: (context, state) {
                if (state.copyStatus.status == MusicHomeCopyStatus.start) {
                  _showDownloadProgressDialog(context, state.checkedMusics);
                }

                if (state.copyStatus.status == MusicHomeCopyStatus.copying) {
                  if (_progressIndicatorDialog?.isShowing == true) {
                    int current = state.copyStatus.current;
                    int total = state.copyStatus.total;

                    if (current > 0) {
                      String title = context.l10n.exporting;

                      if (state.checkedMusics.length == 1) {
                        String name = state.checkedMusics.single.name;

                        title = context.l10n.placeholderExporting
                            .replaceFirst("%s", name);
                      }

                      if (state.checkedMusics.length > 1) {
                        String itemStr = context.l10n.placeHolderItemCount03
                            .replaceFirst(
                                "%d", "${state.checkedMusics.length}");
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

                if (state.copyStatus.status == MusicHomeCopyStatus.failure) {
                  _progressIndicatorDialog?.dismiss();

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(
                            state.copyStatus.error ?? "Copy musics failure.")));
                }

                if (state.copyStatus.status == MusicHomeCopyStatus.success) {
                  _progressIndicatorDialog?.dismiss();
                }
              },
              listenWhen: (previous, current) =>
                  previous.copyStatus != current.copyStatus &&
                  current.copyStatus.status != MusicHomeCopyStatus.initial,
            ),
            BlocListener<MusicHomeBloc, MusicHomeState>(
              listener: (context, state) {
                if (state.uploadStatus.status == MusicHomeUploadStatus.start) {
                  context.read<HomeBloc>().add(
                      HomeProgressIndicatorStatusChanged(
                          HomeLinearProgressIndicatorStatus(visible: true)));
                }

                if (state.uploadStatus.status ==
                    MusicHomeUploadStatus.uploading) {
                  context.read<HomeBloc>().add(
                          HomeProgressIndicatorStatusChanged(
                              HomeLinearProgressIndicatorStatus(
                        visible: true,
                        current: state.uploadStatus.current,
                        total: state.uploadStatus.total,
                      )));
                }

                if (state.uploadStatus.status ==
                    MusicHomeUploadStatus.failure) {
                  context.read<HomeBloc>().add(
                      HomeProgressIndicatorStatusChanged(
                          HomeLinearProgressIndicatorStatus(visible: false)));

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                        content: Text(state.uploadStatus.failureReason ??
                            context.l10n.unknownError)));
                }

                if (state.uploadStatus.status ==
                    MusicHomeUploadStatus.success) {
                  context.read<HomeBloc>().add(
                      HomeProgressIndicatorStatusChanged(
                          HomeLinearProgressIndicatorStatus(visible: false)));
                  SoundEffect.play(SoundType.done);
                }
              },
              listenWhen: (previous, current) =>
                  previous.uploadStatus != current.uploadStatus &&
                  current.uploadStatus.status != MusicHomeStatus.initial,
            )
          ],
          child: Stack(children: [
            DropTarget(
              child: Focus(
                autofocus: true,
                focusNode: _rootFocusNode,
                child: GestureDetector(
                  child: Column(children: [
                    Container(
                        child: Stack(children: [
                          Align(
                              alignment: Alignment.center,
                              child: Text(context.l10n.musics,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Color(0xff616161),
                                      fontSize: 16.0))),
                          Align(
                              child:
                                  StatefulBuilder(builder: (context, setState) {
                                double opacity =
                                    _isDeleteBtnTapDown ? 0.6 : 1.0;

                                if (!isDeleteEnabled) {
                                  opacity = 0.6;
                                }

                                return GestureDetector(
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Container(
                                        child: Image.asset(
                                            "assets/icons/icon_delete.png",
                                            width: _icon_delete_btn_size,
                                            height: _icon_delete_btn_size),
                                        decoration: BoxDecoration(
                                            color: Color(0xffcb6357),
                                            border: new Border.all(
                                                color: Color(0xffb43f32),
                                                width: 1.0),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0))),
                                        width: _delete_btn_width,
                                        height: _delete_btn_height,
                                        padding: EdgeInsets.fromLTRB(
                                            _delete_btn_padding_hor,
                                            _delete_btn_padding_vertical,
                                            _delete_btn_padding_hor,
                                            _delete_btn_padding_vertical),
                                        margin:
                                            EdgeInsets.fromLTRB(0, 0, 15, 0)),
                                  ),
                                  onTap: () {
                                    if (isDeleteEnabled) {
                                      _tryToDeleteMusics(
                                          context,
                                          context
                                              .read<MusicHomeBloc>()
                                              .state
                                              .checkedMusics);
                                    }
                                  },
                                  onTapDown: (details) {
                                    if (isDeleteEnabled) {
                                      setState(() {
                                        _isDeleteBtnTapDown = true;
                                      });
                                    }
                                  },
                                  onTapCancel: () {
                                    if (isDeleteEnabled) {
                                      setState(() {
                                        _isDeleteBtnTapDown = false;
                                      });
                                    }
                                  },
                                  onTapUp: (details) {
                                    if (isDeleteEnabled) {
                                      setState(() {
                                        _isDeleteBtnTapDown = false;
                                      });
                                    }
                                  },
                                );
                              }),
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
                        child: Container(
                      color: Colors.white,
                      child: DataTable2(
                        dividerThickness: 1,
                        bottomMargin: 10,
                        columnSpacing: 0,
                        sortColumnIndex: sortColumn.index,
                        sortAscending:
                            sortDirection == MusicHomeSortDirection.ascending,
                        showCheckboxColumn: false,
                        showBottomBorder: false,
                        columns: [
                          DataColumn2(
                              label: Container(
                                child: Text(
                                  context.l10n.folder,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      inherit: true, fontFamily: 'NotoSansSC'),
                                ),
                              ),
                              onSort: (sortColumnIndex, isSortAscending) {
                                MusicHomeSortColumn sortColumn =
                                    MusicHomeSortColumnX.convertToColumn(
                                        sortColumnIndex);
                                MusicHomeSortDirection sortDirection =
                                    isSortAscending
                                        ? MusicHomeSortDirection.ascending
                                        : MusicHomeSortDirection.descending;

                                _performSort(
                                    context, sortColumn, sortDirection);
                              },
                              size: ColumnSize.L),
                          DataColumn2(
                              label: Container(
                                  child: Text(
                                    context.l10n.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        inherit: true,
                                        fontFamily: 'NotoSansSC'),
                                  ),
                                  padding: EdgeInsets.only(left: 15)),
                              onSort: (sortColumnIndex, isSortAscending) {
                                MusicHomeSortColumn sortColumn =
                                    MusicHomeSortColumnX.convertToColumn(
                                        sortColumnIndex);
                                MusicHomeSortDirection sortDirection =
                                    isSortAscending
                                        ? MusicHomeSortDirection.ascending
                                        : MusicHomeSortDirection.descending;

                                _performSort(
                                    context, sortColumn, sortDirection);
                              }),
                          DataColumn2(
                              label: Container(
                            child: Text(
                              context.l10n.type,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  inherit: true, fontFamily: 'NotoSansSC'),
                            ),
                            padding: EdgeInsets.only(left: 15),
                          )),
                          DataColumn2(
                              label: Container(
                                child: Text(
                                  context.l10n.duration,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      inherit: true, fontFamily: 'NotoSansSC'),
                                ),
                                padding: EdgeInsets.only(left: 15),
                              ),
                              onSort: (sortColumnIndex, isSortAscending) {
                                MusicHomeSortColumn sortColumn =
                                    MusicHomeSortColumnX.convertToColumn(
                                        sortColumnIndex);
                                MusicHomeSortDirection sortDirection =
                                    isSortAscending
                                        ? MusicHomeSortDirection.ascending
                                        : MusicHomeSortDirection.descending;

                                _performSort(
                                    context, sortColumn, sortDirection);
                              }),
                          DataColumn2(
                              label: Container(
                                child: Text(
                                  context.l10n.size,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      inherit: true, fontFamily: 'NotoSansSC'),
                                ),
                                padding: EdgeInsets.only(left: 15),
                              ),
                              onSort: (sortColumnIndex, isSortAscending) {
                                MusicHomeSortColumn sortColumn =
                                    MusicHomeSortColumnX.convertToColumn(
                                        sortColumnIndex);
                                MusicHomeSortDirection sortDirection =
                                    isSortAscending
                                        ? MusicHomeSortDirection.ascending
                                        : MusicHomeSortDirection.descending;

                                _performSort(
                                    context, sortColumn, sortDirection);
                              }),
                          DataColumn2(
                              label: Container(
                                child: Text(
                                  context.l10n.dateModified,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      inherit: true, fontFamily: 'NotoSansSC'),
                                ),
                                padding: EdgeInsets.only(left: 15),
                              ),
                              onSort: (sortColumnIndex, isSortAscending) {
                                MusicHomeSortColumn sortColumn =
                                    MusicHomeSortColumnX.convertToColumn(
                                        sortColumnIndex);
                                MusicHomeSortDirection sortDirection =
                                    isSortAscending
                                        ? MusicHomeSortDirection.ascending
                                        : MusicHomeSortDirection.descending;

                                _performSort(
                                    context, sortColumn, sortDirection);
                              })
                        ],
                        rows: List<DataRow>.generate(musics.length, (index) {
                          AudioItem audioItem = musics[index];

                          bool isChecked = checkedMusics.contains(audioItem);
                          Color textColor =
                              isChecked ? Colors.white : Color(0xff313237);
                          TextStyle textStyle =
                              TextStyle(fontSize: 14, color: textColor);

                          String folderName = audioItem.folder;
                          int pointIndex0 = folderName.lastIndexOf("/");
                          if (pointIndex0 != -1) {
                            folderName = folderName.substring(pointIndex0 + 1);
                          }

                          String type = "";
                          String name = audioItem.name;
                          int pointIndex = name.lastIndexOf(".");
                          if (pointIndex != -1) {
                            type = name.substring(pointIndex + 1);
                          }

                          final inputController = TextEditingController();

                          inputController.text = audioItem.name;

                          final focusNode = FocusNode();

                          focusNode.addListener(() {
                            if (focusNode.hasFocus) {
                              inputController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: inputController.text.length);
                            }
                          });

                          return DataRow2(
                              cells: [
                                DataCell(Listener(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                    child: Text(folderName,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: textStyle),
                                    color: Colors.transparent,
                                  ),
                                  onPointerDown: (event) {
                                    if (event.isRightMouseClick()) {
                                      _onMusicRightMouseClick(
                                          context,
                                          event.position,
                                          checkedMusics,
                                          audioItem);
                                    }
                                  },
                                )),
                                DataCell(Listener(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                    child: Stack(
                                      children: [
                                        Visibility(
                                          child: Text(audioItem.name,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                              style: textStyle),
                                          visible: true,
                                        ),
                                        Visibility(
                                          child: Container(
                                            child: IntrinsicWidth(
                                              child: TextField(
                                                controller: inputController,
                                                focusNode:
                                                    false ? focusNode : null,
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xffcccbcd),
                                                            width: 3,
                                                            style: BorderStyle
                                                                .solid)),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xffcccbcd),
                                                            width: 3,
                                                            style: BorderStyle
                                                                .solid),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                4)),
                                                    focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Color(
                                                                0xffcccbcd),
                                                            width: 4,
                                                            style:
                                                                BorderStyle.solid),
                                                        borderRadius: BorderRadius.circular(4)),
                                                    contentPadding: EdgeInsets.fromLTRB(8, 3, 8, 3)),
                                                cursorColor: Color(0xff333333),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xff333333)),
                                                onChanged: (value) {
                                                  debugPrint(
                                                      "onChange, $value");
                                                  // _newFileName = value;
                                                },
                                              ),
                                            ),
                                            height: 30,
                                            color: Colors.white,
                                          ),
                                          visible: false,
                                          maintainState: false,
                                          maintainSize: false,
                                        )
                                      ],
                                    ),
                                    color: Colors.transparent,
                                  ),
                                  onPointerDown: (event) {
                                    if (event.isRightMouseClick()) {
                                      _onMusicRightMouseClick(
                                          context,
                                          event.position,
                                          checkedMusics,
                                          audioItem);
                                    }
                                  },
                                )),
                                DataCell(Listener(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                    child: Text(type,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: textStyle),
                                    color: Colors.transparent,
                                  ),
                                  onPointerDown: (event) {
                                    if (event.isRightMouseClick()) {
                                      _onMusicRightMouseClick(
                                          context,
                                          event.position,
                                          checkedMusics,
                                          audioItem);
                                    }
                                  },
                                )),
                                DataCell(Listener(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                    child: Text(
                                        CommonUtil.convertToReadableDuration(
                                            context, audioItem.duration),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: textStyle),
                                    color: Colors.transparent,
                                  ),
                                  onPointerDown: (event) {
                                    if (event.isRightMouseClick()) {
                                      _onMusicRightMouseClick(
                                          context,
                                          event.position,
                                          checkedMusics,
                                          audioItem);
                                    }
                                  },
                                )),
                                DataCell(Listener(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                    child: Text(
                                        CommonUtil.convertToReadableSize(
                                            audioItem.size),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: textStyle),
                                    color: Colors.transparent,
                                  ),
                                  onPointerDown: (event) {
                                    if (event.isRightMouseClick()) {
                                      _onMusicRightMouseClick(
                                          context,
                                          event.position,
                                          checkedMusics,
                                          audioItem);
                                    }
                                  },
                                )),
                                DataCell(Listener(
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                                    child: Text(
                                        CommonUtil.formatTime(
                                            audioItem.modifyDate * 1000,
                                            context.l10n.yMdHmPattern),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                        style: textStyle),
                                    color: Colors.transparent,
                                  ),
                                  onPointerDown: (event) {
                                    if (event.isRightMouseClick()) {
                                      _onMusicRightMouseClick(
                                          context,
                                          event.position,
                                          checkedMusics,
                                          audioItem);
                                    }
                                  },
                                )),
                              ],
                              selected: isChecked,
                              onSelectChanged: (isSelected) {
                                debugPrint("onSelectChanged: $isSelected");
                              },
                              onTap: () {
                                context
                                    .read<MusicHomeBloc>()
                                    .add(MusicHomeCheckedChanged(audioItem));
                              },
                              onDoubleTap: () {
                                context
                                    .read<MusicHomeBloc>()
                                    .add(MusicHomeCheckedChanged(audioItem));

                                SystemAppLauncher.openAudio(audioItem);
                              },
                              color: MaterialStateColor.resolveWith((states) {
                                if (states.contains(MaterialState.hovered)) {
                                  return Colors.red;
                                }

                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blue;
                                }

                                if (states.contains(MaterialState.selected)) {
                                  return Color(0xff5e86ec);
                                }

                                return Colors.white;
                              }));
                        }),
                        headingRowHeight: 40,
                        headingTextStyle: headerStyle,
                        onSelectAll: (val) {},
                        empty: Center(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            color: Colors.green[200],
                            child: Text("No download files"),
                          ),
                        ),
                      ),
                      padding: EdgeInsets.only(bottom: 10),
                    )),

                    /// 底部固定区域
                    Divider(
                        color: _divider_line_color,
                        height: 1.0,
                        thickness: 1.0),
                    Container(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(itemNumStr,
                                style: TextStyle(
                                    color: Color(0xff646464), fontSize: 12))),
                        height: 20,
                        color: Color(0xfffafafa)),
                    Divider(
                        color: _divider_line_color,
                        height: 1.0,
                        thickness: 1.0),
                  ], mainAxisSize: MainAxisSize.max),
                  onTap: () {
                    context.read<MusicHomeBloc>().add(MusicHomeClearChecked());
                  },
                ),
                onFocusChange: (value) {},
                onKey: (node, event) {
                  _isControlPressed = Platform.isMacOS
                      ? event.isMetaPressed
                      : event.isControlPressed;
                  _isShiftPressed = event.isShiftPressed;

                  MusicHomeBoardKeyStatus status = MusicHomeBoardKeyStatus.none;

                  if (_isControlPressed) {
                    status = MusicHomeBoardKeyStatus.ctrlDown;
                  } else if (_isShiftPressed) {
                    status = MusicHomeBoardKeyStatus.shiftDown;
                  }

                  context
                      .read<MusicHomeBloc>()
                      .add(MusicHomeKeyStatusChanged(status));

                  if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                    // _onEnterKeyPressed();
                    return KeyEventResult.handled;
                  }

                  if (Platform.isMacOS) {
                    if (event.isMetaPressed &&
                        event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                      _checkAll(context);
                      return KeyEventResult.handled;
                    }
                  } else {
                    if (event.isControlPressed &&
                        event.isKeyPressed(LogicalKeyboardKey.keyA)) {
                      _checkAll(context);
                      return KeyEventResult.handled;
                    }
                  }

                  return KeyEventResult.ignored;
                },
              ),
              onDragDone: (details) {
                final audios = details.files
                    .map((e) => File(e.path))
                    .where((element) => element.isAudio)
                    .toList();

                if (audios.isEmpty) {
                  return;
                }

                context
                    .read<MusicHomeBloc>()
                    .add(MusicHomeUploadAudios(audios));
              },
              onDragEntered: (details) {
                SoundEffect.play(SoundType.bubble);
              },
            ),
            Visibility(
              child: Container(child: spinKit, color: Colors.white),
              maintainSize: false,
              visible: status == MusicHomeStatus.loading,
            )
          ])),
    );
  }

  void _performSort(BuildContext context, MusicHomeSortColumn sortColumn,
      MusicHomeSortDirection sortDirection) {
    context
        .read<MusicHomeBloc>()
        .add(MusicHomeSortInfoChanged(sortColumn, sortDirection));
  }

  void _onMusicRightMouseClick(BuildContext context, Offset position,
      List<AudioItem> checkedMusics, AudioItem music) {
    if (!checkedMusics.contains(music)) {
      context.read<MusicHomeBloc>().add(MusicHomeCheckedChanged(music));
    }

    context.read<MusicHomeBloc>().add(MusicHomeMenuStatusChanged(
        MusicHomeOpenMenuStatus(
            isOpened: true, position: position, target: music)));
  }

  void _checkAll(BuildContext context) {
    context.read<MusicHomeBloc>().add(MusicHomeCheckAll());
  }

  void _openMenu(
      {required BuildContext pageContext,
      required Offset position,
      required AudioItem current}) {
    String copyTitle = "";

    final checkedMusics = pageContext.read<MusicHomeBloc>().state.checkedMusics;

    if (checkedMusics.length == 1) {
      AudioItem audioItem = checkedMusics.single;

      String name = audioItem.name;

      copyTitle = pageContext.l10n.placeHolderCopyToComputer
          .replaceFirst("%s", name)
          .adaptForOverflow();
    } else {
      String itemStr = pageContext.l10n.placeHolderItemCount03
          .replaceFirst("%d", "${checkedMusics.length}");
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
          SystemAppLauncher.openAudio(current);
        },
      ),
      ContextMenuItem(
        title: copyTitle,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          CommonUtil.openFilePicker(pageContext.l10n.chooseDir, (dir) {
            _startCopy(pageContext, checkedMusics, dir);
          }, (error) {
            debugPrint("_openFilePicker, error: $error");
          });
        },
      ),
      ContextMenuItem(
        title: pageContext.l10n.delete,
        onTap: () {
          ContextMenuHelper().hideContextMenu();

          _tryToDeleteMusics(pageContext, checkedMusics);
        },
      )
    ]);
  }

  void _startCopy(BuildContext context, List<AudioItem> musics, String dir) {
    context
        .read<MusicHomeBloc>()
        .add(MusicHomeCopyMusicsSubmitted(musics, dir));
  }

  void _tryToDeleteMusics(
      BuildContext pageContext, List<AudioItem> checkedMusics) {
    CommonUtil.showConfirmDialog(
        pageContext,
        "${pageContext.l10n.tipDeleteTitle.replaceFirst("%s", "${checkedMusics.length}")}",
        pageContext.l10n.tipDeleteDesc,
        pageContext.l10n.cancel,
        pageContext.l10n.delete, (context) {
      Navigator.of(context, rootNavigator: true).pop();

      pageContext
          .read<MusicHomeBloc>()
          .add(MusicHomeDeleteSubmitted(checkedMusics));
    }, (context) {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  void _showDownloadProgressDialog(
      BuildContext context, List<AudioItem> musics) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _progressIndicatorDialog?.dismiss();
        context.read<MusicHomeBloc>().add(MusicHomeCancelCopySubmitted());
      });
    }

    String title = context.l10n.preparing;

    if (musics.length > 1) {
      title = context.l10n.compressing;
    }

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }
}
