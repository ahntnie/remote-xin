// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_map.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryMap _$CategoryMapFromJson(Map<String, dynamic> json) => CategoryMap(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      isDeleted: json['is_deleted'] as bool,
      language: json['language'] as Map<String, dynamic>,
      positions: (json['positions'] as List<dynamic>?)
          ?.map((e) => PositionMap.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryMapToJson(CategoryMap instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'is_deleted': instance.isDeleted,
      'language': instance.language,
      'positions': instance.positions?.map((e) => e.toJson()).toList(),
    };
