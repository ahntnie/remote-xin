import 'dart:async';
import 'dart:collection';

import 'package:get/get.dart';

import '../../core/all.dart';
import '../../core/mixins/anchor_scroll_mixin.dart';
import '../../models/all.dart';
import '../common_widgets/pagination_list/controller/common_paging_controller.dart';
import 'base_controller.dart';

abstract class BaseLoadMoreController<T> extends BaseController
    with AnchorScrollMixin {
  late final CommonPagingController<T> pagingController;

  late PaginatedList<T> paginatedList;

  int pageSize = PagingConstants.defaultPageSize;
  final int initialPage = PagingConstants.initialPage;

  final bool getListWhenInit = true;

  final bool autoLoadMore = true;
  final SplayTreeSet<int> _loadedPages = SplayTreeSet();

  bool _isFetching = false;

  final _showButtonScrollDown = false.obs;

  @override
  void onInit() {
    paginatedList = PaginatedList<T>.initial(
      initialPage: initialPage,
      defaultPageSize: pageSize,
    );
    pagingController = CommonPagingController<T>();

    if (getListWhenInit) {
      refreshData();
    }

    if (autoLoadMore) {
      pagingController.listen(onLoadMore: onEndScroll);
    }

    super.onInit();
  }

  @override
  void onClose() {
    pagingController.dispose();

    super.onClose();
  }

  @override
  Future<void> onEndScroll() async {
    if (paginatedList.isLastPage) {
      return;
    }
    final lastIndex = _loadedPages.isNotEmpty ? _loadedPages.last : 0;

    return _handleFetch(
      // page: paginatedList.currentPage + 1,
      page: lastIndex + 1,
      pageSize: paginatedList.pageSize,
      previousPage: lastIndex,
    );
  }

  Future<void> _handleFetch({
    required int page,
    required int pageSize,
    required int previousPage,
  }) async {
    try {
      if (_isFetching) {
        return;
      }
      _isFetching = true;

      paginatedList = await fetchPaginatedList(
        page: page,
        pageSize: pageSize,
      );

      if (isClosed) {
        return;
      }

      if (page < previousPage) {
        pagingController.appendPreviousPaginatedList(paginatedList);
        _loadedPages.add(page);
        try {
          // // restore scroll position
          await anchorScrollController.scrollToIndex(
            index: 1,
            scrollSpeed: 10,
          );
        } catch (_) {}
      } else {
        pagingController.appendPaginatedList(paginatedList);
        _loadedPages.add(page);
      }
    } on AppException catch (e) {
      pagingController.error = e;
    } finally {
      _isFetching = false;
    }
  }

  @override
  Future<void> onTopScroll() async {
    showButtonScrollDown = false;
    if (_loadedPages.isNotEmpty && _loadedPages.first <= 1) {
      return;
    }

    return _handleFetch(
      // page: paginatedList.currentPage - 1,
      page: _loadedPages.first - 1,
      pageSize: paginatedList.pageSize,
      previousPage: _loadedPages.first,
    );
  }

  Future<void> refreshData() async {
    resetLoadedPages();

    return _handleFetch(
      page: initialPage,
      pageSize: paginatedList.pageSize,
      // refresh first page is always 1
      previousPage: 1,
    );
  }

  Future<PaginatedList<T>> fetchPaginatedList({
    required int page,
    required int pageSize,
  });

  bool pageIsLoaded(int page) => _loadedPages.contains(page);

  void resetLoadedPages() {
    _loadedPages.clear();
  }

  void addLoadedPage(int page) {
    _loadedPages.add(page);
  }

  Future scrollToValue(T value, bool Function(T, T) compareValue) async {
    final index = pagingController.itemList!
        .indexWhere((element) => compareValue(element, value));
    if (index == -1) {
      return;
    }

    await anchorScrollController.scrollToIndex(index: index, scrollSpeed: 5);
  }

  bool get showButtonScrollDown => _showButtonScrollDown.value;

  set showButtonScrollDown(bool value) {
    _showButtonScrollDown.value = value;
  }

  @override
  Future<void> onHideButtonScrollDown() async {
    showButtonScrollDown = false;
  }

  @override
  Future<void> onShowButtonScrollDown() async {
    showButtonScrollDown = true;
  }
}
