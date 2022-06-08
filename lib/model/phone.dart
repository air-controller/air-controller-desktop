import 'package:json_annotation/json_annotation.dart';

part 'phone.g.dart';

@JsonSerializable()
class Phone {
  final int id;
  final int contactId;
  final String? number;
  final String? normalizedNumber;
  final String? label;
  final bool isPrimary;

  const Phone({
    required this.id,
    required this.contactId,
    this.number,
    this.normalizedNumber,
    this.label,
    required this.isPrimary,
  });

  factory Phone.fromJson(Map<String, dynamic> json) => _$PhoneFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneToJson(this);
}
