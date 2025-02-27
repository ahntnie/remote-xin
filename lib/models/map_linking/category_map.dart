import 'package:json_annotation/json_annotation.dart';

import 'position_map.dart';

part 'category_map.g.dart';

@JsonSerializable()
class CategoryMap {
  String id;
  String name;
  String slug;
  bool isDeleted;
  Map<String, dynamic> language;
  List<PositionMap>? positions;

  CategoryMap({
    required this.id,
    required this.name,
    required this.slug,
    required this.isDeleted,
    required this.language,
    this.positions,
  });

  factory CategoryMap.fromJson(Map<String, dynamic> json) {
    final file = _$CategoryMapFromJson(json);

    return file;
  }

  Map<String, dynamic> toJson() => _$CategoryMapToJson(this);

  static List<CategoryMap> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CategoryMap.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  CategoryMap copyWith({
    String? id,
    String? name,
    String? slug,
    bool? isDeleted,
    List<PositionMap>? positions,
    Map<String, dynamic>? language,
  }) {
    return CategoryMap(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      isDeleted: isDeleted ?? this.isDeleted,
      positions: positions ?? List<PositionMap>.from(this.positions ?? []),
      language: language ?? this.language,
    );
  }
}
