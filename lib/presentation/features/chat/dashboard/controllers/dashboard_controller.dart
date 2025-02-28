import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../../models/unread_message.dart';
import '../../../../../models/user_story.dart';
import '../../../../../repositories/all.dart';
import '../../../../../services/chat_socket_service.dart';
import '../../../../../usecases/get_user_by_id_with_pool_usecase.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/user_pool.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../chat_hub/controllers/chat_hub_controller.dart';

const _boxName = 'chat_conversations';
const _conversationKey = 'conversations';
const _unreadMessageCountKey = 'unread_message_count';

class ChatDashboardController extends BaseController
    with WidgetsBindingObserver {
  @override
  String get boxName => _boxName;
  final _chatRepository = Get.find<ChatRepository>();
  final _userRepository = Get.find<UserRepository>();
  final _chatSocketService = Get.find<ChatSocketService>();
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  final _eventBus = Get.find<EventBus>();
  final _storageRepository = Get.find<StorageRepository>();

  final RxList<Conversation> _conversations = <Conversation>[].obs;
  RxList<String> pins = <String>[].obs;
  final RxList<Conversation> _archivedConversations = <Conversation>[].obs;
  List<Conversation> get conversations =>
      _conversations.where((c) => !_archivedConversations.contains(c)).toList();
  List<Conversation> get archivedConversations =>
      _archivedConversations.toList();

  List<Conversation> get allConversations => _conversations.toList();
  // final RxList<Conversation> _filteredConversations = <Conversation>[].obs;

  // List<Conversation> get conversations => _conversations.toList();

  late StreamSubscription _newMessageSubscription;
  late StreamSubscription _conversationDeletedSubscription;
  late StreamSubscription _unreadMessageSubscription;
  late StreamSubscription _messageDeletedSubscription;
  late StreamSubscription _addOrRemoveUserBySocketSubscription;
  late StreamSubscription _messageSeenSubscription;

  final showGroupConversations = false.obs;
  final isSearching = false.obs;
  Worker? worker;

  RxBool isLoadingInit = true.obs;

  final _unReadMessageCount = 0.obs;
  Stream<int> get unReadMessageCountStream =>
      _unReadMessageCount.stream.asBroadcastStream();
  int get unReadMessageCount => _unReadMessageCount.value;

  int test = 0;

  //story
  RxList<UserStory> userStorys = <UserStory>[].obs;
  List<UserStory> get listUserStorys => userStorys.toList();

  @override
  Future<void> onInit() async {
    super.onInit();
    await ensureInitStorage();

    WidgetsBinding.instance.addObserver(this);
    _getArchived();
    _getConversations();
    _getUnreadMessageCount();
    _listenChatSocket();

    // _conversations.listen((conversations) {
    //   _filteredConversations.value = conversations.where((conversation) {
    //     test++;
    //     if (test % 2 == 0) {
    //       logError('messagemessagemessage$test');
    //     }

    //     return true;
    //   }).toList();
    //   // _filteredConversations.value = conversations;
    // });

    unawaited(_setUpPersistedData());
    getListUserStory();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _newMessageSubscription.cancel();
    _conversationDeletedSubscription.cancel();
    _unreadMessageSubscription.cancel();
    _messageDeletedSubscription.cancel();
    _addOrRemoveUserBySocketSubscription.cancel();
    _messageSeenSubscription.cancel();
    worker?.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // _getConversations();
    }
  }

  //story
  Future getListUserStory() async {
    userStorys.value = [];
    await runAction(
      action: () async {
        final storyLists = await _newsFeedRepository.getListUserStory();
        for (var story in storyLists) {
          if (story.stories.isNotEmpty) {
            userStorys.add(story);
          }
        }
      },
    );
  }

  UserStory getUserStory(int index) {
    return userStorys[index - 1];
  }

  UserStory? getMyStory() {
    final index =
        userStorys.indexWhere((story) => story.userId == currentUser.id);
    if (index != -1) {
      return userStorys[index];
    }
    return null;
  }

  int getIndexMyStory() {
    return userStorys.indexWhere((story) => story.userId == currentUser.id);
  }
