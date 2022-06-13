import 'package:json_annotation/json_annotation.dart';

import 'contact_data_type.dart';

part 'contact_data_type_map.g.dart';

@JsonSerializable()
class ContactDataTypeMap {
  final List<ContactDataType> phone;
  final List<ContactDataType> email;
  final List<ContactDataType> address;
  final List<ContactDataType> im;
  final List<ContactDataType> relation;

  const ContactDataTypeMap({
    required this.phone,
    required this.email,
    required this.address,
    required this.im,
    required this.relation,
  });

  factory ContactDataTypeMap.fromJson(Map<String, dynamic> json) =>
      _$ContactDataTypeMapFromJson(json);

  Map<String, dynamic> toJson() => _$ContactDataTypeMapToJson(this);
}
