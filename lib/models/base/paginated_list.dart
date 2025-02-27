// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/ui/all.dart';

part 'paginated_list.freezed.dart';

part 'paginated_list.g.dart';

@Freezed(genericArgumentFactories: true)
class PaginatedList<T> with _$PaginatedList<T> {
  const PaginatedList._();

  const factory PaginatedList({
    required List<T> items,
    required int currentPage,
    required int pageSize,
    int? totalItems,
    @Default(false) bool isLastPage,
  }) = _PaginatedList<T>;

  factory PaginatedList.fromJson(Map<String, dynamic> json,
      T Function(dynamic json) decoder,) =>
      _$PaginatedListFromJson(json, decoder);

  factory PaginatedList.initial({
    int initialPage = PagingConstants.initialPage,
    int defaultPageSize = PagingConstants.defaultPageSize,
  }) =>
      PaginatedList<T>(
        items: <T>[],
        currentPage: initialPage - 1,
        pageSize: defaultPageSize,
      );

  bool get hasNext => !isLastPage;

  bool get isFirstPage => currentPage == PagingConstants.initialPage;

  PaginatedList<T> hasReachedLastPage() {
    return copyWith(isLastPage: true);
  }

  PaginatedList<T> nextPage() {
    return copyWith(currentPage: currentPage + 1);
  }

  PaginatedList<T> removeItem(T item) {
    final newItems = items.where((element) => element != item).toList();

    return copyWith(items: newItems);
  }

  PaginatedList<T> addItem(T item) {
    final newItems = [item, ...items];

    return copyWith(items: newItems);
  }

  PaginatedList<T> replaceItem(T oldItem, T newItem) {
    final newItems = items.map((e) => e == oldItem ? newItem : e).toList();

    return copyWith(items: newItems);
  }

  PaginatedList<T> replaceAll(List<T> newItems) {
    return copyWith(items: newItems);
  }
}
