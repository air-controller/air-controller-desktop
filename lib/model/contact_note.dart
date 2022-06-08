import 'package:json_annotation/json_annotation.dart';

part 'contact_note.g.dart';

@JsonSerializable()
class ContactNote {
  final int id;
  final int? contactId;
  final String? note;
  final bool isPrimary;
  final bool isSuperPrimary;

  const ContactNote({
    required this.id,
    this.contactId,
    this.note,
    required this.isPrimary,
    required this.isSuperPrimary,
  });

  factory ContactNote.fromJson(Map<String, dynamic> json) =>
      _$ContactNoteFromJson(json);

  Map<String, dynamic> toJson() => _$ContactNoteToJson(this);
}
