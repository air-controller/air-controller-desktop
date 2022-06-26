import '../constant.dart';
import '../model/device.dart';

abstract class DeviceConnectionManager {
  static final DeviceConnectionManager _instance =
      DeviceConnectionManagerImpl();

  static DeviceConnectionManager get instance {
    return _instance;
  }

  DeviceConnectionManager._internal();

  Device? currentDevice;

  String get rootURL;
}

class DeviceConnectionManagerImpl implements DeviceConnectionManager {
  Device? currentDevice;

  @override
  String get rootURL => null == DeviceConnectionManager.instance.currentDevice
      ? ""
      : "http://${DeviceConnectionManager.instance.currentDevice?.ip}:${Constant.PORT_HTTP}";
}
