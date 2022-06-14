import 'package:json_annotation/json_annotation.dart';

part 'delete_contacts_request_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class DeleteContactsRequestEntity {
  final List<int> ids;

  DeleteContactsRequestEntity(this.ids);

  factory DeleteContactsRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$DeleteContactsRequestEntityFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteContactsRequestEntityToJson(this);
}
