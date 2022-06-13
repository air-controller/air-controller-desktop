// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_data_type_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactDataTypeMap _$ContactDataTypeMapFromJson(Map<String, dynamic> json) =>
    ContactDataTypeMap(
      phone: (json['phone'] as List<dynamic>)
          .map((e) => ContactDataType.fromJson(e as Map<String, dynamic>))
          .toList(),
      email: (json['email'] as List<dynamic>)
          .map((e) => ContactDataType.fromJson(e as Map<String, dynamic>))
          .toList(),
      address: (json['address'] as List<dynamic>)
          .map((e) => ContactDataType.fromJson(e as Map<String, dynamic>))
          .toList(),
      im: (json['im'] as List<dynamic>)
          .map((e) => ContactDataType.fromJson(e as Map<String, dynamic>))
          .toList(),
      relation: (json['relation'] as List<dynamic>)
          .map((e) => ContactDataType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContactDataTypeMapToJson(ContactDataTypeMap instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'email': instance.email,
      'address': instance.address,
      'im': instance.im,
      'relation': instance.relation,
    };
