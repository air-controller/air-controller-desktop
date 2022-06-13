// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_contact_request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewContactRequestEntity _$NewContactRequestEntityFromJson(
        Map<String, dynamic> json) =>
    NewContactRequestEntity(
      name: json['name'] as String,
      account: json['account'] == null
          ? null
          : Account.fromJson(json['account'] as Map<String, dynamic>),
      group: json['group'] == null
          ? null
          : ContactGroup.fromJson(json['group'] as Map<String, dynamic>),
      phones: (json['phones'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      emails: (json['emails'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      ims: (json['ims'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      relations: (json['relations'] as List<dynamic>?)
          ?.map((e) => ContactFieldValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$NewContactRequestEntityToJson(
        NewContactRequestEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'account': instance.account?.toJson(),
      'group': instance.group?.toJson(),
      'phones': instance.phones?.map((e) => e.toJson()).toList(),
      'emails': instance.emails?.map((e) => e.toJson()).toList(),
      'ims': instance.ims?.map((e) => e.toJson()).toList(),
      'addresses': instance.addresses?.map((e) => e.toJson()).toList(),
      'relations': instance.relations?.map((e) => e.toJson()).toList(),
      'note': instance.note,
    };
