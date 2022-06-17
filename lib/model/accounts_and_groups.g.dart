// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_and_groups.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountsAndGroups _$AccountsAndGroupsFromJson(Map<String, dynamic> json) =>
    AccountsAndGroups(
      accounts: (json['accounts'] as List<dynamic>)
          .map((e) => ContactAccountInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AccountsAndGroupsToJson(AccountsAndGroups instance) =>
    <String, dynamic>{
      'accounts': instance.accounts.map((e) => e.toJson()).toList(),
    };
