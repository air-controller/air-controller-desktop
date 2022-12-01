// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateInfo _$UpdateInfoFromJson(Map<String, dynamic> json) => UpdateInfo(
      inland: UpdateUrls.fromJson(json['inland'] as Map<String, dynamic>),
      overseas: UpdateUrls.fromJson(json['overseas'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateInfoToJson(UpdateInfo instance) =>
    <String, dynamic>{
      'inland': instance.inland.toJson(),
      'overseas': instance.overseas.toJson(),
    };

UpdateUrls _$UpdateUrlsFromJson(Map<String, dynamic> json) => UpdateUrls(
      urlWindows: json['urlWindows'] as String,
      urlMac: json['urlMac'] as String,
      urlLinux: json['urlLinux'] as String,
      urlAndroid: json['urlAndroid'] as String,
    );

Map<String, dynamic> _$UpdateUrlsToJson(UpdateUrls instance) =>
    <String, dynamic>{
      'urlWindows': instance.urlWindows,
      'urlMac': instance.urlMac,
      'urlLinux': instance.urlLinux,
      'urlAndroid': instance.urlAndroid,
    };
