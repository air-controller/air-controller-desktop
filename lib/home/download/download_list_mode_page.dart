

import 'package:flutter/cupertino.dart';
import 'package:mobile_assistant_client/model/FileItem.dart';

class DownloadListModePage extends StatefulWidget {
  _DownloadListModeState? state;

  @override
  State<StatefulWidget> createState() {
    state = _DownloadListModeState();
    return state!;
  }

  void updateFiles(List<FileItem> files) {
    state?.updateFiles(files);
  }
}

class _DownloadListModeState extends State<DownloadListModePage> {
  List<FileItem> _files = [];
  List<FileItem> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Text("列表模式-下载页面");
  }

  void updateFiles(List<FileItem> files) {
    setState(() {
      _files = files;
    });
  }
}