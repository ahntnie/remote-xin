import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../models/conversation.dart';
import '../../../../models/post.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/gen/assets.gen.dart';
import '../../../resource/styles/app_colors.dart';
import '../../../resource/styles/gaps.dart';
import '../../../resource/styles/text_styles.dart';
import '../dashboard/controllers/dashboard_controller.dart';
import '../dashboard/views/widgets/shimmer_loading_conversation.dart';
import 'widgets/shared_conversation_item.dart';

enum SharedToChatType {
  post,
  file,
}

// ignore: must_be_immutable
class SharedToChatView extends StatefulWidget {
  SharedToChatView(
      {required this.type, this.listMediaShared, this.post, super.key});
  List<PickedMedia>? listMediaShared;
  Post? post;
  SharedToChatType type;

  @override
  State<SharedToChatView> createState() => _SharedToChatViewState();
}

class _SharedToChatViewState extends State<SharedToChatView> {
  final List<Conversation> _selectedConversations = [];

  void _onSelected(Conversation conversation) {
    // if (!_isCreatingGroup) {
    //   Get.back(result: [conversation]);
    // }

    setState(() {
      _selectedConversations.contains(conversation)
          ? _selectedConversations.remove(conversation)
          : _selectedConversations.add(conversation);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ChatDashboardController(),
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () {
            controller.isLoadingInit.value = true;

            return controller.onRefresh();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                // horizontal: Sizes.s32,
                // vertical: Sizes.s28,
                ),
            child: SingleChildScrollView(
              child: Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        Row(
                          children: [
                            AppIcon(
                                    icon: Assets.icons.arrowBack,
                                    color: Colors.black)
                                .clickable(() {
                              Navigator.of(context).pop();
                            }),
                            AppSpacing.gapW8,
                            Text(
                              context.l10n.shared_message__to,
                              style: AppTextStyles.s16w700.text2Color,
                            )
                          ],
                        ).paddingSymmetric(horizontal: 20, vertical: 20),
                        _buildSearchField(
                          context,
                          controller,
                        ),
                        AppSpacing.gapH12,
                        Obx(
                          () {
                            if (controller.isLoadingInit.value) {
                              return Padding(
                                padding: AppSpacing.edgeInsetsOnlyTop8,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return const ShimmerLoadingConversation();
                                  },
                                ),
                              );
                            }
                            if (controller.filterAllConversations.isEmpty) {
                              return _buildNoMessageWidget(context, controller);
                            }

                            return Container(
                              padding: AppSpacing.edgeInsetsAll20,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.grey11),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    controller.filterAllConversations.length,
                                itemBuilder: (context, index) {
                                  final conversation =
                                      controller.filterAllConversations[index];

                                  return SharedConversationItem(
                                    conversation: conversation,
                                    isSelected: _selectedConversations
                                        .contains(conversation),
                                    isSelectable: true,
                                    onTap: () {
                                      _onSelected(conversation);
                                    },
                                  ).marginOnly(
                                      bottom: (index !=
                                              controller.filterAllConversations
                                                  .length)
                                          ? 10
                                          : 0);
                                },
                              ),
                            );
                          },
                        ).paddingSymmetric(vertical: 20, horizontal: 20),
                      ],
                    ),
                    Column(
                      children: [
                        _buildMessageTextField(
                          context,
                          controller,
                        ),
                        AppSpacing.gapH24,
                        AppButton.primary(
                          label: controller.l10n.newsfeed__share_action_send,
                          width: double.infinity,
                          onPressed: () {
                            if (widget.type == SharedToChatType.file) {
                              controller.onSharePickedMedia(
                                conversations: _selectedConversations,
                                listPickedMedia: widget.listMediaShared!,
                              );
                            }
                            if (widget.type == SharedToChatType.post) {
                              controller.onSharePost(
                                conversations: _selectedConversations,
                                post: widget.post!,
                                context: context,
                              );
                            }
                          },
                          isDisabled: _selectedConversations.isEmpty,
                        ).paddingSymmetric(horizontal: Sizes.s20),
                        AppSpacing.gapH24,
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).clickable(() {
          controller.isSearching.value = false;
        });
      },
    );
  }

  Widget _buildNoMessageWidget(
      BuildContext context, ChatDashboardController controller) {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.edgeInsetsH32.copyWith(top: 0.2.sh),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon: AppIcons.chat,
              size: 80.w,
              color: AppColors.zambezi,
            ),
            AppSpacing.gapH12,
            Text(
              context.l10n.chat__no_message_title,
              style: AppTextStyles.s16w500.subText1Color,
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH4,
            Text(
              context.l10n.chat__no_message_message,
              style: AppTextStyles.s12w400.subText2Color,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 72,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.grey10,
            ),
          ),
        ),
        // Text(
        //   context.l10n.newsfeed__share,
        //   style: AppTextStyles.s16w500,
        // ).paddingSymmetric(vertical: Sizes.s12),
        // const Divider(
        //   color: AppColors.subText2,
        //   height: 1,
        // ),
      ],
    ).paddingOnly(top: Sizes.s12);
  }

  Widget _buildSearchField(
    BuildContext context,
    ChatDashboardController controller,
  ) {
    return AppTextField(
      controller: controller.searchController,
      hintText: context.l10n.shared_message__find_people,
      hintStyle: AppTextStyles.s16w400.subText2Color,
      prefixIcon: AppIcon(icon: AppIcons.search, color: AppColors.grey10),
      fillColor: AppColors.grey6,
      onChanged: (value) => controller.searchConservation(value),
      border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(100))),
    ).paddingSymmetric(horizontal: Sizes.s20);
  }

  Widget _buildMessageTextField(
    BuildContext context,
    ChatDashboardController controller,
  ) {
    return AppTextField(
      controller: controller.messageTextController,
      hintText: context.l10n.shared_to_chat__hint_message,
      hintStyle: AppTextStyles.s16w400.subText2Color,
      borderRadius: 10,
      fillColor: AppColors.grey11,
      border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10))),
    ).paddingSymmetric(horizontal: Sizes.s20);
  }
}
