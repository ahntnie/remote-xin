import 'dart:async';
import 'dart:collection';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/all.dart';
import '../core/exceptions/custom/conversation_exception.dart';
import '../data/api/clients/chat_api_client.dart';
import '../data/mappers/response_mapper/base/base_success_response_mapper.dart';
import '../data/preferences/app_preferences.dart';
import '../models/all.dart';
import '../models/enums/mute_conversation_option_enum.dart';
import '../models/jump_to_message.dart';
import '../models/unread_message.dart';
import 'base/base_repo.dart';

class ChatRepository extends BaseRepository {
  final _chatApiClient = Get.find<ChatApiClient>();

  late io.Socket _socket;

  late Completer _initSocketCompleter;

  Future<void> initSocket() async {
    _initSocketCompleter = Completer<void>();

    final token = await Get.find<AppPreferences>().getAccessToken();

    if (token != null) {
      _socket = io.io(
        Get.find<EnvConfig>().chatSocketUrl,
        io.OptionBuilder()
            .setQuery({'token': token})
            .setTransports(['websocket'])
            .disableAutoConnect()
            .enableReconnection()
            .build(),
      );

      _initSocketCompleter.complete();

      _socket.on('authenticated', (data) {
        logInfo('Socket authenticated');
      });
      _socket.onConnect((data) => logInfo('Socket connected'));

      _socket.onAny((event, data) => logInfo('Socket event: $event, $data'));
    }
  }

  Future<void> connectSocket() async {
    if (!_initSocketCompleter.isCompleted) {
      await _initSocketCompleter.future;
    }
    _socket.connect();
  }

  Future<void> disconnectSocket() async {
    if (!_initSocketCompleter.isCompleted) {
      await _initSocketCompleter.future;
    }
    _socket.disconnect();
  }

  Future<void> _onSocketEvent(
    String event,
    dynamic Function(dynamic) callback,
  ) async {
    if (!_initSocketCompleter.isCompleted) {
      await _initSocketCompleter.future;
    }

    return _socket.on(event, callback);
  }

  Future<void> onNewMessage(void Function(NewMessage) onNewMessage) async {
    return _onSocketEvent(
      'new-message',
      (data) {
        onNewMessage(NewMessage.fromJson(data));
      },
    );
  }

  Future<void> onConversationDeleted(
    void Function(String conversationId) callback,
  ) {
    return _onSocketEvent(
      'room-deleted',
      (data) {
        final conversationId = data['roomId'] as String?;

        if (conversationId == null) {
          return;
        }

        callback(conversationId);
      },
    );
  }

  Future<void> onUserConnected(void Function(int) onActiveUsers) {
    return _onSocketEvent(
      'user_active',
      (data) {
        final userId = data['user_id'] as String?;

        if (userId == null) {
          return;
        }

        onActiveUsers(int.parse(userId));
      },
    );
  }

  Future<void> onUserDisconnected(void Function(int) onUserDisconnected) {
    return _onSocketEvent(
      'user_inactive',
      (data) {
        final userId = data['user_id'] as String?;

        if (userId == null) {
          return;
        }

        onUserDisconnected(int.parse(userId));
      },
    );
  }

  Future<void> onUnreadMessage(
    void Function(UnreadMessage) onUnreadMessage,
  ) async {
    return _onSocketEvent(
      'unread-message',
      (data) {
        onUnreadMessage(UnreadMessage.fromJson(data));
      },
    );
  }

  Future<void> onMessageDeleted(
    void Function(String conversationId, String messageId) callback,
  ) {
    return _onSocketEvent(
      'delete-message',
      (data) {
        final conversationId = data['roomId'] as String?;
        final messageId = data['messageId'] as String?;

        if (conversationId == null || messageId == null) {
          return;
        }

        callback(conversationId, messageId);
      },
    );
  }

  void onReactToMessage(
    void Function(
      String conversationId,
      String messageId,
      String reactionType,
      String userId,
    ) callback,
  ) {
    _onSocketEvent(
      'message-reaction',
      (data) {
        final conversationId = data['roomId'] as String?;
        final messageId = data['messageId'] as String?;
        final reactionType = data['reactionType'] as String?;
        final userId = data['userId'] as String?;

        if (conversationId == null ||
            messageId == null ||
            reactionType == null ||
            userId == null) {
          return;
        }

        callback(conversationId, messageId, reactionType, userId);
      },
    );
  }

