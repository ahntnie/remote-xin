// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'position_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PositionMap _$PositionMapFromJson(Map<String, dynamic> json) => PositionMap(
      id: json['id'] as String,
      name: json['name'] as String,
      isDeleted: json['is_deleted'] as bool,
      categoryId: json['category_id'] as String,
      isDisabled: json['is_disabled'] as bool,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      physicalAddress: json['physical_address'] as String,
      userId: json['user_id'] as int,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$PositionMapToJson(PositionMap instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
      'physical_address': instance.physicalAddress,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'user_id': instance.userId,
      'category_id': instance.categoryId,
      'is_deleted': instance.isDeleted,
      'is_disabled': instance.isDisabled,
    };
