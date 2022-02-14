import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:mobile_assistant_client/constant.dart';
import 'package:mobile_assistant_client/event/exit_cmd_service.dart';
import 'package:mobile_assistant_client/event/exit_heartbeat_service.dart';
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
import 'package:mobile_assistant_client/widget/multiple_rings.dart';
import 'package:mobile_assistant_client/widget/upward_triangle.dart';
import 'package:qr_flutter/qr_flutter.dart';
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

class _WifiState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  var _iconSize = 80.0;
  var _isWifiOn = false;
  var subscription = null;
  String? _wifiName = "Unknown-ssid";

  final _devices = <Device>[];
  NeatPeriodicTaskScheduler? _refreshDeviceScheduler;
  // 记录上一次设备显示坐标位置（Key为设备IP）
  Map<String, Rect> _deviceRectMap = Map();
  AnimationController? _animationController;

  // 标记连接按钮是否按下
  bool _isConnectPressed = false;
  
  HeartbeatService? _heartbeatService = null;
  CmdClient? _cmdClient = null;

  StreamSubscription<ExitHeartbeatService>? _exitHeartbeatServiceStream;
  StreamSubscription<ExitCmdService>? _exitCmdServiceStream;

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

    _animationController = AnimationController(
      vsync: this, duration: Duration(milliseconds: 4500)
    );

    Future.delayed(Duration.zero, () {
      _animationController?.repeat();
    });

    _registerEventBus();
  }

  void _registerEventBus() {
    _exitHeartbeatServiceStream = eventBus.on<ExitHeartbeatService>().listen((event) {
      _exitHeartbeatService();
    });

    _exitCmdServiceStream = eventBus.on<ExitCmdService>().listen((event) {
      _exitCmdService();
    });
  }

  void _exitHeartbeatService() {
    _heartbeatService?.cancel();
    _heartbeatService = null;
  }

  void _exitCmdService() {
    _cmdClient?.disconnect();
    _cmdClient = null;
  }

  void _unRegisterEventBus() {
    _exitHeartbeatServiceStream?.cancel();
    _exitCmdServiceStream?.cancel();
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
    try {
      _wifiName = await info.getWifiName();
    } catch (e) {
      debugPrint("info.getWifiName() throw error: $e");
    }

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
                  Image.asset("assets/icons/intro_nonetwork.png",
                      width: _iconSize, height: _iconSize),
                  Container(
                    child: Text("请先将电脑连接至网络",
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double radarRadius = width;

    if (height > width) {
      radarRadius = height;
    }

    double marginTop = height / 2 + _iconSize / 2 + 10;

    return Stack(children: [
      Container(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: ClipRect(
                  child: UnconstrainedBox(
                    child: RotationTransition(
                      turns: _animationController!,
                      child: ClipOval(
                        child: Container(
                          width: radarRadius * 1.5,
                          height: radarRadius * 1.5 ,
                          decoration: BoxDecoration(
                              gradient: SweepGradient(
                                  colors: [
                                    Color(0xfff8fbf4),
                                    Color(0xfffcfefb),
                                    Colors.white
                                  ]
                              )
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.center,
                child: Image.asset("assets/icons/intro_radar.png",
                    width: _iconSize, height: _iconSize),
              ),

              Align(
                alignment: Alignment.topCenter,
                child: Wrap(
                  direction: Axis.vertical,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
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
                      margin: EdgeInsets.fromLTRB(0, marginTop, 0, 0),
                    ),
                    Container(
                        child: Text(
                          "请确保手机与电脑处于同一网络，并在手机端保持${Constant.APP_NAME}应用打开",
                          style: TextStyle(
                              color: "#a1a1a1".toColor(),
                              fontSize: 16,
                              decoration: TextDecoration.none),
                          textAlign: TextAlign.center,
                        ),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0))
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Wrap(
                    children: [
                      Text("如手机上尚未安装${Constant.APP_NAME}应用，请",
                          style: TextStyle(
                              color: "#949494".toColor(),
                              fontSize: 16,
                              decoration: TextDecoration.none)),

                      Container(
                        child: Listener(
                          child: Text("扫描二维码",
                              style: TextStyle(
                                  color: Color(0xff2869d3),
                                  fontSize: 16,
                                  decoration: TextDecoration.underline)),
                          onPointerDown: (event) {
                            if (event.kind == PointerDeviceKind.mouse && event.buttons == kPrimaryMouseButton) {
                              debugPrint("Scan qr code for downloading apk file.");
                              _showApkQrCode(event.position);
                            }
                          },
                        ),
                        margin: EdgeInsets.only(left: 5, right: 5),
                      ),

                      Text("下载。",
                          style: TextStyle(
                              color: "#949494".toColor(),
                              fontSize: 16,
                              decoration: TextDecoration.none)),
                    ],
                  ),
                  margin: EdgeInsets.only(bottom: 10),
                ),
              ),

              IgnorePointer(
                child: MultipleRings(
                  width: width,
                  height: height,
                  minRadius: 100,
                  radiusStep: 100,
                  lineColor: Color(0xfff3f3f3),
                  color: Colors.transparent,
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
              var width = MediaQuery.of(context).size.width;
              var height = MediaQuery.of(context).size.height;

              Offset offset = Offset(150, 150);

              bool isValidLeftValue(double left) {
                if (left < offset.dx) return false;

                if (left > width - offset.dx) return false;

                if (left > (width / 2 - _iconSize / 2 - 100) && left < (width / 2 + _iconSize / 2 + 100)) {
                  return false;
                }

                return true;
              }

              bool isValidTop(double top) {
                if (top < offset.dy) return false;
                if (top > height - offset.dy) return false;

                if (top > (height / 2 - _iconSize / 2 - 100)
                && top < (height / 2 + _iconSize / 2 + 100)) {
                  return false;
                }

                return true;
              }

              while (!isValidLeftValue(left)) {
                left = _randomDouble(0, width);
              }

              while (!isValidTop(top)) {
                top = _randomDouble(0, height);
              }

              _deviceRectMap[device.ip] = Rect.fromLTRB(left, top, 0, 0);
            } else {
              left = rect.left;
              top = rect.top;
            }

            return Positioned(
                child: Column(
                  children: [
                    GestureDetector(
                      child: Container(
                        child: Wrap(
                          children: [
                            Text(
                              "连接",
                              style: TextStyle(
                                  color: _isConnectPressed ? Colors.white : Color(0xff949494),
                                  fontSize: 14
                              ),
                            ),
                            Container(
                              child: Image.asset("assets/icons/ic_right_arrow.png", width: 15, height: 15),
                              margin: EdgeInsets.only(left: 3),
                            )
                          ],
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                        ),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Color(0xffe5e5e5), width: 1.5),
                            color: _isConnectPressed ? Color(0xff6989e2) : Color(0xfffefefe),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xffe5e5e5),
                                  offset: Offset(0, 0),
                                  blurRadius: 1.0
                              )
                            ]
                        ),
                        padding: EdgeInsets.fromLTRB(14, 6, 10, 6),
                      ),
                      onTap: () {
                        if (_devices.isEmpty) return;

                          final device = _devices[index];

                          DeviceConnectionManager.instance.currentDevice = device;

                          if (null == _cmdClient) {
                            _cmdClient = CmdClient();
                          }

                          _cmdClient!.connect(device.ip);
                          _cmdClient!.onCmdReceive((data) {
                            debugPrint("onCmdReceive, cmd: ${data.cmd}, data: ${data.data}");
                            _processCmd(data);
                          });
                          _cmdClient!.onConnected(() {
                            debugPrint("onConnected, ip: ${device.ip}");
                            _reportDesktopInfo();
                          });
                          _cmdClient!.onDisconnected(() {
                            debugPrint("onDisconnected, ip: ${device.ip}");
                          });

                          if (null == _heartbeatService) {
                            _heartbeatService = HeartbeatService();
                          }

                          _heartbeatService!.connectToServer(device.ip);

                          _heartbeatService!.onHeartbeatInterrupt(() {
                            debugPrint("HeartbeatService, onHeartbeatInterrupt");
                            _pushToErrorPage();
                          });

                          _heartbeatService!.onHeartbeatTimeout(() {
                            debugPrint("HeartbeatService, onHeartbeatTimeout");
                            _pushToErrorPage();
                          });

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return FileManagerPage(key: FileManagerPage.fileManagerKey);
                          }));
                      },
                      onTapDown: (event) {
                        setState(() {
                          _isConnectPressed = true;
                        });
                      },
                      onTapCancel: () {
                        setState(() {
                          _isConnectPressed = false;
                        });
                      },
                      onTapUp: (event) {
                        setState(() {
                          _isConnectPressed = false;
                        });
                      },
                    ),

                    Container(
                      child: Image.asset("assets/icons/ic_mobile.png", width: 76 * 0.5, height: 134 * 0.5),
                      margin: EdgeInsets.only(top: 5),
                    ),

                    Text(
                      "${device.name}",
                      style: TextStyle(
                        color: Color(0xff313237),
                        fontSize: 14
                      ),
                    )
                  ],
                ), left: left, top: top);
      }))
    ]);
  }

  void _reportDesktopInfo() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    String deviceName = "";

    NetworkInfo networkInfo = NetworkInfo();
    String? ip = await networkInfo.getWifiIP() ?? "*.*.*.*";

    int platform = Device.PLATFORM_MACOS;

    if (Platform.isMacOS) {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      deviceName = macOsDeviceInfo.computerName;
    }

    if (Platform.isLinux) {
      LinuxDeviceInfo linuxDeviceInfo = await deviceInfo.linuxInfo;
      deviceName = linuxDeviceInfo.name;
      platform = Device.PLATFORM_LINUX;
    }

    if (Platform.isWindows) {
      WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;
      deviceName = windowsDeviceInfo.computerName;
      platform = Device.PLATFORM_WINDOWS;
    }

    Device device = Device(platform, deviceName, ip);

    Cmd<Device> cmd = Cmd(Cmd.CMD_REPORT_DESKTOP_INFO, device);

    _cmdClient?.sendToServer(cmd);
  }

  void _showApkQrCode(Offset offset) {
    double width = 160;
    double height = 170;
    double triangleWidth = 20;
    double triangleHeight = 12;

    double left = offset.dx - width / 2;
    double top = offset.dy - height - triangleHeight - 8;

    showDialog(context: context, builder: (context) {
      return Stack(
        children: [
          Positioned(
            left: left,
              top: top,
              child: Stack(
            children: [

              Container(
                child: Column(
                    children: [
                      Container(
                        child: Text(
                          "手机扫描下载App",
                          style: TextStyle(
                              color: Color(0xff848485)
                          ),
                        ),
                        margin: EdgeInsets.only(top: 5),
                      ),

                      QrImage(
                        data: "https://github.com/air-controller/air-controller-mobile/releases",
                        size: 130,
                      )
                    ]
                ),
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Color(0xffe7e7e8),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black54,
                        offset: Offset(0, 0),
                        blurRadius: 1),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Triangle(
                    key: Key("download_qr_code"),
                    width: triangleWidth,
                    height: triangleHeight,
                    isUpward: false,
                    color: Color(0xffe7e7e8),
                    dividerColor: Colors.black12,
                  ),
                  margin: EdgeInsets.only(top: 168, left: 70),
                ),
              ),
            ],
          )
          )
        ],
      );
    },
      barrierColor: Colors.transparent
    );
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
    _animationController?.dispose();

    _unRegisterEventBus();
  }
}
