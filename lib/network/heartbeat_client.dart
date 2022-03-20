import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:mobile_assistant_client/model/heartbeat.dart';
import 'package:mobile_assistant_client/util/count_down_timer.dart';
import 'package:network_info_plus/network_info_plus.dart';

abstract class HeartbeatClient {
  void connectToServer();

  void disconnectToServer();

  void addListener(HeartbeatListener listener);

  void quit();

  static HeartbeatClient create(String ip, int port) {
    return HeartbeatClientImpl(ip, port);
  }
}

abstract class HeartbeatListener {
  void onConnected();

  void onDisconnected();

  void onRequestTimeout();

  void onRetryTimeout();

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
  bool isConnected = false;
  Socket? _socket;
  bool retry = true;
  final RETRY_TIMES = 3;
  final TIMEOUT_IN_MILLS = 3000;
  final RETRY_TIMEOUT_IN_MILLS = 10000;
  Heartbeat? _lastHeartbeat;
  Heartbeat? _lastHeartbeatResponse;
  int _retryCount = 0;
  CountDownTimer? _timeoutTimer;
  CountDownTimer? _retryTimeoutTimer;
  bool _isRetryTimerStarted = false;
  StreamSubscription<Uint8List>? _socketSubscription;
  bool _isQuit = false;

  HeartbeatClientImpl(this.ip, this.port);

  @override
  void connectToServer() async {
    try {
      _socket = await Socket.connect(ip, port);
    } catch (e) {
      log("connectToServer: ${e.toString()}");
      listeners.forEach((listener) { listener.onError(e.toString()); });
    }

    isConnected = true;

    listeners.forEach((listener) {
      listener.onConnected();
    });

    NetworkInfo networkInfo = NetworkInfo();
    String currentIp = await networkInfo.getWifiIP() ?? "Unknown ip";
    _lastHeartbeat = Heartbeat(currentIp, 0, _currentTimeInMills());
    _sendToServer(_lastHeartbeat!);

    _startTimeoutTimer();

    if (null != _socketSubscription) {
      _socketSubscription?.cancel();
    }

    _socketSubscription = _socket?.listen((data) {
      _stopTimeoutTimer();

      String str = String.fromCharCodes(data);

      dynamic map = jsonDecode(str);
      _lastHeartbeatResponse = Heartbeat.fromJson(map);

      log("Heartbeat response, value: ${_lastHeartbeatResponse?.value}");

      int currentTimeInMills = _currentTimeInMills();

      if (null != _lastHeartbeat &&
          currentTimeInMills - _lastHeartbeat!.time > TIMEOUT_IN_MILLS) {
        listeners.forEach((listener) {
          listener.onRequestTimeout();
        });
        log("Hit single timeout!");
      }

      Heartbeat heartbeat = Heartbeat(
          currentIp, _lastHeartbeatResponse!.value + 1, currentTimeInMills);
      _lastHeartbeat = heartbeat;

      Future.delayed(Duration(seconds: 2), () {
        _sendToServer(_lastHeartbeat!);
        _startTimeoutTimer();
      });
    }, onError: (error) {
      listeners.forEach((listener) {
        listener.onError(error.toString());
      });
    }, onDone: () {
      listeners.forEach((listener) {
        listener.onDone(_isQuit);
      });
    }, cancelOnError: true);
  }

  void _startTimeoutTimer() {
    _timeoutTimer = CountDownTimer(TIMEOUT_IN_MILLS, 1000);
    _timeoutTimer?.onFinish(() {
      listeners.forEach((listener) {
        listener.onRequestTimeout();
      });
      log("Start retry heartbeat!");
      _retryHeartbeat();
    });
    _timeoutTimer?.start();
  }

  void _stopTimeoutTimer() {
    _timeoutTimer?.cancel();
  }

  void _retryHeartbeat() async {
    if (!_isRetryTimerStarted) {
      _startRetryTimer();
    }

    if (_retryCount <= RETRY_TIMES) {
      NetworkInfo networkInfo = NetworkInfo();
      String currentIp = await networkInfo.getWifiIP() ?? "Unknown ip";
      Heartbeat heartbeat = Heartbeat(currentIp, 0, _currentTimeInMills());

      if (null != _lastHeartbeat) {
        heartbeat =
            Heartbeat(ip, _lastHeartbeat!.value + 1, _currentTimeInMills());
      }

      _sendToServer(heartbeat);

      _stopTimeoutTimer();
      _startTimeoutTimer();
      _retryCount++;
    } else {
      _stopRetryTimer();
    }
  }

  void _startRetryTimer() {
    _retryTimeoutTimer = CountDownTimer(RETRY_TIMEOUT_IN_MILLS, 1000);

    _retryTimeoutTimer?.onTick((millisUntilFinished) {
      log("_startRetryTimer, millisUntilFinished: $millisUntilFinished");
    });

    _retryTimeoutTimer?.onFinish(() {
      listeners.forEach((listener) {
        listener.onRetryTimeout();
      });
      log("Hit retry timeout!");
    });
    _retryTimeoutTimer?.start();
    _isRetryTimerStarted = true;
  }

  void _stopRetryTimer() {
    _retryTimeoutTimer?.cancel();
    _isRetryTimerStarted = false;
  }

  int _currentTimeInMills() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  void _sendToServer(Heartbeat heartbeat) async {
    String heartbeatStr = jsonEncode(heartbeat);
    log("Heartbeat => _sendToServer, $heartbeatStr, socket: $_socket");
    _socket?.write(heartbeatStr);
    _socket?.flush();
  }

  @override
  void disconnectToServer() {
    if (isConnected) {
      _isQuit = true;
      _socket?.close();
      _socket = null;
      isConnected = false;

      listeners.forEach((listener) {
        listener.onDisconnected();
      });
    }
  }

  void quit() {
    disconnectToServer();
    _stopTimeoutTimer();
    _stopRetryTimer();
  }

  @override
  void addListener(HeartbeatListener listener) {
    listeners.add(listener);
  }
}
