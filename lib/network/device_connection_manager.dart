import '../model/Device.dart';

abstract class DeviceConnectionManager {
  static final DeviceConnectionManager _instance = DeviceConnectionManagerImpl();

  static DeviceConnectionManager get instance {
    return _instance;
  }

  Device? currentDevice;
}

class DeviceConnectionManagerImpl implements DeviceConnectionManager {
  Device? currentDevice;
}