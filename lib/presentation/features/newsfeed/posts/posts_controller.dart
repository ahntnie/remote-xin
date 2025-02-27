import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../models/user_story.dart';
import '../../../../repositories/all.dart';
import '../../../../services/newsfeed_interact_service.dart';
import '../../../base/all.dart';
import '../../../routing/routing.dart';
import '../../all.dart';

class PostsController extends BaseController with ScrollMixin {
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  final sharePostController = Get.find<SharePostController>();
  final homeController = Get.find<HomeController>();
  final ScrollController scrollController = ScrollController();
  final _userRepo = Get.find<UserRepository>();

  RxList<Post> posts = <Post>[].obs;

  static const _pageSize = 20;
  int pageKey = 1;
  RxBool hasMorePage = false.obs;
  RxBool isLoadingLoadMore = false.obs;
  RxBool isLoadingInit = true.obs;

  RxBool isSearch = false.obs;
  final _users = <User>[].obs;
  List<User> get users => _users.toList();
  final _searchDebouncer = Debouncer();

  RxBool newStoryPosted = false.obs;
  RxList<UserStory> userStorys = <UserStory>[].obs;
  List<UserStory> get listUserStorys => userStorys.toList();

  @override
  void onInit() {
    posts.clear();
    pageKey = 1;
    Get.find<NewsfeedInteractService>();
    // getNewsFeed();
    // getListUserStory();
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (homeController.isShowBottomBar.value) {
          homeController.setIsShowBottomBar(false);
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!homeController.isShowBottomBar.value) {
          homeController.setIsShowBottomBar(true);
        }
      }
    });
    loadHistorySearchUsers();
    super.onInit();
  }

  void setIsSearch(bool value) {
    isSearch.value = value;
  }

  void search(String query) {
    query = query.trim();
    searchText.value = query;
    _searchDebouncer.run(() {
      runAction(
        handleLoading: false,
        action: () async {
          if (query.trim().isEmpty) {
            _users.value = [];

            return;
          }

          // if query is phone number and start with 0, remove the 0
          if (RegExp(r'^[0-9]+$').hasMatch(query) && query.startsWith('0')) {
            query = query.substring(1);
          }

          final users = await _userRepo.searchUser(query);

          _users.value =
              users.where((user) => user.id != currentUser.id).toList();
        },
      );
    });
  }

  Future getListUserStory() async {
    userStorys.value = [];
    await runAction(
      action: () async {
        final storyLists = await _newsFeedRepository.getListUserStory();
        for (var story in storyLists) {
          if (story.stories.isNotEmpty) {
            userStorys.add(story);
          }
        }
      },
    );
  }

  UserStory getUserStory(int index) {
    return userStorys[index - 1];
  }

  UserStory? getMyStory() {
    final index =
        userStorys.indexWhere((story) => story.userId == currentUser.id);
    if (index != -1) {
      return userStorys[index];
    }
    return null;
  }

  int getIndexMyStory() {
    return userStorys.indexWhere((story) => story.userId == currentUser.id);
  }

  Future<void> getNewsfeedRepository({
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    final listPost = await _newsFeedRepository.getNewsfeed(
      type: ['post'],
      page: pageKey,
      pageSize: _pageSize,
    );

    hasMorePage.value = listPost.pagination.hasMorePage;

    if (listPost.data.isEmpty) {
      pageKey--;

      return;
    }

    if (isRefresh) {
      posts.clear();
    }

    if (isLoadMore) {
      posts.addAll([...posts, ...listPost.data]);
    } else {
      posts.addAll(listPost.data as List<Post>);
    }
  }

  Future<void> getNewsFeed() async {
    await runAction(
      handleLoading: false,
      action: () async {
        pageKey = 1;
        posts.clear();
        await getNewsfeedRepository(isLoadMore: true);
      },
    );
    isLoadingInit.value = false;
  }

  Future<void> onRefreshNewsfeed() async {
    await runAction(
      handleLoading: false,
      action: () async {
        isLoadingInit.value = true;
        pageKey = 1;

        await getNewsfeedRepository(isRefresh: true);
        await getListUserStory();
        isLoadingInit.value = false;
      },
    );
  }

  Future<void> loadMoreNewsfeed() async {
    await runAction(
      handleLoading: false,
      action: () async {
        if (!hasMorePage.value) return;
        isLoadingLoadMore.value = true;

        pageKey++;
        await getNewsfeedRepository();

        isLoadingLoadMore.value = false;
      },
      onError: (exception) {
        isLoadingLoadMore.value = false;
      },
    );
  }

  void goToCreatePost() {
    Get.toNamed(Routes.createPost);
  }

  void likePost({
    required Post post,
    required RxList<Post> posts,
  }) {
    runAction(
      handleLoading: false,
      action: () async {
        final index = posts.indexWhere((element) => element.id == post.id);

        if (index != -1) {
          posts[index] = post.copyWith(
            likeCount: post.likeCount + 1,
            userReaction: ReactionType.like,
          );
        }

        unawaited(_newsFeedRepository.likePost(
          postId: post.id,
          type: ReactionType.like.name,
        ));
        Get.find<NewsfeedInteractService>().likePost(post.id);
      },
    );
  }

  void unLikePost({
    required Post post,
    required RxList<Post> posts,
  }) {
    runAction(
      handleLoading: false,
      action: () async {
        final index = posts.indexWhere((element) => element.id == post.id);

        if (index != -1 && post.likeCount > 0) {
          posts[index] = post.copyWith(
            likeCount: post.likeCount - 1,
          );
        }

        unawaited(_newsFeedRepository.unLikePost(postId: post.id));
        Get.find<NewsfeedInteractService>().unlikePost(post.id);
      },
    );
  }

  Future<void> createPost({
    required RxList<Post> posts,
    bool isFocus = false,
    bool isMedia = false,
  }) async {
    await Get.toNamed(Routes.createPost, arguments: {
      'is_focus': isFocus,
      'is_media': isMedia,
    })?.then((post) {
      if (post != null) {
        posts.insert(0, post);
        ViewUtil.showAppSnackBarNewFeeds(
            title: l10n.newsfeed__create_post_success);
      }
    });
  }

  void deletePost({
    required Post post,
    required RxList<Post> posts,
    bool isPostDetail = false,
  }) {
    runAction(
      handleLoading: false,
      action: () async {
        final String code =
            await _newsFeedRepository.deletePost(postId: post.id);

        if (code == 'post_deleted') {
          posts.removeWhere((element) => element.id == post.id);
          update();

          if (isPostDetail) {
            Get.back();
          }
          ViewUtil.showAppSnackBarNewFeeds(
            title: l10n.newsfeed__delete_post_success,
          );
        } else {
          ViewUtil.showAppSnackBarNewFeeds(
            title: l10n.newsfeed__delete_post_failure,
            isSuccess: false,
          );
        }
      },
      onError: (exception) {
        ViewUtil.showAppSnackBarNewFeeds(
          title: l10n.newsfeed__delete_post_failure,
          isSuccess: false,
        );
      },
    );
  }

  void onEditPost({required Post post, required RxList<Post> posts}) {
    Get.toNamed(
      Routes.editPost,
      arguments: {
        'post': post,
      },
    )?.then((postUpdated) {
      Get.back();
      if (postUpdated != null) {
        final int index = posts.indexWhere(
          (element) => element.id == postUpdated.id,
        );

        if (index != -1) {
          posts[index] = postUpdated;
        }

        ViewUtil.showAppSnackBarNewFeeds(
            title: l10n.newsfeed__edit_post_success);
      }
    });
  }

  Future<void> onReport(Post post) async {
    await Get.toNamed(
      Routes.report,
      arguments: ReportArgs(
        type: ReportType.post,
        data: post.id,
      ),
    )?.then((code) {
      Get.back();
      if (code == 'success') {
        ViewUtil.showAppSnackBarNewFeeds(title: l10n.newsfeed__report_success);
      } else if (code != null) {
        ViewUtil.showAppSnackBarNewFeeds(
          title: l10n.newsfeed__report_failure,
          isSuccess: false,
        );
      }
    });
  }

  void updateCommentCount(int postId, {bool isDeleted = false}) {
    final int indexPost = posts.indexWhere((element) => element.id == postId);

    if (indexPost != -1) {
      posts[indexPost] = posts[indexPost].copyWith(
        commentCount: posts[indexPost].commentCount + (isDeleted ? -1 : 1),
      );
    }
  }

  @override
  Future<void> onEndScroll() async {
    await loadMoreNewsfeed();
  }

  @override
  Future<void> onTopScroll() async {
    if (scroll.hasClients) {
      await scroll.animateTo(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }

  var searchText = ''.obs;
  void clearSearchText() {
    searchText.value = '';
  }

  static const String _historyKey = 'history_search_users';
  var historyList =
      <HistorySearchUser>[].obs; // Danh sách lịch sử được lưu ở đây
  var isLoadingHistory = false.obs; // Kiểm tra trạng thái đang lấy lịch sử

  // Lấy danh sách lịch sử từ SharedPreferences
  Future<void> loadHistorySearchUsers() async {
    isLoadingHistory.value = true; // Bắt đầu load lịch sử
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_historyKey);

    if (historyJson != null) {
      try {
        // Giải mã chuỗi JSON thành List
        final List<dynamic> jsonList = json.decode(historyJson);

        // Kiểm tra từng phần tử trong danh sách có đúng dạng Map không
        final loadedList = jsonList.map((jsonItem) {
          final mapValue = json.decode(jsonItem);
          if (mapValue is Map<String, dynamic>) {
            return HistorySearchUser.fromJson(mapValue);
          } else {
            throw TypeError(); // Ném lỗi nếu không phải Map<String, dynamic>
          }
        }).toList();

        historyList.value.assignAll(loadedList); // Cập nhật danh sách lịch sử

        sortHistoryList();
      } catch (e) {
        print('Lỗi khi giải mã JSON: $e');
      }
    }

    isLoadingHistory.value = false; // Hoàn thành việc load lịch sử
  }

  // Sắp xếp danh sách ưu tiên các mục có isPin = true
  void sortHistoryList() {
    historyList.value.sort((a, b) {
      if (a.isPin == b.isPin) {
        return 0;
      } else if (a.isPin) {
        return -1; // Di chuyển các mục có isPin = true lên đầu
      } else {
        return 1;
      }
    });
    update();
  }

  // Lưu danh sách vào SharedPreferences
  Future<void> saveHistorySearchUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = historyList.value
        .map((history) => json.encode(history.toJson()))
        .toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  // Kiểm tra số lượng lịch sử được pin
  int getPinnedCount() {
    return historyList.value.where((item) => item.isPin).length;
  }

  // Thêm một mục vào danh sách
  Future<void> addHistorySearchUser(HistorySearchUser newUser) async {
    // Kiểm tra nếu user.id đã tồn tại trong danh sách
    final bool isUserExists =
        historyList.value.any((item) => item.user?.id == newUser.user?.id);

    if (isUserExists) {
      print('User đã tồn tại trong lịch sử tìm kiếm.');
      return; // Không thêm mới nếu user.id đã tồn tại
    }

    // Nếu người dùng được ghim và số lượng mục đã ghim >= 3, không cho phép thêm mới
    if (newUser.isPin && getPinnedCount() >= 3) {
      ViewUtil.showToast(
          title: l10n.notification__title,
          message: l10n.search_history__pin_subtext);
      return;
    }

    historyList.value.add(newUser); // Thêm mục mới vào danh sách

    // Sắp xếp danh sách để ưu tiên isPin = true
    sortHistoryList();
    update();
    await saveHistorySearchUsers(); // Lưu danh sách sau khi cập nhật
  }

  // Xóa một mục khỏi danh sách
  Future<void> deleteHistorySearchUser(int userId) async {
    // Sao chép historyList thành một danh sách mới mà không có tham chiếu
    final List<HistorySearchUser> copiedList = List.from(historyList);

    historyList.value =
        copiedList.where((item) => item.user?.id != userId).toList(); // Xóa mục
    update();
    await saveHistorySearchUsers(); // Lưu danh sách sau khi xóa
  }

  // Cập nhật một mục trong danh sách
  Future<void> updateHistorySearchUser(HistorySearchUser updatedUser) async {
    final int index = historyList.value
        .indexWhere((item) => item.user?.id == updatedUser.user?.id);
    if (index != -1) {
      // Nếu mục đang được cập nhật có thuộc tính isPin và hiện tại có đủ 3 mục đã ghim
      if (getPinnedCount() >= 3) {
        ViewUtil.showToast(
            title: l10n.notification__title,
            message: l10n.search_history__pin_subtext);
        return;
      }

      historyList[index] = updatedUser; // Cập nhật mục

      // Sắp xếp danh sách để ưu tiên isPin = true
      sortHistoryList();
      update();
      await saveHistorySearchUsers(); // Lưu danh sách sau khi cập nhật

      if (updatedUser.isPin == true) {
        Get.back();
      }
    }
  }

  // Xóa toàn bộ danh sách
  Future<void> clearHistorySearchUsers() async {
    historyList.value.clear(); // Xóa toàn bộ danh sách
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey); // Xóa khỏi SharedPreferences
  }
}

class HistorySearchUser {
  User? user;
  bool isPin;
  DateTime createdAt;

  HistorySearchUser({
    required this.user,
    this.isPin = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Chuyển đổi từ HistorySearchUser sang Map để lưu dưới dạng JSON
  Map<String, dynamic> toJson() => {
        'user': user?.toJson(),
        'isPin': isPin,
        'createdAt': createdAt.toIso8601String(),
      };

  // Tạo HistorySearchUser từ JSON (Map)
  factory HistorySearchUser.fromJson(Map<String, dynamic> json) {
    return HistorySearchUser(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      isPin: json['isPin'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
