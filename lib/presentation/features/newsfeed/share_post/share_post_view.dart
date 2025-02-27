import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../chat/dashboard/controllers/dashboard_controller.dart';
import '../../chat/shared_to_chat/shared_to_chat_view.dart';
import 'share_post_controller.dart';
import 'widget/share_timer_widget.dart';

class SharePostView extends BaseView<SharePostController> {
  final Post post;

  const SharePostView({required this.post, super.key});

  @override
  Widget buildPage(BuildContext context) {
    return Obx(
      () => Container(
        constraints: BoxConstraints(minHeight: 1.sh),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Sizes.s20),
            topRight: Radius.circular(Sizes.s20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              post.isMine(controller.currentUser.id)
                  ? const SizedBox.shrink()
                  : _buildSharePostToPersonalPage()
                      .paddingSymmetric(horizontal: Sizes.s20),
              Text(
                l10n.shared_post__to_chat,
                style: AppTextStyles.s16w700.text2Color,
              ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s20),

              SizedBox(
                height: 88,
                child: ListView.builder(
                  // shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.userContacts.length,
                  itemBuilder: (context, index) {
                    final ValueNotifier<String> shareText =
                        ValueNotifier<String>(l10n.newsfeed__share_action_send);

                    return Column(
                      children: [
                        AppCircleAvatar(
                          url:
                              controller.userContacts[index].user?.avatarPath ??
                                  '',
                          size: Sizes.s52,
                        ),
                        AppSpacing.gapH12,
                        SizedBox(
                          width: 54,
                          child: Center(
                            child: Text(
                              controller
                                      .userContacts[index].user?.displayName ??
                                  '',
                              style: AppTextStyles.s14w600.text2Color,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ).marginOnly(right: 20).clickable(() {
                      controller.onSharePost(
                        userContact: controller.userContacts[index],
                        post: post,
                      );
                    });
                  },
                ),
              ).paddingOnly(left: 20),
              // Text(
              //   l10n.newsfeed__share_about_massage,
              //   style: AppTextStyles.s16w500.text2Color,
              // ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s20),
              // AppTextField(
              //   controller: controller.searchController,
              //   hintText: l10n.newsfeed__share_search_hint,
              //   hintStyle: AppTextStyles.s14w400.italic.subText2Color,
              //   prefixIcon:
              //       AppIcon(icon: AppIcons.edit, color: AppColors.subText2),
              //   onChanged: (value) => controller.searchUserSharePost(value),
              // ).paddingSymmetric(horizontal: Sizes.s20),
              // AppSpacing.gapH12,
              // ListView.builder(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   itemCount: controller.userContacts.length,
              //   itemBuilder: (context, index) {
              //     final ValueNotifier<String> shareText =
              //         ValueNotifier<String>(l10n.newsfeed__share_action_send);

              //     return _buildUserItem(
              //       controller.userContacts[index],
              //       shareText: shareText,
              //     );
              //   },
              // ),
              Text(
                l10n.shared_post__to,
                style: AppTextStyles.s16w700.text2Color,
              ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  shareToItem(
                    l10n.home__news_feed_title,
                    Assets.icons.newfeedsIcon,
                    () {
                      controller.onSharePostToPersonalPage(
                        post: post,
                      );
                    },
                  ).marginOnly(right: 20),
                  shareToItem(
                    l10n.shared_post__to_private_chat,
                    Assets.icons.chatIcon,
                    () async {
                      Get.find<ChatDashboardController>()
                          .messageTextController
                          .clear();
                      await ViewUtil.showBottomSheet(
                        isScrollControlled: true,
                        isFullScreen: true,
                        child: SharedToChatView(
                          type: SharedToChatType.post,
                          post: post,
                        ),
                      );
                    },
                  ).marginOnly(right: 20),
                  shareToItem(
                    l10n.shared_post__to_group_chat,
                    Assets.icons.groupChatIcon,
                    () async {
                      Get.find<ChatDashboardController>()
                          .messageTextController
                          .clear();
                      await ViewUtil.showBottomSheet(
                        isScrollControlled: true,
                        isFullScreen: true,
                        child: SharedToChatView(
                          type: SharedToChatType.post,
                          post: post,
                        ),
                      );
                    },
                  ).marginOnly(right: 20),
                  shareToItem(
                    l10n.text_copy,
                    Assets.icons.solarLink,
                    () async {},
                  ),
                ],
              ).paddingSymmetric(horizontal: Sizes.s20),
            ],
          ),
        ),
      ),
    );
  }

  Widget shareToItem(String title, dynamic asset, Function onTap) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            width: Sizes.s52,
            height: Sizes.s52,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.grey6),
            padding: const EdgeInsets.all(13),
            child: AppIcon(
              icon: asset,
              color: Colors.black,
              size: 28.w,
            ),
          ),
        ),
        AppSpacing.gapH4,
        Text(
          title,
          style: AppTextStyles.s14w500.text2Color,
        ),
      ],
    ).clickable(() {
      onTap();
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.edgeInsetsH20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                width: 72,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColors.grey10,
                ),
              ),
            ],
          ).paddingOnly(bottom: Sizes.s20, top: Sizes.s12),
        ],
      ),
    );
  }

  Widget _buildUserItem(
    UserContact userContact, {
    required ValueNotifier<String> shareText,
  }) {
    return Row(
      children: [
        AppCircleAvatar(
          url: userContact.user?.avatarPath ?? '',
          size: Sizes.s52,
        ),
        AppSpacing.gapW12,
        Text(
          (userContact.user?.nickname ?? '').isNotEmpty
              ? userContact.user?.nickname ?? ''
              : userContact.user?.fullName ?? '',
          style: AppTextStyles.s16w600.text2Color,
        ),
        const Expanded(child: SizedBox.shrink()),
        ShareTimerWidget(
          shareText: shareText,
          onSharePost: () => controller.onSharePost(
            userContact: userContact,
            post: post,
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s12);
  }

  Widget _buildSharePostToPersonalPage() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.grey11,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   l10n.newsfeed__share_on_personal_page,
          //   style: AppTextStyles.s16w500.text2Color,
          // ),
          // AppSpacing.gapH12,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppCircleAvatar(
                url: controller.currentUser.avatarPath ?? '',
                size: Sizes.s52,
              ),
              AppSpacing.gapW12,
              Text(
                controller.currentUser.nickname ?? '',
                style: AppTextStyles.s16w700.text2Color,
              ),
              const Expanded(child: SizedBox.shrink()),
              AppButton.primary(
                label: l10n.newsfeed__share_now,
                textStyleLabel: AppTextStyles.s16w500,
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.s20,
                  vertical: Sizes.s4,
                ),
                height: Sizes.s32,
                onPressed: () => controller.onSharePostToPersonalPage(
                  post: post,
                ),
              ),
            ],
          ),
        ],
      ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s12),
    );
  }
}
