// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_basic_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactBasicInfo _$ContactBasicInfoFromJson(Map<String, dynamic> json) =>
    ContactBasicInfo(
      id: json['id'] as int,
      lookupKey: json['lookupKey'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUri: json['photoUri'] as String?,
      photoThumbnailUri: json['photoThumbnailUri'] as String?,
      displayNamePrimary: json['displayNamePrimary'] as String?,
    );

Map<String, dynamic> _$ContactBasicInfoToJson(ContactBasicInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lookupKey': instance.lookupKey,
      'phoneNumber': instance.phoneNumber,
      'photoUri': instance.photoUri,
      'photoThumbnailUri': instance.photoThumbnailUri,
      'displayNamePrimary': instance.displayNamePrimary,
    };
