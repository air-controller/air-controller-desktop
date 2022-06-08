import 'package:json_annotation/json_annotation.dart';

part 'contact_basic_info.g.dart';

@JsonSerializable()
class ContactBasicInfo {
  final int id;
  final String? lookupKey;
  final String? phoneNumber;
  final String? photoUri;
  final String? photoThumbnailUri;
  final String? displayNamePrimary;

  const ContactBasicInfo({
    required this.id,
    this.lookupKey,
    this.phoneNumber,
    this.photoUri,
    this.photoThumbnailUri,
    this.displayNamePrimary,
  });

  factory ContactBasicInfo.fromJson(Map<String, dynamic> json) =>
      _$ContactBasicInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContactBasicInfoToJson(this);

  bool operator ==(Object other) =>
      identical(this, other) || other is ContactBasicInfo && id == other.id;
}
