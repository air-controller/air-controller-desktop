import 'dart:async';

import '../model/Device.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constant.dart';

abstract class DeviceDiscoverManager {
  static final DeviceDiscoverManager _instance = DeviceDiscoverManagerImpl();

  static DeviceDiscoverManager get instance {
    return _instance;
  }

  void startDiscover();

    void stopDiscover();

    void onDeviceFind(void callback(Device device));

    bool isDiscovering();
}

class DeviceDiscoverManagerImpl implements DeviceDiscoverManager {
  RawDatagramSocket? udpSocket;
  var _isDiscovering = false;

  @override
  void startDiscover() {
    if (_isDiscovering) {
      debugPrint("It's discovering, start discover is invalid!");
      return;
    }

    RawDatagramSocket.bind(InternetAddress.anyIPv4, Constant.PORT_SEARCH).then((udpSocket) {
      this.udpSocket = udpSocket;

      udpSocket.listen((event) {
        Datagram? datagram = udpSocket.receive();

        Uint8List? data = datagram?.data;

        if (null != data) {
          String str = String.fromCharCodes(data);
          debugPrint(str + ", ip: ${udpSocket.address.address}");
        }

        debugPrint("ip: ${udpSocket.address.address}");
      });

      debugPrint("Udp listen started, port: ${Constant.PORT_SEARCH}");
    }).catchError((error) {
      debugPrint("startDiscover error: $error");
    });
  }

  @override
  void stopDiscover() {
    udpSocket?.close();
    _isDiscovering = false;
  }

  @override
  void onDeviceFind(void Function(Device device) callback) {
    // TODO: implement onDeviceFind
  }

  @override
  bool isDiscovering() {
    return _isDiscovering;
  }
}