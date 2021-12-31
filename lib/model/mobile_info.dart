
import 'package:mobile_assistant_client/model/storage_size.dart';

class MobileInfo {
  int batteryLevel;
  StorageSize storageSize;

  MobileInfo(this.batteryLevel, this.storageSize);

  factory MobileInfo.fromJson(Map<String, dynamic> parsedJson) {
    return MobileInfo(
        parsedJson["batteryLevel"],
        StorageSize.fromJson(parsedJson["storageSize"])
    );
  }
}