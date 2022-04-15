import 'dart:io';

class Device {
  String name;
  String ip;
  int platform;

  static const int PLATFORM_UNKNOWN = -1;
  static const int PLATFORM_ANDROID = 1;
  static const int PLATFORM_IOS = 2;
  static const int PLATFORM_MACOS = 3;
  static const int PLATFORM_LINUX = 4;
  static const int PLATFORM_WINDOWS = 5;

  Device(this.platform, this.name, this.ip);

  static int convertPlatform() {
    if (Platform.isAndroid) return PLATFORM_ANDROID;
    if (Platform.isIOS) return PLATFORM_IOS;
    if (Platform.isMacOS) return PLATFORM_MACOS;
    if (Platform.isLinux) return PLATFORM_LINUX;
    if (Platform.isWindows) return PLATFORM_WINDOWS;

    return PLATFORM_UNKNOWN;
  }

  factory Device.fromJson(Map<String, dynamic> parsedJson) {
    return Device(
        parsedJson["name"],
        parsedJson["ip"],
        parsedJson["platform"]
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "ip": ip,
    "platform": platform
  };

  @override
  bool operator ==(Object other) {
    // IP地址相同，就认为是同一台设备，暂时这样处理
    if (other is Device) {
      return other.ip == this.ip;
    }
    return super == other;
  }
}