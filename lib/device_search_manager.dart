
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'model/Device.dart';
import 'constant.dart';
import 'package:device_info_plus/device_info_plus.dart';

/**
 * 设备搜索管理接口，用于处理设备搜索逻辑。
 *
 * @author Scott Smith 2021/09/25 21:45
 */
abstract class DeviceSearchManager {

  void startSearch();

  void stopSearch();

  void onSearchStarted(void callback());

  /**
   * 发现设备时回调
   *
   * @param device 设备信息
   */
  void onDeviceFind(void callback(Device device));

  void onSearchError(void callback(String error));

  bool isStarted();
}

class DeviceSearchManagerImpl implements DeviceSearchManager {
  static const int _SEARCH_PORT = Constant.PORT_SEARCH;

  DeviceSearchManagerImpl() {
  }

  @override
  void startSearch() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, _SEARCH_PORT).then((RawDatagramSocket udpSocket) {
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((event) {
        Datagram? datagram = udpSocket.receive();
        if (null != datagram) {
          debugPrint("Received ${datagram.data}");

          Uint8List data = datagram.data;
          
          String dataStr = String.fromCharCodes(data);

          if (_isValidData(dataStr)) {
            debugPrint("Received str: ${dataStr}");
          } else {
            debugPrint("It's not valid data");
          }
        }
      });

      String ip = udpSocket.address.host;

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      deviceInfo.macOsInfo.then((macOS) {
        String name = macOS.computerName;
        String searchCmd = "${Constant.CMD_SEARCH_PREFIX}${Constant.RANDOM_STR_SEARCH}#${name}#${ip}";

        List<int> data = utf8.encode(searchCmd);
        udpSocket.send(data, InternetAddress("255.255.255.255"), _SEARCH_PORT);
      });
    });
  }

  bool _isValidData(String data) {
    return data.startsWith("${Constant.CMD_SEARCH_RES_PREFIX}${Constant.RANDOM_STR_SEARCH}");
  }

  @override
  void stopSearch() {
    // TODO: implement stopSearch
  }

  @override
  void onSearchStarted(void Function() callback) {
    // TODO: implement onSearchStarted
  }

  @override
  void onDeviceFind(void Function(Device device) callback) {
    // TODO: implement onDeviceFind
  }

  @override
  void onSearchError(void Function(String error) callback) {
    // TODO: implement onSearchError
  }

  @override
  bool isStarted() {
    // TODO: implement isStarted
    throw UnimplementedError();
  }
}