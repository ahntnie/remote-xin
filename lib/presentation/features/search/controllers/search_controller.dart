import 'package:flutter/material.dart';
import 'package:flutter_contacts/diacritics.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/conversation.dart';
import '../../../../models/hashtag.dart';
import '../../../../models/user.dart';
import '../../../../repositories/chat_repo.dart';
import '../../../../repositories/short-video/short_video_repo.dart';
import '../../../../repositories/user/user_repo.dart';
import '../../../base/all.dart';
import '../../../routing/routers/app_pages.dart';
import '../../chat/chat_hub/controllers/chat_hub_controller.dart';
import '../../chat/dashboard/controllers/dashboard_controller.dart';
import '../../short_video/modal/user_video/user_video.dart';

class SearchController extends BaseController
    with GetSingleTickerProviderStateMixin {
  final _userRepo = Get.find<UserRepository>();
  final _chatRepository = Get.find<ChatRepository>();

  final _chatDashboardController = Get.find<ChatDashboardController>();
  final _shortVideoRepo = Get.find<ShortVideoRepository>();

  late final TabController tabController;

  bool initVideo = true;
  bool initUser = true;
  bool initHashtag = true;

  String textSearch = '';

  final _users = <User>[].obs;

  List<User> get users => _users.toList();

  final _videos = <Data>[].obs;

  List<Data> get videos => _videos.toList();

  final _hashtags = <Hashtag>[].obs;

  List<Hashtag> get hashtags => _hashtags.toList();

  RxBool isLoadingSearch = false.obs;
 
  //   final _users = <Data>[].obs;
  // List<User> get users => _users.toList();

  //   final _users = <User>[].obs;
  // List<User> get users => _users.toList();

  final _conversations = <Conversation>[].obs;

  List<Conversation> get conversations => _conversations.toList();

  final type = Get.arguments['type'];

  final _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 1000),
  );

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    final searchConditions = {0: initVideo, 1: initUser, 2: initHashtag};

    if (searchConditions[tabController.index] ?? false) {
      search(textSearch);
    }
  }

  void searchConversations(String query) {
    _conversations.clear();

    if (query.trim().isEmpty) {
      return;
    }

    _conversations
        .addAll(_chatDashboardController.allConversations.where((conversation) {
      return conversation.title().containsIgnoreCase(query.trim());
    }));
  }

  void search(String query) {
    query = query.trim();

    searchConversations(query);

    _searchDebouncer.run(() {
      runAction(
        handleLoading: false,
        action: () async {
          if (query.trim().isEmpty) {
            _users.value = [];

            return;
          }
          isLoadingSearch.value = true;
          if (type == 'chat') {
            await searchUsers(query);
          } else if (type == 'reels') {
            if (tabController.index == 0) {
              await searchVideos(query);
            } else if (tabController.index == 1) {
              await searchUsers(query);
            } else {
              await searchHashtags(query);
            }
          }
          isLoadingSearch.value = false;
        },
      );
    });
  }

  Future searchUsers(String query) async {
    // if query is phone number and start with 0, remove the 0
    query = removeDiacritics(query).toLowerCase();
    if (RegExp(r'^[0-9]+$').hasMatch(query) && query.startsWith('0')) {
      query = query.substring(1);
    }

    final users = await _userRepo.searchUser(query);

    _users.value = users.where((user) => user.id != currentUser.id).toList();
    initUser = false;
  }

  Future searchVideos(String query) async {
    query = removeDiacritics(query).toLowerCase();
    // if query is phone number and start with 0, remove the 0

    final data = await _shortVideoRepo.searchShortVideo(query: query);
    _videos.value = data.toList();
    initVideo = false;
    // _users.value = users.where((user) => user.id != currentUser.id).toList();
  }

  Future searchHashtags(String query) async {
    final data = await _shortVideoRepo.searchHashtag(query);
    _hashtags.value = data.toList();
    initHashtag = false;
  }

  Future<void> goToPrivateChat(User user) async {
    return runAction(
      action: () async {
        var conversation = await _chatRepository.createConversation([user.id]);
        conversation = conversation.copyWith(
          members: [
            users.first,
            // currentUser,
          ],
        );

        return Get.toNamed(
          Routes.chatHub,
          arguments: ChatHubArguments(conversation: conversation),
        );
      },
    );
  }

  void updatePinned(int index, bool value) {
    // final index = videos.indexWhere((data) => data.postId == id);
    // logError(index);
    // if (index != -1) {
    _videos[index] = _videos[index].copyWith(isPinned: value);
    // }
  }

  void updateLike(int index, bool liked, int count) {
    if (liked) {
      _videos[index] =
          _videos[index].copyWith(videoLikesOrNot: 1, postLikesCount: count);
    } else {
      _videos[index] =
          _videos[index].copyWith(videoLikesOrNot: 0, postLikesCount: count);
    }
  }

  void updateBookmark(int index, bool value) {
    _videos[index] = _videos[index].copyWith(isBookmark: value);
  }

  void updateComment(int index, int count) {
    _videos[index] = _videos[index].copyWith(postCommentsCount: count);
  }

  void updateFollow(int index, bool value) {
    _videos[index] = _videos[index].copyWith(isFollowed: value);
  }
}
