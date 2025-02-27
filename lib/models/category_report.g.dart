// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryReport _$CategoryReportFromJson(Map<String, dynamic> json) =>
    CategoryReport(
      id: json['id'] as int,
      name: json['name'] as String,
      isSelected: json['is_selected'] as bool? ?? false,
    );

Map<String, dynamic> _$CategoryReportToJson(CategoryReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'is_selected': instance.isSelected,
    };
