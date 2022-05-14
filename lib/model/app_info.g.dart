// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppInfo _$AppInfoFromJson(Map<String, dynamic> json) => AppInfo(
      json['isSystemApp'] as bool,
      json['name'] as String,
      json['versionName'] as String,
      json['versionCode'] as int,
      json['packageName'] as String,
      json['size'] as int,
      json['enable'] as bool,
    );

Map<String, dynamic> _$AppInfoToJson(AppInfo instance) => <String, dynamic>{
      'isSystemApp': instance.isSystemApp,
      'name': instance.name,
      'versionName': instance.versionName,
      'versionCode': instance.versionCode,
      'packageName': instance.packageName,
      'size': instance.size,
      'enable': instance.enable,
    };
