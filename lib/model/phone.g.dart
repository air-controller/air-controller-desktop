// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Phone _$PhoneFromJson(Map<String, dynamic> json) => Phone(
      id: json['id'] as int,
      contactId: json['contactId'] as int,
      number: json['number'] as String?,
      normalizedNumber: json['normalizedNumber'] as String?,
      label: json['label'] as String?,
      isPrimary: json['isPrimary'] as bool,
    );

Map<String, dynamic> _$PhoneToJson(Phone instance) => <String, dynamic>{
      'id': instance.id,
      'contactId': instance.contactId,
      'number': instance.number,
      'normalizedNumber': instance.normalizedNumber,
      'label': instance.label,
      'isPrimary': instance.isPrimary,
    };
