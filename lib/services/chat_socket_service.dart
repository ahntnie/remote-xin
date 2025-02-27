import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:get/get.dart';

import '../core/all.dart';
import '../events/messages/show_unread_message_event.dart';
import '../models/all.dart';
import '../models/unread_message.dart';
import '../presentation/common_controller.dart/app_controller.dart';
import '../presentation/common_controller.dart/user_pool.dart';
import '../presentation/features/chat/chat_hub/controllers/chat_hub_controller.dart';
import '../presentation/routing/routers/app_pages.dart';
import '../repositories/all.dart';

class ChatSocketService extends GetxService with LogMixin {
  final _chatRepository = Get.find<ChatRepository>();
  final _eventBus = Get.find<EventBus>();

  final GetStream<Message> _newMessageStream = GetStream<Message>();

  Stream<Message> get newMessageStream => _newMessageStream.stream.distinct();

  final List<int> _activeUsers = [];

  final GetStream<List<int>> _activeUsersStream = GetStream<List<int>>();

  GetStream<List<int>> get activeUsersStream => _activeUsersStream;

  final GetStream<String> _onConversationDeletedStream = GetStream<String>();

  GetStream<String> get onConversationDeletedStream =>
      _onConversationDeletedStream;
  final GetStream<UnreadMessage> _onUnreadMessageStream =
      GetStream<UnreadMessage>();

  GetStream<UnreadMessage> get onUnreadMessageStream => _onUnreadMessageStream;

  final GetStream<Map<String, dynamic>> _onMessageDeletedStream =
      GetStream<Map<String, dynamic>>();

  GetStream<Map<String, dynamic>> get onMessageDeletedStream =>
      _onMessageDeletedStream;

  final GetStream<Map<String, dynamic>> _onReactToMessageStream =
      GetStream<Map<String, dynamic>>();

  GetStream<Map<String, dynamic>> get onReactToMessageStream =>
      _onReactToMessageStream;

  final GetStream<Map<String, dynamic>> _onUnReactToMessageStream =
      GetStream<Map<String, dynamic>>();

  GetStream<Map<String, dynamic>> get onUnReactToMessageStream =>
      _onUnReactToMessageStream;

  final GetStream<AddOrRemoveUserBySocket> _onAddOrRemoveUserToGroupStream =
      GetStream<AddOrRemoveUserBySocket>();

  GetStream<AddOrRemoveUserBySocket> get onAddOrRemoveUserToGroupStream =>
      _onAddOrRemoveUserToGroupStream;

  final GetStream<Map<String, dynamic>> _onSeenToMessageStream =
      GetStream<Map<String, dynamic>>();
  GetStream<Map<String, dynamic>> get onSeenToMessageStream =>
      _onSeenToMessageStream;

  @override
  Future<void> onInit() async {
    await _chatRepository.initSocket();
    // unawaited(_getActiveUsers());
    _setupSocketListeners();

    super.onInit();
  }

  @override
  void onClose() {
    _chatRepository.disconnectSocket();
    _newMessageStream.close();
    super.onClose();
  }

  Future<void> _getActiveUsers() async {
    if (!Get.find<AppController>().isLogged) {
      return;
    }

    final activeUsers = await _chatRepository.getActiveUsers();
    _activeUsers.addAll(activeUsers);
    _activeUsersStream.add(_activeUsers);
  }

