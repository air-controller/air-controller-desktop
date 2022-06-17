import 'package:air_controller/model/contact_account_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'accounts_and_groups.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountsAndGroups {
  final List<ContactAccountInfo> accounts;

  const AccountsAndGroups({required this.accounts});

  factory AccountsAndGroups.fromJson(Map<String, dynamic> json) => _$AccountsAndGroupsFromJson(json);

  Map<String, dynamic> toJson() => _$AccountsAndGroupsToJson(this);
}
