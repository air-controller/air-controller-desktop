
import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable()
class Account {
  final String name;
  final String type;

  const Account({required this.name, required this.type});

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);
  
  Map<String, dynamic> tojson() => _$AccountToJson(this);
}