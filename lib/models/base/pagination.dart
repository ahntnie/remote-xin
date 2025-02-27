import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination.g.dart';

@JsonSerializable(explicitToJson: true, genericArgumentFactories: true)
class PaginationResponse<T> {
  final String code;
  final List<T> data;
  final Pagination pagination;

  PaginationResponse({
    required this.code,
    required this.data,
    required this.pagination,
  });

  factory PaginationResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJson,
  ) {
    final paginationResponse = _$PaginationResponseFromJson(json, fromJson);

    return paginationResponse;
  }

  Map<String, dynamic> toJson(Object? Function(T) toJson) =>
      _$PaginationResponseToJson(
        this,
        toJson,
      );
}

@JsonSerializable()
class Pagination {
  @Default(20)
  final int perPage;
  @Default(1)
  final int page;
  final int count;
  @JsonKey(name: 'hasMorePage')
  @Default(false)
  final bool hasMorePage;

  Pagination({
    required this.perPage,
    required this.page,
    required this.count,
    required this.hasMorePage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    final pagination = _$PaginationFromJson(json);

    return pagination;
  }

  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
