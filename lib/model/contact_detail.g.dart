// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDetail _$ContactDetailFromJson(Map<String, dynamic> json) =>
    ContactDetail(
      id: json['id'] as int,
      contactId: json['contactId'] as int,
      displayNamePrimary: json['displayNamePrimary'] as String?,
      accounts: (json['accounts'] as List<dynamic>?)
          ?.map((e) => Account.fromJson(e as Map<String, dynamic>))
          .toList(),
      groups: (json['groups'] as List<dynamic>?)
          ?.map((e) => ContactGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      phones: (json['phones'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      emails: (json['emails'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      ims: (json['ims'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      relations: (json['relations'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: json['note'] == null
          ? null
          : ContactNote.fromJson(json['note'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContactDetailToJson(ContactDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contactId': instance.contactId,
      'displayNamePrimary': instance.displayNamePrimary,
      'accounts': instance.accounts?.map((e) => e.toJson()).toList(),
      'groups': instance.groups?.map((e) => e.toJson()).toList(),
      'phones': instance.phones?.map((e) => e.toJson()).toList(),
      'emails': instance.emails?.map((e) => e.toJson()).toList(),
      'addresses': instance.addresses?.map((e) => e.toJson()).toList(),
      'ims': instance.ims?.map((e) => e.toJson()).toList(),
      'relations': instance.relations?.map((e) => e.toJson()).toList(),
      'note': instance.note?.toJson(),
    };