  void _setupSocketListeners() {
    _chatRepository.onNewMessage((newMessage) {
      _handleNewMessage(newMessage);
    });

    _chatRepository.onUserConnected((userId) {
      _activeUsers.add(userId);
      _activeUsersStream.add(_activeUsers);
    });

    _chatRepository.onUserDisconnected((userId) {
      _activeUsers.remove(userId);
      _activeUsersStream.add(_activeUsers);
    });

    _chatRepository.onConversationDeleted(
      (conversationId) {
        _onConversationDeletedStream.add(conversationId);
      },
    );

    _chatRepository.onUnreadMessage((unreadMessage) {
      _onUnreadMessageStream.add(unreadMessage);

      // to show unread message badge in the message nav item
      _eventBus.fire(ShowUnreadMessageEvent());
    });

    _chatRepository.onMessageDeleted((conversationId, messageId) {
      _onMessageDeletedStream.add({
        'conversationId': conversationId,
        'messageId': messageId,
      });
    });

    _chatRepository.onReactToMessage((
      conversationId,
      messageId,
      reactionType,
      userId,
    ) {
      _onReactToMessageStream.add({
        'conversationId': conversationId,
        'messageId': messageId,
        'reactionType': reactionType,
        'userId': userId,
      });
    });

    _chatRepository.onUnReactToMessage((
      conversationId,
      messageId,
      reactionType,
      userId,
    ) {
      _onUnReactToMessageStream.add({
        'conversationId': conversationId,
        'messageId': messageId,
        'reactionType': reactionType,
        'userId': userId,
      });
    });

    _chatRepository.onAddOrRemoveUserToGroup((addOrRemoveUser) {
      _onAddOrRemoveUserToGroupStream.add(addOrRemoveUser);
    });

    _chatRepository.onUserSeen((
      roomId,
      userId,
      lastSeen,
    ) {
      _onSeenToMessageStream.add({
        'roomId': roomId,
        'userId': userId,
        'lastSeen': lastSeen,
      });
    });
  }

  Future<void> connectSocket() async {
    await _chatRepository.connectSocket();
  }

  void disconnectSocket() {
    _chatRepository.disconnectSocket();
  }

  Future<void> _handleNewMessage(NewMessage newMessage) async {
    final message = newMessage.message;

    if (message == null) {
      return;
    }

    _newMessageStream.add(message);

    final currentPage = Get.currentRoute;
    if (currentPage == Routes.chatHub) {
      final currentConversationId =
          Get.find<ChatHubController>().conversation.id;

      if (currentConversationId == message.conversationId) {
        return;
      }
    }

    final user = await _getSender(message.senderId);
    LogUtil.i(user.toString());
    final title = user.contactName;
    final body = _getNotiMessage(message);
    LogUtil.i(body);

    if (!(newMessage.receiverMutedRoom ?? false)) {
      ViewUtil.showToast(
        title: title,
        message: body,
        onTapped: () {
          if (currentPage == Routes.chatHub) {
            final controller = Get.find<ChatHubController>();

            if (controller.conversation.id != message.conversationId) {
              controller.reloadWithNewConversationId(message.conversationId);
            }
          } else {
            Get.toNamed(
              Routes.chatHub,
              arguments: ChatHubArguments(
                conversationId: message.conversationId,
              ),
            );
          }
        },
      );
    }
  }

  Future<User> _getSender(int senderId) async {
    final userPool = Get.find<UserPool>();

    late User user;
    final cachedUser = userPool.getUser(senderId);
    if (cachedUser != null) {
      user = cachedUser;
    } else {
      user = await Get.find<UserRepository>().getUserById(senderId);
      unawaited(userPool.storeUser(user));
    }

    return user;
  }

  String _getNotiMessage(Message message) {
    final text = switch (message.type) {
      MessageType.text => message.content,
      MessageType.hyperText => message.contentWithoutFormat,
      MessageType.image => Get.context!.l10n.chat__sent_you_an_image,
      MessageType.video => Get.context!.l10n.chat__sent_you_a_video,
      MessageType.audio => Get.context!.l10n.chat__sent_you_a_voice,
      MessageType.file => Get.context!.l10n.chat__sent_a_document,
      MessageType.call => Get.context!.l10n.chat__a_call,
      MessageType.post => Get.context!.l10n.chat__sent_a_post,
      MessageType.sticker => Get.context!.l10n.chat__sent_a_sticker,
      MessageType.system => Get.context!.l10n.chat__sent_system_message,
    };

    return text.capitalizeFirst!;
  }
}
