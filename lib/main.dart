import 'package:flutter/material.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/home/file_manager.dart';
import 'package:mobile_assistant_client/model/Device.dart';
import 'package:mobile_assistant_client/network/device_connection_manager.dart';
import 'package:mobile_assistant_client/network/device_discover_manager.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:window_size/window_size.dart';
import 'ext/string-ext.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'network/device_discover_manager.dart';
import 'dart:math';

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
      ),
      home: MyHomePage(title: '手机助手PC端'),
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

  var _randomLeft = 0;
  var _randomTop = 0;
  final _devices = <Device>[
    Device(1, "aaa", "192.168.1.1")
  ];

  @override
  void initState() {
    super.initState();

    initWifiState();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        debugPrint("Wifi已连接");
        updateWifiStatus(true);
        // Wifi已连接的情况下，开启设备搜索
        _startSearchDevices();
      } else {
        debugPrint("Wifi已断开");
        updateWifiStatus(false);
      }
    });
  }

  void initWifiState() async {
    final result = Connectivity().checkConnectivity();
    if (result == ConnectivityResult.wifi) {
      debugPrint("Wifi已连接");
      updateWifiStatus(true);
      // Wifi已连接的情况下，开启设备搜索
      _startSearchDevices();
    } else {
      debugPrint("Wifi已断开");
      updateWifiStatus(false);
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

  Future<void> updateWifiStatus(bool isConnected) async {
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
        padding: EdgeInsets.fromLTRB(
            0, MediaQuery.of(context).size.height / 2 - _iconSize / 2, 0, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("icons/intro_nonetwork.tiff",
                width: _iconSize, height: _iconSize),
            Container(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("请先连接到无线网络",
                    style: TextStyle(
                        color: "#5b5c61".toColor(),
                        fontSize: 25,
                        decoration: TextDecoration.none,
                        inherit: false))
              ]),
              margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
            ),
            Container(
                child: Text(
                  "要通过无线网络与手机建立链接，请确保电脑与手机连接至同一网络",
                  style: TextStyle(
                      color: "#a1a1a1".toColor(),
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      inherit: false),
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0)),
          ],
        ),
        color: Colors.white);
  }

  Widget _createWifiOnWidget() {
    return Stack(children: [
      Container(
          padding: EdgeInsets.fromLTRB(
              0, MediaQuery.of(context).size.height / 2 - _iconSize / 2, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("icons/intro_radar.tiff",
                  width: _iconSize, height: _iconSize),
              Container(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("当前网络：",
                      style: TextStyle(
                          color: "#5b5c61".toColor(),
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          inherit: false)),
                  Text("${_wifiName}",
                      style: TextStyle(
                          color: "#5b5c61".toColor(),
                          fontSize: 16,
                          decoration: TextDecoration.none,
                          inherit: false))
                ]),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              ),
              Container(
                  child: Text(
                    "请确保手机和电脑处理同一无线网络，并在手机端打开HandShaker应用",
                    style: TextStyle(
                        color: "#a1a1a1".toColor(),
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        inherit: false),
                    textAlign: TextAlign.center,
                  ),
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0)),
              Spacer(),
              Text("如手机上尚未安装HandShaker应用，请扫描二维码下载。",
                  style: TextStyle(
                      color: "#949494".toColor(),
                      fontSize: 16,
                      decoration: TextDecoration.none,
                      inherit: false)),
              SizedBox(height: 20)
            ],
          ),
          color: Colors.white),
      Stack(
          children: List.generate(_devices.length, (index) {
            var width = MediaQuery.of(context).size.width - 80;
            var height = MediaQuery.of(context).size.height - 30;

            final left = _randomDouble(0, width);
            final top = _randomDouble(0, height);
        return Positioned(
            child: ElevatedButton(onPressed: () {
              final device = _devices[index];

              DeviceConnectionManager.instance.onConnectSuccess((manager) {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FileManagerWidget();
                }));
              });

              DeviceConnectionManager.instance.connect(device);
            }, child: Text(_devices[index].name)), left: left, top: top, width: 80, height: 30);
      }))
    ]);
  }

  double _randomDouble(double start, double end) {
    final random = Random();
    return random.nextDouble() * (end - start) + start;
  }

  @override
  void dispose() {
    super.dispose();

    subscription?.cancel();
  }
}
