import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/view_util.dart';
import '../../../../../models/conversation.dart';
import '../../../../../models/user.dart';
import '../../../../../repositories/all.dart';
import '../../../../../usecases/get_conversation_usecase.dart';
import '../../../../base/base_controller.dart';
import '../../../all.dart';

class ConversationMembersArguments {
  final Conversation conversation;

  const ConversationMembersArguments({
    required this.conversation,
  });
}

class ConversationMembersController extends BaseController {
  final ChatRepository _chatRepo = Get.find();

  late Conversation conversation;
  final _userRepository = Get.find<UserRepository>();

  final _members = <User>[].obs;
  List<User> get members => _members;

  Rx<bool> isLoadingMembers = false.obs;

  bool get canRemoveMembers =>
      conversation.creatorId == currentUser.id ||
      conversation.isAdmin(currentUser.id);

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as ConversationMembersArguments;
    conversation = args.conversation;
    getMemberLists();

    // _getConversationDetails();

    // searchMemberResult.value = args.conversation.members;
  }

  Future getMemberLists() async {
    isLoadingMembers.value = true;
    if (conversation.members.isNotEmpty) {
      _members.assignAll(conversation.members);
      searchMemberResult.value = members;
    } else {
      final members =
          await _userRepository.getUsersByIds(conversation.memberIds);
      _members.assignAll(members);
      searchMemberResult.value = members;
    }
    isLoadingMembers.value = false;
  }

  Future<void> _getConversationDetails() async {
    return runAction(
      action: () async {
        final updatedConversation =
            await GetConversationUseCase().call(conversation.id);

        updateMembers(updatedConversation.members);

        conversation = updatedConversation;
      },
    );
  }

  void updateMembers(List<User> members) {
    // order creator > admin > you > others
    final sortedMembers = List<User>.from(
      members
        ..sort(
          (a, b) {
            if (a.id == conversation.creatorId) {
              return -1;
            } else if (conversation.isAdmin(a.id)) {
              return -1;
            } else if (a.id == currentUser.id) {
              return -1;
            } else {
              return 1;
            }
          },
        ),
    );

    _members.assignAll(sortedMembers);
  }

  Future<void> removeMember(User member) async {
    return runAction(action: () async {
      await _chatRepo.updateConversationMembers(
        conversationId: conversation.id,
        membersIds:
            members.where((m) => m.id != member.id).map((m) => m.id).toList(),
        adminIds: conversation.adminIds,
      );

      _members.removeWhere((m) => m.id == member.id);

      // updateConversation(conversation.copyWith(members: members));

      final membersValue =
          conversation.members.where((m) => m.id != member.id).toList();
      final memberIds =
          conversation.memberIds.where((m) => m != member.id).toList();

      updateConversation(conversation.copyWith(
        members: membersValue,
        memberIds: memberIds,
      ));

      ViewUtil.showToast(
          title: l10n.global__success_title,
          message: l10n.conversation_members__remove_confirm_title);

      Future.delayed(const Duration(seconds: 1), () {
        searchUserInGroup(searchController.text.trim());
      });
    });
  }

  Future<void> addMember(User member) async {
    return runAction(action: () async {
      await _chatRepo.updateConversationMembers(
        conversationId: conversation.id,
        membersIds: [...members.map((m) => m.id), member.id],
        adminIds: conversation.adminIds,
      );

      _members.add(member);

      updateConversation(conversation.copyWith(members: members));

      final membersValue = [...members, member];

      final memberIdsValue = [...conversation.memberIds, member.id];

      updateConversation(conversation.copyWith(
        members: membersValue,
        memberIds: memberIdsValue,
      ));

      ViewUtil.showToast(
          title: l10n.global__success_title,
          message: l10n.conversation_members__add_member);
      Future.delayed(const Duration(seconds: 1), () {
        searchUserInGroup(searchController.text.trim());
      });
    });
  }

  void updateConversation(Conversation updatedConversation) {
    conversation = updatedConversation;
    Get.find<ConversationDetailsController>()
        .updateConversation(updatedConversation);
    Get.find<ChatHubController>().conversationUpdated(updatedConversation);
  }

  void promoteOrRemoveAdmin(User member, bool isAddAdmin) {
    final adminIds = isAddAdmin
        ? [...conversation.adminIds, member.id]
        : conversation.adminIds.where((id) => id != member.id).toList();

    runAction(action: () async {
      await _chatRepo.updateConversationMembers(
        conversationId: conversation.id,
        membersIds: conversation.memberIds,
        adminIds: adminIds,
      );

      updateConversation(
        conversation.copyWith(
          adminIds: adminIds,
          admins: members.where((m) => adminIds.contains(m.id)).toList(),
        ),
      );

      updateMembers(members);
    });
  }

  Future<void> goToPrivateChat(User member) async {
    // Pop utils `call-gateway` page
    // Get.until((route) => route.settings.name == Routes.callGateway);

    final dashboardController = Get.find<ChatDashboardController>();

    return dashboardController.goToPrivateChat(member);
  }

  RxList<User> searchMemberResult = <User>[].obs;

  TextEditingController searchController = TextEditingController();

  List<User> searchUsersByQuery(List<User> users, String query) {
    // Chuyển query về chữ thường để không phân biệt chữ hoa, chữ thường
    final String lowerCaseQuery = query.toLowerCase();

    // Lọc danh sách user theo điều kiện
    return users.where((user) {
      return (query.isEmpty) ||
          (user.nickname ?? '').toLowerCase().contains(lowerCaseQuery) ||
          (user.email ?? '').toLowerCase().contains(lowerCaseQuery) ||
          (user.phone ?? '').toLowerCase().contains(lowerCaseQuery) ||
          (user.webUserId ?? '').toLowerCase().contains(lowerCaseQuery);
    }).toList();
  }

  void searchUserInGroup(String query) {
    searchMemberResult.value = searchUsersByQuery(_members, query);
    update();
  }
}
