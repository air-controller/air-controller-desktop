import 'package:air_controller/model/contact_account_info.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_summary_info.g.dart';

@JsonSerializable()
class ContactSummaryInfo {
  final int total;
  final List<ContactAccountInfo> accounts;

  const ContactSummaryInfo({required this.total, required this.accounts});

  factory ContactSummaryInfo.fromJson(Map<String, dynamic> json) => _$ContactSummaryInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContactSummaryInfoToJson(this);
}
