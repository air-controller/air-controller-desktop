// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactName _$ContactNameFromJson(Map<String, dynamic> json) => ContactName(
      contactId: json['contactId'] as int,
      displayName: json['displayName'] as String?,
      givenName: json['givenName'] as String?,
      familyName: json['familyName'] as String?,
      isPrimary: json['isPrimary'] as bool,
      rawContactId: json['rawContactId'] as int,
    );

Map<String, dynamic> _$ContactNameToJson(ContactName instance) =>
    <String, dynamic>{
      'contactId': instance.contactId,
      'displayName': instance.displayName,
      'givenName': instance.givenName,
      'familyName': instance.familyName,
      'isPrimary': instance.isPrimary,
      'rawContactId': instance.rawContactId,
    };
