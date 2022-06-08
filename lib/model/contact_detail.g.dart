// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDetail _$ContactDetailFromJson(Map<String, dynamic> json) =>
    ContactDetail(
      id: json['id'] as int,
      displayNamePrimary: json['displayNamePrimary'] as String?,
      accounts: (json['accounts'] as List<dynamic>?)
          ?.map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => ContactGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      phones: (json['phones'] as List<dynamic>?)
          ?.map((e) => Phone.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoUri: json['photoUri'] as String?,
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => ContactNote.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContactDetailToJson(ContactDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayNamePrimary': instance.displayNamePrimary,
      'accounts': instance.accounts,
      'groups': instance.groups,
      'phones': instance.phones,
      'photoUri': instance.photoUri,
      'notes': instance.notes,
    };
