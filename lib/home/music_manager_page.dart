import 'dart:io';
import 'dart:ui';

import 'package:data_table_2/data_table_2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flowder/flowder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/model/AudioItem.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:intl/intl.dart';
import 'package:mobile_assistant_client/util/system_app_launcher.dart';
import 'package:mobile_assistant_client/widget/confirm_dialog_builder.dart';
import 'package:mobile_assistant_client/widget/progress_indictor_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';

import 'file_manager.dart';

class MusicManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MusicManagerState();
  }
}

class _MusicManagerState extends State<MusicManagerPage> with AutomaticKeepAliveClientMixin {
  var _isLoadingSuccess = false;
  final _icon_delete_btn_size = 10.0;
  final _delete_btn_width = 40.0;
  final _delete_btn_height = 25.0;
  final _delete_btn_padding_hor = 8.0;
  final _delete_btn_padding_vertical = 4.5;
  final _divider_line_color = Color(0xffe0e0e0);

  List<AudioItem> _audioItems = [];
  List<AudioItem> _selectedAudioItems = [];

  static final _COLUMN_INDEX_FOLDER = 0;
  static final _COLUMN_INDEX_NAME = 1;
  static final _COLUMN_INDEX_TYPE = 2;
  static final _COLUMN_INDEX_DURATION = 3;
  static final _COLUMN_INDEX_SIZE = 4;
  static final _COLUMN_INDEX_MODIFY_DATE = 5;

  int _sortColumnIndex = _COLUMN_INDEX_FOLDER;
  bool _isAscending = true;

  final _ONE_HOUR = 60 * 60 * 1000;
  final _ONE_MINUTE = 60 * 1000;
  final _ONE_SECOND = 1000;

  final _KB_BOUND = 1 * 1024;
  final _MB_BOUND = 1 * 1024 * 1024;
  final _GB_BOUND = 1 * 1024 * 1024 * 1024;

  final _URL_SERVER = "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";

  bool _isDeleteBtnEnabled = false;

  DownloaderCore? _downloaderCore;
  ProgressIndicatorDialog? _progressIndicatorDialog;

  AudioItem? _renamingAudioFile;
  String? _newFileName;

  FocusNode? _rootFocusNode;

  bool _isControlPressed = false;
  bool _isShiftPressed = false;

  @override
  void initState() {
    super.initState();

    _getAllAudios((audios) {
      setState(() {
        _audioItems = audios;
        _isLoadingSuccess = true;
      });
    }, (error) {
      debugPrint("_getAllAudios, error: $error");
      setState(() {
        _isLoadingSuccess = true;
      });
    });
  }

  void _setAllSelected() {
    setState(() {
      _selectedAudioItems.clear();
      _selectedAudioItems.addAll(_audioItems);
      _updateDeleteBtnStatus();
    });
  }

  void _updateDeleteBtnStatus() {
    setState(() {
      _isDeleteBtnEnabled = _selectedAudioItems.length > 0;
    });
  }

