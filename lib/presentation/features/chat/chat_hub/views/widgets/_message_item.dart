import 'dart:convert';
import 'dart:core';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stipop_sdk/model/sp_sticker.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../common_widgets/app_blurry_container.dart';
import '../../../../../common_widgets/reaction_chat_widget/flutter_chat_reactions.dart';
import '../../../../../common_widgets/reaction_chat_widget/model/menu_item.dart';
import '../../../../../common_widgets/reaction_chat_widget/utilities/hero_dialog_route.dart';
import '../../../../../resource/resource.dart';
import '../../../../../routing/routers/app_pages.dart';
import '../../../../all.dart';
import '../../../../search_user/all.dart';
import '../../controllers/pin_message_controller.dart';
import '_call_message_body.dart';
import '_media_message_body.dart';
import 'hyper_text_message_widget.dart';
import 'reply_message_widget.dart';
import 'swipe_to_reply_wrapper.dart';
import 'text_message_widget.dart';

class MessageItem extends StatelessWidget {
  final Message message;
  final Message? previousMessage;
  final Message? nextMessage;
  final bool isMine;
  final int currentUserId;
  final Function()? onTap;
  final VoidCallback onPressedUserAvatar;
  final bool isAdmin;
  final List<User> members;
  final bool isGroup;
  final Function(String? mention, Map<String, int> mentionUserIdMap)
      onMentionPressed;
  final Function(Message message) onSelectMessage;
  final bool isSelect;
  final bool isSelectMode;

  MessageItem({
    required this.message,
    required this.currentUserId,
    required this.onPressedUserAvatar,
    required this.onMentionPressed,
    required this.onSelectMessage,
    required this.isSelect,
    required this.isSelectMode,
    super.key,
    this.isMine = false,
    this.previousMessage,
    this.nextMessage,
    this.onTap,
    this.isAdmin = false,
    this.members = const [],
    this.isGroup = false,
  });

  /// variable for check if user is click see more first time
  final ValueNotifier<bool> _isClickedSeeMoreFirstTime = ValueNotifier(false);

  /// variable for store list of menu item
  final ValueNotifier<List<MenuItem>> _menuItems = ValueNotifier([]);

  List<MenuItem> _showMessageOptions(BuildContext context) {
    _menuItems.value.clear();
    _addReplyMenuItem(context);
    _addCopyMenuItem(context);
    _addCallJitsiMenuItem(context);
    _addPinMenuItem(context);
    // _addReportAndBlockMenuItems(context);
    _addSelectMenuItem(context, message);
    _addDownloadMenuItem(context);
    _addSeeMoreMenuItem(context, message);

    return _menuItems.value.isEmpty ? [] : _menuItems.value;
  }

  void _onReportMessagePressed(BuildContext context) {
    _popUpDialog(context);
    Get.find<ChatHubController>().reportMessage(message);
  }

  void _onBlockUserPressed(BuildContext context) {
    _popUpDialog(context);
    Get.find<ChatHubController>().blockUser(message.senderId);
  }

