import 'package:json_annotation/json_annotation.dart';

part 'update_info.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateInfo {
  final UpdateUrls inland;
  final UpdateUrls overseas;

  UpdateInfo({required this.inland, required this.overseas});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$UpdateInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateInfoToJson(this);
}

@JsonSerializable()
class UpdateUrls {
  final String urlWindows;
  final String urlMac;
  final String urlLinux;
  final String urlAndroid;

  UpdateUrls(
      {required this.urlWindows,
      required this.urlMac,
      required this.urlLinux,
      required this.urlAndroid});

  factory UpdateUrls.fromJson(Map<String, dynamic> json) => 
      _$UpdateUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateUrlsToJson(this);
}
