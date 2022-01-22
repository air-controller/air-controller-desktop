import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/event/update_mobile_info.dart';
import 'package:mobile_assistant_client/home/connection_disconnected_page.dart';
import 'package:mobile_assistant_client/home/file_manager.dart';
import 'package:mobile_assistant_client/model/Device.dart';
import 'package:mobile_assistant_client/model/cmd.dart';
import 'package:mobile_assistant_client/model/mobile_info.dart';
import 'package:mobile_assistant_client/network/cmd_client.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/network/device_discover_manager.dart';
import 'package:mobile_assistant_client/network/heartbeat_service.dart';
import 'package:mobile_assistant_client/util/event_bus.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:window_size/window_size.dart';
import 'ext/string-ext.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'network/device_discover_manager.dart';
import 'dart:math';
import 'package:neat_periodic_task/neat_periodic_task.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(Size(1036, 687));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: !Constant.HIDE_DEBUG_MARK,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xffe0e0e0)
        ),
        fontFamily: 'NotoSansSC'
      ),
      home: MyHomePage(title: '手机助手PC端'),
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key) {}

  final String title;

  @override
  State createState() => _WifiState();
}

class _WifiState extends State<MyHomePage> {
  var _iconSize = 80.0;
  var _isWifiOn = false;
  var subscription = null;
  String? _wifiName = "Unknown-ssid";

  final _devices = <Device>[];
  NeatPeriodicTaskScheduler? _refreshDeviceScheduler;
  // 记录上一次设备显示坐标位置（Key为设备IP）
  Map<String, Rect> _deviceRectMap = Map();

