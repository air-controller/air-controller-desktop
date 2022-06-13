// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_basic_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactBasicInfo _$ContactBasicInfoFromJson(Map<String, dynamic> json) =>
    ContactBasicInfo(
      id: json['id'] as int,
      contactId: json['contactId'] as int,
      phoneNumber: json['phoneNumber'] as String,
      displayNamePrimary: json['displayNamePrimary'] as String?,
    );

Map<String, dynamic> _$ContactBasicInfoToJson(ContactBasicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contactId': instance.contactId,
      'phoneNumber': instance.phoneNumber,
      'displayNamePrimary': instance.displayNamePrimary,
    };
