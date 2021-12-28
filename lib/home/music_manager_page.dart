import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/model/AudioItem.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:intl/intl.dart';
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

  late Function() _ctrlAPressedCallback;

  bool _isDeleteBtnEnabled = false;

  @override
  void initState() {
    super.initState();

    _ctrlAPressedCallback = () {
      _setAllSelected();
      debugPrint("Ctrl + A pressed...");
    };

    _addCtrlAPressedCallback(_ctrlAPressedCallback);

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
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/audio/all");
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

  @override
  Widget build(BuildContext context) {
    const color = Color(0xff85a8d0);

    const spinKit = SpinKitCircle(color: color, size: 60.0);

    return Stack(children: [
      _realContent(),
      Visibility(
        child: Container(child: spinKit, color: Colors.white),
        maintainSize: false,
        visible: !_isLoadingSuccess,
      )
    ]);
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
                        inherit: false,
                        color: Color(0xff616161),
                        fontSize: 16.0))),
            Align(
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
                      color: Color(0xff646464), fontSize: 12, inherit: false))),
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
        TextStyle(inherit: false, fontSize: 14, color: Colors.black);

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
                  ),
                  padding: EdgeInsets.only(left: 15),
                )),
                DataColumn2(
                    label: Container(
                      child: Text(
                        "时长",
                        textAlign: TextAlign.center,
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
            )));
  }

  List<DataRow> _generateRows() {
    return List<DataRow>.generate(_audioItems.length, (index) {
      AudioItem audioItem = _audioItems[index];

      Color textColor =
          _isSelected(audioItem) ? Colors.white : Color(0xff313237);
      TextStyle textStyle =
          TextStyle(inherit: false, fontSize: 14, color: textColor);

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

      return DataRow2(
          cells: [
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(folderName,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(audioItem.name,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(type,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(_convertToReadableDuration(audioItem.duration),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(_convertToReadableSize(audioItem.size),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
            )),
            DataCell(Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: Text(_formatChangeDate(audioItem.modifyDate),
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: textStyle),
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

    _updateDeleteBtnStatus();
  }

  bool _isControlDown() {
    return FileManagerPage.fileManagerKey.currentState?.isControlDown() == true;
  }

  bool _isShiftDown() {
    return FileManagerPage.fileManagerKey.currentState?.isShiftDown() == true;
  }

  void _addCtrlAPressedCallback(Function() callback) {
    FileManagerPage.fileManagerKey.currentState
        ?.addCtrlAPressedCallback(callback);
  }

  void _removeCtrlAPressedCallback(Function() callback) {
    FileManagerPage.fileManagerKey.currentState
        ?.removeCtrlAPressedCallback(callback);
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
        "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080/audio/item/${audioItem.id}";

    if (!await launch(videoUrl, universalLinksOnly: true)) {
      debugPrint("Open audio: $videoUrl fail");
    } else {
      debugPrint("Open audio: $videoUrl success");
    }
  }

  @override
  void deactivate() {
    super.deactivate();

    _removeCtrlAPressedCallback(_ctrlAPressedCallback);
  }

  @override
  bool get wantKeepAlive => true;
}
