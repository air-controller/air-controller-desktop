import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/event/update_bottom_item_num.dart';
import 'package:mobile_assistant_client/event/update_delete_btn_status.dart';
import 'package:mobile_assistant_client/home/download/download_file_manager.dart';
import 'package:mobile_assistant_client/model/FileItem.dart';
import 'package:mobile_assistant_client/model/FileNode.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';

import '../file_manager.dart';

class DownloadIconModePage extends StatefulWidget {
  late _DownloadIconModeState? state;

  @override
  State<StatefulWidget> createState() {
    state = _DownloadIconModeState();
    return state!;
  }

  void updateFiles(List<FileItem> files) {
    state?.updateFiles(files);
  }

  void setSelectedFiles(List<FileItem> files) {
    state?.updateSelectedFiles(files);
  }

  void rebuild() {
    state?.rebuild();
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

  @override
  void initState() {
    super.initState();

    _ctrlAPressedCallback = () {
      _setAllSelected();
      debugPrint("Ctrl + A pressed...");
    };

    _addCtrlAPressedCallback(_ctrlAPressedCallback);
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

    Widget content = Column(children: [
      Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("手机存储",
                style: TextStyle(
                    color: Color(0xff5b5c61), fontSize: 12.0, inherit: false)),
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
                        child:
                        Image.asset(fileTypeIcon, width: 100, height: 100),
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
                    ),
                    GestureDetector(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: 150),
                        child: Text(fileItem.data.name,
                              style: TextStyle(
                                  inherit: false,
                                  fontSize: 14,
                                  color:
                                  _isContainsFile(selectedFiles, fileItem)
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

  void _clearSelectedFiles() {
    setState(() {
      List<FileNode> selectedFiles = DownloadFileManager.instance.selectedFiles();
      selectedFiles.clear();
      DownloadFileManager.instance.updateSelectedFiles(selectedFiles);

      updateBottomItemNum();
      _setDeleteBtnEnabled(false);
    });
  }

  void _setDeleteBtnEnabled(bool enable) {
    eventBus.fire(UpdateDeleteBtnStatus(enable));
  }

  bool _isControlDown() {
    FileManagerPage? fileManagerPage =
        context.findAncestorWidgetOfExactType<FileManagerPage>();
    return fileManagerPage?.state?.isControlDown() == true;
  }

  bool _isShiftDown() {
    FileManagerPage? fileManagerPage =
        context.findAncestorWidgetOfExactType<FileManagerPage>();
    return fileManagerPage?.state?.isShiftDown() == true;
  }

  void _addCtrlAPressedCallback(Function() callback) {
    FileManagerPage? fileManagerPage =
        context.findAncestorWidgetOfExactType<FileManagerPage>();
    fileManagerPage?.state?.addCtrlAPressedCallback(callback);
  }

  void _removeCtrlAPressedCallback(Function() callback) {
    FileManagerPage? fileManagerPage =
        context.findAncestorWidgetOfExactType<FileManagerPage>();
    fileManagerPage?.state?.addCtrlAPressedCallback(callback);
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
      if (file.data.folder == current.data.folder && file.data.name == current.data.name) {
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
    List<FileNode> allFiles = DownloadFileManager.instance.allFiles();
    List<FileNode> selectedFiles = DownloadFileManager.instance.selectedFiles();

    eventBus.fire(UpdateBottomItemNum(allFiles.length, selectedFiles.length));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();

    _removeCtrlAPressedCallback(_ctrlAPressedCallback);
  }
}