  // 获取音乐列表
  void _getAllAudios(Function(List<AudioItem> audios) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse(
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}/audio/all");
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
              .map((e) => AudioItem.fromJson(e as Map<String, dynamic>))
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

  void _openMenu(Offset position, AudioItem audioItem) {
    RenderBox? overlay =
    Overlay.of(context)?.context.findRenderObject() as RenderBox;

    String name = audioItem.name;


    String copyTitle = "";

    if (_selectedAudioItems.length == 1) {
      copyTitle = "拷贝${_selectedAudioItems.single.name}到电脑";
    } else {
      copyTitle = "拷贝 ${_selectedAudioItems.length} 项 到 电脑";
    }

    showMenu(
        context: context,
        position: RelativeRect.fromSize(
            Rect.fromLTRB(position.dx, position.dy, 0, 0),
            overlay.size),
        items: [
          PopupMenuItem(
              child: Text("打开"),
              onTap: () {
                SystemAppLauncher.openAudio(audioItem);
              }),
          PopupMenuItem(
              child: Text("重命名"),
              onTap: () {
                setState(() {
                  _renamingAudioFile = audioItem;
                  _newFileName = audioItem.name;
                });
              }),
          PopupMenuItem(
              child: Text(copyTitle),
              onTap: () {
                _openFilePicker((dir) {
                  _startDownload(dir, _selectedAudioItems);
                }, (error) {
                  debugPrint("_openFilePicker, error: $error");
                });
              }),
          PopupMenuItem(
              child: Text("删除"),
              onTap: () {
                Future<void>.delayed(const Duration(),
                        () => _tryToDeleteFiles(_selectedAudioItems));
              }),
        ]);
  }

  void _startDownload(String dir, List<AudioItem> audios) {
    _showDownloadProgressDialog(audios);

    _downloadFiles(audios, dir, () {
      _progressIndicatorDialog?.dismiss();
    }, (error) {
      debugPrint("_startDownload, $error");
      _progressIndicatorDialog?.dismiss();

      SmartDialog.showToast(error);
    }, (current, total) {
      if (_progressIndicatorDialog?.isShowing == true) {
        if (current > 0) {
          setState(() {
            String title = "正在导出音频";

            if (audios.length == 1) {
              title = "正在导出音频${audios.single.name}...";
            }

            if (audios.length > 1) {
              title = "正在导出${audios.length}个音频...";
            }

            _progressIndicatorDialog?.title = title;
          });
        }

        setState(() {
          _progressIndicatorDialog?.subtitle =
          "${_convertToReadableSize(current)}/${_convertToReadableSize(total)}";
          _progressIndicatorDialog?.updateProgress(current / total);
        });
      }
    });
  }

  void _rename(AudioItem audio, String newName, Function() onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/file/rename");

    var folder = audio.path;
    int index = folder.lastIndexOf("/");

    if (index != -1) {
      folder = folder.substring(0, index);
    }

    http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "folder": folder,
          "file": audio.name,
          "newName": newName,
          "isDir": false
        }))
        .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("_rename, body: $body");

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

  void _tryToDeleteFiles(List<AudioItem> audios) {
    _showConfirmDialog("确定删除这${audios.length}个项目吗？", "注意：删除的文件无法恢复", "取消", "删除",
            (context) {
          Navigator.of(context, rootNavigator: true).pop();

          SmartDialog.showLoading();

          _deleteFiles(audios, () {
            SmartDialog.dismiss();

            setState(() {
              _audioItems.removeWhere((audio) => audios.contains(audio));
              _selectedAudioItems.clear();
              _isDeleteBtnEnabled = false;
            });
          }, (error) {
            SmartDialog.dismiss();

            SmartDialog.showToast(error);
          });
        }, (context) {
          Navigator.of(context, rootNavigator: true).pop();
        });
  }


  void _deleteFiles(List<AudioItem> audios, Function() onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/file/deleteMulti");
    http
        .post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "paths": audios
              .map((audio) => audio.path)
              .toList()
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

  void _openFilePicker(void onSuccess(String dir), void onError(String error)) {
    FilePicker.platform.getDirectoryPath(dialogTitle: "选择目录", lockParentWindow: true)
        .then((value) {
      if (null == value) {
        onError.call("Dir is null");
      } else {
        onSuccess.call(value);
      }
    }).catchError((error) {
      onError.call(error);
    });
  }
  
  void _downloadFiles(List<AudioItem> audios, String dir, void onSuccess(),
      void onError(String error), void onDownload(current, total)) async {
    if (audios.isEmpty) return;

    String name = "";

    if (audios.length <= 1) {
      name = audios.single.name;
    } else {
      final df = DateFormat("yyyyMd_HHmmss");

      String formatTime = df.format(new DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));

      name = "AirController_${formatTime}.zip";
    }

    var options = DownloaderUtils(
        progress: ProgressImplementation(),
        file: File("$dir/$name"),
        onDone: () {
          debugPrint("Download done");
          onSuccess.call();
        },
        progressCallback: (current, total) {
          debugPrint("total: $total");
          debugPrint("Downloading percent: ${current / total}");
          onDownload.call(current, total);
        });

    String pathsStr =  Uri.encodeComponent(jsonEncode(audios.map((audio) => audio.path).toList()));

    String api = "${_URL_SERVER}/stream/download?paths=$pathsStr";
    if (null == _downloaderCore) {
      _downloaderCore = await Flowder.download(api, options);
    } else {
      _downloaderCore?.download(api, options);
    }
  }

  void _showDownloadProgressDialog(List<AudioItem> audios) {
    if (null == _progressIndicatorDialog) {
      _progressIndicatorDialog = ProgressIndicatorDialog(context: context);
      _progressIndicatorDialog?.onCancelClick(() {
        _downloaderCore?.cancel();
        _progressIndicatorDialog?.dismiss();
      });
    }

    String title = "正在准备中，请稍后...";

    if (audios.length > 1) {
      title = "正在压缩中，请稍后...";
    }

    _progressIndicatorDialog?.title = title;

    if (!_progressIndicatorDialog!.isShowing) {
      _progressIndicatorDialog!.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);

    const spinKit = SpinKitCircle(color: color, size: 60.0);

    _rootFocusNode = FocusNode();

    _rootFocusNode?.canRequestFocus = true;
    _rootFocusNode?.requestFocus();

    return Stack(children: [
      Focus(
        autofocus: true,
        focusNode: _rootFocusNode,
        child: GestureDetector(
          child: _realContent(),
          onTap: () {
            _clearSelectedAudios();
            _resetRenamingAudioFile();
            _isDeleteBtnEnabled = false;
          },
        ),
        onFocusChange: (value) {

        },
        onKey: (node, event) {
          debugPrint(
              "Outside key pressed: ${event.logicalKey.keyId}, ${event.logicalKey.keyLabel}");

          _isControlPressed =
          Platform.isMacOS ? event.isMetaPressed : event.isControlPressed;
          _isShiftPressed = event.isShiftPressed;

          if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
            _onEnterKeyPressed();
            return KeyEventResult.handled;
          }

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
      ),
      Visibility(
        child: Container(child: spinKit, color: Colors.white),
        maintainSize: false,
        visible: !_isLoadingSuccess,
      )
    ]);
  }

  void _clearSelectedAudios() {
    setState(() {
      _selectedAudioItems.clear();
    });
  }

  void _onControlAndAPressed() {
    debugPrint("_onControlAndAPressed.");
    _setAllSelected();
  }

  void _onEnterKeyPressed() {
    debugPrint("_onEnterKeyPressed.");
    if (_renamingAudioFile == null) {
      if (_isSingleFileSelected()) {
        AudioItem audio = _selectedAudioItems.single;
        setState(() {
          _newFileName = audio.name;
          _renamingAudioFile = audio;
        });
      }
    } else {
      if (_isSingleFileSelected()) {
        AudioItem audio = _selectedAudioItems.single;
        String oldFileName = audio.name;
        if (_newFileName != null && _newFileName?.trim() != "") {
          if (_newFileName != oldFileName) {
            _rename(audio, _newFileName!, () {
              setState(() {
                audio.name = _newFileName!;
                _resetRenamingAudioFile();
              });
            }, (error) {
              SmartDialog.showToast("文件重命名失败！");
            });
          } else {
            _resetRenamingAudioFile();
          }
        }
      }
    }
  }

  bool _isSingleFileSelected() {
    return _selectedAudioItems.length == 1;
  }

  Widget _realContent() {
    String itemNumStr = "共${_audioItems.length}项";

    if (_selectedAudioItems.length > 0) {
      itemNumStr = "选中${_selectedAudioItems.length}项（共${_audioItems.length}项目)";
    }

    return Column(children: [
      Container(
          child: Stack(children: [
            Align(
                alignment: Alignment.center,
                child: Text("音乐",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xff616161),
                        fontSize: 16.0))),
            Align(
                child: GestureDetector(
                  child: Container(
                      child: Opacity(
                        opacity: _isDeleteBtnEnabled ? 1.0 : 0.6,
                        child: Image.asset("icons/icon_delete.png",
                            width: _icon_delete_btn_size,
                            height: _icon_delete_btn_size),
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xffcb6357),
                          border: new Border.all(
                              color: Color(0xffb43f32), width: 1.0),
                          borderRadius: BorderRadius.all(Radius.circular(4.0))),
                      width: _delete_btn_width,
                      height: _delete_btn_height,
                      padding: EdgeInsets.fromLTRB(
                          _delete_btn_padding_hor,
                          _delete_btn_padding_vertical,
                          _delete_btn_padding_hor,
                          _delete_btn_padding_vertical),
                      margin: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                  onTap: () {
                    if (_isDeleteBtnEnabled) {
                      _tryToDeleteFiles(_selectedAudioItems);
                    }
                  },
                ),
                alignment: Alignment.centerRight)
          ]),
          color: Color(0xfff4f4f4),
          height: Constant.HOME_NAVI_BAR_HEIGHT),
      Divider(
        color: _divider_line_color,
        height: 1.0,
        thickness: 1.0,
      ),

      /// 内容区域
      _createContent(),

      /// 底部固定区域
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
      Container(
          child: Align(
              alignment: Alignment.center,
              child: Text(itemNumStr,
                  style: TextStyle(
                      color: Color(0xff646464), fontSize: 12))),
          height: 20,
          color: Color(0xfffafafa)),
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
    ], mainAxisSize: MainAxisSize.max);
  }

  String _convertToReadableDuration(int duration) {
    if (duration >= _ONE_HOUR) {
      int hour = (duration / _ONE_HOUR).truncate();

      String durStr = "${hour}小时";

      if (duration - hour * _ONE_HOUR > 0) {
        int min = ((duration - hour * _ONE_HOUR) / _ONE_MINUTE).truncate();

        durStr = "${durStr}${min}分";

        if (duration - hour * _ONE_HOUR - min * _ONE_MINUTE > 0) {
          int sec =
              ((duration - hour * _ONE_HOUR - min * _ONE_MINUTE) / _ONE_SECOND)
                  .truncate();

          durStr = "${durStr}${sec}秒";
        }
      }

      return durStr;
    } else if (duration < _ONE_HOUR && duration >= _ONE_MINUTE) {
      int min = (duration / _ONE_MINUTE).truncate();

      String durStr = "${min}分";

      if (duration - min * _ONE_MINUTE > 0) {
        int sec = ((duration - min * _ONE_MINUTE) / _ONE_SECOND).truncate();

        durStr = "${durStr}${sec}秒";
      }

      return durStr;
    } else {
      int sec = (duration / _ONE_SECOND).truncate();

      return "${sec}秒";
    }
  }

  String _convertToReadableSize(int size) {
    if (size < _KB_BOUND) {
      return "${size}Byte";
    }
    if (size >= _KB_BOUND && size < _MB_BOUND) {
      return "${size ~/ 1024}KB";
    }

    if (size >= _MB_BOUND && size <= _GB_BOUND) {
      return "${size / 1024 ~/ 1024}MB";
    }

    return "${size / 1024 / 1024 ~/ 1024}GB";
  }

  Widget _createContent() {
    TextStyle headerStyle =
        TextStyle(fontSize: 14, color: Colors.black);

    return Expanded(
        child: Container(
            color: Colors.white,
            child: DataTable2(
              dividerThickness: 1,
              bottomMargin: 10,
              columnSpacing: 0,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _isAscending,
              showCheckboxColumn: false,
              showBottomBorder: false,
              columns: [
                DataColumn2(
                    label: Container(
                      child: Text(
                        "文件夹",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          inherit: true,
                          fontFamily: 'NotoSansSC'
                        ),
                      ),
                    ),
                    onSort: (sortColumnIndex, isSortAscending) {
                      _performSort(sortColumnIndex, isSortAscending);
                      debugPrint(
                          "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
                    },
                    size: ColumnSize.L),
                DataColumn2(
                    label: Container(
                        child: Text(
                          "名称",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              inherit: true,
                              fontFamily: 'NotoSansSC'
                          ),
                        ),
                        padding: EdgeInsets.only(left: 15)),
                    onSort: (sortColumnIndex, isSortAscending) {
                      _performSort(sortColumnIndex, isSortAscending);
                      debugPrint(
                          "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
                    }),
                DataColumn2(
                    label: Container(
                  child: Text(
                    "类型",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        inherit: true,
                        fontFamily: 'NotoSansSC'
                    ),
                  ),
                  padding: EdgeInsets.only(left: 15),
                )),
                DataColumn2(
                    label: Container(
                      child: Text(
                        "时长",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            inherit: true,
                            fontFamily: 'NotoSansSC'
                        ),
                      ),
                      padding: EdgeInsets.only(left: 15),
                    ),
                    onSort: (sortColumnIndex, isSortAscending) {
                      _performSort(sortColumnIndex, isSortAscending);
                      debugPrint(
                          "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
                    }),
                DataColumn2(
                    label: Container(
                      child: Text(
                        "大小",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            inherit: true,
                            fontFamily: 'NotoSansSC'
                        ),
                      ),
                      padding: EdgeInsets.only(left: 15),
                    ),
                    onSort: (sortColumnIndex, isSortAscending) {
                      _performSort(sortColumnIndex, isSortAscending);
                      debugPrint(
                          "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
                    }),
                DataColumn2(
                    label: Container(
                      child: Text(
                        "修改日期",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            inherit: true,
                            fontFamily: 'NotoSansSC'
                        ),
                      ),
                      padding: EdgeInsets.only(left: 15),
                    ),
                    onSort: (sortColumnIndex, isSortAscending) {
                      _performSort(sortColumnIndex, isSortAscending);
                      debugPrint(
                          "sortColumnIndex: $sortColumnIndex, isSortAscending: $isSortAscending");
                    })
              ],
              rows: _generateRows(),
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
        ));
  }

  List<DataRow> _generateRows() {
    return List<DataRow>.generate(_audioItems.length, (index) {
      AudioItem audioItem = _audioItems[index];

      Color textColor =
          _isSelected(audioItem) ? Colors.white : Color(0xff313237);
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
                if (_isMouseRightClicked(event)) {
                  if (!_selectedAudioItems.contains(audioItem)) {
                    _setAudioSelected(audioItem);
                  }

                  _openMenu(event.position, audioItem);
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
                      visible: audioItem != _renamingAudioFile,
                    ),
                    Visibility(
                      child: Container(
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: inputController,
                            focusNode: audioItem != _renamingAudioFile
                                ? focusNode
                                : null,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffcccbcd),
                                        width: 3,
                                        style: BorderStyle.solid)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffcccbcd),
                                        width: 3,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(4)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffcccbcd),
                                        width: 4,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(4)),
                                contentPadding:
                                EdgeInsets.fromLTRB(8, 3, 8, 3)),
                            cursorColor: Color(0xff333333),
                            style: TextStyle(
                                fontSize: 14, color: Color(0xff333333)),
                            onChanged: (value) {
                              debugPrint("onChange, $value");
                              _newFileName = value;
                            },
                          ),
                        ),
                        height: 30,
                        color: Colors.white,
                      ),
                      visible: audioItem == _renamingAudioFile,
                      maintainState: false,
                      maintainSize: false,
                    )
                  ],
                ),
                color: Colors.transparent,
              ),
              onPointerDown: (event) {
                if (_isMouseRightClicked(event)) {
                  if (!_selectedAudioItems.contains(audioItem)) {
                    _setAudioSelected(audioItem);
                  }

                  _openMenu(event.position, audioItem);
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
                if (_isMouseRightClicked(event)) {
                  if (!_selectedAudioItems.contains(audioItem)) {
                    _setAudioSelected(audioItem);
                  }

                  _openMenu(event.position, audioItem);
                }
              },
            )),
            DataCell(Listener(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(_convertToReadableDuration(audioItem.duration),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle),
                color: Colors.transparent,
              ),
              onPointerDown: (event) {
                if (_isMouseRightClicked(event)) {
                  if (!_selectedAudioItems.contains(audioItem)) {
                    _setAudioSelected(audioItem);
                  }

                  _openMenu(event.position, audioItem);
                }
              },
            )),
            DataCell(Listener(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(_convertToReadableSize(audioItem.size),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle),
                color: Colors.transparent,
              ),
              onPointerDown: (event) {
                if (_isMouseRightClicked(event)) {
                  if (!_selectedAudioItems.contains(audioItem)) {
                    _setAudioSelected(audioItem);
                  }

                  _openMenu(event.position, audioItem);
                }
              },
            )),
            DataCell(Listener(
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
                child: Text(_formatChangeDate(audioItem.modifyDate),
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: textStyle),
                color: Colors.transparent,
              ),
              onPointerDown: (event) {
                if (_isMouseRightClicked(event)) {
                  if (!_selectedAudioItems.contains(audioItem)) {
                    _setAudioSelected(audioItem);
                  }

                  _openMenu(event.position, audioItem);
                }
              },
            )),
          ],
          selected: _isSelected(audioItem),
          onSelectChanged: (isSelected) {
            debugPrint("onSelectChanged: $isSelected");
          },
          onTap: () {
            _setAudioSelected(audioItem);
          },
          onDoubleTap: () {
            _openVideoWithSystemApp(audioItem);
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
    });
  }

  bool _isMouseRightClicked(PointerDownEvent event) {
    return event.kind == PointerDeviceKind.mouse &&
        event.buttons == kSecondaryMouseButton;
  }

  void _setAudioSelected(AudioItem audio) {
    debugPrint("Shift key down status: ${_isShiftDown()}");
    debugPrint("Control key down status: ${_isControlDown()}");

    if (!_isSelected(audio)) {
      if (_isControlDown()) {
        setState(() {
          _selectedAudioItems.add(audio);
        });
      } else if (_isShiftDown()) {
        if (_selectedAudioItems.length == 0) {
          setState(() {
            _selectedAudioItems.add(audio);
          });
        } else if (_selectedAudioItems.length == 1) {
          int index = _audioItems.indexOf(_selectedAudioItems[0]);

          int current = _audioItems.indexOf(audio);

          if (current > index) {
            setState(() {
              _selectedAudioItems = _audioItems.sublist(index, current + 1);
            });
          } else {
            setState(() {
              _selectedAudioItems = _audioItems.sublist(current, index + 1);
            });
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < _selectedAudioItems.length; i++) {
            AudioItem current = _selectedAudioItems[i];
            int index = _audioItems.indexOf(current);
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

          int current = _audioItems.indexOf(audio);

          if (current >= minIndex && current <= maxIndex) {
            setState(() {
              _selectedAudioItems = _audioItems.sublist(current, maxIndex + 1);
            });
          } else if (current < minIndex) {
            setState(() {
              _selectedAudioItems = _audioItems.sublist(current, maxIndex + 1);
            });
          } else if (current > maxIndex) {
            setState(() {
              _selectedAudioItems = _audioItems.sublist(minIndex, current + 1);
            });
          }
        }
      } else {
        setState(() {
          _selectedAudioItems.clear();
          _selectedAudioItems.add(audio);
        });
      }
    } else {
      debugPrint("It's already contains this image, id: ${audio.id}");

      if (_isControlDown()) {
        setState(() {
          _selectedAudioItems.remove(audio);
        });
      } else if (_isShiftDown()) {
        setState(() {
          _selectedAudioItems.remove(audio);
        });
      } else {
        setState(() {
          _selectedAudioItems.clear();
          _selectedAudioItems.add(audio);
        });
      }
    }


    if (null != _renamingAudioFile && audio != _renamingAudioFile) {
      _rename(_renamingAudioFile!, _newFileName!, () {
        setState(() {
          _renamingAudioFile!.name = _newFileName!;
          _resetRenamingAudioFile();
        });
      }, (error) {
        SmartDialog.showToast(error);
        _resetRenamingAudioFile();
      });
    }
    
    _updateDeleteBtnStatus();
  }

  void _resetRenamingAudioFile() {
    setState(() {
      _renamingAudioFile = null;
      _newFileName = null;
    });
  }
  
  bool _isControlDown() {
    return _isControlPressed;
  }

  bool _isShiftDown() {
    return _isShiftPressed;
  }

  String _formatChangeDate(int changeDate) {
    final df = DateFormat("yyyy年M月d日 HH:mm");
    return df
        .format(new DateTime.fromMillisecondsSinceEpoch(changeDate * 1000));
  }

  bool _isSelected(AudioItem audioItem) {
    return _selectedAudioItems.contains(audioItem);
  }

  void _performSort(int sortColumnIndex, bool isSortAscending) {
    if (sortColumnIndex == _COLUMN_INDEX_FOLDER) {
      _audioItems.sort((itemA, itemB) {
        String folderA = itemA.folder;
        String folderB = itemB.folder;

        int lastIndexA = folderA.lastIndexOf("/");

        if (lastIndexA != -1) {
          folderA = folderA.substring(lastIndexA + 1);
        }

        int lastIndexB = folderB.lastIndexOf("/");

        if (lastIndexB != -1) {
          folderB = folderB.substring(lastIndexB + 1);
        }

        if (isSortAscending) {
          return folderA.toLowerCase().compareTo(folderB.toLowerCase());
        } else {
          return folderB.toLowerCase().compareTo(folderA.toLowerCase());
        }
      });
      setState(() {
        _sortColumnIndex = sortColumnIndex;
        _isAscending = isSortAscending;
      });
    }

    if (sortColumnIndex == _COLUMN_INDEX_NAME) {
      _audioItems.sort((itemA, itemB) {
        if (isSortAscending) {
          return itemA.name.toLowerCase().compareTo(itemB.name.toLowerCase());
        } else {
          return itemB.name.toLowerCase().compareTo(itemA.name.toLowerCase());
        }
      });
      setState(() {
        _sortColumnIndex = sortColumnIndex;
        _isAscending = isSortAscending;
      });
    }

    if (sortColumnIndex == _COLUMN_INDEX_DURATION) {
      _audioItems.sort((itemA, itemB) {
        if (isSortAscending) {
          return itemA.duration.compareTo(itemB.duration);
        } else {
          return itemB.duration.compareTo(itemA.duration);
        }
      });
      setState(() {
        _sortColumnIndex = sortColumnIndex;
        _isAscending = isSortAscending;
      });
    }

    if (sortColumnIndex == _COLUMN_INDEX_SIZE) {
      _audioItems.sort((itemA, itemB) {
        if (isSortAscending) {
          return itemA.size.compareTo(itemB.size);
        } else {
          return itemB.size.compareTo(itemA.size);
        }
      });
      setState(() {
        _sortColumnIndex = sortColumnIndex;
        _isAscending = isSortAscending;
      });
    }

    if (sortColumnIndex == _COLUMN_INDEX_MODIFY_DATE) {
      _audioItems.sort((itemA, itemB) {
        if (isSortAscending) {
          return itemA.modifyDate.compareTo(itemB.modifyDate);
        } else {
          return itemB.modifyDate.compareTo(itemA.modifyDate);
        }
      });
      setState(() {
        _sortColumnIndex = sortColumnIndex;
        _isAscending = isSortAscending;
      });
    }
  }

  void _openVideoWithSystemApp(AudioItem audioItem) async {
    debugPrint("_openVideoWithSystemApp, path: ${audioItem.path}");

    String videoUrl =
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}/audio/item/${audioItem.id}";

    if (!await launch(videoUrl, universalLinksOnly: true)) {
      debugPrint("Open audio: $videoUrl fail");
    } else {
      debugPrint("Open audio: $videoUrl success");
    }
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  bool get wantKeepAlive => true;
}
