import 'dart:async';

import 'package:get/get.dart';

import '../../../presentation/common_controller.dart/all.dart';
import '../../../presentation/features/chat/chat_hub/controllers/chat_hub_controller.dart';
import '../../../presentation/routing/routers/app_pages.dart';
import '../../../repositories/chat_repo.dart';
import '../deep_link_service.dart';

class InviteGroupChatLinkHandler extends DeepLinkHandler {
  final _chatRepo = Get.find<ChatRepository>();

  @override
  String get prefix => '/conversation';

  @override
  Future<void> handle(dynamic id) async {
    final conversation =
        await _chatRepo.getConversationById(conversationId: id);

    final currentUser = Get.find<AppController>().currentUser;

    if (!conversation.memberIds.contains(currentUser.id)) {
      await _chatRepo.updateConversationMembers(
        conversationId: id,
        adminIds: conversation.adminIds,
        membersIds: [...conversation.memberIds, currentUser.id],
      );
    }

    if (Get.currentRoute == Routes.chatHub) {
      final controller = Get.find<ChatHubController>();

      if (controller.conversation.id != conversation.id) {
        controller.reloadWithNewConversation(conversation);

        return;
      }
    }

    unawaited(
      Get.toNamed(
        Routes.chatHub,
        arguments: ChatHubArguments(conversation: conversation),
      ),
    );
  }
}
