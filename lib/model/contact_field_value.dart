import 'package:air_controller/model/contact_data_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_field_value.g.dart';

@JsonSerializable(explicitToJson: true)
class ContactFieldValue {
  final int id;
  final ContactDataType? type;
  final String value;

  const ContactFieldValue({this.id = -1, this.type, required this.value});

  factory ContactFieldValue.fromJson(Map<String, dynamic> json) =>
      _$ContactFieldValueFromJson(json);

  Map<String, dynamic> toJson() => _$ContactFieldValueToJson(this);
}
