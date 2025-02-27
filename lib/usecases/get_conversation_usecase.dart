import 'package:get/get.dart';

import '../models/conversation.dart';
import '../models/user.dart';
import '../presentation/common_controller.dart/user_pool.dart';
import '../repositories/all.dart';

class GetConversationUseCase {
  final ChatRepository _chatRepository = Get.find();
  final UserRepository _userRepository = Get.find();

  GetConversationUseCase();

  Future<Conversation> call(String conversationId) async {
    final conversation = await _chatRepository.getConversationById(
      conversationId: conversationId,
    );

    final members = <User>[];

    final userPool = Get.find<UserPool>();

    for (final memberId in conversation.memberIds) {
      final cachedUser = userPool.getUser(memberId);

      if (cachedUser != null) {
        members.add(cachedUser);
      } else {
        final member = await _userRepository.getUserById(memberId);
        members.add(member);
      }
    }

    if (!members.any((element) => element.id == conversation.creatorId)) {
      final creator = await _userRepository.getUserById(conversation.creatorId);
      members.add(creator);
    }

    return conversation.copyWith(members: members);
  }
}
