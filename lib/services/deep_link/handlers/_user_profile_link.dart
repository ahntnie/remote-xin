import 'dart:async';

import 'package:get/get.dart';

import '../../../presentation/common_controller.dart/app_controller.dart';
import '../../../presentation/features/chat/chat_hub/controllers/chat_hub_controller.dart';
import '../../../presentation/routing/routers/app_pages.dart';
import '../../../repositories/all.dart';
import '../deep_link_service.dart';

class UserProfileLinkHandler extends DeepLinkHandler {
  final _userRepository = Get.find<UserRepository>();
  final _chatRepository = Get.find<ChatRepository>();

  @override
  String get prefix => '/user';

  @override
  Future<void> handle(dynamic id) async {
    final currentUser = Get.find<AppController>().currentUser;

    final userId = int.tryParse(id);

    if (userId == null) {
      return;
    }

    if (currentUser.id == userId) {
      return;
    }

    final conversation = await _chatRepository.createConversation([userId]);
    if (Get.currentRoute == Routes.chatHub) {
      final controller = Get.find<ChatHubController>();

      if (controller.conversation.id != conversation.id) {
        controller.reloadWithNewConversation(conversation);

        return;
      }
    } else {
      unawaited(
        Get.toNamed(
          Routes.chatHub,
          arguments: ChatHubArguments(conversation: conversation),
        ),
      );
    }

    // final user = await _userRepository.getUserById(id);

    // unawaited(
    //   Get.toNamed(
    //     Routes.posterPersonal,
    //     arguments: {'user': user},
    //   ),
    // );
  }
}
