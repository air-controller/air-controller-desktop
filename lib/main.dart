import 'package:flutter/material.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:window_size/window_size.dart';
import 'ext/string-ext.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setWindowMinSize(Size(800, 600));
  runApp(MyApp());
  // startServer();
}

void startServer() async {
  var handler = webSocketHandler((channel) {
    channel.stream.listen((message) {
      channel.sink.add("我已经收到了你的消息： $message，$channel");
      channel.sink.add("1111");
      channel.sink.add("2222");
    });

    channel.sink.add("Hello, MIX2S");
  });

  shelf_io.serve(handler, '192.168.0.201', 9527).then((server) {
    print('Serving at ws://${server.address.host}:${server.port}');

    print("响应: ${server.serverHeader}");
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '手机助手PC端'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key? key, required this.title}) : super(key: key) {
  
  }

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State createState() =>  _WifiState();
}

class _WifiState extends State<MyHomePage> {
  var _iconSize = 80.0;
  var _isWifiOn = false;
  var subscription = null;
  String? _wifiName = "Unknown-ssid";

  @override
  void initState() {
    super.initState();

    initWifiState();

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        debugPrint("Wifi已连接");
        updateWifiStatus(true);
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
    } else {
      debugPrint("Wifi已断开");
      updateWifiStatus(false);
    }
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
                    style: TextStyle(color: "#5b5c61".toColor(), fontSize: 25, decoration: TextDecoration.none, inherit: false))
              ]),
              margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
            ),
            Container(
                child: Text(
                  "要通过无线网络与手机建立链接，请确保电脑与手机连接至同一网络",
                  style: TextStyle(color: "#a1a1a1".toColor(), fontSize: 16, decoration: TextDecoration.none, inherit: false),
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0)),
          ],
        ),
        color: Colors.white);
  }

  Widget _createWifiOnWidget() {
    return Container(
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
                    style: TextStyle(color: "#5b5c61".toColor(), fontSize: 16, decoration: TextDecoration.none, inherit: false)),
                Text("${_wifiName}",
                    style: TextStyle(color: "#5b5c61".toColor(), fontSize: 16, decoration: TextDecoration.none, inherit: false))
              ]),
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
            ),
            Container(
                child: Text(
                  "请确保手机和电脑处理同一无线网络，并在手机端打开HandShaker应用",
                  style: TextStyle(color: "#a1a1a1".toColor(), fontSize: 16, decoration: TextDecoration.none, inherit: false),
                  textAlign: TextAlign.center,
                ),
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0)),
            Spacer(),
            Text("如手机上尚未安装HandShaker应用，请扫描二维码下载。",
                style: TextStyle(color: "#949494".toColor(), fontSize: 16, decoration: TextDecoration.none, inherit: false)),
            SizedBox(height: 20)
          ],
        ),
        color: Colors.white);
  }

  @override
  void dispose() {
    super.dispose();

    subscription?.cancel();
  }
}
