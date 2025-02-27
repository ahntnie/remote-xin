import 'package:json_annotation/json_annotation.dart';

part 'category_report.g.dart';

@JsonSerializable()
class CategoryReport {
  final int id;
  final String name;
  bool isSelected;

  CategoryReport({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    final category = _$CategoryReportFromJson(json);

    return category;
  }

  factory CategoryReport.fromVideoJson(Map<String, dynamic> json) {
    return CategoryReport(
      id: json['id'] as int,
      name: json['reason_name'] as String,
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }

  static List<CategoryReport> fromJsonVideoList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CategoryReport.fromVideoJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<CategoryReport> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => CategoryReport.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
