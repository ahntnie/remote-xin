import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../models/call_history.dart';
import '../../../../repositories/call/call_repository.dart';
import '../../../../repositories/chat_repo.dart';
import '../../../base/all.dart';
import '../../call/controllers/call_kit_manager.dart';

class CallHistoryController extends BaseController {
  final CallRepository _callRepository = Get.find<CallRepository>();
  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  RxBool switchCallHistory = false.obs;
  RxInt currentIndex = 0.obs;
  RxString nameGroup = ''.obs;
  RxString avatarGroup = ''.obs;
  PageController pageController = PageController();

  static const _pageSize = 15;

  final PagingController<int, CallHistory> allHistoryPagingController =
      PagingController(firstPageKey: 0);
  final PagingController<int, CallHistory> missedHistoryPagingController =
      PagingController(firstPageKey: 0);

  var isEmpty = true.obs;

  @override
  void onInit() {
    getAllCallHistory(0);

    allHistoryPagingController.addPageRequestListener((pageKey) {
      getAllCallHistory(pageKey);
    });

    // missedHistoryPagingController.addPageRequestListener((pageKey) {
    //   getMissedCallHistory(pageKey);
    // });

    super.onInit();
  }

  set changeTab(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void updateCallHistoryAppBar(bool switchValue) {
    switchCallHistory.value = switchValue;
    changeTab = switchValue ? 1 : 0;
    update();
  }

  void getAllCallHistory(int pageKey) {
    runAction(
        handleLoading: false,
        action: () async {
          final callHistories = await _callRepository.getAllCallHistory(
            userId: currentUser.id,
            pageSize: _pageSize,
            offset: pageKey * _pageSize,
          );

          if (callHistories.isNotEmpty) {
            isEmpty.value = false;
            update();
          }

          final isLastPage = callHistories.length < _pageSize;
          if (isLastPage) {
            allHistoryPagingController.appendLastPage(callHistories);
          } else {
            final nextPageKey = pageKey + 1;
            allHistoryPagingController.appendPage(callHistories, nextPageKey);
          }
        });
  }

  Future<void> getMissedCallHistory(int pageKey) async {
    await runAction(
      action: () async {
        final callHistories = await _callRepository.getMissedCallHistory(
          userId: currentUser.id,
          pageSize: _pageSize,
          offset: pageKey * _pageSize,
        );

        if (callHistories.isNotEmpty) {
          isEmpty.value = false;
          update();
        }

        final isLastPage = callHistories.length < _pageSize;
        if (isLastPage) {
          missedHistoryPagingController.appendLastPage(callHistories);
        } else {
          final nextPageKey = pageKey + 1;
          missedHistoryPagingController.appendPage(callHistories, nextPageKey);
        }
      },
    );
  }

  Future<void> getConversationById(String conversationId) async {
    final conversationGroup = await _chatRepository.getConversationById(
      conversationId: conversationId,
    );

    nameGroup.value = conversationGroup.name;
    avatarGroup.value = conversationGroup.avatarUrl ?? '';
  }

  Future onCallAction(CallHistory callHistory, bool isCaller) async {
    await CallKitManager.instance.createCall(
      chatChannelId: callHistory.call!.chatChannelId,
      receiverIds: isCaller
          ? callHistory.call?.receivers.map((e) => e.user.id).toList() ?? []
          : callHistory.call?.callers.map((e) => e.user.id).toList() ?? [],
      isGroup: callHistory.call!.isGroup ?? false,
      isVideo: callHistory.call!.isVideo ?? false,
      isTranslate: callHistory.call!.isTranslate ?? false,
    );
  }
}
