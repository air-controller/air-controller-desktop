// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_contacts_request_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteContactsRequestEntity _$DeleteContactsRequestEntityFromJson(
        Map<String, dynamic> json) =>
    DeleteContactsRequestEntity(
      (json['ids'] as List<dynamic>).map((e) => e as int).toList(),
    );

Map<String, dynamic> _$DeleteContactsRequestEntityToJson(
        DeleteContactsRequestEntity instance) =>
    <String, dynamic>{
      'ids': instance.ids,
    };
