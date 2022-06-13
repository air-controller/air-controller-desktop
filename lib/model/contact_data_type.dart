import 'package:json_annotation/json_annotation.dart';

part 'contact_data_type.g.dart';

@JsonSerializable(explicitToJson: true)
class ContactDataType {
  final int value;
  final String typeLabel;
  final bool isUserCustomType;
  final bool isSystemCustomType;

  ContactDataType(this.value, this.typeLabel, this.isUserCustomType,
      this.isSystemCustomType);

  factory ContactDataType.fromJson(Map<String, dynamic> json) =>
      _$ContactDataTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDataTypeToJson(this);

  @override
  operator ==(Object other) =>
      identical(this, other) || other is ContactDataType && value == other.value;
}
