import 'dart:convert';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:stipop_sdk/model/sp_sticker.dart';

import '../../../../../../../../core/all.dart';
import '../../../../../../../../models/all.dart';
import '../../../../../../../../usecases/get_user_by_id_with_pool_usecase.dart';
import '../../../../../../../common_widgets/app_blurry_container.dart';
import '../../../../../../../common_widgets/app_icon.dart';
import '../../../../../../../common_widgets/button.dart';
import '../../../../../../../common_widgets/circle_avatar.dart';
import '../../../../../../../common_widgets/network_image.dart';
import '../../../../../../../common_widgets/pooling/user_contact_name.dart';
import '../../../../../../../resource/styles/app_colors.dart';
import '../../../../../../../resource/styles/gaps.dart';
import '../../../../../../../resource/styles/text_styles.dart';
import '_call_message_body.dart';
import '_media_message_body.dart';
import 'hyper_text_message_widget.dart';
import 'reply_message_widget.dart';
import 'swipe_to_reply_wrapper.dart';
import 'text_message_widget.dart';

class PreviewMessageItem extends StatelessWidget {
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
  final Conversation conversation;

  const PreviewMessageItem({
    required this.message,
    required this.currentUserId,
    required this.onPressedUserAvatar,
    required this.onMentionPressed,
    required this.conversation,
    super.key,
    this.isMine = false,
    this.previousMessage,
    this.nextMessage,
    this.onTap,
    this.isAdmin = false,
    this.members = const [],
    this.isGroup = false,
  });

  void _onReportMessagePressed() {}

  void _onBlockUserPressed() {}

  void _onDeleteMessagePressed(BuildContext context) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: context.l10n.chat_hub__delete_message_title,
      message: context.l10n.chat_hub__delete_message_content,
      negativeText: context.l10n.button__cancel,
      positiveText: context.l10n.button__delete,
      onPositivePressed: () {},
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
    // ViewUtil.showBottomSheet<List<User>>(
    //   isScrollControlled: true,
    //   isFullScreen: true,
    //   child: CreateChatSearchUsersBottomSheet(
    //     allowSelectMultiple: false,
    //     title: context.l10n.chat__forward_to,
    //     hintText: context.l10n.global__search,
    //   ),
    // ).then(
    //   (selectedUsers) {
    //     if (selectedUsers != null) {
    //       Get.find<ChatHubController>()
    //           .forwardMessage(selectedUsers.first, message);
    //     }
    //   },
    // );
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
      if (previousMessage!.type == MessageType.text &&
          message.repliedFrom == null &&
          message.forwardedFrom == null &&
          message.type == MessageType.text &&
          message.createdAt.isSameDay(previousMessage!.createdAt)) {
        shouldPadding = false;
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
                    if (!isMine) _buildMessageAvatar(),
                    AppSpacing.gapW8,
                    Flexible(child: _buildMessageBody(context)),
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
                style: AppTextStyles.s12w400
                    .toColor(
                      AppColors.grey8,
                    )
                    .copyWith(decoration: TextDecoration.none),
              ),
            ),
          )
        : AppSpacing.emptyBox;
  }

  Widget _buildMessageBody(BuildContext context) {
    final Widget messageBody;

    switch (message.type) {
      case MessageType.text:
        messageBody = PreviewTextMessageWidget(
          isMine: isMine,
          message: message,
          members: members,
          onMentionPressed: onMentionPressed,
        );
      // _buildTextMessage();
      case MessageType.hyperText:
        messageBody = PreviewHyperTextMessageWidget(
          isMine: isMine,
          message: message,
          members: members,
          onMentionPressed: onMentionPressed,
        );
      // messageBody = _buildHyperTextMessage();
      case MessageType.image:
      case MessageType.video:
      case MessageType.audio:
        messageBody = PreviewMediaMessageBody(
          key: ValueKey(message.id),
          message: message,
          isMine: isMine,
        );
      case MessageType.call:
        messageBody = PreviewCallMessageBody(
          message: message,
          isMine: isMine,
          currentUserId: currentUserId,
          conversation: conversation,
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
          PreviewReplyMessageWidget(
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
                              message.type == MessageType.hyperText
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
                onLongPressStart: (details) {},
                onDoubleTap: () {},
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
                              message.type == MessageType.hyperText
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
        style: AppTextStyles.s12w400
            .toColor(
              AppColors.grey8,
            )
            .copyWith(decoration: TextDecoration.none),
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
        style: AppTextStyles.s12w600.text2Color
            .copyWith(decoration: TextDecoration.none),
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
              style: AppTextStyles.s14w400
                  .toColor(
                    isMine ? AppColors.blue10 : AppColors.text2,
                  )
                  .copyWith(decoration: TextDecoration.none),
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
                    style: AppTextStyles.s14w600.text2Color
                        .copyWith(decoration: TextDecoration.none),
                    linkColor: AppColors.grey8,
                    onUrlTap: (url) {
                      IntentUtils.openBrowserURL(url: url);
                    },
                    urlStyle: AppTextStyles.s12w500.text4Color
                        .copyWith(decoration: TextDecoration.none),
                  ),
                AppSpacing.gapH8,
                AppButton.primary(
                  label: context.l10n.newsfeed__view_post,
                  textStyleLabel: AppTextStyles.s14w400
                      .copyWith(decoration: TextDecoration.none),
                  width: double.infinity,
                  padding: EdgeInsets.zero,
                  height: Sizes.s40,
                  onPressed: () {
                    // Get.toNamed(
                    //   Routes.postDetail,
                    //   arguments: {'postId': post.id},
                    // );
                  },
                ),
              ],
            ).marginSymmetric(horizontal: Sizes.s16, vertical: Sizes.s12),
          ],
        ),
      ),
    );
  }

  void _onReplyMessagePressed() {}

  void _onJumpToRepliedMessage(Message message) {}

  Widget _buildButtonReaction() {
    return ReactionButton<String>(
      toggle: false,
      onReactionChanged: (Reaction<String>? reaction) {},
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

  Future<List<User>> getUsersByIds(List<String> reactListUser) async {
    final userIds = reactListUser.map((str) => int.parse(str)).toList();

    final members =
        await GetUsersByIdsWithUserPoolUsecase().call(userIds.toSet());

    return members;
  }

  Widget _buildItemBottomSheet(List<String> reactListUser) {
    final members = getUsersByIds(reactListUser);

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
    final members = getUsersByIds(memberIds);

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
  }

  Widget _buildTextMessageSystemRemoveMember(
    BuildContext context, {
    List<String> memberIds = const [],
  }) {
    final members = getUsersByIds(memberIds);

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
          style: AppTextStyles.s14w400
              .toColor(
                AppColors.zambezi,
              )
              .copyWith(decoration: TextDecoration.none),
        );
      },
    );
  }
}
