
import 'package:flutter/cupertino.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/model/RequestEntity.dart';
import 'package:mobile_assistant_client/model/ResponseEntity.dart';
import '../model/Device.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

abstract class DeviceConnectionManager {
  static final DeviceConnectionManager _instance = DeviceConnectionManagerImpl();

  static DeviceConnectionManager get instance {
    return _instance;
  }

  void connect(Device device);

  void disconnect();

  void onMessageReceived(Function(Map<String, dynamic> msg) callback);

  void sendToClient(RequestEntity requestEntity);

  void onConnectSuccess(Function(DeviceConnectionManager manager) callback);

  void onConnectFail(Function(DeviceConnectionManager manager, String? error) callback);

  void onDisconnected(Function(DeviceConnectionManager manager) callback);

  Device? currentClient();

  bool isConnected();
}

class DeviceConnectionManagerImpl implements DeviceConnectionManager {
  final _PORT = Constant.PORT_CONNECTION;
  Device? _currentClient;
  IOWebSocketChannel? _clientChannel;
  var _isConnected = false;

  Function(DeviceConnectionManager manager)? _onConnectSuccess;
  Function(DeviceConnectionManager manager, String error)? _onConnectFail;
  Function(DeviceConnectionManager manager)? _onDisconnected;

  final _onMessageCallbacks = <Function(Map<String, dynamic> msg)>[];

  @override
  void connect(Device device) {
    if (_isConnected) {
      debugPrint("It's connected.");
      return;
    }

    try {
      _clientChannel =
          IOWebSocketChannel.connect(Uri.parse("ws://${device.ip}:$_PORT"));
      _clientChannel?.stream.listen(
          (dynamic message) {
            if (message is String) {
              Map<String, dynamic> map = jsonDecode(message);

              for (var onMessageCallback in _onMessageCallbacks) {
                onMessageCallback.call(map);
              }
            } else {
              debugPrint("Wrong message type");
            }
          },
          // Ws channel close.
          onDone: () {
            _onDisconnected?.call(this);
          },

          onError: (error) {
            debugPrint("Ws error: $error");
          }
      );
      _currentClient = device;
      _isConnected = true;
      _onConnectSuccess?.call(this);
    } on Exception {
    } catch(e) {
      debugPrint("Connection to ${device.ip} fail, error: ${e}");
      _onConnectFail?.call(this, "$e");
    }
  }

  @override
  void disconnect() {
    _clientChannel?.sink.close();
    _isConnected = false;
    _onDisconnected?.call(this);
  }

  @override
  void onMessageReceived(Function(Map<String, dynamic> msg) callback) {
    _onMessageCallbacks.add(callback);
  }

  @override
  void sendToClient(RequestEntity requestEntity) {
    String json = jsonEncode(requestEntity);
    _clientChannel?.sink.add(json);
  }

  @override
  void onDisconnected(Function(DeviceConnectionManager manager) callback) {
    _onDisconnected = callback;
  }

  @override
  Device? currentClient() {
    return _currentClient;
  }

  @override
  void onConnectSuccess(Function(DeviceConnectionManager manager) callback) {
    _onConnectSuccess = callback;
  }

  @override
  void onConnectFail(Function(DeviceConnectionManager manager, String? error) callback) {
    _onConnectFail = callback;
  }

  @override
  bool isConnected() {
    return _isConnected;
  }
}