import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/model/cmd.dart';

class CmdClient {
  Socket? _socket;
  Function(Cmd<dynamic> data)? _onCmdReceive;
  Function()? _onConnected;
  Function()? _onDisconnected;
  Function(String error)? _onError;
  bool _isConnected = false;

  void connect(String ip) async {
    _socket = await Socket.connect(ip, Constant.PORT_CMD);
    print('Connected to: ${_socket?.remoteAddress.address}:${_socket?.remotePort}');

    _isConnected = true;
    _onConnected?.call();

    _socket?.listen((Uint8List data) {
      if (!_isConnected) return;

      String str = String.fromCharCodes(data);
      debugPrint("CmdClient listen str: $str\n");
      dynamic map = jsonDecode(str);
      Cmd<dynamic> cmd = Cmd.fromJson(map);

      _onCmdReceive?.call(cmd);
    }, onError: (error) {
      _onError?.call(error);
      _isConnected = false;
    }, onDone: () {
      debugPrint("CmdClient, onDone.");
      _isConnected = false;
    }, cancelOnError: true);
  }

  void onConnected(Function() callback) {
    _onConnected = callback;
  }

  void onDisconnected(Function() callback) {
    _onDisconnected = callback;
  }

  void onCmdReceive(Function(Cmd<dynamic> data) callback) {
    _onCmdReceive = callback;
  }

  void sendToServer(Cmd<dynamic> cmd) {
    String data = jsonEncode(cmd);
    debugPrint("CmdClient, sendToServer: $data");
    _socket?.write(data);
    _socket?.flush();
  }

  void sendStrToServer(String str) {
    _socket?.write(str);
    _socket?.flush();
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
    _isConnected = false;
    _onDisconnected?.call();
  }

  bool isConnected() {
    return _isConnected;
  }
}
