// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactNote _$ContactNoteFromJson(Map<String, dynamic> json) => ContactNote(
      id: json['id'] as int,
      contactId: json['contactId'] as int?,
      note: json['note'] as String?,
      isPrimary: json['isPrimary'] as bool,
      isSuperPrimary: json['isSuperPrimary'] as bool,
    );

Map<String, dynamic> _$ContactNoteToJson(ContactNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contactId': instance.contactId,
      'note': instance.note,
      'isPrimary': instance.isPrimary,
      'isSuperPrimary': instance.isSuperPrimary,
    };
