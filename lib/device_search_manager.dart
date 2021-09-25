
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

abstract class DeviceSearchManager {

  void startSearch();

  void onSearchStarted();

  void onSearchCompleted();

  void onSearchError(String error);
}

class DeviceSearchManagerImpl implements DeviceSearchManager {

  DeviceSearchManagerImpl() {
  }

  @override
  void startSearch() {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 20000).then((RawDatagramSocket udpSocket) {
      udpSocket.broadcastEnabled = true;
      udpSocket.listen((event) {
        Datagram? datagram = udpSocket.receive();
        if (null != datagram) {
          debugPrint("Received ${datagram.data}");
        }
      });

      List<int> data = utf8.encode("TEST");
      udpSocket.send(data, InternetAddress("255.255.255.255"), 20000);
    });
  }

  @override
  void onSearchStarted() {
    // TODO: implement onSearchStarted
  }

  @override
  void onSearchError(String error) {
    // TODO: implement onSearchError
  }

  @override
  void onSearchCompleted() {
    // TODO: implement onSearchCompleted
  }
}