  @override
  void initState() {
    super.initState();

    initWifiState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (_isNetworkConnected(result)) {
        debugPrint("Network connected");
        updateNetworkStatus(true);
        // Wifi已连接的情况下，开启设备搜索
        _startSearchDevices();
      } else {
        debugPrint("Network disconnected");
        updateNetworkStatus(false);
      }
    });
    _startRefreshDeviceScheduler();
  }
  
  bool _isNetworkConnected(ConnectivityResult result) {
    return result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet;
  }

  void _startRefreshDeviceScheduler() {
    if (null == _refreshDeviceScheduler) {
      _refreshDeviceScheduler = NeatPeriodicTaskScheduler(
        interval: Duration(seconds: 3),
        name: 'refreshDeviceScheduler',
        timeout: Duration(seconds: 5),
        task: () async => _refreshDevices(),
        minCycle: Duration(seconds: 1),
      );
      _refreshDeviceScheduler?.start();
    }
  }

  void _refreshDevices() {
    setState(() {
      _devices.clear();
    });
  }

  void _stopRefreshDeviceScheduler() async {
    await _refreshDeviceScheduler?.stop();
  }

  void initWifiState() async {
    final result = await Connectivity().checkConnectivity();
    if (_isNetworkConnected(result)) {
      updateNetworkStatus(true);
      // 已连接的情况下，开启设备搜索
      _startSearchDevices();
    } else {
      updateNetworkStatus(false);
    }
  }

  void _startSearchDevices() {
    debugPrint("Device discover service start...");
    DeviceDiscoverManager.instance.onDeviceFind((device) {
      if (!_devices.contains(device)) {
        debugPrint("Find new device, ip: ${device.ip}");
        setState(() {
          _devices.add(device);
        });
      }
    });
    DeviceDiscoverManager.instance.startDiscover();
  }

  Future<void> updateNetworkStatus(bool isConnected) async {
    final info = NetworkInfo();
    _wifiName = await info.getWifiName();

    setState(() {
      _isWifiOn = isConnected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isWifiOn ? _createWifiOnWidget() : _createWifiOffWidget();
  }

  Widget _createWifiOffWidget() {
    return Container(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Wrap(
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset("icons/intro_nonetwork.png",
                      width: _iconSize, height: _iconSize),
                  Container(
                    child: Text("请先将脑连接至网络",
                        style: TextStyle(
                            color: Color(0xff5b5c61),
                            fontSize: 25,
                            decoration: TextDecoration.none)),
                    margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                  ),
                  Container(
                      child: Text(
                        "为确保应用正常工作，请确保手机与电脑连接至同一网络",
                      style: TextStyle(
                            color: Color(0xffa1a1a1),
                            fontSize: 16,
                            decoration: TextDecoration.none),
                      ),
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  ),
                ],
              )
            )
          ],
        ),
        color: Colors.white,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _createWifiOnWidget() {
    return Stack(children: [
      Container(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Image.asset("icons/intro_radar.png",
                        width: _iconSize, height: _iconSize),
                    Container(
                      child:
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text("当前网络：",
                            style: TextStyle(
                                color: "#5b5c61".toColor(),
                                fontSize: 16,
                                decoration: TextDecoration.none)),
                        Text("${_wifiName}",
                            style: TextStyle(
                                color: "#5b5c61".toColor(),
                                fontSize: 16,
                                decoration: TextDecoration.none))
                      ]),
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    ),
                    Container(
                        child: Text(
                          "请确保手机与电脑处于同一网络，并在手机端保持${Constant.APP_NAME}应用打开",
                          style: TextStyle(
                              color: "#a1a1a1".toColor(),
                              fontSize: 16,
                              decoration: TextDecoration.none,
                              inherit: false),
                          textAlign: TextAlign.center,
                        ),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0))
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Text("如手机上尚未安装${Constant.APP_NAME}应用，请扫描二维码下载。",
                      style: TextStyle(
                          color: "#949494".toColor(),
                          fontSize: 16,
                          decoration: TextDecoration.none)),
                  margin: EdgeInsets.only(bottom: 10),
                ),
              )
            ],
          ),
           width: double.infinity,
          height: double.infinity,
          color: Colors.white),
      Stack(
          children: List.generate(_devices.length, (index) {
            Device device = _devices[index];

            debugPrint("List.generate => Device ip: ${device.ip}");

            Rect? rect = _deviceRectMap[device.ip];

            double left = 0;
            double top = 0;

            if (null == rect) {
              var width = MediaQuery
                  .of(context)
                  .size
                  .width - 80;
              var height = MediaQuery
                  .of(context)
                  .size
                  .height - 30;

              left = _randomDouble(0, width);
              top = _randomDouble(0, height);

              _deviceRectMap[device.ip] = Rect.fromLTRB(left, top, 0, 0);
            } else {
              left = rect.left;
              top = rect.top;
            }
        return Positioned(
            child: ElevatedButton(onPressed: () {
              final device = _devices[index];

              DeviceConnectionManager.instance.currentDevice = device;
              CmdClient.getInstance().connect(device.ip);
              CmdClient.getInstance().onCmdReceive((data) {
                debugPrint("onCmdReceive, cmd: ${data.cmd}, data: ${data.data}");
                _processCmd(data);
              });
              CmdClient.getInstance().onConnected(() {
                debugPrint("onConnected, ip: ${device.ip}");
              });
              CmdClient.getInstance().onDisconnected(() {
                debugPrint("onDisconnected, ip: ${device.ip}");
              });

              HeartbeatService.instance.connectToServer(device.ip);

              HeartbeatService.instance.onHeartbeatInterrupt(() {
                debugPrint("HeartbeatService, onHeartbeatInterrupt");
                _pushToErrorPage();
              });

              HeartbeatService.instance.onHeartbeatTimeout(() {
                debugPrint("HeartbeatService, onHeartbeatTimeout");
                _pushToErrorPage();
              });

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FileManagerPage(key: FileManagerPage.fileManagerKey);
              }));
            }, child: Text(_devices[index].name)), left: left, top: top, width: 80, height: 30);
      }))
    ]);
  }

  void _pushToErrorPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ConnectionDisconnectedPage();
    }));
  }

  double _randomDouble(double start, double end) {
    final random = Random();
    return random.nextDouble() * (end - start) + start;
  }

  void _processCmd(Cmd<dynamic> cmd) {
    if (cmd.cmd == Cmd.CMD_UPDATE_MOBILE_INFO) {
      MobileInfo mobileInfo = MobileInfo.fromJson(cmd.data);
      UpdateMobileInfo updateMobileInfo = UpdateMobileInfo(mobileInfo);
      eventBus.fire(updateMobileInfo);

      debugPrint("BatteryLevel: ${mobileInfo.batteryLevel}, totalSize: ${mobileInfo.storageSize.totalSize}, "
          "availableSize: ${mobileInfo.storageSize.availableSize}");
    }
  }

  @override
  void dispose() {
    super.dispose();

    subscription?.cancel();
    _stopRefreshDeviceScheduler();
  }
}
