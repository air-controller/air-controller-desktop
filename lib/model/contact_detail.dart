import 'package:air_controller/model/contact_group.dart';
import 'package:air_controller/model/contact_note.dart';
import 'package:air_controller/model/phone.dart';
import 'package:json_annotation/json_annotation.dart';

import 'account.dart';

part 'contact_detail.g.dart';

@JsonSerializable()
class ContactDetail {
  final int id;
  final String? displayNamePrimary;
  final List<Account>? accounts;
  final List<ContactGroup>? groups;
  final List<Phone>? phones;
  final String? photoUri;
  final List<ContactNote>? notes;

  const ContactDetail({
    required this.id,
    this.displayNamePrimary,
    this.accounts,
    this.groups,
    this.phones,
    this.photoUri,
    this.notes,
  });

  factory ContactDetail.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDetailToJson(this);
}
