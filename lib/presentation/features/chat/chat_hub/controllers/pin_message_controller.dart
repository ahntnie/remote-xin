import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../base/all.dart';
import '../../../all.dart';
import '../views/widgets/pin_messages_widget.dart';

class PinMessageController extends BaseController {
  final Conversation conversation;

  final ChatRepository _chatRepository = Get.find<ChatRepository>();

  final RxList<Message> _pinnedMessages = <Message>[].obs;
  LinkedHashMap<String, Message> _pinnedMessagesMap = LinkedHashMap();

  PinMessageController(this.conversation);

  RxInt currentReplyIndex = (-1).obs;

  @override
  void onInit() {
    getPinMessages(conversation.id);
    super.onInit();
  }

  Future getPinMessages(String conversationId) async {
    await runAction(
      action: () async {
        _pinnedMessagesMap =
            await _chatRepository.getPinnedMessages(conversationId);

        pinnedMessages = _pinnedMessagesMap.values.toList();

        loadCurrentReply();
        Future.delayed(const Duration(milliseconds: 1000), () {
          scrollToIndex(currentReplyIndex.value);
        });
      },
    );
  }

  void loadCurrentReply() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_pinnedMessagesMap.values.toList().isNotEmpty) {
        currentReplyIndex.value = _pinnedMessagesMap.values.toList().length - 1;
      }
    });
  }

  void nextReplyMessage() {
    if (currentReplyIndex.value - 1 >= 0) {
      currentReplyIndex.value--;
    } else {
      currentReplyIndex.value = _pinnedMessagesMap.values.toList().length - 1;
    }
    scrollToIndex(currentReplyIndex.value);
    update();
  }

  final ScrollController scrollController = ScrollController();

  // Hàm scrollToIndex để cuộn đến vị trí index
  void scrollToIndex(int index) {
    double containerHeight;
    if (pinnedMessages.length == 1) {
      containerHeight = 50; // Full height
    } else if (pinnedMessages.length == 2) {
      containerHeight = 50 / 2; // Half height
    } else {
      containerHeight = 50 / 3;
    }

    final position = containerHeight *
        index; // Chiều cao của Container trong ListView.builder
    scrollController.animateTo(
      position,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future pinMessage(Message message) async {
    if (isMessagePinned(message.id)) {
      ViewUtil.showAppSnackBarNewFeeds(
        title: Get.context!.l10n.conversation__pinned_message,
      );

      return;
    }
    _addMessage(message);
    await _updateMessage(message);
  }

  Future unPinMessage(Message message) async {
    if (!isMessagePinned(message.id)) {
      return;
    }
    _removeMessage(message);
    await _updateMessage(message);
  }

  Future _updateMessage(Message message) async {
    await runAction(
      action: () async {
        await _chatRepository.updatePinMessage(
          conversation.id,
          _pinnedMessagesMap.keys.toList(),
        );
      },
      onSuccess: () async {
        if (_pinnedMessagesMap.length > _pinnedMessages.length) {
          _pinnedMessages.add(message);
        } else {
          _pinnedMessages.removeWhere(
            (element) => element.id == message.id,
          );
        }
        _pinnedMessages.refresh();
      },
      onError: (exception) {
        if (_pinnedMessagesMap.length > _pinnedMessages.length) {
          _pinnedMessagesMap.remove(message.id);
        } else {
          _pinnedMessagesMap.putIfAbsent(message.id, () => message);
        }
      },
    );
  }

  Future _unPinAllMessage() async {
    if (pinnedMessages.isEmpty) {
      return;
    }
    await runAction(
      action: () async {
        await _chatRepository.updatePinMessage(
          conversation.id,
          _pinnedMessagesMap.keys.toList(),
        );
      },
    );
  }

  void _addMessage(Message message) {
    _pinnedMessagesMap[message.id] = message;
    loadCurrentReply();
  }

  void _removeMessage(Message message) {
    _pinnedMessagesMap.remove(message.id);
    loadCurrentReply();
  }

  bool isMessagePinned(String messageId) =>
      _pinnedMessagesMap.containsKey(messageId);

  List<Message> get pinnedMessages => _pinnedMessages;

  RxList<Message> get rxPinnedMessages => _pinnedMessages;

  set pinnedMessages(List<Message> value) => _pinnedMessages.assignAll(value);

  void showListPinnedMessages() {
    ViewUtil.showBottomSheet(
      child: const PinMessagesWidget(),
      heightFactor: 0.9,
      enableDrag: false,
    );
  }

  void onMessageClick(Message message) {
    if (Get.isRegistered<ChatHubController>()) {
      Get.find<ChatHubController>().jumpToMessage(message);
      nextReplyMessage();
    }
  }

  Future unPinAllMessage() async {
    _pinnedMessagesMap.clear();
    await _unPinAllMessage();
    _pinnedMessages.clear();
    loadCurrentReply();
  }
}
