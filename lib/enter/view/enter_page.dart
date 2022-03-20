import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_assistant_client/enter/bloc/enter_bloc.dart';
import 'package:mobile_assistant_client/home/view/home_page.dart';
import 'package:mobile_assistant_client/network/heartbeat_client.dart';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../constant.dart';
import '../../event/exit_cmd_service.dart';
import '../../event/exit_heartbeat_service.dart';
import '../../event/update_mobile_info.dart';
import '../../connection_disconnected/connection_disconnected_page.dart';
import '../../model/Device.dart';
import '../../model/cmd.dart';
import '../../model/mobile_info.dart';
import '../../network/cmd_client.dart';
import '../../network/device_connection_manager.dart';
import '../../network/device_discover_manager.dart';
import '../../util/event_bus.dart';
import '../../widget/multiple_rings.dart';
import '../../widget/upward_triangle.dart';
import '../../l10n/l10n.dart';

class EnterPage extends StatefulWidget {
  const EnterPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EnterState();
  }
}

class _EnterState extends State<EnterPage> with SingleTickerProviderStateMixin implements HeartbeatListener {
  static final _ICON_SIZE = 80.0;

  AnimationController? _animationController;
  bool _isConnectPressed = false;

  // 记录上一次设备显示坐标位置（Key为设备IP）
  Map<String, Rect> _deviceRectMap = Map();

  NeatPeriodicTaskScheduler? _refreshDeviceScheduler;

  HeartbeatClient? _heartbeatClient = null;
  CmdClient? _cmdClient = null;

  StreamSubscription<ConnectivityResult>? _networkConnectivitySubscription = null;
  StreamSubscription<ExitHeartbeatService>? _exitHeartbeatServiceStream;
  StreamSubscription<ExitCmdService>? _exitCmdServiceStream;

