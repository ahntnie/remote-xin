// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PaginatedListImpl<T> _$$PaginatedListImplFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    _$PaginatedListImpl<T>(
      items: (json['items'] as List<dynamic>).map(fromJsonT).toList(),
      currentPage: json['current_page'] as int,
      pageSize: json['page_size'] as int,
      totalItems: json['total_items'] as int?,
      isLastPage: json['is_last_page'] as bool? ?? false,
    );

Map<String, dynamic> _$$PaginatedListImplToJson<T>(
  _$PaginatedListImpl<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'items': instance.items.map(toJsonT).toList(),
      'current_page': instance.currentPage,
      'page_size': instance.pageSize,
      'total_items': instance.totalItems,
      'is_last_page': instance.isLastPage,
    };