  void onUnReactToMessage(
    void Function(
      String conversationId,
      String messageId,
      String reactionType,
      String userId,
    ) callback,
  ) {
    _onSocketEvent(
      'message-remove-reaction',
      (data) {
        final conversationId = data['roomId'] as String?;
        final messageId = data['messageId'] as String?;
        final reactionType = data['removedType'] as String?;
        final userId = data['userId'] as String?;

        if (conversationId == null ||
            messageId == null ||
            reactionType == null ||
            userId == null) {
          return;
        }

        callback(conversationId, messageId, reactionType, userId);
      },
    );
  }

  Future<void> onAddOrRemoveUserToGroup(
    void Function(AddOrRemoveUserBySocket) callback,
  ) {
    return _onSocketEvent(
      'room-updated',
      (data) {
        callback(AddOrRemoveUserBySocket.fromJson(data));
      },
    );
  }

  Future<void> onUserSeen(
    void Function(
      String roomId,
      String userId,
      int lastSeen,
    ) callback,
  ) {
    return _onSocketEvent('user-seen', (data) {
      final userId = data['userId'] as String?;
      final roomId = data['roomId'] as String?;
      final lastSeen = data['lastSeen'] as int?;

      if (userId == null || roomId == null || lastSeen == null) {
        return;
      }

      callback(roomId, userId, lastSeen);
    });
  }

  Future onCallTranslate(Function(String) callback) async {
    return _onSocketEvent(
      'call-translate',
      (data) {
        callback(data['message']['data']);
      },
    );
  }

  // ######### End Socket events #########