//story

  Future<void> onRefresh() async {
    isSearching.value = false;
    _getConversations();
    getListUserStory();
    _getArchived();
  }

  Future<void> _setUpPersistedData() async {
    // set conversations
    await hydrate<List<Conversation>, String>(
      _conversations,
      key: _conversationKey,
      encoder: (value) => jsonEncode(value?.map((e) => e.toJson()).toList()),
      decoder: (value) => jsonDecode(value ?? '[]')
          .map<Conversation>((e) => Conversation.fromJson(e))
          .toList(),
    ).then((cachedConversations) {
      if (cachedConversations != null) {
        _conversations.value = cachedConversations;
        if (cachedConversations.isNotEmpty) {
          isLoadingInit.value = false;
        }
      }
    });

    // set unread message count
    await hydrate<int, String>(
      _unReadMessageCount,
      key: _unreadMessageCountKey,
      encoder: (value) => value.toString(),
      decoder: (value) => int.tryParse(value ?? '0') ?? 0,
    );
  }

/////DEMO PINS MESSAGE
  Map<String, int> originalPositions = {};
  AnimatedListState? animatedListState;

  void setAnimatedListState(AnimatedListState state) {
    animatedListState = state;
  }

  void pinConversation(String conversationId) {
    final conversationExists =
        _conversations.any((conv) => conv.id == conversationId);

    if (!conversationExists) {
      return;
    }
    final conversationIndex =
        _conversations.indexWhere((conv) => conv.id == conversationId);
    final conversationToPin = _conversations[conversationIndex];

    if (pins.contains(conversationId)) {
      pins.remove(conversationId);
      final originalIndex =
          originalPositions[conversationId] ?? _conversations.length;
      _conversations.removeAt(conversationIndex);
      _conversations.insert(originalIndex, conversationToPin);
      originalPositions.remove(conversationId);
    } else {
      pins.add(conversationId);
      originalPositions[conversationId] = conversationIndex;
      _conversations.removeAt(conversationIndex);
      _conversations.insert(0, conversationToPin);
    }

    update();
  }

  void _listenChatSocket() {
    _newMessageSubscription =
        _chatSocketService.newMessageStream.listen(_onNewMessage);

    _conversationDeletedSubscription = _chatSocketService
        .onConversationDeletedStream
        .listen(_onConversationDeleted);

    _unreadMessageSubscription =
        _chatSocketService.onUnreadMessageStream.listen((event) async {});

    _messageDeletedSubscription =
        _chatSocketService.onMessageDeletedStream.listen((event) async {
      // TODO : Implement this delete message logic
    });

    _addOrRemoveUserBySocketSubscription = _chatSocketService
        .onAddOrRemoveUserToGroupStream
        .listen(addOrRemoveUserBySocket);

    _messageSeenSubscription =
        _chatSocketService.onSeenToMessageStream.listen(_onSeenMessage);
  }

  void _getConversations() {
    runAction(
      handleLoading: false,
      action: () async {
        final conversations = await _chatRepository.getConversations();

        // conversations = conversations
        //     .where((conversation) =>
        //         conversation.messages.isNotEmpty || conversation.isGroup)
        //     .toList();

        _conversations.value = conversations;
        isLoadingInit.value = false;
        for (final conversation in _conversations) {
          try {
            await _updateConversationMembers(conversation);
          } catch (e) {
            continue;
          }
        }
        filterAllConversations.value = conversations.take(6).toList();
        // _conversations.removeWhere((element) => element.members.isEmpty);
      },
      onError: (exception) {
        isLoadingInit.value = false;
      },
    );
  }

  void _getArchived() {
    runAction(
      handleLoading: false,
      action: () async {
        final conversations = await _chatRepository.getConversationByArchived();
        _archivedConversations.value = conversations;
        isLoadingInit.value = false;
        for (final conversation in _archivedConversations) {
          try {
            await _updateConversationMembers(conversation);
          } catch (e) {
            continue;
          }
        }
      },
      onError: (exception) {
        isLoadingInit.value = false;
      },
    );
  }

  Future<void> _updateConversationMembers(Conversation conversation) async {
    final index = _conversations.indexOf(conversation);

    // Only update get conversation members if the conversation is private chat
    if (conversation.isGroup) {
      final lastMessage = conversation.lastMessage;
      if (lastMessage?.type == MessageType.system) {
        final contentMessage =
            MessageSystem.fromJson(jsonDecode(lastMessage?.content ?? ''));

        if (contentMessage.memberIds.isNotEmpty) {
          final userId = int.tryParse(contentMessage.memberIds.first);
          if (userId != null) {
            final User member =
                await GetUserByIdWithUserPoolUsecase().call(userId);

            _conversations[index] = conversation.copyWith(
              memberActionSystem: [member],
            );
          }
        }
      }

      return;
    }

    for (final memberId in conversation.memberIds) {
      try {
        await _updateConversationMember(
          memberId: memberId,
          conversationIndex: index,
        );
      } catch (e) {
        continue;
      }
    }

    await _updateConversationMember(
      memberId: conversation.creatorId,
      conversationIndex: index,
    );
  }

  Future<void> updateConversation(Conversation conversation) async {
    final index = _conversations
        .toList()
        .indexWhere((item) => item.id == conversation.id);

    // final newConversation = await _chatRepository.getConversationById(
    //   conversationId: conversation.id,
    // );
    _conversations[index] = conversation.copyWith(
      lastSeen: 0,
      unreadCount: 0,
      // lastSeenUsers: newConversation.lastSeenUsers,
    );
  }

  Future<void> _updateConversationMember({
    required int memberId,
    required int conversationIndex,
  }) async {
    await runAction(
      handleLoading: false,
      action: () async {
        final conversation = _conversations[conversationIndex];

        if (conversation.members.any((member) => member.id == memberId)) {
          return;
        }

        final userPool = Get.find<UserPool>();

        late User user;
        final cachedUser = userPool.getUser(memberId);
        if (cachedUser != null) {
          user = cachedUser;
        } else {
          user = await _userRepository.getUserById(memberId);

          unawaited(userPool.storeUser(user));
        }

        final members = [...conversation.members, user];

        _conversations[conversationIndex] = conversation.copyWith(
          members: members,
          admins: members.where((member) {
            return conversation.adminIds.contains(member.id);
          }).toList(),
        );
      },
    );
  }

  Future<Conversation> getPrivateConversation(User user) async {
    Conversation? conversation;

    conversation = _conversations.firstWhereOrNull(
      (conversation) =>
          !conversation.isGroup && conversation.memberIds.contains(user.id),
    );

    if (conversation == null) {
      conversation = await _chatRepository.createConversation([user.id]);
      conversation = conversation.copyWith(
        members: [user],
      );
    }

    return conversation;
  }

  Future<void> createConversationAndGotoChatHub(List<User> users) async {
    return runAction(
      action: () async {
        // Private chat
        if (users.length == 1) {
          final privateConversation = await getPrivateConversation(users.first);

          return Get.toNamed(
            Routes.chatHub,
            arguments: ChatHubArguments(conversation: privateConversation),
          );
        }

        // Group chat
        var conversation = await _chatRepository
            .createConversation(users.map((e) => e.id).toList());

        var conversationName = 'New Group';
        try {
          if (conversationNameController.text.trim().isNotEmpty) {
            conversationName = conversationNameController.text.trim();
          }
        } catch (e) {
          LogUtil.e(e);
        }
        conversation = await _chatRepository.updateGroupChatInfo(
          conversation: conversation,
          name: conversationName,
        );

        conversation = conversation.copyWith(
          members: [
            ...users,
            // currentUser,
          ],
        );

        return Get.toNamed(
          Routes.chatHub,
          arguments: ChatHubArguments(conversation: conversation),
        );
      },
    );
  }

  final conversationNameController = TextEditingController();

  Future<void> _onNewMessage(Message newMessage) async {
    _incrementUnreadMessageCount();

    final conversation = _conversations.firstWhereOrNull(
      (conversation) => conversation.id == newMessage.conversationId,
    );

    // TODO: Check chat members

    // if not null => re-oder conversation to top of list
    if (conversation != null) {
      _conversations.remove(conversation);
      _conversations.insert(
        0,
        conversation.copyWith(
          messages: [
            newMessage,
            ...conversation.messages,
          ],
          unreadCount: (conversation.unreadCount ?? 0) + 1,
        ),
      );

      return;
    }

    // If conversation is null, get the conversation by id from the server
    await runAction(
      handleLoading: false,
      action: () async {
        final newConversation = await _chatRepository.getConversationById(
          conversationId: newMessage.conversationId,
        );

        if (newConversation.messages.isEmpty ||
            newConversation.messages.first.id != newMessage.id) {
          newConversation.messages.add(newMessage);
        }

        _conversations.insert(0, newConversation);

        await _updateConversationMembers(newConversation);
      },
    );
  }

  Future<void> _onSeenMessage(Map<String, dynamic> data) async {
    final String roomId = data['roomId'];
    final String userId = data['userId'];
    final int lastSeen = data['lastSeen'];

    final conversation = _conversations.firstWhereOrNull(
      (conversation) => conversation.id == roomId,
    );

    if (conversation != null) {
      final index = _conversations.indexOf(conversation);

      final updatedLastSeenUsers =
          Map<String, int>.from(conversation.lastSeenUsers ?? {});
      updatedLastSeenUsers[userId] = lastSeen;

      final newConversation = conversation.copyWith(
        lastSeenUsers: updatedLastSeenUsers,
      );
      _conversations[index] = newConversation;
      update();

      return;
    }
  }

  void _onConversationDeleted(String conversationId) {
    _conversations
        .removeWhere((conversation) => conversation.id == conversationId);
  }

  void deleteConversation(Conversation conversation) {
    runAction(
      handleError: true,
      action: () async {
        await _chatRepository.deleteConversation(conversation);
        _conversations.remove(conversation);
        Get.back();
        ViewUtil.showToast(
          title: l10n.global__success_title,
          message: l10n.chat_dashboard__delete_conversation_success,
        );
      },
    );
  }

  // void filterConversations(String query) {
  //   if (query.isEmpty) {
  //     _filteredConversations.value = _conversations;

  //     return;
  //   }

  //   _filteredConversations.value = _conversations
  //       .where((conversation) =>
  //           conversation.title().toLowerCase().contains(query.toLowerCase()))
  //       .toList();
  // }

  // void updateShowGroupConversations(bool isShowGroup) {
  //   showGroupConversations.value = isShowGroup;

  //   // hide filter group

  //   // _filteredConversations.value = _conversations
  //   //     .where((conversation) => conversation.isGroup == isShowGroup)
  //   //     .toList();

  //   _filteredConversations.value = _conversations.toList();
  // }

  // void clearSearch() {
  //   isSearching.value = false;

  //   // hide filter group

  //   // _filteredConversations.value = _conversations.where((conversation) {
  //   //   return conversation.isGroup == showGroupConversations.value;
  //   // }).toList();

  //   _filteredConversations.value = _conversations.toList();
  // }

  Future<void> goToPrivateChat(
    User user, {
    Completer<void>? completer,
  }) async {
    try {
      showLoading();
      Conversation? conversation = _conversations.firstWhereOrNull(
        (conversation) =>
            !conversation.isGroup && conversation.memberIds.contains(user.id),
      );

      conversation ??= await getPrivateConversation(user);

      completer?.complete();

      if (Get.currentRoute == Routes.chatHub) {
      } else {
        Get.find<ChatHubController>()
            .replaceConversation(ChatHubArguments(conversation: conversation));
        Get.back();
        Get.back();
      }

      // await Future.delayed(const Duration(milliseconds: 500));

      // unawaited(
      //   Get.offAndToNamed(
      //     Routes.chatHub,
      //     arguments: ChatHubArguments(conversation: conversation),
      //   ),
      // );
    } finally {
      hideLoading();
    }
  }

  // /// Handles the event of receiving an unread message.
  // ///
  // /// This method is triggered when a new unread message event is received.
  // /// It updates the unread count of the corresponding conversation in the
  // /// [_conversations] list and refreshes the list to reflect the changes in the UI.
  // ///
  // /// The [event] parameter is an instance of [UnreadMessage] which contains
  // /// the ID of the conversation room and the count of unread messages.
  // void _onUnreadMessage(UnreadMessage event) {
  //   // Find the index of the conversation in the _conversations list
  //   // that matches the roomId in the event
  //   final conversationIndex = _conversations.indexWhere(
  //     (conversation) => conversation.id == event.roomId,
  //   );

  //   // If no matching conversation is found, exit the function
  //   if (conversationIndex == -1) return;

  //   // Update the unreadCount of the found conversation with the unreadCount from the event
  //   _conversations[conversationIndex] =
  //       _conversations[conversationIndex].copyWith(
  //     unreadCount: event.unreadCount,
  //   );

  //   // Refresh the _conversations list to reflect the changes in the UI
  //   _conversations.refresh();
  // }

  void addOrRemoveUserBySocket(AddOrRemoveUserBySocket addOrRemoveUser) {
    final conversation = _conversations.firstWhereOrNull(
      (conversation) => conversation.id == addOrRemoveUser.roomId,
    );

    // if not null => re-oder conversation to top of list
    if (conversation != null) {
      final contentJson = addOrRemoveUser.addedMembers.isNotEmpty
          ? {
              'type': MessageSystemType.addMember.value,
              'members': addOrRemoveUser.addedMembers,
            }
          : addOrRemoveUser.removedMembers.isNotEmpty
              ? {
                  'type': MessageSystemType.removeMember.value,
                  'members': addOrRemoveUser.removedMembers,
                }
              : {};

      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversation.id,
        type: MessageType.system,
        createdAt: DateTime.now(),
        senderId: -1,
        content: jsonEncode(contentJson),
      );

      _conversations.remove(conversation);
      _conversations.insert(
        0,
        conversation.copyWith(
          messages: [
            newMessage,
            ...conversation.messages,
          ],
        ),
      );

      return;
    }
  }

  void _getUnreadMessageCount() {
    runAction(
      handleLoading: false,
      action: () async {
        final unreadMessages = await _chatRepository.getUnreadMessageCount();

        _unReadMessageCount.value = unreadMessages;
      },
    );
  }

  void _incrementUnreadMessageCount() {
    _unReadMessageCount.value++;
  }

  void _decrementUnreadMessageCount({int count = 1}) {
    _unReadMessageCount.value -= count;
  }

  void goToChat(Conversation conversation) {
    _decrementUnreadMessageCount(count: conversation.unreadCount ?? 0);

    Get.toNamed(
      Routes.chatHub,
      arguments: ChatHubArguments(conversation: conversation),
    )?.then((_) => refresh());
  }

  void onSharePickedMedia({
    required List<Conversation> conversations,
    required List<PickedMedia> listPickedMedia,
  }) {
    runAction(
      handleLoading: false,
      action: () async {
        final messageType = switch (listPickedMedia.first.type) {
          MediaAttachmentType.image => MessageType.image,
          MediaAttachmentType.video => MessageType.video,
          MediaAttachmentType.audio => MessageType.audio,
          MediaAttachmentType.document => MessageType.file,
        };

        sendMediaMessageFromShareToConversationsSelected(
          conversations: conversations,
          type: messageType,
          files: listPickedMedia.map((e) {
            return e.file;
          }).toList(),
        );
        if (messageTextController.text.trim().isNotEmpty) {
          Future.delayed(const Duration(seconds: 1), () {
            sendTextMessageToConversationsSelected(
              conversations,
              messageTextController.text.trim(),
            );
          });
        }

        Get.back();

        Future.delayed(const Duration(seconds: 2), () {
          ViewUtil.showToast(
            title: l10n.notification__title,
            message: l10n.newsfeed__share_action_sent,
          );
        });

        update();
      },
      onError: (exception) {
        update();
      },
    );
  }

  void onSharePost({
    required List<Conversation> conversations,
    required Post post,
    required BuildContext context,
  }) {
    runAction(
      action: () async {
        if (messageTextController.text.trim().isNotEmpty) {
          sendTextMessageToConversationsSelected(
            conversations,
            messageTextController.text.trim(),
          );
        }

        for (var conversation in conversations) {
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
          Navigator.of(context).pop();
        }
      },
      onError: (exception) {
        update();
      },
    );
  }

  void sendMediaMessageFromShareToConversationsSelected({
    required List<Conversation> conversations,
    required MessageType type,
    required List<File> files,
  }) {
    assert(type != MessageType.text);
    for (var conversation in conversations) {
      final conversationId = conversation.id;
      for (var file in files) {
        final localMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          content: file.path,
          type: type,
          createdAt: DateTime.now(),
          senderId: currentUser.id,
          sender: currentUser,
          isLocal: true,
        );

        runAction(
          handleLoading: false,
          action: () async {
            final url = await _storageRepository.uploadConversationMedia(
              file: file,
              messageType: type,
              conversationId: conversationId,
            );

            if (file.existsSync()) {
              await file.delete();
            }

            final toSendMessage = localMessage.copyWith(content: url);

            await _chatRepository.sendMessage(
              toSendMessage,
            );

            Future.delayed(const Duration(seconds: 3), () {
              _getConversations();
            });
          },
        );
      }
    }
  }

  Future<void> sendTextMessageToConversationsSelected(
    List<Conversation> conversations,
    String content,
  ) async {
    if (content.trim().isEmpty) {
      return;
    }

    // detect if the message contains link and send it as hyperlink with <hyper> tag

    MessageType type = MessageType.text;

    for (var conversation in conversations) {
      final conversationId = conversation.id;
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

      final toSendMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        content: content.trim(),
        type: type,
        createdAt: DateTime.now(),
        senderId: currentUser.id,
        sender: currentUser,
      );

      runAction(
        handleLoading: false,
        action: () async {
          await _chatRepository.sendMessage(
            toSendMessage,
          );
        },
      );
    }
  }

  TextEditingController searchController = TextEditingController();
  TextEditingController messageTextController = TextEditingController();

  RxList<Conversation> filterAllConversations = <Conversation>[].obs;
  void searchConservation(String query) {
    query = query.trim().toLowerCase();

    filterAllConversations.value = allConversations
        .where((conversation) {
          // Assuming conversation has a 'name' property to search by
          return conversation.title().toLowerCase().contains(query);
        })
        .take(6)
        .toList();
  }

  // Preview chat
  Future<List<Message>> getPreviewChatMessage(String conversationId) async {
    final messageList =
        await _chatRepository.getPaginatedMessagesByConversationId(
      conversationId: conversationId,
      page: 1,
      pageSize: 30,
    );
    return messageList;
  }

  void updateLastSeenMessage(String conversationId) {
    runAction(
      handleLoading: false,
      action: () async {
        await _chatRepository.updateLastSeen(conversationId);

        _chatSocketService.onUnreadMessageStream.add(
          UnreadMessage(roomId: conversationId, unreadCount: 0),
        );

        ViewUtil.showToast(
          title: l10n.global__success_title,
          message: l10n.chat_dashboard__mark_seen_message_success,
        );
      },
    );
  }

  void blockConversation(Conversation conversation) {
    runAction(
      handleError: true,
      action: () async {
        await _chatRepository.blockUser(conversation.chatPartner()!.id);
        final index = _conversations.indexOf(conversation);
        final newConversation = conversation.copyWith(
          isBlocked: true,
          blockedByMe: true,
        );
        if (index != -1) {
          _conversations[index] = newConversation;
          ViewUtil.showAppSnackBar(
            Get.context!,
            l10n.global__user_has_been_blocked,
          );
          update();
        }
      },
    );
  }

  void archivedConversation(Conversation conversation) {
    runAction(
      handleError: true,
      action: () async {
        await _chatRepository.archivedRoom(conversation.id);
      },
    );
    update();
  }

  //   _archivedConversations.remove(conversation);
  //   _conversations.add(conversation);
  //   _archivedConversations.refresh();
  void unArchivedConversation(Conversation conversation) {
    runAction(
      handleError: true,
      action: () async {
        await _chatRepository.archivedRoom(conversation.id);
      },
    );
    update();
  }

  void unblockConversation(Conversation conversation) {
    if (conversation.isGroup ||
        !conversation.isBlocked ||
        !conversation.blockedByMe) {
      return;
    }

    runAction(
      action: () async {
        await _chatRepository.unblockUser(conversation.chatPartner()!.id);

        final index = _conversations.indexOf(conversation);
        final newConversation = conversation.copyWith(
          isBlocked: false,
        );
        if (index != -1) {
          _conversations[index] = newConversation;
          ViewUtil.showAppSnackBar(
            Get.context!,
            l10n.global__user_has_been_unblocked,
          );
          update();
        }
      },
    );
  }
}
