// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_data_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDataType _$ContactDataTypeFromJson(Map<String, dynamic> json) =>
    ContactDataType(
      json['value'] as int,
      json['typeLabel'] as String,
      json['isUserCustomType'] as bool,
      json['isSystemCustomType'] as bool,
    );

Map<String, dynamic> _$ContactDataTypeToJson(ContactDataType instance) =>
    <String, dynamic>{
      'value': instance.value,
      'typeLabel': instance.typeLabel,
      'isUserCustomType': instance.isUserCustomType,
      'isSystemCustomType': instance.isSystemCustomType,
    };
