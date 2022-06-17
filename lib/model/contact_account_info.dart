import 'package:air_controller/model/account.dart';
import 'package:json_annotation/json_annotation.dart';

import 'contact_group.dart';

part 'contact_account_info.g.dart';

@JsonSerializable(explicitToJson: true)
class ContactAccountInfo {
  final Account account;
  final List<ContactGroup> groups;

  ContactAccountInfo({required this.account, required this.groups});

  factory ContactAccountInfo.fromJson(Map<String, dynamic> json) => _$ContactAccountInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContactAccountInfoToJson(this);
}
