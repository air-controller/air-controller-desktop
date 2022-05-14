import 'package:json_annotation/json_annotation.dart';

part 'app_info.g.dart';

@JsonSerializable()
class AppInfo {
  final bool isSystemApp;
  final String name;
  final String versionName;
  final int versionCode;
  final String packageName;
  final int size;
  final bool enable;

  const AppInfo(
      this.isSystemApp, this.name, this.versionName, this.versionCode, this.packageName, this.size, this.enable);

  factory AppInfo.fromJson(Map<String, dynamic> json) =>
      _$AppInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AppInfoToJson(this);

  @override
  bool operator ==(Object other) {
    if (other is AppInfo) {
      return other.packageName == this.packageName;
    }
    return super == other;
  }
}
