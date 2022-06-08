import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_group.g.dart';

@JsonSerializable()
class ContactGroup extends Equatable {
  final int id;
  final String title;
  final int count;

  const ContactGroup({required this.id, required this.title, required this.count});

  factory ContactGroup.fromJson(Map<String, dynamic> json) =>
      _$ContactGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ContactGroupToJson(this);

  @override
  List<Object?> get props => [id];
}
