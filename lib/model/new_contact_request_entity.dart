import 'package:air_controller/model/account.dart';
import 'package:air_controller/model/contact_field_value.dart';
import 'package:air_controller/model/contact_group.dart';
import 'package:json_annotation/json_annotation.dart';

part 'new_contact_request_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class NewContactRequestEntity {
  final String name;
  final Account? account;
  final ContactGroup? group;
  final List<ContactFieldValue>? phones;
  final List<ContactFieldValue>? emails;
  final List<ContactFieldValue>? ims;
  final List<ContactFieldValue>? addresses;
  final List<ContactFieldValue>? relations;
  final String? note;

  const NewContactRequestEntity({
    required this.name,
    this.account,
    this.group,
    this.phones,
    this.emails,
    this.ims,
    this.addresses,
    this.relations,
    this.note,
  });

  factory NewContactRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$NewContactRequestEntityFromJson(json);

  Map<String, dynamic> toJson() => _$NewContactRequestEntityToJson(this);
}