  @override
  void initState() {
    super.initState();

    _registerEventBus();

    _networkConnectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
          log("_isNetworkConnected: ${_isNetworkConnected(result)}");
      if (_isNetworkConnected(result)) {
        final info = NetworkInfo();
        String? networkName = "";

        try {
          networkName = await info.getWifiName();
        } catch (e) {
          log("info.getWifiName() throw error: $e");
        }
        context.read<EnterBloc>().add(EnterNetworkChanged(true, networkName));

        _startSearchDevices();

        _startRefreshDeviceScheduler();
      } else {
        context.read<EnterBloc>().add(EnterNetworkChanged(false, null));
      }
    });

    Connectivity().checkConnectivity().then((result) async {
      log("Initial network check: ${_isNetworkConnected(result)}");
      if (_isNetworkConnected(result)) {
        final info = NetworkInfo();
        String? networkName = "";

        try {
          networkName = await info.getWifiName();
        } catch (e) {
          log("info.getWifiName() throw error: $e");
        }
        context.read<EnterBloc>().add(EnterNetworkChanged(true, networkName));
      } else {
        context.read<EnterBloc>().add(EnterNetworkChanged(false, null));
      }
    }).catchError((error) {
      log("Initial network check error: $error");
    });
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
    _heartbeatClient?.quit();
    _heartbeatClient = null;
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

  void _startSearchDevices() {
    log("Device discover service start...");

    DeviceDiscoverManager.instance.onDeviceFind((device) {
      List<Device> devices = context.read<EnterBloc>().state.devices;
      if (!devices.contains(device)) {
        log("Find new device, ip: ${device.ip}");

        context.read<EnterBloc>().add(EnterFindMobile(device));
      }
    });
    DeviceDiscoverManager.instance.startDiscover();
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
    context.read<EnterBloc>().add(EnterClearFindMobiles());
  }

  @override
  Widget build(BuildContext context) {
    final isNetworkConnected = context.select((EnterBloc bloc) => bloc.state.isNetworkConnected);

    return BlocListener<EnterBloc, EnterState>(
      listener: (context, state) {
        if (state.isNetworkConnected) {
          _animationController?.repeat();
        } else {
          _animationController?.stop();
        }
      },
      child: isNetworkConnected ? _createWifiOnWidget() : _createWifiOffWidget(),
    );
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
                      width: _ICON_SIZE, height: _ICON_SIZE),
                  Container(
                    child: Text(context.l10n.tipConnectToNetworkFirst,
                        style: TextStyle(
                            color: Color(0xff5b5c61),
                            fontSize: 25,
                            decoration: TextDecoration.none)),
                    margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                  ),
                  Container(
                    child: Text(
                      context.l10n.tipConnectToNetworkDesc,
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
    final devices = context.select((EnterBloc bloc) => bloc.state.devices);
    final networkName = context.select((EnterBloc bloc) => bloc.state.networkName);

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    double radarRadius = width;

    if (height > width) {
      radarRadius = height;
    }

    double marginTop = height / 2 + _ICON_SIZE / 2 + 10;

    if (null == _animationController) {
      _animationController = AnimationController(
          vsync: this, duration: Duration(milliseconds: 4500)
      );

      Future.delayed(Duration.zero, () {
        _animationController?.repeat();
      });
    }

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
                    width: _ICON_SIZE, height: _ICON_SIZE),
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
                        Text(context.l10n.currentNetworkLabel,
                            style: TextStyle(
                                color: Color(0xff5b5c61),
                                fontSize: 16,
                                decoration: TextDecoration.none)),
                        Text("${networkName}",
                            style: TextStyle(
                                color: Color(0xff5b5c61),
                                fontSize: 16,
                                decoration: TextDecoration.none))
                      ]),
                      margin: EdgeInsets.fromLTRB(0, marginTop, 0, 0),
                    ),
                    Container(
                        child: Text(context.l10n.tipConnectToSameNetwork.replaceFirst("%s", "${Constant.APP_NAME}"),
                          style: TextStyle(
                              color: Color(0xffa1a1a1),
                              fontSize: 16,
                              decoration: TextDecoration.none),
                          textAlign: TextAlign.center,
                        ),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Wrap(
                    children: [
                      Text(context.l10n.tipInstallMobileApp01.replaceFirst("%s", "${Constant.APP_NAME}"),
                          style: TextStyle(
                              color: Color(0xff949494),
                              fontSize: 16,
                              decoration: TextDecoration.none)),

                      Container(
                        child: Listener(
                          child: Text(context.l10n.tipInstallMobileApp02,
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

                      Text(context.l10n.tipInstallMobileApp03,
                          style: TextStyle(
                              color: Color(0xff949494),
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
          children: List.generate(devices.length, (index) {
            Device device = devices[index];

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

                if (left > (width / 2 - _ICON_SIZE / 2 - 100) && left < (width / 2 + _ICON_SIZE / 2 + 100)) {
                  return false;
                }

                return true;
              }

              bool isValidTop(double top) {
                if (top < offset.dy) return false;
                if (top > height - offset.dy) return false;

                if (top > (height / 2 - _ICON_SIZE / 2 - 100)
                    && top < (height / 2 + _ICON_SIZE / 2 + 100)) {
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
                              context.l10n.connect,
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
                        if (devices.isEmpty) return;

                        final device = devices[index];

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

                        if (null == _heartbeatClient) {
                          _heartbeatClient = HeartbeatClient.create(device.ip, Constant.PORT_HEARTBEAT);
                        }
                        
                        _heartbeatClient?.addListener(this);

                        _heartbeatClient!.connectToServer();

                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return HomePage();
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

  void _pushToErrorPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ConnectionDisconnectedPage();
    }));
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

  double _randomDouble(double start, double end) {
    final random = Random();
    return random.nextDouble() * (end - start) + start;
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
                              context.l10n.scanToDownloadApk,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
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
                        color: Colors.white,
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

  @override
  void dispose() {
    super.dispose();
    _networkConnectivitySubscription?.cancel();
    _refreshDeviceScheduler?.stop();

    _unRegisterEventBus();
  }

  @override
  void onConnected() {
    log("Heartbeat client connected!");
  }

  @override
  void onDisconnected() {
    log("Heartbeat client disconnected!");
  }

  @override
  void onRequestTimeout() {
    log("Heartbeat client single timeout!");
  }

  @override
  void onRetryTimeout() {
    log("Heartbeat client onRetryTimeout!");

    _pushToErrorPage();
  }

  @override
  void onDone(bool isQuit) {
    log("Heartbeat client onDone!");

    if (!isQuit) {
      _pushToErrorPage();
    }
  }

  @override
  void onError(String error) {
    log("Heartbeat client onError!");

    _pushToErrorPage();
  }
}