  Future<List<int>> getActiveUsers() async {
    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/user/active-users',
          decoder: (data) {
            final activeUsers =
                (data as Map<String, dynamic>)['userIds'] as List<dynamic>;

            return activeUsers
                .map((user) => int.parse(user as String))
                .toList();
          },
        );
      },
    );
  }

  Future<List<Conversation>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = {
      'skip': (page - 1) * limit,
      'limit': limit,
    };

    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/room',
          // queryParameters: queryParameters,
          decoder: (data) {
            return Conversation.fromJsonList(
              (data as Map<String, dynamic>)['rooms'] as List<dynamic>,
            );
          },
        );
      },
    );
  }

  Future<Conversation> getConversationById({
    required String conversationId,
  }) async {
    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/room/$conversationId',
          decoder: (data) =>
              Conversation.fromJson((data as Map<String, dynamic>)['room']),
        );
      },
    );
  }

  Future<List<Conversation>> getConversationByArchived() async {
    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/room/managed',
          decoder: (data) {
            return Conversation.fromJsonList(
              (data as Map<String, dynamic>)['archive'] as List<dynamic>,
            );
          },
        );
      },
    );
  }

  Future<List<Message>> getAllMessagesByConversationId({
    required String conversationId,
    int skip = 0,
    int limit = 10,
    List<MessageType>? types,
  }) async {
    return executeApiRequest(
      () async {
        final queryParameters = types == null
            ? <String, dynamic>{}
            : {
                // 'skip': skip,
                // 'limit': limit,
                'types[]': types.map((type) => type.value).toList(),
              };

        return _chatApiClient.get(
          '/message/$conversationId',
          queryParameters: queryParameters,
          decoder: (data) => Message.fromJsonList(
            (data as Map<String, dynamic>)['messages'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<List<Message>> getPaginatedMessagesByConversationId({
    required String conversationId,
    required int page,
    required int pageSize,
  }) async {
    final queryParameters = {
      'skip': (page - 1) * pageSize,
      'limit': pageSize,
    };

    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/message/$conversationId',
          queryParameters: queryParameters,
          decoder: (data) => Message.fromJsonList(
            (data as Map<String, dynamic>)['messages'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<Conversation> createConversation(List<int> userIds) async {
    return executeApiRequest(
      () async {
        return _chatApiClient.post(
          '/room',
          body: {
            'members': userIds.map((userId) => userId.toString()).toList(),
            'isGroup': userIds.length > 1,
          },
          decoder: (data) =>
              Conversation.fromJson((data as Map<String, dynamic>)['chatRoom']),
        );
      },
    );
  }

  Future<Message> sendMessage(
    Message toSendMessage, {
    String? replyMessage,
    Map<String, String>? mentionsData,
  }) async {
    return executeApiRequest(
      () async {
        final body = <String, dynamic>{
          'content': toSendMessage.content,
          'type': toSendMessage.type.value,
        };

        if (replyMessage != null) {
          body['repliedFrom'] = replyMessage;
        }
        if (!toSendMessage.description.isBlank) {
          body['description'] = toSendMessage.description!;
        }
        if (mentionsData != null) {
          body['mentions'] = mentionsData;
        }

        return _chatApiClient.post(
          '/message/${toSendMessage.conversationId}',
          body: body,
          decoder: (data) => Message.fromJson(
            (data as Map<String, dynamic>)['new_message'],
          ),
        );
      },
    );
  }

  Future<void> deleteConversation(Conversation conversation) {
    return executeApiRequest(
      () async {
        return _chatApiClient.delete(
          '/room/${conversation.id}',
          successResponseMapperType: SuccessResponseMapperType.plain,
          serverKnownExceptionParser: (statusCode, serverError) {
            if (statusCode == 403) {
              return const ConversationException(
                ConversationExceptionKind.onlyCreatorCanDelete,
              );
            }

            return null;
          },
        );
      },
    );
  }

  Future<Conversation> updateGroupChatInfo({
    required Conversation conversation,
    String? name,
    String? avatarUrl,
  }) {
    if (!conversation.isGroup) {
      throw ArgumentError('Conversation must be a group chat');
    }

    final body = <String, dynamic>{};

    if (name != null) {
      body['name'] = name;
    }

    if (avatarUrl != null) {
      body['avatar'] = avatarUrl;
    }

    return executeApiRequest(
      () async {
        await _chatApiClient.patch(
          '/room/${conversation.id}',
          body: body,
          successResponseMapperType: SuccessResponseMapperType.plain,
        );

        return conversation.copyWith(
          name: name,
          avatar: avatarUrl,
        );
      },
    );
  }

  Future<void> updateConversationMembers({
    required String conversationId,
    required List<int> membersIds,
    required List<int> adminIds,
  }) {
    return executeApiRequest(
      () async {
        return _chatApiClient.patch(
          '/room/$conversationId',
          body: {
            'members': membersIds.map((id) => id.toString()).toList(),
            'admins': adminIds.map((id) => id.toString()).toList(),
          },
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<Conversation> updateLastSeen(String conversationId) {
    return executeApiRequest(
      () async {
        return _chatApiClient.patch(
          '/room/$conversationId/last-seen',
          decoder: (data) => Conversation.fromJson(
            (data as Map<String, dynamic>)['room'],
          ),
        );
      },
    );
  }

  Future<int> getUnreadMessageCount() {
    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/user/unread-count',
          decoder: (data) =>
              (data as Map<String, dynamic>)['unreadCount'] as int,
        );
      },
    );
  }

  Future<void> deleteMessage(Conversation conversation, Message message) {
    return executeApiRequest(
      () async {
        return _chatApiClient.delete(
          '/message/${conversation.id}/${message.id}',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<void> blockUser(int userId) {
    return executeApiRequest(
      () async {
        return _chatApiClient.post(
          '/user/$userId/block',
          body: {'userId': userId},
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<void> unblockUser(int userId) {
    return executeApiRequest(
      () async {
        return _chatApiClient.delete(
          '/user/$userId/block',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<void> leaveGroupChat(String conversationId) {
    return executeApiRequest(
      () async {
        return _chatApiClient.patch(
          '/room/$conversationId/leave',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future muteConversation({
    required String conversationId,
    required MuteConversationOption muteOption,
  }) {
    return executeApiRequest(
      () async {
        return _chatApiClient.patch(
          '/room/$conversationId/mute',
          body: {
            'type': muteOption.type,
            'until': muteOption.type == MuteConversationOption.typeP
                ? null
                : DateTime.now()
                    .add(muteOption.duration)
                    .toUtc()
                    .toIso8601String(),
          }..removeWhere((key, value) => value == null),
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future unMuteConversation(String conversationId) {
    return executeApiRequest(
      () async {
        return _chatApiClient.patch(
          '/room/$conversationId/unmute',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<Message> forwardMessage({
    required Message toMessage,
    required String conversationId,
  }) async {
    return executeApiRequest(
      () async {
        final body = {
          'forwardedFrom': toMessage.id,
          'content': toMessage.content,
          'type': toMessage.type.value,
        };

        return _chatApiClient.post(
          '/message/$conversationId',
          body: body,
          decoder: (data) => Message.fromJson(
            (data as Map<String, dynamic>)['new_message'],
          ),
        );
      },
    );
  }

  Future<LinkedHashMap<String, Message>> getPinnedMessages(
    String conversationId,
  ) {
    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/room/$conversationId/pinned-messages',
          decoder: (data) {
            final LinkedHashMap<String, Message> linkedHashMap =
                LinkedHashMap<String, Message>();
            for (var element in (data as Map<String, dynamic>)['messages']
                as List<dynamic>) {
              linkedHashMap.putIfAbsent(
                element['id'],
                () => Message.fromJson(element as Map<String, dynamic>),
              );
            }

            return linkedHashMap;
          },
        );
      },
    );
  }

  Future updatePinMessage(String id, List<String> messageId) {
    return executeApiRequest(
      () async {
        return _chatApiClient.patch(
          '/room/$id',
          body: {'pins': messageId},
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<JumpToMessage> jumpToMessage({
    required String conversationId,
    required String messageId,
    required int limit,
  }) {
    return executeApiRequest(
      () async {
        return _chatApiClient.get(
          '/message/$conversationId/jump',
          queryParameters: {
            'messageId': messageId,
            'limit': limit,
          },
          decoder: (data) => JumpToMessage.fromJson(
            data as Map<String, dynamic>,
          ),
        );
      },
    );
  }

  Future<Message> replyMessage(Message toSendMessage, Message replyFrom) async {
    return executeApiRequest(
      () async {
        final body = {
          'content': toSendMessage.content,
          'type': toSendMessage.type.value,
          'replyFrom': replyFrom.id,
        };

        if (!toSendMessage.description.isBlank) {
          body['description'] = toSendMessage.description!;
        }

        return _chatApiClient.post(
          '/message/${toSendMessage.conversationId}',
          body: body,
          decoder: (data) => Message.fromJson(
            (data as Map<String, dynamic>)['new_message'],
          ),
        );
      },
    );
  }

  Future reactToMessage({
    required String conversationId,
    required String messageId,
    required String reactionType,
  }) {
    return executeApiRequest(
      () async {
        return _chatApiClient.post(
          '/message/$conversationId/$messageId/react',
          body: {
            'reactionType': reactionType,
          },
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future archivedRoom(String roomId) {
    return executeApiRequest(
      () async {
        final response = await _chatApiClient.post(
          '/room/$roomId/archive',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
        print('Response from archivedRoom: $response');
        return response;
      },
    );
  }

  Future unReactToMessage({
    required String conversationId,
    required String messageId,
  }) {
    return executeApiRequest(
      () async {
        return _chatApiClient.delete(
          '/message/$conversationId/$messageId/react',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<Message> repStory({
    required String content,
    required String repliedStoryId,
    required String userId,
  }) async {
    return executeApiRequest(
      () async {
        return _chatApiClient.post(
          '/message/reply-story',
          body: {
            'content': content,
            'repliedStoryId': repliedStoryId,
            'userId': userId,
          },
          decoder: (data) =>
              Message.fromJson((data as Map<String, dynamic>)['new_message']),
        );
      },
    );
  }

  Future sendCallTranslate({required String roomId, required String data}) {
    return executeApiRequest(
      () async {
        return _chatApiClient.post(
          '/message/$roomId/send',
          body: {'data': data},
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }
}
