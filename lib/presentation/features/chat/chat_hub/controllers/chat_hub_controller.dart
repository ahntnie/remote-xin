import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:stipop_sdk/model/sp_sticker.dart';

import '../../../../../core/all.dart';
import '../../../../../events/messages/leave_group_chat_event.dart';
import '../../../../../models/all.dart';
import '../../../../../models/unread_message.dart';
import '../../../../../repositories/all.dart';
import '../../../../../repositories/missions/translate_repo.dart';
import '../../../../../services/all.dart';
import '../../../../../usecases/get_user_by_id_with_pool_usecase.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/language_controller.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../../call/controllers/call_kit_manager.dart';
import '../../../report/report_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../views/widgets/text_message_widget.dart';
import 'pin_message_controller.dart';

const _boxName = 'chat_hub';

class ChatHubArguments {
  final Conversation? conversation;
  final String? conversationId;
  final Function()? leadingIconOnTap;
  final bool isBot;

  const ChatHubArguments({
    this.conversation,
    this.conversationId,
    this.leadingIconOnTap,
    this.isBot = true,
  }) : assert(conversation != null || conversationId != null);
}

class ChatHubController extends BaseLoadMoreController<Message>
    with WidgetsBindingObserver {
  @override
  String get boxName => _boxName;

  final _chatRepository = Get.find<ChatRepository>();
  final _userRepository = Get.find<UserRepository>();
  final _storageRepository = Get.find<StorageRepository>();
  final _translateRepository = Get.find<TranslateRepository>();
  final chatDashboardController = Get.find<ChatDashboardController>();

  final _conversation = Rxn<Conversation?>();
  final Rxn<Message> _replyFromMessage = Rxn<Message>();

  Message? get replyFromMessage => _replyFromMessage.value;

  set replyFromMessage(Message? value) => _replyFromMessage.value = value;

  Conversation get conversation => _conversation.value!;

  bool get isConversationInitiated => _conversation.value != null;

  final _chatSocketService = Get.find<ChatSocketService>();

  Rx<bool> isShowDelete = false.obs;

  late StreamSubscription _newMessageSubscription;
  late StreamSubscription _conversationDeletedSubscription;
  late StreamSubscription _messageDeletedSubscription;
  late StreamSubscription _leaveConversationSubscription;
  late StreamSubscription _reactionToMessageSubscription;
  late StreamSubscription _unReactionToMessageSubscription;
  late StreamSubscription _addUserToGroupSubscription;
  late StreamSubscription _messageSeenSubscription;

  final _isOnline = false.obs;

  bool get isOnline => _isOnline.value;
  var isTranslateMessage = false.obs;

  var translateLanguageMessageIndex = 1.obs;
  var translateMessageMap = <String, String>{}.obs;

  // for pip view
  Function()? leadingIconOnTap;
  final ChatHubArguments arguments = Get.arguments as ChatHubArguments;

  @override
  bool get getListWhenInit => false;

  bool get isCreatorOrAdmin => conversation.isCreatorOrAdmin(currentUser.id);

  void reloadWithNewConversationId(String conversationId) {
    _initConversation(ChatHubArguments(conversationId: conversationId));
  }

  void reloadWithNewConversation(Conversation conversation) {
    _initConversation(ChatHubArguments(conversation: conversation));
  }

  final _debouncer = Debouncer(delay: const Duration(seconds: 2));

  /// variable for selected mode in conversation
  RxBool isSelectMode = false.obs;

  /// variable for selected message in conversation
  RxList<Message> listMessageSelected = <Message>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await ensureInitStorage();

    try {} catch (e) {
      Get.back();

      return;
    }
    leadingIconOnTap = arguments.leadingIconOnTap;
    WidgetsBinding.instance.addObserver(this);
    _setupSocketListener();

    unawaited(_initConversation(arguments));

    final languageController = Get.find<LanguageController>();

    if (languageController.currentIndex.value == 0) {
      translateLanguageMessageIndex.value = 1;
    } else {
      translateLanguageMessageIndex.value = 0;
    }
    update();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // Store the first page of messages to cache
    if (pagingController.itemList != null) {
      _storeMessages(
        conversationId: conversation.id,
        messages: (pagingController.itemList ?? []).sublist(
          0,
          min(pagingController.itemList!.length, pageSize),
        ),
      );
    }

    // updateLastSeenMessage();
    chatDashboardController.updateConversation(conversation.copyWith(
      messages: (pagingController.itemList ?? []).sublist(
        0,
        min(pagingController.itemList!.length, pageSize),
      ),
    ));

    _newMessageSubscription.cancel();
    _conversationDeletedSubscription.cancel();
    _messageDeletedSubscription.cancel();
    _leaveConversationSubscription.cancel();
    _reactionToMessageSubscription.cancel();
    _unReactionToMessageSubscription.cancel();
    _addUserToGroupSubscription.cancel();
    _messageSeenSubscription.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // refreshData();
    }
  }

  void replaceConversation(ChatHubArguments arg) {
    const PaginatedList<Message> firstPage = PaginatedList(
      items: [],
      currentPage: 1,
      pageSize: 30,
    );
    pagingController.appendPaginatedList(firstPage);
    leadingIconOnTap = arg.leadingIconOnTap;

    unawaited(_initConversation(arg));
    update();
  }

  void setIsShowDelete() {
    if (conversation.isGroup && conversation.creatorId == currentUser.id) {
      isShowDelete.value = true;
    } else {
      isShowDelete.value = true;
      for (var message in listMessageSelected) {
        if (message.senderId != currentUser.id) {
          isShowDelete.value = false;
          break;
        }
      }
    }
  }

  void _storeMessages({
    required String conversationId,
    required List<Message> messages,
  }) {
    write(
      conversationId,
      jsonEncode(messages.map((message) => message.toJson()).toList()),
    );
    try {
      findIndexLastSeen(
        lastSeenUsers: lastSeenUser,
        messages: messages,
      );
    } catch (e) {
      LogUtil.e(e);
    }
  }

  void _loadCachedMessages({required String conversationId}) {
    final cachedMessages = readSync(conversationId);

    if (cachedMessages == null) {
      return;
    }

    final messages = (jsonDecode(cachedMessages) as List)
        .map((message) => Message.fromJson(message as Map<String, dynamic>))
        .toList();

    final firstPage = PaginatedList(
      items: messages,
      currentPage: initialPage,
      pageSize: pageSize,
    );

    pagingController.appendPaginatedList(firstPage);

    try {
      if (firstPage.items.isNotEmpty) {
        findIndexLastSeen(
          lastSeenUsers: lastSeenUser,
          messages: firstPage.items,
        );
      }
    } catch (e) {
      LogUtil.e(e);
    }
  }

  void _setupSocketListener() {
    _newMessageSubscription =
        _chatSocketService.newMessageStream.listen(_onNewMessage);

    _conversationDeletedSubscription = _chatSocketService
        .onConversationDeletedStream
        .listen(_onConversationDeleted);

    _messageDeletedSubscription =
        _chatSocketService.onMessageDeletedStream.listen((event) {
      final messageId = event['messageId'] as String?;

      deleteMessageOnSocket(messageId!);
    });

    _leaveConversationSubscription = Get.find<EventBus>().on().listen((event) {
      if (event is LeaveGroupEvent) {
        _showLeaveGroupSuccess();
      }
    });

    _reactionToMessageSubscription =
        _chatSocketService.onReactToMessageStream.listen((event) {
      final messageId = event['messageId'] as String?;
      final reactionType = event['reactionType'] as String?;
      final userId = event['userId'] as String?;

      final message = pagingController.itemList
          ?.firstWhereOrNull((element) => element.id == messageId);

      if (message != null) {
        reactToMessage(
          message,
          reactionType!,
          isCallToApi: false,
          userId: userId!,
          isSocket: true,
        );
      }
    });

    _unReactionToMessageSubscription =
        _chatSocketService.onUnReactToMessageStream.listen((event) {
      final messageId = event['messageId'] as String?;
      final reactionType = event['reactionType'] as String?;
      final userId = event['userId'] as String?;

      final message = pagingController.itemList
          ?.firstWhereOrNull((element) => element.id == messageId);

      if (message != null) {
        reactToMessage(
          message,
          reactionType!,
          isCallToApi: false,
          userId: userId!,
          isSocket: true,
          isRemoveReaction: true,
        );
      }
    });

    _addUserToGroupSubscription =
        _chatSocketService.onAddOrRemoveUserToGroupStream.listen((event) {
      if (event.roomId == conversation.id) {
        addOrRemoveUserToGroup(
          addUsers: event.addedMembers,
          removeUsers: event.removedMembers,
        );
      }
    });

    _messageSeenSubscription =
        _chatSocketService.onSeenToMessageStream.listen(_onSeenMessage);
  }

  void _listenToActiveUsers() {
    if (conversation.isGroup) {
      return;
    }

    final partnerId = conversation.members
        .whereNot((member) => member.id == currentUser.id)
        .firstOrNull
        ?.id;

    if (partnerId == null) {
      return;
    }

    _chatSocketService.activeUsersStream.listen((activeUsers) {
      _isOnline.value = activeUsers.contains(partnerId);
    });
  }

  void conversationUpdated(Conversation newConversation) {
    _conversation.value = newConversation;
    update();
  }

  Future<void> _initConversation(ChatHubArguments arguments) async {
    var conversation = arguments.conversation != null
        ? arguments.conversation!
        : await _getConversationById(arguments.conversationId!);

    if (!conversation.isGroup) {
      final senderId = conversation.memberIds.firstWhereOrNull(
        (element) => element != currentUser.id,
      );

      if (senderId != null) {
        final sender = await GetUserByIdWithUserPoolUsecase().call(senderId);

        conversation = conversation.copyWith(
          members: [sender],
        );
      }
    }

    _conversation.value = conversation;

    _loadCachedMessages(
      conversationId: conversation.id,
    );

    unawaited(refreshDataMessage());

    updateLastSeenMessage();
    // _listenToActiveUsers();

    unawaited(loadConversationMembers());
  }

  Future<Conversation> _getConversationById(String conversationId) async {
    late Conversation conversation;

    await runAction(
      handleLoading: false,
      action: () async {
        conversation = await _chatRepository.getConversationById(
          conversationId: conversationId,
        );
      },
    );

    return conversation;
  }

  Future refreshDataMessage() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!Get.isRegistered<ChatHubController>()) {
      return;
    }
    await refreshData();
  }

  Future<void> loadConversationMembers() async {
    // _debouncer.run(() async {
    //   if (conversation.memberIds.length == conversation.members.length) {
    //     return;
    //   }

    //   final members =
    //       await _userRepository.getUsersByIds(conversation.memberIds);

    //   _conversation.value = conversation.copyWith(
    //     members: members,
    //   );
    // });

    await Future.delayed(const Duration(seconds: 2));
    if (!Get.isRegistered<ChatHubController>()) {
      return;
    }
    if (conversation.memberIds.length == conversation.members.length) {
      return;
    }

    final members = await _userRepository.getUsersByIds(conversation.memberIds);

    _conversation.value = conversation.copyWith(
      members: members,
    );

    // if (conversation.memberIds.length == 2) {
    //   final userPool = Get.find<UserPool>();
    //   for (final member in members) {
    //     await userPool.storeUser(member);
    //   }
    // }
  }

  @override
  Future<PaginatedList<Message>> fetchPaginatedList({
    required int page,
    required int pageSize,
  }) async {
    final messages = await _chatRepository.getPaginatedMessagesByConversationId(
      conversationId: conversation.id,
      page: page,
      pageSize: pageSize,
    );

    final List<Message> messagesWithSender = [];

    final senderIds = messages.map((message) => message.senderId).toSet();

    final senders = await GetUsersByIdsWithUserPoolUsecase().call(senderIds);

    for (final message in messages) {
      messagesWithSender.add(
        message.copyWith(
          sender: senders
              .firstWhereOrNull((sender) => sender.id == message.senderId),
          repliedFrom: addSenderToMessage(message.repliedFrom),
        ),
      );
    }

    if (page == initialPage) {
      _storeMessages(
        conversationId: conversation.id,
        messages: messagesWithSender,
      );
    }

    return PaginatedList(
      items: messagesWithSender,
      currentPage: page,
      pageSize: pageSize,
      isLastPage: messages.length < pageSize,
    );
  }

  Future<void> sendTextMessage(
    String content,
  ) async {
    if (content.trim().isEmpty) {
      return;
    }

    // detect if the message contains link and send it as hyperlink with <hyper> tag

    MessageType type = MessageType.text;

    if (content.contains(RegExp(r'http[s]?://'))) {
      type = MessageType.hyperText;

      final hyperLinks = content.split(RegExp(r'(?=http[s]?://)'));
      final hyperTexts = hyperLinks.map((link) {
        if (link.contains(RegExp(r'\s'))) {
          final linkParts = link.split(RegExp(r'\s'));

          return linkParts.map((part) {
            if (part.contains(RegExp(r'http[s]?://'))) {
              return '<${AppConstants.hyperTextTag}>$part</${AppConstants.hyperTextTag}>';
            }

            return part;
          }).join(' ');
        }

        return '<${AppConstants.hyperTextTag}>$link</${AppConstants.hyperTextTag}>';
      }).join();

      content = hyperTexts;
    }

    final mentionedUsers = _extractMentionedUsers(content);
    final mentionsData = <String, String>{};

    if (mentionedUsers.isNotEmpty) {
      // eg: @'user full name' => @${id}
      for (final user in mentionedUsers) {
        final mentionText =
            userIdMentionWrapper.replaceAll('userId', user.id.toString());
        mentionsData[mentionText] = user.fullName;
        content = content.replaceAll('@${user.fullName}', mentionText);
      }
    }

    final toSendMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      content: content.trim(),
      type: type,
      createdAt: DateTime.now(),
      senderId: currentUser.id,
      sender: currentUser,
      repliedFrom: replyFromMessage,
      mentions: mentionsData,
    );

    _insertMessage(toSendMessage);
    _scrollToBottom();

    return runAction(
      handleLoading: false,
      action: () async {
        final replyMessageId = replyFromMessage?.id;
        clearReplyMessage();
        final newMessage = await _chatRepository.sendMessage(
          toSendMessage,
          replyMessage: replyMessageId,
          mentionsData: mentionsData,
        );

        _replaceMessage(
          oldMessage: toSendMessage,
          newMessage: addSenderToMessage(
            newMessage.copyWith(
              repliedFrom: addSenderToMessage(newMessage.repliedFrom),
            ),
          )!,
        );
      },
    );
  }

  Future<Message?> sendCallGroupMessage(Call call) async {
    final toSendMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      content: jsonEncode(call.toJson()),
      description: 'jitsi',
      type: MessageType.call,
      createdAt: DateTime.now(),
      senderId: currentUser.id,
      sender: currentUser,
      repliedFrom: replyFromMessage,
    );

    _insertMessage(toSendMessage);
    _scrollToBottom();
    Message? message;
    await runAction(
      handleLoading: false,
      action: () async {
        final newMessage = await _chatRepository.sendMessage(
          toSendMessage,
        );

        _replaceMessage(
          oldMessage: toSendMessage,
          newMessage: addSenderToMessage(
            newMessage.copyWith(
              repliedFrom: addSenderToMessage(newMessage.repliedFrom),
            ),
          )!,
        );
        message = newMessage;
      },
      onSuccess: () async {
        clearReplyMessage();
      },
    );

    return message;
  }

  List<User> _extractMentionedUsers(String message) {
    // Currently, the format of mention is @full name (can include space)

    if (!message.contains('@')) {
      return [];
    }

    final mentionUsers = <User>[];

    final mentionPattern = RegExp(r'@([a-zA-Z0-9\s]+)');

    final matches = mentionPattern.allMatches(message);

    for (final match in matches) {
      final mentionedUserText = match.group(1);

      if (mentionedUserText == null) {
        continue;
      }

      final mentionUser = conversation.members.firstWhereOrNull(
        (member) => mentionedUserText.startsWith(member.fullName),
      );

      if (mentionUser != null) {
        mentionUsers.add(mentionUser);
      }
    }

    return mentionUsers;
  }

  void sendMediaMessage({
    required MessageType type,
    required File file,
  }) {
    assert(type != MessageType.text);

    final localMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      content: file.path,
      type: type,
      createdAt: DateTime.now(),
      senderId: currentUser.id,
      sender: currentUser,
      isLocal: true,
      repliedFrom: replyFromMessage,
    );

    _insertMessage(localMessage);
    _scrollToBottom();

    runAction(
      handleLoading: false,
      action: () async {
        String url = '';
        logError('${file.lengthSync()}qqqqq');
        if (type == MessageType.video) {
          file = await MediaService().compressVideo(file) ?? file;
          url = await _storageRepository.uploadConversationMedia(
            file: file,
            messageType: type,
            conversationId: conversation.id,
          );
        }
        logError(file.lengthSync());

        if (file.existsSync()) {
          await file.delete();
        }

        final toSendMessage = localMessage.copyWith(content: url);
        final replyMessageId = replyFromMessage?.id;
        clearReplyMessage();
        final newMessage = await _chatRepository.sendMessage(
          toSendMessage,
          replyMessage: replyMessageId,
        );

        _replaceMessage(
          oldMessage: toSendMessage,
          newMessage: addSenderToMessage(
            newMessage.copyWith(
              repliedFrom: addSenderToMessage(newMessage.repliedFrom),
            ),
          )!,
        );
      },
    );
  }

  void sendImagesMessage({
    required List<File> files,
  }) {
    String path = '';
    // setStateMessage(StateMessage.loading);
    for (var file in files) {
      path = file != files.last ? '$path${file.path} ' : path + file.path;
    }
    final localMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      content: path,
      type: MessageType.image,
      createdAt: DateTime.now(),
      senderId: currentUser.id,
      sender: currentUser,
      isLocal: true,
      repliedFrom: replyFromMessage,
    );

    _insertMessage(localMessage);
    _scrollToBottom();
    // setStateMessage(StateMessage.sending);
    runAction(
      handleLoading: false,
      action: () async {
        String url = '';
        for (var file in files) {
          logError('${file.lengthSync()}qqq');
          file = await MediaService().compressImage(file) ?? file;
          final urlNetwork = await _storageRepository.uploadConversationMedia(
            file: file,
            messageType: MessageType.image,
            conversationId: conversation.id,
          );
          logError(file.lengthSync().toString());
          if (file.existsSync()) {
            await file.delete();
          }
          url = file != files.last ? '$url$urlNetwork ' : url + urlNetwork;
        }
        if (url != '') {
          final toSendMessage = localMessage.copyWith(content: url);
          final replyMessageId = replyFromMessage?.id;
          clearReplyMessage();
          final newMessage = await _chatRepository.sendMessage(
            toSendMessage,
            replyMessage: replyMessageId,
          );

          _replaceMessage(
            oldMessage: toSendMessage,
            newMessage: addSenderToMessage(
              newMessage.copyWith(
                repliedFrom: addSenderToMessage(newMessage.repliedFrom),
              ),
            )!,
          );
          // setStateMessage(StateMessage.sent);
        }
      },
    );
  }

  void clearReplyMessage() {
    replyFromMessage = null;
  }

  Message? addSenderToMessage(Message? message) {
    if (message == null) {
      return null;
    }
    final sender = conversation.members.firstWhereOrNull(
      (member) => member.id == message.senderId,
    );

    return message.copyWith(sender: sender);
  }

  void _insertMessage(Message message) {
    pagingController.insertItemAt(0, message);
    if (indexLastSeen.value != -1) {
      indexLastSeen.value++;
    }
  }

  void _scrollToBottom() {
    anchorScrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onSeenMessage(Map<String, dynamic> data) async {
    final String userId = data['userId'];
    final int lastSeen = data['lastSeen'];

    final updatedLastSeenUsers =
        Map<String, int>.from(conversation.lastSeenUsers ?? {});
    updatedLastSeenUsers[userId] = lastSeen;

    updateConversationLastSeenUser(updatedLastSeenUsers);
  }

  void _replaceMessage({
    required Message oldMessage,
    required Message newMessage,
  }) {
    pagingController.replaceItem(
      oldMessage,
      newMessage,
      comparator: (oldItem, message) => oldItem.id == message.id,
    );
  }

  Future<void> _onNewMessage(Message message) async {
    if (message.conversationId != conversation.id ||
        message.isMine(myId: currentUser.id)) {
      return;
    }

    final isExist =
        pagingController.itemList?.any((element) => element.id == message.id) ??
            false;

    if (isExist) {
      return;
    }

    final sender = await _getSenderById(message.senderId);

    final messageWithSender = message.copyWith(
      sender: sender,
      repliedFrom: addSenderToMessage(message.repliedFrom),
    );

    _insertMessage(messageWithSender);

    updateLastSeenMessage();
  }

  Future<User> _getSenderById(int senderId) async {
    var member = (_conversation.value?.members ?? []).firstWhereOrNull(
      (member) => member.id == senderId,
    );

    if (member == null) {
      member = await GetUserByIdWithUserPoolUsecase().call(senderId);
      _conversation.value = conversation.copyWith(
        members: [
          ...conversation.members,
          member,
        ],
      );
    }

    return member;
  }

  Future onCallVoiceTap() async {
    if (!isConversationInitiated) {
      return;
    }

    if (conversation.isBlocked || conversation.isLocked) {
      return;
    }

    logInfo('onCallVoiceTap');
    await CallKitManager.instance.createCall(
      chatChannelId: conversation.id,
      receiverIds: conversation.memberIds
          .where((element) => element != currentUser.id)
          .toList(),
      isGroup: conversation.isGroup,
      isVideo: false,
      isTranslate: true,
    );
  }

  Future onCallVideoTap() async {
    if (!isConversationInitiated) {
      return;
    }

    if (conversation.isBlocked || conversation.isLocked) {
      return;
    }

    logInfo('onCallVideoTap');
    await CallKitManager.instance.createCall(
      chatChannelId: conversation.id,
      receiverIds: conversation.memberIds
          .where((element) => element != currentUser.id)
          .toList(),
      isGroup: conversation.isGroup,
      isVideo: true,
      isTranslate: false,
    );
  }

  Future onCallTranslateTap() async {
    if (!isConversationInitiated) {
      return;
    }

    if (conversation.isBlocked || conversation.isLocked) {
      return;
    }

    await CallKitManager.instance.createCall(
        chatChannelId: conversation.id,
        receiverIds: conversation.memberIds
            .where((element) => element != currentUser.id)
            .toList(),
        isGroup: conversation.isGroup,
        isVideo: false,
        isTranslate: true);
    Get.back();
  }

  void _onConversationDeleted(String event) {
    if (event != conversation.id) {
      return;
    }

    Get.back();
    ViewUtil.showToast(
      title: Get.context!.l10n.notification__title,
      message: Get.context!.l10n.chat__conversation_has_been_deleted,
    );
  }

  void onMessageTap(Message message) {
    switch (message.type) {
      case MessageType.call:
        final Call? call = Call.callFromStringJson(message.content);

        if (call != null) {
          if (message.isCallJitsi) {
            joinCallJitsi(call);

            return;
          }
          CallKitManager.instance.createCall(
            chatChannelId: conversation.id,
            receiverIds: conversation.memberIds
                .where((element) => element != currentUser.id)
                .toList(),
            isGroup: conversation.isGroup,
            isVideo: call.isVideo ?? false,
            isTranslate: false,
          );
        }
        break;
      default:
        break;
    }
  }

  void onUserAvatarTap(Message message) {
    if (!conversation.isGroup ||
        message.isMine(myId: currentUser.id) ||
        message.sender == null) {
      return;
    }

    final dashboardController = Get.find<ChatDashboardController>();

    showLoading();

    final Completer<void> completer = Completer<void>();
    dashboardController.goToPrivateChat(
      message.sender!,
      completer: completer,
    );

    completer.future.whenComplete(() => hideLoading());
  }

  void reportMessage(Message message) {
    Get.toNamed(
      Routes.report,
      arguments: ReportArgs(
        type: ReportType.message,
        data: message,
      ),
    )?.then(
      (isReported) {
        if (isReported != null && isReported) {
          // hideMessage(message);

          ViewUtil.showAppSnackBarNewFeeds(
            title: Get.context!.l10n.newsfeed__report_success,
          );
        }
      },
    );
  }

  void hideMessage(Message message) {
    // _messages.value =
    //     _messages.where((element) => element.id != message.id).toList();

    final index = pagingController.itemList!
        .indexWhere((element) => element.id == message.id);

    if (index == -1) {
      return;
    }

    pagingController.removeItemAt(index);
  }

  /// This method is responsible for updating the last seen message in a conversation.
  ///
  /// After the new conversation object is retrieved, the current conversation's value is updated
  /// with the new last seen message and unread count from the new conversation object.
  ///
  /// Finally, an `UnreadMessage` event is added to the `_chatSocketService.onUnreadMessageStream`
  /// with the current conversation's ID and an unread count of 0. This is to notify other parts of the
  /// application that the last seen message for this conversation has been updated.
  void updateLastSeenMessage() {
    if (!isConversationInitiated) {
      return;
    }
    runAction(
      handleLoading: false,
      action: () async {
        final newConversation =
            await _chatRepository.updateLastSeen(conversation.id);
        _conversation.value = conversation.copyWith(
          lastSeen: newConversation.lastSeen,
          unreadCount: newConversation.unreadCount ?? 0,
        );
        _chatSocketService.onUnreadMessageStream.add(
          UnreadMessage(roomId: conversation.id, unreadCount: 0),
        );
      },
    );
  }

  void deleteMessage(Message message) {
    runAction(
      action: () async {
        await _chatRepository.deleteMessage(conversation, message);
        hideMessage(message);
      },
    );
  }

  void deleteMessageOnSocket(String messageId) {
    final message = pagingController.itemList
        ?.firstWhereOrNull((element) => element.id == messageId);

    if (message != null) {
      hideMessage(message);
    }
  }

  void blockUser(int userId) {
    runAction(
      action: () async {
        await _chatRepository.blockUser(userId);
        unawaited(_userRepository.blockUserById(userId));

        ViewUtil.showToast(
          title: Get.context!.l10n.notification__title,
          message: l10n.global__user_has_been_blocked,
        );

        conversationUpdated(conversation.copyWith(
          isBlocked: true,
          blockedByMe: true,
        ));
      },
    );
  }

  void unblockUser() {
    if (!isConversationInitiated ||
        conversation.isGroup ||
        !conversation.isBlocked ||
        !conversation.blockedByMe) {
      return;
    }

    runAction(
      action: () async {
        await _chatRepository.unblockUser(conversation.chatPartner()!.id);
        unawaited(
          _userRepository.unblockUserById(conversation.chatPartner()!.id),
        );

        ViewUtil.showToast(
          title: Get.context!.l10n.notification__title,
          message: l10n.global__user_has_been_unblocked,
        );

        _conversation.value = conversation.copyWith(isBlocked: false);
      },
    );
  }

  void _showLeaveGroupSuccess() {
    ViewUtil.showToast(
      title: Get.context!.l10n.notification__title,
      message: Get.context!.l10n.chat__conversation_leave_success,
    );
  }

  void forwardMessage(User toUser, Message message) {
    runAction(action: () async {
      final Conversation conversation =
          await _chatRepository.createConversation([toUser.id]);

      await _chatRepository.forwardMessage(
        conversationId: conversation.id,
        toMessage: message,
      );

      ViewUtil.showToast(
        title: Get.context!.l10n.notification__title,
        message: Get.context!.l10n.chat__forward_message,
      );
    });
  }

  Future jumpToMessage(Message message) async {
    await runAction(
      handleLoading: false,
      action: () async {
        pageSize = 10;
        final jumpToMessage = await _chatRepository.jumpToMessage(
          conversationId: conversation.id,
          messageId: message.id,
          limit: pageSize,
        );
        if (pageIsLoaded(jumpToMessage.pageNumber!)) {
          await scrollToMessage(message);

          return;
        }
        resetLoadedPages();
        addLoadedPage(jumpToMessage.pageNumber!);
        // reset all image inlist
        pagingController.pagingController.itemList = jumpToMessage.messages;
        pagingController.pagingController.nextPageKey =
            jumpToMessage.pageNumber ?? 1;
        pagingController.pagingController.notifyListeners();
        paginatedList = paginatedList.copyWith(pageSize: pageSize);
      },
      onSuccess: () async {
        await scrollToMessage(message);
        Get.find<TextMessageController>().triggerFlash(message.id);
      },
    );
  }

  Future scrollToMessage(Message message) async {
    await scrollToValue(
      message,
      (element, value) => element.id == value.id,
    );
  }

  Future replyMessage(Message message) async {
    replyFromMessage = message;
  }

  void removeReplyMessage() {
    replyFromMessage = null;
  }

  void reactToMessage(
    Message message,
    String reactionType, {
    bool isCallToApi = true,
    String userId = '',
    bool isSocket = false,
    bool isRemoveReaction = false,
  }) {
    runAction(
      action: () async {
        var reactions = message.reactions ?? {};

        // listen to reaction event from socket
        if (isSocket) {
          // check userId exist in reactions
          final userIdExistReaction = reactions.values
              .expand((element) => element)
              .toList()
              .contains(userId);

          // remove userId from reactions
          if (userIdExistReaction) {
            reactions = reactions.map((key, value) {
              final newValue = value.where((element) => element != userId);

              return MapEntry(key, newValue.toList());
            });
          }

          // update unReaction to message
          if (isRemoveReaction) {
            final newMessageWithReaction = message.copyWith(reactions: {
              ...reactions,
            });

            _replaceMessage(
              oldMessage: message,
              newMessage: newMessageWithReaction,
            );

            return;
          }

          // update reaction to message from socket
          final newMessageWithReaction = message.copyWith(
            reactions: {
              ...reactions,
              reactionType: [
                ...reactions[reactionType] ?? [],
                userId,
              ],
            },
          );

          _replaceMessage(
            oldMessage: message,
            newMessage: newMessageWithReaction,
          );

          return;
        }

        // user react to message
        // check user has reacted according to the reactionType
        // if user has reacted according to the reactionType, remove reaction
        final valueWithReactionType = reactions[reactionType] ?? [];

        // if userId exist in valueWithReactionType, remove userId and unReact to message
        if (valueWithReactionType.contains(userId)) {
          reactions = reactions.map((key, value) {
            final newValue = value.where((element) => element != userId);

            return MapEntry(key, newValue.toList());
          });

          Message newMessageWithReaction;

          newMessageWithReaction = message.copyWith(reactions: {
            ...reactions,
          });

          _replaceMessage(
            oldMessage: message,
            newMessage: newMessageWithReaction,
          );
          if (isCallToApi) {
            unawaited(
              _chatRepository.unReactToMessage(
                conversationId: conversation.id,
                messageId: message.id,
              ),
            );
          }

          return;
        }

        // check userId exist in reactions
        final userIdExistReaction = reactions.values
            .expand((element) => element)
            .toList()
            .contains(userId);

        if (userIdExistReaction) {
          reactions = reactions.map((key, value) {
            final newValue = value.where((element) => element != userId);

            return MapEntry(key, newValue.toList());
          });
        }

        final newMessageWithReaction = message.copyWith(
          reactions: {
            ...reactions,
            reactionType: [
              ...reactions[reactionType] ?? [],
              userId,
            ],
          },
        );

        _replaceMessage(
          oldMessage: message,
          newMessage: newMessageWithReaction,
        );

        if (isCallToApi) {
          unawaited(
            _chatRepository.reactToMessage(
              conversationId: conversation.id,
              messageId: message.id,
              reactionType: reactionType,
            ),
          );
        }

        return;
      },
    );
  }

  void sendStickerMessage(SPSticker sticker) {
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      content: jsonEncode(sticker.toJson()),
      type: MessageType.sticker,
      createdAt: DateTime.now(),
      senderId: currentUser.id,
      sender: currentUser,
      isLocal: true,
    );

    _insertMessage(message);
    _scrollToBottom();

    runAction(
      handleLoading: false,
      action: () async {
        final newMessage = await _chatRepository.sendMessage(message);

        _replaceMessage(
          oldMessage: message,
          newMessage: addSenderToMessage(
            newMessage.copyWith(
              repliedFrom: addSenderToMessage(newMessage.repliedFrom),
            ),
          )!,
        );
      },
    );
  }

  Future onCallVideoGroupTap() async {
    try {
      // check pin exits call jitsi
      final pinMessageController = Get.find<PinMessageController>();
      final hasCall = pinMessageController.pinnedMessages.any(
        (element) => element.type == MessageType.call && element.isCallJitsi,
      );
      // if exits throw message error and return
      if (hasCall) {
        ViewUtil.showToast(
          title: l10n.call__cant_create_meeting,
          message: l10n.call__meeting_going_on,
        );

        return;
      }
      final Call call = Call(
        id: conversation.id,
        chatChannelId: conversation.id,
      );
      final message = await sendCallGroupMessage(call);
      if (message == null) {
        return;
      }
      await pinMessageController.pinMessage(message);
      await createOrJoinCallJitsi(conversation.id, conversation.name);
    } catch (e) {
      LogUtil.e(e, name: runtimeType.toString());
    }
  }

  Future joinCallJitsi(Call call) async {
    await createOrJoinCallJitsi(call.id, conversation.name);
  }

  Future createOrJoinCallJitsi(String roomId, String roomName) async {
    final jitsiMeet = JitsiMeet();
    final configOverrides = {
      'startWithAudioMuted': true,
      'startWithVideoMuted': true,
      'subject': roomName,
    };
    if (!isCreatorOrAdmin) {
      configOverrides['buttonsWithNotifyClick'] = ['end-meeting'];
    }
    final options = JitsiMeetConferenceOptions(
      serverURL: Get.find<EnvConfig>().jitsiUrl,
      room: roomId,
      configOverrides: configOverrides,
      featureFlags: {'unsaferoomwarning.enabled': false},
      userInfo: currentUser.avatarPath != null && currentUser.avatarPath != ''
          ? JitsiMeetUserInfo(
              displayName: currentUser.fullName,
              email: currentUser.email ?? currentUser.phone ?? '',
              avatar: currentUser.avatarPath ?? '',
            )
          : JitsiMeetUserInfo(
              displayName: currentUser.fullName,
              email: currentUser.email ?? currentUser.phone ?? '',
            ),
    );
    await jitsiMeet.join(options);
  }

  Future<List<User>> getUsersByIds(List<String> reactListUser) async {
    final userIds = reactListUser.map((str) => int.parse(str)).toList();

    final members =
        await GetUsersByIdsWithUserPoolUsecase().call(userIds.toSet());

    return members;
  }

  void onMentionPressed(String? mention, Map<String, int> mentionUserIdMap) {
    if (mention == null) {
      return;
    }

    final userId = mentionUserIdMap[
        '<${AppConstants.mentionTag}>$mention</${AppConstants.mentionTag}>'];

    if (userId == null || userId == currentUser.id) {
      return;
    }

    final user = conversation.members.firstWhereOrNull(
      (element) => element.id == userId,
    );

    if (user != null) {
      Get.find<ChatDashboardController>().goToPrivateChat(user);
    }
  }

  Future<void> addOrRemoveUserToGroup({
    List<String> addUsers = const [],
    List<String> removeUsers = const [],
  }) async {
    final contentJson = addUsers.isNotEmpty
        ? {
            'type': MessageSystemType.addMember.value,
            'members': addUsers,
          }
        : removeUsers.isNotEmpty
            ? {
                'type': MessageSystemType.removeMember.value,
                'members': removeUsers,
              }
            : {};

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversation.id,
      type: MessageType.system,
      createdAt: DateTime.now(),
      senderId: -1,
      content: jsonEncode(contentJson),
    );

    _insertMessage(message);
  }

  void scrollToBottom() {
    anchorScrollController.jumpTo(0);
  }

  void updateConversationLastSeenUser(Map<String, int> lastSeenUsersValue) {
    try {
      if (pagingController.itemList != null) {
        findIndexLastSeen(
          lastSeenUsers: lastSeenUsersValue,
          messages: pagingController.itemList!,
        );
      }
    } catch (e) {
      LogUtil.e(e);
    }
  }

  RxInt indexLastSeen = 0.obs;
  late Map<String, int> lastSeenUser;

  void findIndexLastSeen({
    required Map<String, int> lastSeenUsers,
    required List<Message> messages,
  }) {
    try {
      if (pagingController.itemList == null) {
        indexLastSeen.value = -1;
        update();
        return;
      }
      if (conversation.isGroup) {
        indexLastSeen.value = -1;
        update();
        return;
      }
      var res = -1;
      final partner = conversation.chatPartner();
      final partnerLastSeen = DateTime.fromMillisecondsSinceEpoch(
          lastSeenUsers[partner!.id.toString()]!);

      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        final messageCreateAt = message.createdAt;
        final isPartnerSeenLastMessage =
            messageCreateAt.isBefore(partnerLastSeen);
        if (message.isMine(myId: currentUser.id)) {
          if (isPartnerSeenLastMessage) {
            res = i;
            break;
          }
        } else {
          break;
        }
      }
      indexLastSeen.value = res;
      update();
    } catch (e) {
      LogUtil.e(e);
    }
  }

  void translateMessage(Message message) {
    if (!message.type.isTranslatable) {
      return;
    }

    runAction(
      action: () async {
        final translatedText = message.translatedMessage ??
            await _translateRepository.translate(
              text: message.content,
              to: 'en',
            );

        final newMessage = message.copyWith(
          translatedMessage: translatedText,
          displayState: MessageDisplayState.translated,
        );

        _replaceMessage(
          oldMessage: message,
          newMessage: newMessage,
        );
      },
    );
  }

  void showOriginalMessage(Message message) {
    final newMessage =
        message.copyWith(displayState: MessageDisplayState.original);

    _replaceMessage(
      oldMessage: message,
      newMessage: newMessage,
    );
  }

  Future<void> handleTranslateMessage(bool isTranslateValue) async {
    runAction(action: () async {
      if (isTranslateValue) {
        isTranslateMessage.value = true;

        translateMessageMap.value =
            await _translateRepository.translateListMessage(
                languages[translateLanguageMessageIndex.value]['talkCode']
                    as String,
                pagingController.itemList!);
      } else {
        isTranslateMessage.value = false;
      }
      update();
    });
  }

  void updateTranslateLanguageMessage(int index) {
    translateLanguageMessageIndex.value = index;
    update();
  }

  /// function for updating current conversation
  void updateConversation(Conversation updatedConversation) {
    _conversation.value = updatedConversation;
  }

  /// function for removing member in group
  Future<void> removeMember(int memberId) async {
    return runAction(action: () async {
      // update list, remove member from conversation by id
      await _chatRepository.updateConversationMembers(
        conversationId: conversation.id,
        membersIds: conversation.members
            .where((m) => m.id != memberId)
            .map((m) => m.id)
            .toList(),
        adminIds: conversation.adminIds,
      );

      // update conversation members
      final members =
          _conversation.value?.members.where((m) => m.id != memberId).toList();
      // update conversation memberIds
      final memberIds =
          _conversation.value?.memberIds.where((m) => m != memberId).toList();

      updateConversation(conversation.copyWith(
        members: members,
        memberIds: memberIds,
      ));
    });
  }

  /// function for forwarding multiple message
  void forwardMultiMessage(User toUser) {
    runAction(action: () async {
      // disable selected mode
      isSelectMode.value = false;
      final Conversation conversation =
          await _chatRepository.createConversation([toUser.id]);
      // loop through list message selected and forward to conversation
      for (var message in listMessageSelected) {
        await _chatRepository.forwardMessage(
          conversationId: conversation.id,
          toMessage: message,
        );
      }

      // clear list message selected
      listMessageSelected.clear();

      // show snackbar
      ViewUtil.showAppSnackBar(
        Get.context!,
        Get.context!.l10n.chat__forward_message,
      );
    });
  }

  /// function for deleting multiple message
  void deleteMultiMessage() {
    runAction(
      action: () async {
        isSelectMode.value = false;
        // loop through list message selected and delete message
        for (var message in listMessageSelected) {
          await _chatRepository.deleteMessage(conversation, message);
          hideMessage(message);
        }

        // clear list message selected
        listMessageSelected.clear();
      },
    );
  }

  /// function for selecting message
  void onSelectMessage(Message message) {
    if (listMessageSelected.contains(message)) {
      listMessageSelected.remove(message);
      if (listMessageSelected.isEmpty) {
        isSelectMode.value = false;
      }
    } else {
      listMessageSelected.add(message);
    }
    setIsShowDelete();
    update();
  }
}
