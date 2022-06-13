// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_field_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactFieldValue _$ContactFieldValueFromJson(Map<String, dynamic> json) =>
    ContactFieldValue(
      id: json['id'] as int? ?? -1,
      type: json['type'] == null
          ? null
          : ContactDataType.fromJson(json['type'] as Map<String, dynamic>),
      value: json['value'] as String,
    );

Map<String, dynamic> _$ContactFieldValueToJson(ContactFieldValue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type?.toJson(),
      'value': instance.value,
    };
