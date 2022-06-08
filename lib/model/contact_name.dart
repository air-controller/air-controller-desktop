import 'package:json_annotation/json_annotation.dart';

part 'contact_name.g.dart';

@JsonSerializable()
class ContactName {
  final int contactId;
  final String? displayName;
  final String? givenName;
  final String? familyName;
  final bool isPrimary;
  final int rawContactId;

  const ContactName(
      {required this.contactId,
      this.displayName,
      this.givenName,
      this.familyName,
      required this.isPrimary,
      required this.rawContactId});

  factory ContactName.fromJson(Map<String, dynamic> json) =>
      _$ContactNameFromJson(json);

  Map<String, dynamic> toJson() => _$ContactNameToJson(this);
}
