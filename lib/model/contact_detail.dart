import 'package:air_controller/model/contact_field_value.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:air_controller/model/contact_note.dart';
import 'package:json_annotation/json_annotation.dart';

import 'account.dart';

part 'contact_detail.g.dart';

@JsonSerializable()
class ContactDetail {
  final int id;
  final int contactId;
  final String? displayNamePrimary;
  final List<Account>? accounts;
  final List<ContactGroup>? groups;
  final List<ContactFieldValue>? phones;
  final List<ContactFieldValue>? emails;
  final List<ContactFieldValue>? addresses;
  final List<ContactFieldValue>? ims;
  final List<ContactFieldValue>? relations;
  final ContactNote? note;

  const ContactDetail({
    required this.id,
    required this.contactId,
    this.displayNamePrimary,
    this.accounts,
    this.groups,
    this.phones,
    this.emails,
    this.addresses,
    this.ims,
    this.relations,
    this.note,
  });

  factory ContactDetail.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDetailToJson(this);
}
