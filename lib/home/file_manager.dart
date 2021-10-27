import 'package:flutter/material.dart';

class FileManagerWidget extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '文件管理页面',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FileManagerPage(title: '手机助手PC端'),
    );
  }
}

class FileManagerPage extends StatefulWidget {
  FileManagerPage({Key? key, required this.title}) : super(key: key) {}

  final String title;

  @override
  State createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManagerPage> {

  @override
  Widget build(BuildContext context) {
    return Text("Hello, File manager");
  }
}