import 'dart:async';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../events/messages/leave_group_chat_event.dart';
import '../../../../../models/all.dart';
import '../../../../../models/enums/mute_conversation_option_enum.dart';
import '../../../../../repositories/all.dart';
import '../../../../base/base_controller.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../../call/call.dart';
import '../../chat_hub/controllers/chat_hub_controller.dart';
import '../../conversation_members/controllers/conversation_members_controller.dart';
import '../../conversation_resources/controllers/conversation_resources_controller.dart';

class ConversationDetailsArguments {
  final Conversation conversation;

  const ConversationDetailsArguments({
    required this.conversation,
  });
}

class ConversationDetailsController extends BaseController {
  final ChatRepository _chatRepository = Get.find();
  final StorageRepository _storageRepository = Get.find();
  final SharedLinkRepository _sharedLinkRepository = Get.find();
  final UserRepository _userRepository = Get.find();
  final ContactRepository _contactRepository = Get.find();

  late final Rx<Conversation> _conversation;

  Conversation get conversation => _conversation.value;

  final conversationNameController = TextEditingController();
  final _newAvatar = Rxn<File>();

  File? get newAvatar => _newAvatar.value;

  final _isEdited = false.obs;

  bool get isEdited => _isEdited.value;

  bool isConversationUpdated = false;

  bool get isCreatorOrAdmin => conversation.isCreatorOrAdmin(currentUser.id);

  RxList<UserContact> userContactList = <UserContact>[].obs;

  final Rx<User?> _userPartner = Rx(null);

  Rx<User?> get userPartner => _userPartner;

  final _eventBus = Get.find<EventBus>();

  @override
  Future<void> onInit() async {
    super.onInit();
    final args = Get.arguments as ConversationDetailsArguments;
    _conversation = args.conversation.obs;
    conversationNameController.text = conversation.name;

    if (!conversation.isGroup) {
      await _getContactInfo();
    }
  }

  @override
  void onClose() {
    conversationNameController.dispose();
    super.onClose();
  }

  Future<void> _getContactInfo() async {
    await getUserById(_conversation.value.chatPartner()!.id);
    await checkContactExist();
  }

  void validateIsEdited() {
    _isEdited.value = conversationNameController.text != conversation.name ||
        newAvatar != null;
  }

  void goToChatResources() {
    Get.toNamed(
      Routes.conversationResources,
      arguments: ConversationResourcesArguments(conversation: conversation),
    );
  }

