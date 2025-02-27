import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/constants/ui/paging_constants.dart';
import '../../../../core/exceptions/all.dart';
import '../../../../models/base/paginated_list.dart';

class CommonPagingController<T> {
  CommonPagingController({
    this.invisibleItemsThreshold = 3,
    this.firstPageKey = PagingConstants.initialPage,
  }) : pagingController = PagingController<int, T>(
          firstPageKey: firstPageKey,
          invisibleItemsThreshold: invisibleItemsThreshold,
        );

  final PagingController<int, T> pagingController;

  final int? invisibleItemsThreshold;
  final int firstPageKey;

  // call when error
  set error(AppException? appException) {
    pagingController.error = appException;
  }

  List<T>? get itemList => pagingController.itemList;

  // call when initState to listen to trigger load more
  void listen({
    required VoidCallback onLoadMore,
  }) {
    pagingController.addPageRequestListener((pageKey) {
      if (pageKey > PagingConstants.initialPage) {
        onLoadMore();
      }
    });
  }

  /// Appends [newItems] to the previously loaded ones and replaces
  /// the next page's key.
  void appendPreviousPage(List<T> newItems, int? nextPageKey) {
    final previousItems = pagingController.itemList ?? [];
    final itemList = newItems + previousItems;
    pagingController.itemList = itemList;
    pagingController.nextPageKey = nextPageKey;
  }

  void appendPreviousPaginatedList(PaginatedList<T> paginatedList) {
    appendPreviousPage(
      paginatedList.items,
      (pagingController.nextPageKey ?? (PagingConstants.initialPage - 1)) - 1,
    );
  }

  // call append data when load first page / more page success
  void appendPaginatedList(PaginatedList<T> paginatedList) {
    if (paginatedList.isFirstPage) {
      pagingController.refresh();
    }

    if (paginatedList.isLastPage) {
      pagingController.appendLastPage(paginatedList.items);
    } else {
      pagingController.appendPage(
        paginatedList.items,
        (pagingController.nextPageKey ?? (PagingConstants.initialPage - 1)) + 1,
      );
    }
  }

  void insertItemAt(int index, T item) {
    pagingController.itemList?.insert(index, item);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void insertAllItemsAt(int index, Iterable<T> items) {
    pagingController.itemList?.insertAll(index, items);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void updateItemAt(int index, T newItem) {
    pagingController.itemList?[index] = newItem;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void removeItemAt(int index) {
    pagingController.itemList?.removeAt(index);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void removeRange(int start, int end) {
    pagingController.itemList?.removeRange(start, end);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void clear() {
    pagingController.itemList?.clear();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void replaceItem(T oldItem, T newItem, {bool Function(T, T)? comparator}) {
    final index = comparator != null
        ? pagingController.itemList
            ?.indexWhere((element) => comparator(element, oldItem))
        : pagingController.itemList?.indexOf(oldItem);

    if (index != null && index >= 0) {
      pagingController.itemList?[index] = newItem;
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      pagingController.notifyListeners();
    }
  }

  void dispose() {
    pagingController.dispose();
  }
}
