import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../../../models/enums/mute_conversation_option_enum.dart';
import '../../../../../../repositories/all.dart';
import '../../../../../common_controller.dart/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../common_widgets/reaction_chat_widget/model/menu_item.dart';
import '../../../../../common_widgets/reaction_chat_widget/utilities/hero_dialog_route.dart';
import '../../../../../resource/resource.dart';
import '../../../../all.dart';
import '../../../conversation_details/views/widgets/mute_widget.dart';
import 'preview_chat/preview_chat_dialog.dart';

class ConversationItem extends StatefulWidget {
  final Conversation conversation;
  final bool showChildOnly;
  final EdgeInsets? contentPadding;
  final VoidCallback? beforeGoToChat;
  final ChatDashboardController? controller;
  final bool isArchived;
  const ConversationItem({
    required this.conversation,
    this.contentPadding,
    this.showChildOnly = false,
    this.beforeGoToChat,
    this.isArchived = false,
    this.controller,
    super.key,
  });

  @override
  State<ConversationItem> createState() => _ConversationItemState();
}

class _ConversationItemState extends State<ConversationItem> {
  bool isMute = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.conversation.toJson());
    isMute = widget.conversation.isMuted ?? false;
  }

  void _onDeleteChat(BuildContext context) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.delete_chat__confirm_title,
      message: context.l10n.delete_chat__confirm_message,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__confirm,
      onPositivePressed: () {
        Get.find<ChatDashboardController>()
            .deleteConversation(widget.conversation);
      },
    );
  }

  Future<void> _onMuteChat(BuildContext context) async {
    final ChatRepository chatRepository = Get.find();
    if (widget.conversation.isMuted!) {
      await chatRepository.unMuteConversation(widget.conversation.id);
    } else {
      await chatRepository.muteConversation(
        conversationId: widget.conversation.id,
        muteOption: MuteConversationOption.forever,
      );
      // // update current conversation ui
      // conversation.value = conversation.copyWith(isMuted: true);
      // // update chat hub view
      // updateMuteInChatHubView(true);

      ViewUtil.showToast(
        title: Get.context!.l10n.notification__title,
        message: MuteConversationOption.forever.labelName(context.l10n),
      );
    }
    setState(() {
      isMute = !isMute;
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = GestureDetector(
      child: ListTile(
        contentPadding: widget.contentPadding,
        splashColor: Colors.transparent,
        leading: _buildAvatar(),
        title: MuteWidget(
          isMuted: widget.conversation.isMuted == true,
          child: _buildTitle(),
        ),
        subtitle: _buildSubtitle(context),
        trailing: _buildTrailing(context),
        onTap: () {
          Get.find<ChatDashboardController>().goToChat(widget.conversation);
        },
      ),
      onLongPressStart: (details) {
        if (widget.conversation.isBlocked && !widget.conversation.blockedByMe) {
          return;
        }
        showPreviewChat(
          context: context,
          details: details,
        );
      },
    );

    if (widget.showChildOnly) {
      return child;
    }

    return Slidable(
      key: ValueKey(widget.conversation.id),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.isArchived
                  ? widget.controller!
                      .unArchivedConversation(widget.conversation)
                  : widget.controller!
                      .archivedConversation(widget.conversation);
            });
          },
        ),
        children: [
          if (widget.isArchived)
            CustomSlidableAction(
              onPressed: (context) => widget.controller!
                  .unArchivedConversation(widget.conversation),
              backgroundColor: AppColors.subText2,
              child: const Icon(Icons.archive_outlined, color: Colors.white),
            )
          else ...[
            _buildMuteAction(context),
            _buildDeleteAction(context),
            _buildStorageAction(context),
          ]
        ],
      ),
      child: child,
    );
  }

  Widget _buildAvatar() {
    final child = AppCircleAvatar(
      url: widget.conversation.avatarUrl ?? '',
    );

    if (widget.conversation.isBlocked) {
      return Stack(
        children: [
          child,
          Positioned(
            bottom: 0,
            right: 0,
            child: AppIcon(
              icon: AppIcons.block,
              isCircle: true,
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.negative,
              color: AppColors.white,
              size: Sizes.s20,
            ),
          ),
        ],
      );
    }

    return child;
  }

  Widget _buildTitle() {
    if (!widget.conversation.isGroup &&
        widget.conversation.chatPartner() != null) {
      return ContactDisplayNameText(
        user: widget.conversation.chatPartner()!,
        style: AppTextStyles.s16w500.text2Color,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return Row(
      children: [
        if (widget.conversation.isGroup)
          const Icon(
            Icons.group,
            size: 18,
            color: Colors.black,
          ),
        AppSpacing.gapW4,
        Expanded(
          child: Text(
            widget.conversation.title(),
            style: AppTextStyles.s16w500.text2Color,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final lastMessage = widget.conversation.lastMessage;

    final sender = widget.conversation.members.firstWhereOrNull(
      (e) => e.id == lastMessage?.senderId,
    );

    final senderText = sender == null || lastMessage?.type == MessageType.system
        ? null
        : sender.id == Get.find<AppController>().currentUser.id
            ? context.l10n.global__you
            : sender.contactName;

    String? content;

    if (widget.conversation.lastMessage != null) {
      final isMyMessage = widget.conversation.lastMessage!
          .isMine(myId: Get.find<AppController>().currentUser.id);

      // ignore: no-equal-then-else, prefer-conditional-expressions
      if (!isMyMessage) {
        content = switch (widget.conversation.lastMessage!.type) {
          MessageType.text =>
            widget.conversation.lastMessage!.contentWithoutFormat,
          MessageType.hyperText =>
            widget.conversation.lastMessage!.contentWithoutFormat,
          MessageType.image => context.l10n.chat__sent_you_an_image,
          MessageType.video => context.l10n.chat__sent_you_a_video,
          MessageType.audio => context.l10n.chat__sent_you_a_voice,
          MessageType.call => context.l10n.chat__a_call,
          MessageType.file => context.l10n.chat__sent_a_document,
          MessageType.post => context.l10n.chat__sent_a_post,
          MessageType.sticker => context.l10n.chat__sent_a_sticker,
          MessageType.system => _textMessageSystem(context,
              message: widget.conversation.lastMessage!),
        };
      } else {
        content = switch (widget.conversation.lastMessage!.type) {
          MessageType.text =>
            widget.conversation.lastMessage!.contentWithoutFormat,
          MessageType.hyperText =>
            widget.conversation.lastMessage!.contentWithoutFormat,
          MessageType.image => context.l10n.chat__you_sent_an_image,
          MessageType.video => context.l10n.chat__you_sent_a_video,
          MessageType.audio => context.l10n.chat__you_sent_a_voice,
          MessageType.call => context.l10n.chat__a_call,
          MessageType.file => context.l10n.chat__you_sent_a_document,
          MessageType.post => context.l10n.chat__sent_a_post,
          MessageType.sticker => context.l10n.chat__you_sent_a_sticker,
          MessageType.system => _textMessageSystem(context,
              message: widget.conversation.lastMessage!),
        };
      }
    }

    if (content == null &&
        widget.conversation.isGroup &&
        widget.conversation.creator != null) {
      content = context.l10n
          .chat__name_created_group(widget.conversation.creator!.contactName);
    }

    if (content == null) {
      return AppSpacing.gapH4;
    }

    return Text(
      senderText != null ? '$senderText: $content' : content,
      style: widget.conversation.unreadCount != null &&
              widget.conversation.unreadCount! > 0
          ? AppTextStyles.s12w700.copyWith(color: AppColors.text2)
          : AppTextStyles.s12w400.copyWith(color: AppColors.zambezi),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildTrailing(BuildContext context) {
    if (widget.conversation.lastMessage == null) {
      return null;
    }

    final lastMessage = widget.conversation.lastMessage;

    final partner = widget.conversation.chatPartner();

    bool isPartnerSeenLastMessage = false;

    try {
      if (lastMessage != null &&
          partner != null &&
          widget.conversation.lastSeenUsers != null) {
        final isMyMessage =
            lastMessage.isMine(myId: Get.find<AppController>().currentUser.id);

        // ignore: no-equal-then-else, prefer-conditional-expressions
        if (isMyMessage) {
          final messageCreateAt = lastMessage.createdAt;
          final partnerLastSeen = DateTime.fromMillisecondsSinceEpoch(
              widget.conversation.lastSeenUsers![partner.id.toString()]!);
          isPartnerSeenLastMessage = messageCreateAt.isBefore(partnerLastSeen);
          if (isPartnerSeenLastMessage) {
            print(1);
          }
        }
      }
    } catch (e) {
      LogUtil.e(e);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.conversation.lastMessage != null
              ? DateTimeUtil.timeAgo(
                  context, widget.conversation.lastMessage!.createdAt)
              : '',
          style: AppTextStyles.s12w400.subText2Color,
        ),
        AppSpacing.gapH4,
        if (widget.conversation.unreadCount != null &&
            widget.conversation.unreadCount! > 0)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.conversation.unreadCount.toString(),
              style: AppTextStyles.s12w500.copyWith(color: AppColors.white),
            ),
          )
        else if (isPartnerSeenLastMessage)
          AppCircleAvatar(
            url: widget.conversation.avatarUrl ?? '',
            size: 16,
          ),
      ],
    );
  }

  Widget _buildDeleteAction(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (context) => _onDeleteChat(context),
      backgroundColor: AppColors.negative,
      child: AppIcon(
        icon: AppIcons.delete,
        color: AppColors.white,
        padding: EdgeInsets.zero,
        onTap: () => _onDeleteChat(context),
      ),
    );
  }

  Widget _buildStorageAction(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (context) =>
          widget.controller!.archivedConversation(widget.conversation),
      backgroundColor: AppColors.subText2,
      child: const AppIcon(
        icon: Icons.archive,
        color: AppColors.white,
        padding: EdgeInsets.zero,
      ),
    );
  }

  // void _onArchiveChat(BuildContext context, Conversation conversation) {
  //   widget.controller?.archivedConversation(conversation);
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Đã lưu trữ ${conversation.title()}')),
  //   );
  // }

  Widget _buildMuteAction(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (context) => _onMuteChat(context),
      backgroundColor: AppColors.blue10,
      child: AppIcon(
        icon: !isMute ? Assets.icons.muteNoti : Assets.icons.bell,
        color: AppColors.white,
        padding: EdgeInsets.zero,
      ),
    );
  }

  String _textMessageSystem(
    BuildContext context, {
    required Message message,
  }) {
    try {
      final messageSystem = MessageSystem.fromJson(jsonDecode(message.content));

      var user = widget.conversation.memberActionSystem.firstWhereOrNull(
        (element) => element.id.toString() == messageSystem.memberIds.first,
      );

      user ??= widget.conversation.members.firstWhereOrNull(
        (element) => element.id.toString() == messageSystem.memberIds.first,
      );

      final name = user?.contactName ?? user?.fullName ?? '';

      switch (messageSystem.type) {
        case MessageSystemType.addMember:
          return context.l10n.conversation_details__add_member(name);
        case MessageSystemType.removeMember:
          return context.l10n.conversation_details__remove_member(name);
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> showPreviewChat(
      {required BuildContext context,
      required LongPressStartDetails details}) async {
    final chatDashboardController = Get.find<ChatDashboardController>();
    final messageList = await chatDashboardController
        .getPreviewChatMessage(widget.conversation.id);

    final indexLastSeen = findIndexLastSeen(
      lastSeenUsers: widget.conversation.lastSeenUsers!,
      messages: messageList,
      conversation: widget.conversation,
      currentUserId: chatDashboardController.currentUser.id,
    );

    final double screenHeight = MediaQuery.of(context).size.height;
    final double yPosition = details.globalPosition.dy;
    String position = '';
    // Xác định vị trí nhấn theo chiều dọc
    if (yPosition < screenHeight / 3) {
      position = 'top';
    } else if (yPosition < 2 * screenHeight / 3) {
      position = 'center';
    } else {
      position = 'bottom';
    }
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      HeroDialogRoute(
        builder: (context) {
          final menuItems = _showMessageOptions(context);

          return PreviewChatDialogWidget(
            id: widget.conversation.id,
            menuItems: menuItems,
            messageWidget: const SizedBox(),
            onReactionTap: (reaction) {},
            onContextMenuTap: (item) {
              item.onPressed.call();
              // handle context menu item
            },
            position: position,
            messages: messageList,
            conversation: widget.conversation,
            currentUserId: chatDashboardController.currentUser.id,
            indexLastSeen: indexLastSeen,
          );
        },
      ),
    );
  }

  int findIndexLastSeen({
    required Map<String, int> lastSeenUsers,
    required List<Message> messages,
    required Conversation conversation,
    required int currentUserId,
  }) {
    var res = -1;
    try {
      if (conversation.isGroup) {
        return res;
      }

      final partner = conversation.chatPartner();
      final partnerLastSeen = DateTime.fromMillisecondsSinceEpoch(
          lastSeenUsers[partner!.id.toString()]!);

      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        final messageCreateAt = message.createdAt;
        final isPartnerSeenLastMessage =
            messageCreateAt.isBefore(partnerLastSeen);
        if (message.isMine(myId: currentUserId)) {
          if (isPartnerSeenLastMessage) {
            res = i;
            break;
          }
        } else {
          break;
        }
      }
    } catch (e) {
      LogUtil.e(e);
    }
    return res;
  }

  List<MenuItem> _showMessageOptions(BuildContext context) {
    final items = <MenuItem>[];
    final chatDashboardController = Get.find<ChatDashboardController>();
    final isPinned =
        chatDashboardController.pins.contains(widget.conversation.id);
    // items.add(
    //   MenuItem(
    //     label: context.l10n.chat_dashboard__mark_seen_message,
    //     icon: const Icon(
    //       Icons.mark_chat_read_outlined,
    //       size: 20,
    //       color: AppColors.grey8,
    //     ),
    //     onPressed: () {
    //       Get.find<ChatDashboardController>()
    //           .updateLastSeenMessage(widget.conversation.id);
    //     },
    //   ),
    // );

    items.add(
      MenuItem(
        label: widget.conversation.isBlocked
            ? context.l10n.text_unblock
            : context.l10n.button__block_user,
        icon: Icons.block,
        onPressed: widget.conversation.isBlocked
            ? _unBlockUserPressed
            : _onBlockUserPressed,
      ),
    );

    items.add(
      MenuItem(
          label: 'Lưu trữ tin nhắn',
          icon: Icons.archive_outlined,
          onPressed: () {
            _pinConversation();
          }),
    );
    items.add(
      MenuItem(
        label: isPinned ? 'Bỏ ghim' : 'Ghim tin nhắn',
        icon: isPinned
            ? AppIcons.unpin.svg(color: AppColors.subText2)
            : AppIcons.pin.svg(color: AppColors.subText2),
        onPressed: () {
          _pinConversation();
        },
      ),
    );
    items.add(
      MenuItem(
          label: context.l10n.chat_dashboard__delete_conversation,
          icon: AppIcons.delete.svg(color: AppColors.negative),
          onPressed: () {
            _onDeleteChat(context);
          }),
    );
    if (items.isEmpty) {
      return [];
    }
    return items;
  }

  void _onBlockUserPressed() {
    Get.find<ChatDashboardController>().blockConversation(widget.conversation);
  }

  void _unBlockUserPressed() {
    Get.find<ChatDashboardController>()
        .unblockConversation(widget.conversation);
  }

  void _pinConversation() {
    Get.find<ChatDashboardController>().pinConversation(widget.conversation.id);
  }
}
