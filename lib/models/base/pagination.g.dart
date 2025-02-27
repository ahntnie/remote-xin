// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationResponse<T> _$PaginationResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginationResponse<T>(
      code: json['code'] as String,
      data: (json['data'] as List<dynamic>).map(fromJsonT).toList(),
      pagination:
          Pagination.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PaginationResponseToJson<T>(
  PaginationResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data.map(toJsonT).toList(),
      'pagination': instance.pagination.toJson(),
    };

Pagination _$PaginationFromJson(Map<String, dynamic> json) => Pagination(
      perPage: json['per_page'] as int,
      page: json['page'] as int,
      count: json['count'] as int,
      hasMorePage: json['hasMorePage'] as bool,
    );

Map<String, dynamic> _$PaginationToJson(Pagination instance) =>
    <String, dynamic>{
      'per_page': instance.perPage,
      'page': instance.page,
      'count': instance.count,
      'hasMorePage': instance.hasMorePage,
    };
