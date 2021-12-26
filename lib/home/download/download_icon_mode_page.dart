import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/event/back_btn_visibility.dart';
import 'package:mobile_assistant_client/event/refresh_download_file_list.dart';
import 'package:mobile_assistant_client/event/update_bottom_item_num.dart';
import 'package:mobile_assistant_client/event/update_delete_btn_status.dart';
import 'package:mobile_assistant_client/home/download/download_file_manager.dart';
import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:mobile_assistant_client/model/FileNode.dart';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';
import 'package:mobile_assistant_client/model/UIModule.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';
import 'package:mobile_assistant_client/util/stack.dart';
import 'package:http/http.dart' as http;

import '../file_manager.dart';

class DownloadIconModePage extends StatefulWidget {
  late _DownloadIconModeState? state;

  @override
  State<StatefulWidget> createState() {
    state = _DownloadIconModeState();
    debugPrint("DownloadIconModePage, createState, instance: $this");
    return state!;
  }

  void updateFiles(List<FileItem> files) {
    state?.updateFiles(files);
  }

  void setSelectedFiles(List<FileItem> files) {
    state?.updateSelectedFiles(files);
  }
}

class _DownloadIconModeState extends State<DownloadIconModePage>
    with AutomaticKeepAliveClientMixin {
  final _divider_line_color = Color(0xffe0e0e0);
  final _BACKGROUND_FILE_SELECTED = Color(0xffe6e6e6);
  final _BACKGROUND_FILE_NORMAL = Colors.white;

  final _FILE_NAME_TEXT_COLOR_NORMAL = Color(0xff515151);

  final _FILE_NAME_TEXT_COLOR_SELECTED = Colors.white;

  final _BACKGROUND_FILE_NAME_NORMAL = Colors.white;
  final _BACKGROUND_FILE_NAME_SELECTED = Color(0xff5d87ed);

  late Function() _ctrlAPressedCallback;

  final _URL_SERVER =
      "http://${DeviceConnectionManager.instance.currentDevice?.ip}:8080";

  StreamSubscription<RefreshDownloadFileList>? _refreshDownloadFileList;

  @override
  void initState() {
    super.initState();

    _registerEventBus();

    _ctrlAPressedCallback = () {
      _setAllSelected();
      debugPrint("Ctrl + A pressed...");
    };

    _addCtrlAPressedCallback(_ctrlAPressedCallback);

    debugPrint("_DownloadIconModeState: initState, instance: $this");
  }

  void _registerEventBus() {
    _refreshDownloadFileList =
        eventBus.on<RefreshDownloadFileList>().listen((event) {
          setState(() {

          });
        });
  }

  void _unRegisterEventBus() {
    _refreshDownloadFileList?.cancel();
  }

  void _setAllSelected() {
    setState(() {
      List<FileNode> selectedFiles =
          DownloadFileManager.instance.selectedFiles();
      selectedFiles.clear();

      List<FileNode> allFiles = DownloadFileManager.instance.allFiles();
      selectedFiles.addAll(allFiles);
      DownloadFileManager.instance.updateSelectedFiles(selectedFiles);

      updateBottomItemNum();
      _setDeleteBtnEnabled(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    String getFileTypeIcon(bool isDir, String extension) {
      if (isDir) {
        return "icons/ic_large_type_folder.png";
      } else {
        if (_isAudio(extension)) {
          return "icons/ic_large_type_audio.png";
        }

        if (_isTextFile(extension)) {
          return "icons/ic_large_type_txt.png";
        }

        return "icons/ic_large_type_doc.png";
      }
    }

    List<FileNode> files = DownloadFileManager.instance.allFiles();
    List<FileNode> selectedFiles = DownloadFileManager.instance.selectedFiles();

    int dirStackLength = DownloadFileManager.instance.dirStackLength();

    Widget content = Column(children: [
      Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  child: GestureDetector(
                    child: Text("下载",
                        style: TextStyle(
                            color: Color(0xff5b5c61),
                            fontSize: 12.0,
                            inherit: false)),
                    onTap: () {
                      _backToRootDir();
                    },
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                ...List.generate(dirStackLength, (index) {
                  List<FileNode> fileNodes = DownloadFileManager.instance.dirStackToList();
                  FileNode fileNode = fileNodes[index];

                  return GestureDetector(
                    child: Row(
                      children: [
                        Image.asset("icons/ic_right_arrow.png", height: 20),
                        Container(
                          child: Text(fileNode.data.name,
                              style: TextStyle(
                                  color: Color(0xff5b5c61),
                                  fontSize: 12.0,
                                  inherit: false)),
                          padding: EdgeInsets.only(right: 5),
                        ),
                      ],
                    ),
                    onTap: () {
                      _tryToOpenDirectory(fileNode, (files) {

                        setState(() {
                          DownloadFileManager.instance.popTo(fileNode);
                          DownloadFileManager.instance.updateSelectedFiles([]);
                          DownloadFileManager.instance.updateFiles(files);
                          DownloadFileManager.instance.updateCurrentDir(fileNode);
                          _updateBackBtnVisibility();
                          _setDeleteBtnEnabled(DownloadFileManager.instance.selectedFileCount() > 0);
                          updateBottomItemNum();
                        });
                      }, (error) {

                      });
                    },
                  );
                })
              ],
            ),
          ),
          color: Color(0xfffaf9fa),
          padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
          height: 30),
      Divider(color: _divider_line_color, height: 1.0, thickness: 1.0),
      Expanded(
          child: Container(
              child: GridView.builder(
                itemBuilder: (BuildContext context, int index) {
                  FileNode fileItem = files[index];

                  bool isDir = fileItem.data.isDir;

                  String name = fileItem.data.name;
                  String extension = "";
                  int pointIndex = name.lastIndexOf(".");
                  if (pointIndex != -1) {
                    extension = name.substring(pointIndex + 1);
                  }

                  String fileTypeIcon = getFileTypeIcon(isDir, extension);

                  return Column(children: [
                    GestureDetector(
                        child: Container(
                          child: Image.asset(fileTypeIcon,
                              width: 100, height: 100),
                          decoration: BoxDecoration(
                              color: _isContainsFile(selectedFiles, fileItem)
                                  ? _BACKGROUND_FILE_SELECTED
                                  : _BACKGROUND_FILE_NORMAL,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0))),
                          padding: EdgeInsets.all(8),
                        ),
                        onTap: () {
                          _setFileSelected(fileItem);
                        },
                        onDoubleTap: () {
                          debugPrint(
                              "_tryToOpenDirectory: ${fileItem.data.name}");

                          _tryToOpenDirectory(fileItem, (files) {
                            setState(() {
                              DownloadFileManager.instance.updateSelectedFiles([]);
                              DownloadFileManager.instance.updateFiles(files);
                              DownloadFileManager.instance.updateCurrentDir(fileItem);
                              DownloadFileManager.instance.pushToStack(fileItem);
                              _updateBackBtnVisibility();
                              _setDeleteBtnEnabled(DownloadFileManager.instance.selectedFileCount() > 0);
                              updateBottomItemNum();
                            });
                          }, (error) {

                          });
                        }),
                    GestureDetector(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 150),
                        child: Text(
                          fileItem.data.name,
                          style: TextStyle(
                              inherit: false,
                              fontSize: 14,
                              color: _isContainsFile(selectedFiles, fileItem)
                                  ? _FILE_NAME_TEXT_COLOR_SELECTED
                                  : _FILE_NAME_TEXT_COLOR_NORMAL),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                          color: _isContainsFile(selectedFiles, fileItem)
                              ? _BACKGROUND_FILE_NAME_SELECTED
                              : _BACKGROUND_FILE_NAME_NORMAL,
                        ),
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.fromLTRB(5, 3, 5, 3),
                      ),
                      onTap: () {
                        _setFileSelected(fileItem);
                      },
                      onDoubleTap: () {
                        debugPrint(
                            "_tryToOpenDirectory: ${fileItem.data.name}");

                        _tryToOpenDirectory(fileItem, (files) {
                          setState(() {
                            DownloadFileManager.instance.updateSelectedFiles([]);
                            DownloadFileManager.instance.updateFiles(files);
                            DownloadFileManager.instance.updateCurrentDir(fileItem);
                            DownloadFileManager.instance.pushToStack(fileItem);
                            _updateBackBtnVisibility();
                          });
                        }, (error) {

                        });
                      },
                    )
                  ]);
                },
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.0,
                    mainAxisSpacing: 10),
                padding: EdgeInsets.all(10.0),
                itemCount: files.length,
              ),
              color: Colors.white)),
    ]);

    return GestureDetector(
      child: content,
      onTap: () {
        _clearSelectedFiles();
      },
    );
  }

  void _tryToOpenDirectory(FileNode dir, Function(List<FileNode>) onSuccess, Function(String) onError) {
    debugPrint("_tryToOpenDirectory, dir: ${dir.data.folder}/${dir.data.name}");
    _getDownloadFiles("${dir.data.folder}/${dir.data.name}", (files) {
      List<FileNode> allFiles =
          files.map((e) => FileNode(dir, e, dir.level + 1)).toList();

      onSuccess.call(allFiles);
    }, (error) {
      debugPrint("_tryToOpenDirectory, error: $error");

      onError.call(error);
    });
  }

  void _getDownloadRootFiles(Function(List<FileItem> files) onSuccess, Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/file/downloadedFiles");
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
        debugPrint("Get download file list, body: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          onSuccess.call(data
              .map((e) => FileItem.fromJson(e as Map<String, dynamic>))
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


  void _backToRootDir() {
    _getDownloadRootFiles((files) {
      List<FileNode> allFiles =
      files.map((e) => FileNode(null, e, 0)).toList();

      setState(() {
        DownloadFileManager.instance.updateSelectedFiles([]);
        DownloadFileManager.instance.updateFiles(allFiles);
        DownloadFileManager.instance.updateCurrentDir(null);
        DownloadFileManager.instance.clearDirStack();
        _updateBackBtnVisibility();
        _setDeleteBtnEnabled(DownloadFileManager.instance.selectedFileCount() > 0);
        updateBottomItemNum();
      });
    }, (error) {
      debugPrint("_tryToOpenDirectory, error: $error");
    });
  }

  void _updateBackBtnVisibility() {
    var isRoot = DownloadFileManager.instance.isRoot();
    debugPrint("Icon mode, _updateBackBtnVisibility, isRoot: $isRoot");
    eventBus.fire(BackBtnVisibility(!isRoot, module: UIModule.Download));
  }

  void _getDownloadFiles(String dir, Function(List<FileItem> files) onSuccess,
      Function(String error) onError) {
    var url = Uri.parse("${_URL_SERVER}/file/list");
    http
        .post(url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({"path": dir}))
        .then((response) {
      if (response.statusCode != 200) {
        onError.call(response.reasonPhrase != null
            ? response.reasonPhrase!
            : "Unknown error");
      } else {
        var body = response.body;
        debugPrint("Get download file list, body: $body");

        final map = jsonDecode(body);
        final httpResponseEntity = ResponseEntity.fromJson(map);

        if (httpResponseEntity.isSuccessful()) {
          final data = httpResponseEntity.data as List<dynamic>;

          onSuccess.call(data
              .map((e) => FileItem.fromJson(e as Map<String, dynamic>))
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

  void _clearSelectedFiles() {
    setState(() {
      List<FileNode> selectedFiles =
          DownloadFileManager.instance.selectedFiles();
      selectedFiles.clear();
      DownloadFileManager.instance.updateSelectedFiles(selectedFiles);

      updateBottomItemNum();
      _setDeleteBtnEnabled(false);
    });
  }

  void _setDeleteBtnEnabled(bool enable) {
    eventBus.fire(UpdateDeleteBtnStatus(enable, module: UIModule.Download));
  }

  bool _isControlDown() {
    return FileManagerPage.fileManagerKey.currentState?.isControlDown() == true;
  }

  bool _isShiftDown() {
    return FileManagerPage.fileManagerKey.currentState?.isShiftDown() == true;
  }

  void _addCtrlAPressedCallback(Function() callback) {
    FileManagerPage.fileManagerKey.currentState?.addCtrlAPressedCallback(callback);
  }

  void _removeCtrlAPressedCallback(Function() callback) {
    FileManagerPage.fileManagerKey.currentState?.removeCtrlAPressedCallback(callback);
  }

  void _setFileSelected(FileNode fileItem) {
    debugPrint("Shift key down status: ${_isShiftDown()}");
    debugPrint("Control key down status: ${_isControlDown()}");

    List<FileNode> allFiles = DownloadFileManager.instance.allFiles();
    List<FileNode> selectedFiles = DownloadFileManager.instance.selectedFiles();

    if (!_isContainsFile(selectedFiles, fileItem)) {
      if (_isControlDown()) {
        setState(() {
          selectedFiles.add(fileItem);
          DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
        });
      } else if (_isShiftDown()) {
        if (selectedFiles.length == 0) {
          setState(() {
            selectedFiles.add(fileItem);
            DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
          });
        } else if (selectedFiles.length == 1) {
          int index = allFiles.indexOf(selectedFiles[0]);

          int current = allFiles.indexOf(fileItem);

          if (current > index) {
            setState(() {
              selectedFiles = allFiles.sublist(index, current + 1);
            });
          } else {
            setState(() {
              selectedFiles = allFiles.sublist(current, index + 1);
            });
          }
        } else {
          int maxIndex = 0;
          int minIndex = 0;

          for (int i = 0; i < selectedFiles.length; i++) {
            FileNode current = selectedFiles[i];
            int index = allFiles.indexOf(current);
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

          int current = allFiles.indexOf(fileItem);

          if (current >= minIndex && current <= maxIndex) {
            setState(() {
              selectedFiles = allFiles.sublist(current, maxIndex + 1);
              DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
            });
          } else if (current < minIndex) {
            setState(() {
              selectedFiles = allFiles.sublist(current, maxIndex + 1);
              DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
            });
          } else if (current > maxIndex) {
            setState(() {
              selectedFiles = allFiles.sublist(minIndex, current + 1);
              DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
            });
          }
        }
      } else {
        setState(() {
          selectedFiles.clear();
          selectedFiles.add(fileItem);
          DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
        });
      }
    } else {
      debugPrint("It's already contains this image, id: ${fileItem.data.name}");

      if (_isControlDown()) {
        setState(() {
          selectedFiles.remove(fileItem);
          DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
        });
      } else if (_isShiftDown()) {
        setState(() {
          selectedFiles.remove(fileItem);
          DownloadFileManager.instance.updateSelectedFiles(selectedFiles);
        });
      }
    }

    _setDeleteBtnEnabled(selectedFiles.length > 0);
    updateBottomItemNum();
  }

  void rebuild() {
    setState(() {
      debugPrint("强制刷新页面");
    });
  }

  bool _isContainsFile(List<FileNode> files, FileNode current) {
    for (FileNode file in files) {
      if (file.data.folder == current.data.folder &&
          file.data.name == current.data.name) {
        return true;
      }
    }

    return false;
  }

  void updateFiles(List<FileItem> files) {}

  void updateSelectedFiles(List<FileItem> files) {}

  bool _isAudio(String extension) {
    if (extension.toLowerCase() == "mp3") return true;
    if (extension.toLowerCase() == "wav") return true;

    return false;
  }

  bool _isTextFile(String extension) {
    if (extension.toLowerCase() == "txt") return true;

    return false;
  }

  bool _isDoc(String extension) {
    if (_isAudio(extension)) return false;
    if (_isTextFile(extension)) return false;

    return true;
  }

  void updateBottomItemNum() {
    eventBus.fire(UpdateBottomItemNum(DownloadFileManager.instance.totalFileCount(),
        DownloadFileManager.instance.selectedFileCount(), module: UIModule.Download));
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void deactivate() {
    super.deactivate();

    _unRegisterEventBus();
    _removeCtrlAPressedCallback(_ctrlAPressedCallback);
    debugPrint("_DownloadIconModeState: deactivate, instance: $this");
  }

  @override
  void dispose() {
    super.dispose();
  }
}
