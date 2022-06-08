// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_account_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactAccountInfo _$ContactAccountInfoFromJson(Map<String, dynamic> json) =>
    ContactAccountInfo(
      account: Account.fromJson(json['account'] as Map<String, dynamic>),
      count: json['count'] as int,
      groups: (json['groups'] as List<dynamic>)
          .map((e) => ContactGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContactAccountInfoToJson(ContactAccountInfo instance) =>
    <String, dynamic>{
      'account': instance.account,
      'count': instance.count,
      'groups': instance.groups,
    };
