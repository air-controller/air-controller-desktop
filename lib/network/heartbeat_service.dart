
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mobile_assistant_client/model/heartbeat.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../constant.dart';

class HeartbeatService {
  Function()? _onHeartbeatInterrupt;
  Function()? _onHeartbeatTimeout;
  bool _isConnected = false;
  Socket? _socket;
  Function()? _onConnected;
  Function(String error)? _onError;
  Heartbeat? _lastHeartbeat;
  Heartbeat? _heartbeatResponse;
  Timer? _countdownTimer;
  bool _isTimerStarted = false;
  Timer? _delayTimer;

  static final HeartbeatService _instance = HeartbeatService._();

  static HeartbeatService get instance {
    return _instance;
  }

  // 心跳连接阈值（单位：秒）
  static final int _HEARTBEAT_THRESHOLD_VALUE = 5;
  // 剩余时间
  int _leftTime = _HEARTBEAT_THRESHOLD_VALUE;


  HeartbeatService._();

  void connectToServer(String ip) async {
    _reset();

    _socket = await Socket.connect(ip, Constant.PORT_HEARTBEAT);
    print('Connected to: ${_socket?.remoteAddress.address}:${_socket?.remotePort}');

    _isConnected = true;
    _onConnected?.call();

    _sendHeartbeatToServer(needDelay: false);

    _socket?.listen((Uint8List data) {
      _stopTimer();

      String str = String.fromCharCodes(data);

      debugPrint("HeartbeatService listen str: $str\n");
      dynamic map = jsonDecode(str);

      _heartbeatResponse = Heartbeat.fromJson(map);
      debugPrint("Heartbeat response, ip: ${_heartbeatResponse?.ip}, value: ${_heartbeatResponse?.value}, time: ${_heartbeatResponse?.time}");

      int timeInMillis = DateTime.now().millisecondsSinceEpoch;

      if (null != _lastHeartbeat) {
        debugPrint("Heartbeat delay time: ${(timeInMillis - _lastHeartbeat!.time) / 1000}s");
        if (timeInMillis - _lastHeartbeat!.time > _HEARTBEAT_THRESHOLD_VALUE * 1000) {
          _onHeartbeatTimeout?.call();
        }
      }

      _sendHeartbeatToServer(needDelay: true);
    }, onError: (error) {
      _onError?.call(error);
      _isConnected = false;
    }, onDone: () {
      debugPrint("HeartbeatService, onDone.");
      _onHeartbeatInterrupt?.call();
      _countdownTimer?.cancel();
      _delayTimer?.cancel();
    }, cancelOnError: true);
  }

  void _sendHeartbeatToServer({bool needDelay = false}) {
    _delayTimer = Timer(Duration(seconds: needDelay ? 1 : 0), () async {
      NetworkInfo networkInfo = NetworkInfo();
      String ip = await networkInfo.getWifiIP() ?? "Unknown ip";

      int timeInMillis = DateTime.now().millisecondsSinceEpoch;
      Heartbeat heartbeat = Heartbeat(ip, 0, timeInMillis);

      if (null != _lastHeartbeat) {
        heartbeat = Heartbeat(ip, _lastHeartbeat!.value + 1, timeInMillis);
      }

      String heartbeatStr = jsonEncode(heartbeat);

      json.decode(heartbeatStr);

      debugPrint("_sendHeartbeatToServer, heartbeatStr: $heartbeatStr");

      _socket?.write(heartbeatStr);
      _socket?.flush();

      _lastHeartbeat = heartbeat;

      _startTimer();
    });
  }

  void _startTimer() {
    if (null == _countdownTimer) {
      _leftTime = _HEARTBEAT_THRESHOLD_VALUE;

      const oneSec = Duration(seconds: 1);
      _countdownTimer = Timer.periodic(oneSec, (timer) {
        if (_leftTime == 0) {
          if (_noHeartbeatResponse()) {
            _countdownTimer?.cancel();
            _onHeartbeatInterrupt?.call();
          }
        } else {
          _leftTime --;
          debugPrint("_startTimer, leftTime: $_leftTime");
        }
      });
      _isTimerStarted = true;
    }
  }

  bool _noHeartbeatResponse() {
    if (null == _heartbeatResponse) return true;
    // 响应无效，认为没有心跳响应
    if (_heartbeatResponse?.value != _lastHeartbeat?.value) return true;

    return false;
  }

  void _reset() {
    if (_isTimerStarted) {
      _countdownTimer?.cancel();
      _countdownTimer = null;
      _isTimerStarted = false;
    }
    _leftTime = _HEARTBEAT_THRESHOLD_VALUE;

    _isConnected = false;
    _socket = null;
    _lastHeartbeat = null;
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _isTimerStarted = false;
    _leftTime = _HEARTBEAT_THRESHOLD_VALUE;
  }

  void _stopDelayTimer() {
    _delayTimer?.cancel();
    _delayTimer = null;
  }

  void cancel() {
    _isConnected = false;
    _stopTimer();
    _stopDelayTimer();
    _socket?.close();
    _socket = null;
  }

  void onHeartbeatTimeout(void callback()) {
    _onHeartbeatTimeout = callback;
  }

  void onHeartbeatInterrupt(void callback()) {
    _onHeartbeatInterrupt = callback;
  }

  bool isConnected() {
    return _isConnected;
  }
}