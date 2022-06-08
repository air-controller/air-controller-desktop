// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_summary_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactSummaryInfo _$ContactSummaryInfoFromJson(Map<String, dynamic> json) =>
    ContactSummaryInfo(
      total: json['total'] as int,
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => ContactAccountInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContactSummaryInfoToJson(ContactSummaryInfo instance) =>
    <String, dynamic>{
      'total': instance.total,
      'accounts': instance.accounts,
    };