  void _onDeleteMessagePressed(BuildContext context) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.chat_hub__delete_message_title,
      message: context.l10n.chat_hub__delete_message_content,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__delete,
      onPositivePressed: () {
        Get.find<ChatHubController>().deleteMessage(message);
      },
    );
  }

  Future<void> _downloadMedia() {
    switch (message.type) {
      case MessageType.image:
        return FileUtil.saveNetworkImage(message.content);
      case MessageType.video:
        return FileUtil.saveNetworkFile(message.content);
      default:
        throw Exception('Unsupported media type');
    }
  }

  void _onForwardMessagePressed(BuildContext context) {
    ViewUtil.showBottomSheet<List<User>>(
      isScrollControlled: true,
      isFullScreen: true,
      child: CreateChatSearchUsersBottomSheet(
        allowSelectMultiple: false,
        title: context.l10n.chat__forward_to,
        hintText: context.l10n.global__search,
      ),
    ).then(
      (selectedUsers) {
        if (selectedUsers != null) {
          Get.find<ChatHubController>()
              .forwardMessage(selectedUsers.first, message);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool shouldPadding = true;
    if (previousMessage != null) {
      // log('--------------------------');
      // log(previousMessage!.type.toString());
      // log(previousMessage!.content.toString());
      // log(message.content);
      // log('--------------------------');
      if ((previousMessage!.type == MessageType.text ||
              message.type == MessageType.hyperText) &&
          message.repliedFrom == null &&
          message.forwardedFrom == null &&
          (message.type == MessageType.text ||
              message.type == MessageType.hyperText) &&
          message.createdAt.isSameDay(previousMessage!.createdAt)) {
        shouldPadding = false;
      }
    }

    bool shouldShowTime = true;
    if (nextMessage != null) {
      if (message.createdAt.isSameDay(nextMessage!.createdAt) &&
          (nextMessage!.type == MessageType.text ||
              nextMessage!.type == MessageType.sticker ||
              nextMessage!.type == MessageType.file ||
              nextMessage!.type == MessageType.call ||
              nextMessage!.type == MessageType.audio ||
              nextMessage!.type == MessageType.hyperText ||
              nextMessage!.type == MessageType.image ||
              nextMessage!.type == MessageType.video ||
              nextMessage!.type == MessageType.post) &&
          message.forwardedFrom == null &&
          (message.type == MessageType.text ||
              message.type == MessageType.sticker ||
              message.type == MessageType.file ||
              message.type == MessageType.call ||
              message.type == MessageType.audio ||
              message.type == MessageType.hyperText ||
              message.type == MessageType.image ||
              message.type == MessageType.video ||
              message.type == MessageType.post) &&
          nextMessage!.senderId == message.senderId) {
        shouldShowTime = false;
      }
    }

    final child = Column(
      children: [
        shouldPadding
            ? AppSpacing.gapH16
            : const SizedBox(
                height: 2,
              ),
        _buildDate(),
        if (message.type == MessageType.system && isGroup)
          _buildSystemMessage(context),
        if (message.type != MessageType.system)
          SwipeToReply(
            isMyMessage: isMine,
            onReply: () {
              _onReplyMessagePressed();
            },
            child: Column(
              crossAxisAlignment:
                  isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildSenderName(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment:
                      isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isMine && isSelectMode)
                      isSelect
                          ? AppIcon(
                              color: Colors.black,
                              icon: Icons.check_circle,
                              onTap: () {
                                onSelectMessage(message);
                              },
                            ).paddingOnly(
                              bottom: shouldShowTime ? 28 : 4, right: 8)
                          : AppIcon(
                              color: Colors.black,
                              icon: Icons.radio_button_unchecked,
                              onTap: () {
                                onSelectMessage(message);
                              },
                            ).paddingOnly(
                              bottom: shouldShowTime ? 28 : 4, right: 8),
                    if (!isMine) _buildMessageAvatar(),
                    AppSpacing.gapW8,
                    Flexible(child: _buildMessageBody(context)),
                    if (isMine && isSelectMode)
                      isSelect
                          ? AppIcon(
                              color: Colors.black,
                              icon: Icons.check_circle,
                              onTap: () {
                                onSelectMessage(message);
                              },
                            ).paddingOnly(
                              bottom: shouldShowTime ? 28 : 4,
                              left: 8,
                            )
                          : AppIcon(
                              color: Colors.black,
                              icon: Icons.radio_button_unchecked,
                              onTap: () {
                                onSelectMessage(message);
                              },
                            ).paddingOnly(
                              bottom: shouldShowTime ? 28 : 4,
                              left: 8,
                            ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }

  Widget _buildMessageAvatar() {
    // Check if next message is from the same user to avoid showing the avatar
    final bool shouldShowAvatar = nextMessage == null ||
        nextMessage!.senderId != message.senderId ||
        nextMessage!.type == MessageType.system;

    return shouldShowAvatar
        ? Padding(
            padding: const EdgeInsets.only(bottom: 26, right: 4),
            child: AppCircleAvatar(
              url: message.sender?.avatarPath ?? '',
              size: Sizes.s36,
            ).clickable(onPressedUserAvatar),
          )
        : AppSpacing.gapW40;
  }

  Widget _buildDate() {
    final bool shouldShowDate = previousMessage == null ||
        !message.createdAt.isSameDay(previousMessage!.createdAt);

    return shouldShowDate
        ? IgnorePointer(
            child: Container(
              padding: AppSpacing.edgeInsetsAll16.copyWith(top: 0),
              alignment: Alignment.center,
              child: Text(
                message.createdAt.toLocaleString(),
                style: AppTextStyles.s12w400.toColor(
                  AppColors.grey8,
                ),
              ),
            ),
          )
        : AppSpacing.emptyBox;
  }

  Widget _buildMessageBody(BuildContext context) {
    final Widget messageBody;

    switch (message.type) {
      case MessageType.text:
        messageBody = TextMessageWidget(
          isMine: isMine,
          message: message,
          members: members,
          onMentionPressed: onMentionPressed,
        );
      // _buildTextMessage();
      case MessageType.hyperText:
        messageBody = HyperTextMessageWidget(
          isMine: isMine,
          message: message,
          members: members,
          onMentionPressed: onMentionPressed,
        );
      // messageBody = _buildHyperTextMessage();
      case MessageType.image:
      case MessageType.video:
      case MessageType.audio:
        messageBody = MediaMessageBody(
          key: ValueKey(message.id),
          message: message,
          isMine: isMine,
        );
      case MessageType.call:
        messageBody = CallMessageBody(
          message: message,
          isMine: isMine,
          currentUserId: currentUserId,
        );
      case MessageType.file:
        messageBody = _buildFileMessage();
      case MessageType.post:
        messageBody = _buildPostMessage(context);
      case MessageType.sticker:
        messageBody = _buildStickerMessage();
      case MessageType.system:
        messageBody = const SizedBox();
    }

    bool shouldShowTime = true;
    if (nextMessage != null) {
      if (message.createdAt.isSameDay(nextMessage!.createdAt) &&
          (nextMessage!.type == MessageType.text ||
              nextMessage!.type == MessageType.sticker ||
              nextMessage!.type == MessageType.file ||
              nextMessage!.type == MessageType.call ||
              nextMessage!.type == MessageType.audio ||
              nextMessage!.type == MessageType.hyperText ||
              nextMessage!.type == MessageType.image ||
              nextMessage!.type == MessageType.video ||
              nextMessage!.type == MessageType.post) &&
          message.forwardedFrom == null &&
          (message.type == MessageType.text ||
              message.type == MessageType.sticker ||
              message.type == MessageType.file ||
              message.type == MessageType.call ||
              message.type == MessageType.audio ||
              message.type == MessageType.hyperText ||
              message.type == MessageType.image ||
              message.type == MessageType.video ||
              message.type == MessageType.post) &&
          nextMessage!.senderId == message.senderId) {
        shouldShowTime = false;
      }
    }

    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (message.repliedFrom != null)
          ReplyMessageWidget(
            message: message.repliedFrom!,
            isMine: isMine,
            onClick: _onJumpToRepliedMessage,
            members: members,
            onMentionPressed: onMentionPressed,
          ),
        if (message.forwardedFrom != null)
          Text(
            context.l10n.chat__forward_message,
            style: AppTextStyles.s12w600.toColor(
              AppColors.blue10,
            ),
          ).paddingOnly(bottom: Sizes.s8),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMine)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      message.type == MessageType.text ||
                              message.type == MessageType.hyperText ||
                              message.type == MessageType.image
                          ? SizedBox(
                              width: 0.15.sw,
                            )
                          : AppSpacing.gapW8,
                      // _buildButtonReaction(),
                    ],
                  ),
                  AppSpacing.gapW8,
                ],
              ),
            Flexible(
              child: GestureDetector(
                // onLongPress: () => _showMessageOptions(context),
                onLongPressStart: (details) {
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
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

                        return ReactionsDialogWidget(
                          id: message.id,
                          menuItems: menuItems,
                          messageWidget: message.type == MessageType.image ||
                                  message.type == MessageType.video ||
                                  message.type == MessageType.audio
                              ? MediaMessageBody(
                                  key: ValueKey(message.id),
                                  message: message,
                                  isMine: isMine,
                                  isReaction: true,
                                )
                              : message.type == MessageType.call
                                  ? CallMessageBody(
                                      message: message,
                                      isMine: isMine,
                                      currentUserId: currentUserId,
                                    )
                                  : message.type == MessageType.file
                                      ? _buildFileMessage()
                                      : message.type == MessageType.post
                                          ? _buildPostMessage(context)
                                          : message.type == MessageType.sticker
                                              ? _buildStickerMessage()
                                              : TextMessageWidget(
                                                  isReaction: true,
                                                  isMine: isMine,
                                                  message: message,
                                                  members: members,
                                                  onMentionPressed:
                                                      onMentionPressed), // message widget
                          onReactionTap: (reaction) {
                            print('reaction: $reaction');

                            if (reaction == '➕') {
                              // show emoji picker container
                              // showEmojiBottomSheet(
                              //   message: message,
                              // );
                            } else {
                              Get.find<ChatHubController>().reactToMessage(
                                message,
                                reaction,
                                userId: currentUserId.toString(),
                              );
                            }
                          },
                          onContextMenuTap: (item) {
                            item.onPressed.call();
                            // handle context menu item
                          },
                          // align widget to the right for my message and to the left for contact message
                          // default is [Alignment.centerRight]
                          widgetAlignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          position: position,
                        );
                      },
                    ),
                  );
                },
                onDoubleTap: () {
                  Get.find<ChatHubController>().reactToMessage(
                    message,
                    ReactionMessageEnum.love.name,
                    userId: currentUserId.toString(),
                  );
                },
                child: Hero(
                  tag: message.id,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isMine
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          messageBody,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildShowReaction(
                                message.reactions,
                              ),
                            ],
                          ),
                          if (shouldShowTime && isMine)
                            Align(
                              alignment: Alignment.centerRight,
                              child: _buildMessageTime(),
                            ),
                        ],
                      ),
                      if (shouldShowTime && !isMine) _buildMessageTime(),
                    ],
                  ),
                ),
              ),
            ),
            if (!isMine)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSpacing.gapW8,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      message.type == MessageType.text ||
                              message.type == MessageType.hyperText ||
                              message.type == MessageType.image
                          ? SizedBox(
                              width: 0.15.sw,
                            )
                          : AppSpacing.gapW8,
                      // _buildButtonReaction(),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessageTime() {
    return Padding(
      padding:
          message.reactions != null ? EdgeInsets.zero : AppSpacing.edgeInsetsV4,
      child: Text(
        message.createdAt.toStringTimeOnly(),
        style: AppTextStyles.s12w400.toColor(
          AppColors.grey8,
        ),
      ),
    );
  }

  Widget _buildSenderName() {
    if (isMine ||
        message.sender == null ||
        (previousMessage != null &&
            previousMessage!.senderId == message.senderId)) {
      return AppSpacing.emptyBox;
    }

    return Padding(
      padding: const EdgeInsets.only(
        left: Sizes.s48,
        bottom: Sizes.s8,
      ),
      child: ContactDisplayNameText(
        user: message.sender!,
        style: AppTextStyles.s12w600.text2Color,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFileMessage() {
    return Container(
      padding: AppSpacing.edgeInsetsAll16,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            Sizes.s12,
          ),
          color: isMine ? AppColors.blue8 : AppColors.grey7),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: isMine ? AppColors.blue10 : AppColors.grey8,
          ),
          AppSpacing.gapW4,
          Flexible(
            child: Text(
              message.content.split('/').last,
              style: AppTextStyles.s14w400.toColor(
                isMine ? AppColors.blue10 : AppColors.text2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).clickable(() {
      IntentUtils.openBrowserURL(url: message.content);
    });
  }

  Widget _buildPostMessage(BuildContext context) {
    final Post post = Post.fromJson(jsonDecode(message.content));

    return AppBlurryContainer(
      blur: isMine ? 5 : 0,
      color: isMine ? AppColors.blue8 : AppColors.grey7,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 0.6.sw,
        child: Column(
          children: [
            if (post.attachments.isNotEmpty)
              AppNetworkImage(
                post.attachments.first.thumb ?? '',
                width: 0.6.sw,
                height: 0.6.sw,
                fit: BoxFit.fitWidth,
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((post.content ?? '').isNotEmpty)
                  ExpandableText(
                    (post.content ?? '').trim(),
                    expandText: context.l10n.global__show_more_label,
                    collapseText: context.l10n.global__show_less_label,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.s14w600.text2Color,
                    linkColor: AppColors.grey8,
                    onUrlTap: (url) {
                      IntentUtils.openBrowserURL(url: url);
                    },
                    urlStyle: AppTextStyles.s12w500.text4Color,
                  ),
                AppSpacing.gapH8,
                AppButton.primary(
                  label: context.l10n.newsfeed__view_post,
                  textStyleLabel: AppTextStyles.s14w400,
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  height: Sizes.s40,
                  onPressed: () {
                    Get.toNamed(
                      Routes.postDetail,
                      arguments: {'postId': post.id},
                    );
                  },
                ),
              ],
            ).marginSymmetric(horizontal: Sizes.s16, vertical: Sizes.s12),
          ],
        ),
      ),
    );
  }

  void _onReplyMessagePressed() {
    Get.find<ChatHubController>().replyMessage(message);
  }

  void _onJumpToRepliedMessage(Message message) {
    Get.find<ChatHubController>().jumpToMessage(message);
  }

  Widget _buildButtonReaction() {
    return ReactionButton<String>(
      toggle: false,
      onReactionChanged: (Reaction<String>? reaction) {
        if (reaction != null) {
          Get.find<ChatHubController>().reactToMessage(
            message,
            reaction.value ?? ReactionMessageEnum.like.name,
            userId: currentUserId.toString(),
          );
        }
      },
      reactions: <Reaction<String>>[
        Reaction<String>(
          value: ReactionMessageEnum.love.name,
          icon: const Text(
            '❤️',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Reaction<String>(
          value: ReactionMessageEnum.haha.name,
          icon: const Text(
            '😄',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Reaction(
          value: ReactionMessageEnum.sad.name,
          icon: const Text(
            '😢',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Reaction(
          value: ReactionMessageEnum.like.name,
          icon: const Text(
            '👍',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Reaction(
          value: ReactionMessageEnum.angry.name,
          icon: const Text(
            '😡',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
        Reaction(
          value: ReactionMessageEnum.wow.name,
          icon: const Text(
            '😮',
            style: TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
        ),
      ],
      itemSize: const Size(
        Sizes.s36,
        Sizes.s36,
      ),
      child: AppIcon(
        icon: AppIcons.emoji,
        size: Sizes.s16,
        color: AppColors.text2,
      ),
    );
  }

  Widget _buildShowReaction(Map<String, dynamic>? reactions) {
    if (reactions == null || reactions.isEmpty) {
      return const SizedBox();
    }

    final List<String> like = [];
    final List<String> love = [];
    final List<String> haha = [];
    final List<String> wow = [];
    final List<String> angry = [];
    final List<String> sad = [];

    reactions.forEach((key, value) {
      if (key == ReactionMessageEnum.like.name) {
        for (var item in value) {
          like.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.love.name) {
        for (var item in value) {
          love.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.haha.name) {
        for (var item in value) {
          haha.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.wow.name) {
        for (var item in value) {
          wow.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.angry.name) {
        for (var item in value) {
          angry.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.sad.name) {
        for (var item in value) {
          sad.add(item.toString());
        }
      }
    });

    return Transform.translate(
      offset: const Offset(0, -Sizes.s8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMine) AppSpacing.gapW8,
          if (love.isNotEmpty)
            _buildItemReaction(
              icon: '❤️',
              reactListUser: love,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (haha.isNotEmpty)
            _buildItemReaction(
              icon: '😆',
              reactListUser: haha,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (sad.isNotEmpty)
            _buildItemReaction(
              icon: '😢',
              reactListUser: sad,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (like.isNotEmpty)
            _buildItemReaction(
              icon: '👍',
              reactListUser: like,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (angry.isNotEmpty)
            _buildItemReaction(
              icon: '😡',
              reactListUser: angry,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (wow.isNotEmpty)
            _buildItemReaction(
              icon: '😮',
              reactListUser: wow,
              onTap: () {
                _buildShowBottomSheetUserReaction(reactions);
              },
            ),
          if (isMine) AppSpacing.gapW8,
        ],
      ),
    );
  }

  Widget _buildItemReaction({
    required String icon,
    List<String> reactListUser = const [],
    Function()? onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(
            icon,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        if (reactListUser.length > 1)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacing.gapW2,
              Text(
                reactListUser.length.toString(),
                style: AppTextStyles.s12w400.toColor(AppColors.pacificBlue),
              ),
            ],
          ),
      ],
    );
  }

  Future _buildShowBottomSheetUserReaction(Map<String, dynamic> reactions) {
    final List<String> like = [];
    final List<String> love = [];
    final List<String> haha = [];
    final List<String> wow = [];
    final List<String> angry = [];
    final List<String> sad = [];

    message.reactions?.forEach((key, value) {
      if (key == ReactionMessageEnum.like.name) {
        for (var item in value) {
          like.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.love.name) {
        for (var item in value) {
          love.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.haha.name) {
        for (var item in value) {
          haha.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.wow.name) {
        for (var item in value) {
          wow.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.angry.name) {
        for (var item in value) {
          angry.add(item.toString());
        }
      }

      if (key == ReactionMessageEnum.sad.name) {
        for (var item in value) {
          sad.add(item.toString());
        }
      }
    });

    final int tabLength = (like.isNotEmpty ? 1 : 0) +
        (love.isNotEmpty ? 1 : 0) +
        (haha.isNotEmpty ? 1 : 0) +
        (wow.isNotEmpty ? 1 : 0) +
        (angry.isNotEmpty ? 1 : 0) +
        (sad.isNotEmpty ? 1 : 0);

    return Get.bottomSheet(
      SizedBox(
        height: 0.4.sh,
        child: AppBlurryContainer(
          child: DefaultTabController(
            length: tabLength,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    if (love.isNotEmpty)
                      Tab(
                        icon: AppIcon(
                          icon: AppIcons.love,
                          size: Sizes.s32,
                        ),
                      ),
                    if (haha.isNotEmpty)
                      Tab(
                        icon: AppIcon(
                          icon: AppIcons.haha,
                          size: Sizes.s32,
                        ),
                      ),
                    if (sad.isNotEmpty)
                      Tab(
                        icon: AppIcon(
                          icon: AppIcons.sad,
                          size: Sizes.s32,
                        ),
                      ),
                    if (like.isNotEmpty)
                      Tab(
                        icon: AppIcon(
                          icon: AppIcons.like,
                          size: Sizes.s32,
                        ),
                      ),
                    if (angry.isNotEmpty)
                      Tab(
                        icon: AppIcon(
                          icon: AppIcons.angry,
                          size: Sizes.s32,
                        ),
                      ),
                    if (wow.isNotEmpty)
                      Tab(
                        icon: AppIcon(
                          icon: AppIcons.wow,
                          size: Sizes.s32,
                        ),
                      ),
                  ],
                ),
                AppSpacing.gapH12,
                Expanded(
                  child: TabBarView(
                    children: [
                      if (love.isNotEmpty) _buildItemBottomSheet(love),
                      if (haha.isNotEmpty) _buildItemBottomSheet(haha),
                      if (like.isNotEmpty) _buildItemBottomSheet(like),
                      if (sad.isNotEmpty) _buildItemBottomSheet(sad),
                      if (angry.isNotEmpty) _buildItemBottomSheet(angry),
                      if (wow.isNotEmpty) _buildItemBottomSheet(wow),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemBottomSheet(List<String> reactListUser) {
    return GetBuilder<ChatHubController>(
      init: ChatHubController(),
      builder: (controller) {
        final members = controller.getUsersByIds(reactListUser);

        return FutureBuilder<List<User>>(
          future: members,
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];

            return Center(
              child: ListView.separated(
                itemCount: reactListUser.length,
                itemBuilder: (context, index) {
                  final user = members.firstWhereOrNull(
                    (element) => element.id.toString() == reactListUser[index],
                  );

                  return ListTile(
                    leading: AppCircleAvatar(
                      url: user?.avatarPath ?? '',
                      size: Sizes.s40,
                    ),
                    title: Text(
                      (user?.contact?.fullName ?? '').isNotEmpty
                          ? user?.contact?.fullName ?? ''
                          : user?.fullName ?? '',
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStickerMessage() {
    final sticker = SPSticker.fromJson(jsonDecode(message.content));

    if (message.isLocal && sticker.stickerImgLocalFilePath != null) {
      return Image(
        image: AssetImage(sticker.stickerImgLocalFilePath!),
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }

    return AppNetworkImage(
      sticker.stickerImg,
      width: 120,
      height: 120,
      fit: BoxFit.cover,
    );
  }

  Widget _buildSystemMessage(BuildContext context) {
    final Widget messageSystemWidget;

    try {
      final messageSystem = MessageSystem.fromJson(jsonDecode(message.content));

      switch (messageSystem.type) {
        case MessageSystemType.addMember:
          messageSystemWidget = _buildTextMessageSystemAddMember(
            context,
            memberIds: messageSystem.memberIds,
          );
        case MessageSystemType.removeMember:
          messageSystemWidget = _buildTextMessageSystemRemoveMember(
            context,
            memberIds: messageSystem.memberIds,
          );
      }

      return messageSystemWidget;
    } catch (e) {
      return AppSpacing.emptyBox;
    }
  }

  Widget _buildTextMessageSystemAddMember(
    BuildContext context, {
    List<String> memberIds = const [],
  }) {
    return GetBuilder<ChatHubController>(
      init: ChatHubController(),
      builder: (controller) {
        final members = controller.getUsersByIds(memberIds);

        return FutureBuilder<List<User>>(
          future: members,
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];

            final user = members.firstWhereOrNull(
              (element) => memberIds.contains(element.id.toString()),
            );

            final name = user?.contactName ?? user?.fullName ?? '';

            return Text(
              context.l10n.conversation_details__add_member(name),
              style: AppTextStyles.s14w400.toColor(
                AppColors.zambezi,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextMessageSystemRemoveMember(
    BuildContext context, {
    List<String> memberIds = const [],
  }) {
    return GetBuilder<ChatHubController>(
      init: ChatHubController(),
      builder: (controller) {
        final members = controller.getUsersByIds(memberIds);

        return FutureBuilder<List<User>>(
          future: members,
          builder: (context, snapshot) {
            final members = snapshot.data ?? [];

            final user = members.firstWhereOrNull(
              (element) => memberIds.contains(element.id.toString()),
            );

            final name = user?.contactName ?? user?.fullName ?? '';

            return Text(
              context.l10n.conversation_details__remove_member(name),
              style: AppTextStyles.s14w400.toColor(
                AppColors.zambezi,
              ),
            );
          },
        );
      },
    );
  }

  /// function for pop up menu item after clicked
  void _popUpDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// function for handle see more button pressed
  void _onSeeMorePressed(BuildContext context, Message message) {
    // set value for isClickedSeeMoreFirstTime, if it is false, then it will be true, and vice versa
    _isClickedSeeMoreFirstTime.value = !_isClickedSeeMoreFirstTime.value;
    // first clear all of menu item, otherwise it will be duplicated
    _menuItems.value.clear();
    if (_isClickedSeeMoreFirstTime.value == false) {
      // if see more is first clicked, then show first menu item
      _addReplyMenuItem(context);
      _addCopyMenuItem(context);
      _addCallJitsiMenuItem(context);
      _addPinMenuItem(context);
      // _addReportAndBlockMenuItems(context);
      _addSelectMenuItem(context, message);
      _addDownloadMenuItem(context);
      _addSeeMoreMenuItem(context, message);
    } else {
      // if see more is clicked again, then show second menu item
      _addTranslateMenuItem(context);
      _addForwardMenuItem(context);
      _addReportAndBlockMenuItems(context);
      _addDeleteMenuItem(context);
      _addDeleteMemberMenuItem(context);
      _addSeeMoreMenuItem(context, message);
    }
  }

  /// function for handle reply message pressed
  void _addReplyMenuItem(BuildContext context) {
    // add reply menu item
    _menuItems.value.add(
      MenuItem(
        label: context.l10n.button__reply_message,
        icon: AppIcons.reply,
        onPressed: () {
          _popUpDialog(context);
          _onReplyMessagePressed();
        },
      ),
    );
  }

  /// function for handle report message pressed
  void _addCopyMenuItem(BuildContext context) {
    // add copy menu item
    _menuItems.value.add(
      MenuItem(
        label: context.l10n.button__copy,
        icon: Assets.icons.copy,
        onPressed: () {
          _popUpDialog(context);
          ViewUtil.copyToClipboard(message.contentWithoutFormat).then((_) {
            ViewUtil.showAppSnackBar(
              context,
              context.l10n.global__copied_to_clipboard,
            );
          });
        },
      ),
    );
  }

  /// function for handle call jitsi menu item pressed
  void _addCallJitsiMenuItem(BuildContext context) {
    if (message.isCallJitsi) {
      _menuItems.value.add(MenuItem(
        label: context.l10n.button__copy,
        icon: Assets.icons.copy,
        onPressed: () {
          _popUpDialog(context);
          ViewUtil.copyToClipboard(
                  '${Get.find<EnvConfig>().jitsiUrl}/${message.conversationId}')
              .then(
            (_) => ViewUtil.showAppSnackBar(
              context,
              context.l10n.global__copied_to_clipboard,
            ),
          );
        },
      ));
    }
  }

  /// function for handle pin message pressed
  void _addPinMenuItem(BuildContext context) {
    // check if pin message controller is registered and user is admin or not, and group or not
    if (Get.isRegistered<PinMessageController>() && (isAdmin || !isGroup)) {
      final pinMessageController = Get.find<PinMessageController>();
      // check if message is already pinned or not
      final isPinned = pinMessageController.isMessagePinned(message.id);
      _menuItems.value.add(MenuItem(
        label: isPinned
            ? context.l10n.button__unpin_message
            : context.l10n.button__pin_message,
        icon: isPinned ? AppIcons.unpin : AppIcons.pin,
        onPressed: isPinned
            // if not pinned, then pin message, otherwise unpin message
            ? () {
                _popUpDialog(context);
                pinMessageController.unPinMessage(message);
              }
            : () {
                _popUpDialog(context);
                pinMessageController.pinMessage(message);
              },
      ));
    }
  }

  /// function for handle block user pressed
  void _addReportAndBlockMenuItems(BuildContext context) {
    // check if message is not mine, then add report and block menu items
    if (!message.isMine(myId: currentUserId)) {
      _menuItems.value.add(
        MenuItem(
          label: context.l10n.button__report,
          icon: AppIcons.reportMessage,
          onPressed: () => _onReportMessagePressed(context),
        ),
      );
      // check if current conversation is not group, then add block user menu item
      if (!isGroup) {
        _menuItems.value.add(MenuItem(
          label: context.l10n.button__block_user,
          icon: Assets.icons.block,
          onPressed: () => _onBlockUserPressed(context),
        ));
      }
    }
  }

  /// function for handle download media pressed
  void _addDownloadMenuItem(BuildContext context) {
    // only allow download is message is image or video
    // check if message is image or video, then add download menu item
    if (message.type == MessageType.image ||
        message.type == MessageType.video) {
      _menuItems.value.add(MenuItem(
        label: context.l10n.button__download,
        icon: Assets.icons.downloadMessage,
        onPressed: () {
          _popUpDialog(context);
          _downloadMedia().then(
            (_) => ViewUtil.showRawToast(context.l10n.global__saved_label),
          );
        },
      ));
    }
  }

  /// function for handling delete member in group
  void _addDeleteMemberMenuItem(BuildContext context) {
    // check if current user is admin and current conversation is group, and this message is not mine, then add delete member menu item
    if (isGroup && isAdmin && !isMine) {
      _menuItems.value.add(MenuItem(
        label: context.l10n.conversation_members__remove_confirm_title,
        icon: Icons.close,
        isDestuctive: true,
        onPressed: () {
          _popUpDialog(context);
          ViewUtil.showAppCupertinoAlertDialog(
            title: context.l10n.conversation_members__remove_confirm_title,
            message: context.l10n.conversation_members__remove_confirm_message,
            negativeText: context.l10n.button__cancel,
            positiveText: context.l10n.button__confirm,
            onPositivePressed: () =>
                Get.find<ChatHubController>().removeMember(message.senderId),
          );
        },
      ));
    }
  }

  /// function for handling translate menu item
  void _addTranslateMenuItem(BuildContext context) {
    _menuItems.value.add(
      MenuItem(
        label: context.l10n.chat_hub__see_translation_btn,
        icon: Assets.icons.translation.svg(
          color: AppColors.grey8,
          width: Sizes.s24,
          height: Sizes.s24,
        ),
        onPressed: () {
          _popUpDialog(context);
          Get.find<ChatHubController>().translateMessage(message);
        },
      ),
    );
  }

  /// function for handling see more menu item
  void _addSeeMoreMenuItem(BuildContext context, Message message) {
    _menuItems.value.add(MenuItem(
      label: context.l10n.see_more,
      icon: Assets.icons.more,
      onPressed: () {
        _onSeeMorePressed(context, message);
      },
    ));
  }

  /// function for handling forward menu item
  void _addForwardMenuItem(BuildContext context) {
    _menuItems.value.add(
      MenuItem(
        label: context.l10n.chat__forward,
        icon: AppIcons.forward,
        onPressed: () {
          _popUpDialog(context);
          _onForwardMessagePressed(context);
        },
      ),
    );
  }

  /// function for handling delete menu item
  void _addDeleteMenuItem(BuildContext context) {
    if (message.isMine(myId: currentUserId) || isAdmin) {
      _menuItems.value.add(
        MenuItem(
          label: context.l10n.chat_hub__delete_message,
          icon: AppIcons.trashMessage,
          isDestuctive: true,
          onPressed: () {
            _popUpDialog(context);
            _onDeleteMessagePressed(context);
          },
        ),
      );
    }
  }

  /// function for handling select menu item
  void _addSelectMenuItem(BuildContext context, Message message) {
    _menuItems.value.add(
      MenuItem(
        label: context.l10n.select,
        icon: Assets.icons.checkDone,
        onPressed: () {
          Get.find<ChatHubController>().listMessageSelected.clear();
          _popUpDialog(context);
          Get.find<ChatHubController>().listMessageSelected.add(message);
          Get.find<ChatHubController>().isSelectMode.value = true;
          Get.find<ChatHubController>().setIsShowDelete();
        },
      ),
    );
  }
}
