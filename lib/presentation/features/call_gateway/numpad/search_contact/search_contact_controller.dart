import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../../models/user.dart';
import '../../../../../repositories/user/user_repo.dart';
import '../../../../base/all.dart';

class SearchContactController extends BaseController {
  static const _pageSize = 15;
  final UserRepository _userRepository = Get.find<UserRepository>();

  final PagingController<int, User> searchUserPagingController =
      PagingController(firstPageKey: 0);

  TextEditingController searchController = TextEditingController();
  RxBool isSearching = false.obs;

  @override
  void onInit() {
    searchUserPagingController.addPageRequestListener((pageKey) {
      searchUser(pageKey);
    });
    super.onInit();
  }

  set changeSearching(bool value) {
    isSearching.value = value;
  }

  Future<void> searchUser(int pageKey) async {
    if (searchController.text.isEmpty) {
      searchUserPagingController.itemList = [];

      return;
    }

    await runAction(
      handleLoading: false,
      action: () async {
        final users = await _userRepository.searchUserWithPaging(
          searchController.text.trim(),
          _pageSize,
          pageKey * _pageSize,
        );

        final isLastPage = users.length < _pageSize;
        if (isLastPage) {
          searchUserPagingController.appendLastPage(users);
        } else {
          final nextPageKey = pageKey + 1;
          searchUserPagingController.appendPage(users, nextPageKey);
        }
      },
    );
  }
}
