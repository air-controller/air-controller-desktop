

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/device_search_manager.dart';

class DeviceSearch extends StatelessWidget {
  DeviceSearchManager _deviceSearchManager = DeviceSearchManagerImpl();

  DeviceSearch() : super();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "设备搜索",
      home: Scaffold(
        appBar: AppBar(
          title: const Text("搜索设备"),
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
              }, child: Text("返回")),
              ElevatedButton(onPressed: () {
                _deviceSearchManager.startSearch();
              }, child: Text("开始搜索"))
            ],
          )
        ),
      ),
    );
  }
}