  void onDeleteChat(BuildContext context) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.delete_chat__confirm_title,
      message: context.l10n.delete_chat__confirm_message,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__confirm,
      onPositivePressed: deleteChat,
    );
  }

  void deleteChat() {
    runAction(action: () async {
      await _chatRepository.deleteConversation(conversation);
      // Back 2 times to go back to the chat list
      Get.back();
      Get.back();
    });
  }

  void saveChanges() {
    if (!isEdited) {
      return;
    }

    if (conversationNameController.text.isEmpty) {
      ViewUtil.showToast(
        title: Get.context!.l10n.notification__title,
        message: Get.context!.l10n.conversation_details__error_empty_chat_name,
      );
    }

    runAction(action: () async {
      String? avatarUrl;
      if (newAvatar != null) {
        avatarUrl = await _storageRepository.uploadConversationAvatar(
          conversationId: conversation.id,
          file: newAvatar!,
        );
      }

      _conversation.value = await _chatRepository.updateGroupChatInfo(
        conversation: conversation,
        name: conversationNameController.text.trim(),
        avatarUrl: avatarUrl,
      );

      _newAvatar.value = null;
      _isEdited.value = false;
      isConversationUpdated = true;
    });
  }

  Future<void> pickImage() async {
    final pickedImage = await MediaHelper.pickImageFromGallery();

    if (pickedImage == null) {
      return;
    }

    _newAvatar.value = pickedImage.file;

    validateIsEdited();
  }

  void updateConversation(Conversation updatedConversation) {
    _conversation.value = updatedConversation;
    Get.find<ChatHubController>().conversationUpdated(updatedConversation);
    update();
  }

  void goToChatMembers() {
    Get.toNamed(
      Routes.conversationMembers,
      arguments: ConversationMembersArguments(conversation: conversation),
    );
  }

  Future<String> getSharedLink() async {
    late String sharedLink;

    await runAction(action: () async {
      sharedLink = await _sharedLinkRepository.getSharedLink(
        type: SharedLinkType.conversation,
        id: conversation.id,
      );
    });

    return sharedLink;
  }

  void onCallVoiceClick() {
    CallKitManager.instance.createCall(
      chatChannelId: conversation.id,
      receiverIds: conversation.memberIds
          .where((element) => element != currentUser.id)
          .toList(),
      isGroup: conversation.isGroup,
      isVideo: false,
      isTranslate: false,
    );
  }

  void onCallVideoClick() {
    CallKitManager.instance.createCall(
      chatChannelId: conversation.id,
      receiverIds: conversation.memberIds
          .where((element) => element != currentUser.id)
          .toList(),
      isGroup: conversation.isGroup,
      isVideo: true,
      isTranslate: false,
    );
  }

  Future<void> getUserById(int userId) async {
    await runAction(
      handleLoading: false,
      action: () async {
        final userPartner = await _userRepository.getUserById(userId);

        unawaited(Get.find<UserPool>().storeUser(userPartner));

        _conversation.value.members[_conversation.value.members
            .indexWhere((element) => element.id == userId)] = userPartner;

        _userPartner.value = userPartner;
      },
    );
  }

  String getInfoPartner() {
    final String phone = _userPartner.value?.phone ?? '';
    final String nickname = _userPartner.value?.nickname ?? '';

    if (phone.isNotEmpty && nickname.isNotEmpty) {
      return '$phone • @$nickname';
    } else if (phone.isNotEmpty) {
      return phone;
    } else if (nickname.isNotEmpty) {
      return '@$nickname';
    } else {
      return '';
    }
  }

  String getEmailPartner() {
    return _userPartner.value?.email ?? '';
  }

  String getPhonePartner() {
    return _userPartner.value?.phone ?? '';
  }

  Future<void> checkContactExist() async {
    await runAction(
      handleLoading: false,
      action: () async {
        final resultContactList = await _contactRepository.checkContactExist(
          phoneNumber: getPhonePartner(),
          userId: currentUser.id,
        );

        userContactList.assignAll(resultContactList);
      },
    );
  }

  void onAddContactClick({required UserContact userContact}) {
    runAction(
      action: () async {
        final resultsContact =
            await _contactRepository.addContact([userContact]);

        Get.find<UserPool>().updateContact(userContact);

        if (resultsContact.created.isNotEmpty) {
          userContactList.add(resultsContact.created.first);

          Get.back();

          ViewUtil.showToast(
            title: l10n.global__success_title,
            message: l10n.contact__add_success,
          );
        } else if (resultsContact.notCreated.existed.isNotEmpty) {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.contact__already_exist,
          );
        } else if (resultsContact.notCreated.notFounds.isNotEmpty) {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.contact__no_exist,
          );
        } else {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.global__error_has_occurred,
          );
        }
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.global__error_has_occurred,
        );
      },
    );
  }

  void onEditContactClick({required UserContact userContact}) {
    runAction(
      action: () async {
        final List<UserContact> resultsContact =
            await _contactRepository.updateContactById(userContact);
        if (resultsContact.isNotEmpty) {
          final index = userContactList
              .indexWhere((element) => element.id == userContact.id);
          userContactList[index] = resultsContact.first;
          Get.find<UserPool>().updateContact(resultsContact.first);
        }

        Get.back();
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.global__error_has_occurred,
        );
      },
    );
  }

  void onLeaveGroupChat() {
    runAction(action: () async {
      await _chatRepository.leaveGroupChat(conversation.id);
      // Back 2 times to go back to the chat list
      Get.back();
      Get.back();
      _eventBus.fire(LeaveGroupEvent());
    });
  }

  void onBlockChat(BuildContext context) {
    if (conversation.isGroup) {
      return;
    }

    final chatHubController = Get.find<ChatHubController>();

    chatHubController.blockUser(conversation.chatPartner()!.id);

    Get.back();
  }

  void onMuteConversation(MuteConversationOption e) {
    runAction(
      action: () async {
        await _chatRepository.muteConversation(
          conversationId: conversation.id,
          muteOption: e,
        );
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: Get.context!.l10n.notification__title,
          message: l10n.error__unknown,
        );

        LogUtil.e(exception, name: runtimeType.toString());
      },
      onSuccess: () async {
        // update current conversation ui
        _conversation.value = conversation.copyWith(isMuted: true);
        // update chat hub view
        updateMuteInChatHubView(true);

        ViewUtil.showToast(
          title: Get.context!.l10n.notification__title,
          message: e.labelName(l10n),
        );
      },
    );
  }

  void onUnMuteConversation() {
    runAction(
      action: () async {
        await _chatRepository.unMuteConversation(conversation.id);
      },
      onSuccess: () async {
        _conversation.value = conversation.copyWith(isMuted: false);
        // update chat hub view
        updateMuteInChatHubView(false);
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: Get.context!.l10n.notification__title,
          message: l10n.error__unknown,
        );

        LogUtil.e(exception, name: runtimeType.toString());
      },
    );
  }

  void updateMuteInChatHubView(bool mute) {
    if (Get.isRegistered<ChatHubController>()) {
      final chatHubController = Get.find<ChatHubController>();
      chatHubController.conversationUpdated(
        chatHubController.conversation.copyWith(
          isMuted: mute,
        ),
      );
    }
  }

  void onCallVideoGroupClick() {
    if (Get.isRegistered<ChatHubController>()) {
      final chatHubController = Get.find<ChatHubController>();
      chatHubController.onCallVideoGroupTap();
    }
  }

  Future<void> addMember(User member) async {
    return runAction(action: () async {
      await _chatRepository.updateConversationMembers(
        conversationId: conversation.id,
        membersIds: [...conversation.members.map((m) => m.id), member.id],
        adminIds: conversation.adminIds,
      );
      // final List<User> members = [];
      // members.assignAll(conversation.members);
      // members.add(member);
      // // _members.add(member);

      // updateConversation(conversation.copyWith(members: members));

      final members = [..._conversation.value.members, member];
      final memberIds = [..._conversation.value.memberIds, member.id];

      updateConversation(conversation.copyWith(
        members: members,
        memberIds: memberIds,
      ));

      ViewUtil.showToast(
          title: l10n.global__success_title,
          message: l10n.conversation_members__add_member);
    });
  }
}
