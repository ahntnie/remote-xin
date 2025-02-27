import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../../services/newsfeed_interact_service.dart';
import '../../../base/base_controller.dart';

class SharePostController extends BaseController {
  final _newsfeedRepository = Get.find<NewsfeedRepository>();
  final _chatRepository = Get.find<ChatRepository>();

  RxList<UserContact> userContacts = <UserContact>[].obs;

  TextEditingController searchController = TextEditingController();

  void getUserSharePost() {
    runAction(action: () async {
      final user = await _newsfeedRepository.getUserShare(
        userId: currentUser.id,
        search: searchController.text,
      );

      userContacts.value = user;
    });
  }

  void searchUserSharePost(String search) {
    runAction(
      handleLoading: false,
      action: () async {
        final user = await _newsfeedRepository.getUserShare(
          userId: currentUser.id,
          search: search,
        );

        userContacts.clear();
        userContacts.value = user;
      },
    );
  }

  void onSharePost({
    required UserContact userContact,
    required Post post,
  }) {
    runAction(
      handleLoading: false,
      action: () async {
        final Conversation conversation =
            await _chatRepository.createConversation([userContact.user!.id]);

        final toSendMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversation.id,
          content: jsonEncode(post.toJson()),
          type: MessageType.post,
          createdAt: DateTime.now(),
          senderId: currentUser.id,
          sender: currentUser,
        );

        await _chatRepository.sendMessage(toSendMessage);
        update();

        ViewUtil.showToast(
          title: l10n.notification__title,
          message: l10n.newsfeed__share_post_success,
        );
      },
      onError: (exception) {
        update();
      },
    );
  }

  void onSharePostToPersonalPage({
    required Post post,
  }) {
    runAction(
      handleLoading: false,
      action: () async {
        final int postId = post.originalPost?.id ?? post.id;

        final result = await _newsfeedRepository.sharePostToPersonal(
          postId: postId,
          type: PostType.post.name,
        );
        Get.find<NewsfeedInteractService>().sharePost(postId);
        Get.back(result: result);
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.newsfeed__share_post_failed,
        );
      },
    );
  }
}
