// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactGroup _$ContactGroupFromJson(Map<String, dynamic> json) => ContactGroup(
      id: json['id'] as int,
      title: json['title'] as String,
      count: json['count'] as int,
    );

Map<String, dynamic> _$ContactGroupToJson(ContactGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'count': instance.count,
    };
