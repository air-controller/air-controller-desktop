import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../bootstrap.dart';
import '../constant.dart';
import '../model/heartbeat.dart';
import '../util/count_down_timer.dart';

abstract class HeartbeatClient {
  Future<void> connectToServer();

  void addListener(HeartbeatListener listener);

  Future<void> quit();

  static HeartbeatClient create(String ip, int port) {
    return HeartbeatClientImpl(ip, port);
  }
}

abstract class HeartbeatListener {
  void onConnected();

  void onDisconnected();

  void onTimeOut();

  void onError(String error);

  /**
   * @param isQuit whether is quit by positively.
   */
  void onDone(bool isQuit);
}

class HeartbeatClientImpl extends HeartbeatClient {
  final String ip;
  final int port;
  final List<HeartbeatListener> listeners = [];
  final _timeOutInMills = 5000;

  Socket? _socket;
  bool _isConnected = false;
  bool _isQuit = false;

  Heartbeat? _lastHeartbeat;
  Heartbeat? _lastHeartbeatResponse;

  CountDownTimer? _timeoutTimer;

  StreamSubscription<Uint8List>? _socketSubscription;
  CancelableOperation? _cancelableOperation;

  HeartbeatClientImpl(this.ip, this.port);

  @override
  Future<void> connectToServer() async {
    try {
      _socket = await Socket.connect(ip, port);
    } catch (e) {
      _log("connectToServer: ${e.toString()}");
      listeners.forEach((listener) {
        listener.onError(e.toString());
      });
      return;
    }

    _isConnected = true;
    _isQuit = false;

    listeners.forEach((listener) {
      listener.onConnected();
    });

    NetworkInfo networkInfo = NetworkInfo();
    String currentIp = "Unknown ip";
    try {
      currentIp = await networkInfo.getWifiIP() ?? "Unknown ip";
    } catch (e) {
      _log("HeartClient: get wifi ip failure: ${e.toString()}");
    }
    _lastHeartbeat = Heartbeat(currentIp, 0, _currentTimeInMills());

    _sendToServer(_lastHeartbeat!);
    _startTimeoutTimer();

    _socketSubscription = _socket?.listen((data) {
      if (_isQuit) return;

      _stopTimeoutTimer();

      String str = String.fromCharCodes(data);

      dynamic map = jsonDecode(str);
      _lastHeartbeatResponse = Heartbeat.fromJson(map);

      _log("Heartbeat response, value: ${_lastHeartbeatResponse?.value}");

      int currentTimeInMills = _currentTimeInMills();

      if (null != _lastHeartbeat &&
          currentTimeInMills - _lastHeartbeat!.time > _timeOutInMills) {
        listeners.forEach((listener) {
          listener.onTimeOut();
        });

        _log("Hit single timeout!");
      }

      Heartbeat heartbeat = Heartbeat(
          currentIp, _lastHeartbeatResponse!.value + 1, currentTimeInMills);
      _lastHeartbeat = heartbeat;

      _cancelableOperation = CancelableOperation.fromFuture(
          Future.delayed(Duration(seconds: 2), () {
            if (_isQuit) {
              _log(
                  "Heartbeat: heartbeat service had quit, don't need start timeout timer again!");
              return;
            }
            _sendToServer(_lastHeartbeat!);
            _startTimeoutTimer();
          }), onCancel: () {
        logger.d("Heartbeat: cancel delay timer!");
      });
    }, onError: (error) {
      listeners.forEach((listener) {
        listener.onError(error.toString());
      });
      _isQuit = true;
      _recycle();
    }, onDone: () {
      listeners.forEach((listener) {
        listener.onDone(_isQuit);
      });
      _isQuit = true;
      _recycle();
    }, cancelOnError: true);
  }

  void _startTimeoutTimer() {
    if (_isQuit) {
      _log("Heartbeat: _startTimeoutTimer, heartbeat service had quit.");
      return;
    }
    _timeoutTimer = CountDownTimer(_timeOutInMills, 1000);
    _timeoutTimer?.onFinish(() {
      listeners.forEach((listener) {
        listener.onTimeOut();
      });
    });
    _timeoutTimer?.start();
  }

  void _stopTimeoutTimer() {
    _timeoutTimer?.cancel();
  }

  void _stopDelayTimer() {
    _cancelableOperation?.cancel();
  }

  int _currentTimeInMills() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void _sendToServer(Heartbeat heartbeat) async {
    if (_isQuit) {
      _log("Heartbeat: _sendToServer, heartbeat service had quit.");
      return;
    }

    String heartbeatStr = jsonEncode(heartbeat);
    _log("Heartbeat => _sendToServer, $heartbeatStr, socket: $_socket");

    _socket?.write(heartbeatStr);
    _socket?.flush();
  }

  void _log(String msg) {
    if (Constant.ENABLE_HEARTBEAT_LOG) {
      logger.d("HeartBeat: $msg");
    }
  }

  void _disconnectToServer() async {
    if (_isConnected) {
      await _socketSubscription?.cancel();
      await _socket?.close();
      _socket = null;
      _isConnected = false;

      listeners.forEach((listener) {
        listener.onDisconnected();
      });
      listeners.clear();
    }
  }

  Future<void> quit() async {
    _isQuit = true;

    _disconnectToServer();

    _stopTimeoutTimer();
    _stopDelayTimer();
  }

  @override
  void addListener(HeartbeatListener listener) {
    listeners.add(listener);
  }

  void _recycle() {
    _socketSubscription?.cancel();
    _socket = null;
    _stopTimeoutTimer();
    _stopDelayTimer();
  }
}
