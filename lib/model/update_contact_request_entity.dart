import 'package:air_controller/model/new_contact_request_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import 'account.dart';
import 'contact_field_value.dart';
import 'contact_group.dart';

part 'update_contact_request_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class UpdateContactRequestEntity extends NewContactRequestEntity {
  final int id;

  const UpdateContactRequestEntity({
    required this.id,
    required String name,
    Account? account,
    ContactGroup? group,
    List<ContactFieldValue>? phones,
    List<ContactFieldValue>? emails,
    List<ContactFieldValue>? ims,
    List<ContactFieldValue>? addresses,
    List<ContactFieldValue>? relations,
    String? note,
  }) : super(
          name: name,
          account: account,
          group: group,
          phones: phones,
          emails: emails,
          ims: ims,
          addresses: addresses,
          relations: relations,
          note: note,
        );

  factory UpdateContactRequestEntity.fromJson(Map<String, dynamic> json) => _$UpdateContactRequestEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateContactRequestEntityToJson(this);
}