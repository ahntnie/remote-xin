import 'package:json_annotation/json_annotation.dart';

part 'position_map.g.dart';

@JsonSerializable()
class PositionMap {
  String id;
  String name;
  String? email;
  String? phone;
  String physicalAddress;
  double longitude;
  double latitude;
  int userId;
  String categoryId;
  bool isDeleted;
  bool isDisabled;

  PositionMap({
    required this.id,
    required this.name,
    required this.isDeleted,
    required this.categoryId,
    required this.isDisabled,
    required this.latitude,
    required this.longitude,
    required this.physicalAddress,
    required this.userId,
    this.email,
    this.phone,
  });

  factory PositionMap.fromJson(Map<String, dynamic> json) {
    final file = _$PositionMapFromJson(json);

    return file;
  }

  Map<String, dynamic> toJson() => _$PositionMapToJson(this);

  static List<PositionMap> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => PositionMap.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
