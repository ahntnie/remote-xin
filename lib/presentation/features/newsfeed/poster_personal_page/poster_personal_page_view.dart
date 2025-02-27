import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../common_widgets/app_blurry_container.dart';
import '../../../resource/resource.dart';
import '../../all.dart';

class PosterPersonalPageView extends BaseView<PosterPersonalPageController> {
  const PosterPersonalPageView({super.key});

  String maskString(String input) {
    // if (input.length < 3) {
    //   return '*' * input.length;
    // } else {
    //   return input.substring(0, 3) + '*' * (input.length - 3);
    // }
    return '*' * 10;
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        titleType: AppBarTitle.none,
        centerTitle: false,
        titleWidget: const Row(),
      ),
      body: Obx(
        () => RefreshIndicator(
          color: AppColors.deepSkyBlue,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await controller.onRefreshPostPersonalPage();
          },
          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.edgeInsetsH20,
                  child: SizedBox(
                    height: 147,
                    child: Row(
                      children: [
                        AppCircleAvatar(
                            size: 135, url: controller.user.avatarPath ?? ''),
                        AppSpacing.gapW12,
                        Expanded(
                          child: SizedBox(
                            child: Obx(
                              () => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.user.fullName,
                                    style: AppTextStyles.s24w700.text2Color,
                                  ),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      AppIcon(
                                        icon: Assets.icons.phoneInfo,
                                        color: AppColors.grey10,
                                        size: 18,
                                      ),
                                      AppSpacing.gapW8,
                                      Text(
                                        controller.userPhoneText.value,
                                        style: AppTextStyles.s14w700
                                            .toColor(AppColors.text2),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      AppIcon(
                                        icon: Assets.icons.nft,
                                        color: AppColors.grey10,
                                        size: 18,
                                      ),
                                      AppSpacing.gapW8,
                                      Text(
                                        controller.userNftText.value,
                                        style: AppTextStyles.s14w700
                                            .toColor(AppColors.text2),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      AppIcon(
                                        icon: Assets.icons.mailInfo,
                                        color: AppColors.grey10,
                                        size: 18,
                                      ),
                                      AppSpacing.gapW8,
                                      Text(
                                        controller.userEmailText.value,
                                        // 'hovuminhquang@gmail.com',
                                        style: AppTextStyles.s14w700
                                            .toColor(AppColors.text2),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  SizedBox(
                                    // height: 26,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 12),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: AppColors.grey6),
                                          child: Row(
                                            children: [
                                              AppIcon(
                                                icon: controller
                                                    .userGenderIcon.value,
                                                color: AppColors.text2,
                                                size: 18,
                                              ),
                                              AppSpacing.gapW4,
                                              Text(
                                                controller
                                                    .userAgeValueText.value,
                                                style: AppTextStyles
                                                    .s14w500.text2Color,
                                              )
                                            ],
                                          ),
                                        ),
                                        AppSpacing.gapW12,
                                        AppIcon(
                                          icon: Assets.icons.locationProfile,
                                          color: const Color(0xff369C09),
                                          size: 20,
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          controller.userLocationText.value,
                                          style: AppTextStyles
                                              .s14w500.subText2Color,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.edgeInsetsH20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: AppSpacing.edgeInsetsH20
                              .copyWith(top: 32, bottom: 32, left: 0, right: 0),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                              color: AppColors.blue8,
                              borderRadius: BorderRadius.circular(100)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcon(
                                icon: AppIcons.chat,
                                color: AppColors.blue10,
                              ),
                              AppSpacing.gapW12,
                              Text(
                                l10n.chat,
                                style: AppTextStyles.s16Base
                                    .toColor(AppColors.blue10),
                              )
                            ],
                          ),
                        ).clickable(() {
                          if (controller.isChat) {
                            Get.back();
                            Get.back();
                          } else {
                            controller.goToPrivateChat(controller.user.id);
                          }
                        }),
                      ),
                      if (!controller.isContactSaved.value) AppSpacing.gapW20,
                      if (!controller.isContactSaved.value)
                        Expanded(
                          child: Container(
                            margin: AppSpacing.edgeInsetsH20.copyWith(
                                top: 32, bottom: 32, left: 0, right: 0),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                color: AppColors.blue8,
                                borderRadius: BorderRadius.circular(100)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppIcon(
                                  icon: AppIcons.addContact,
                                  color: AppColors.blue10,
                                ),
                                AppSpacing.gapW12,
                                Text(
                                  l10n.text_add_contact,
                                  style: AppTextStyles.s16Base
                                      .toColor(AppColors.blue10),
                                )
                              ],
                            ),
                          ).clickable(() {
                            _onAddContact(controller.user);
                          }),
                        )
                      else
                        Expanded(
                          child: Container(
                            margin: AppSpacing.edgeInsetsH20.copyWith(
                                top: 32, bottom: 32, left: 0, right: 0),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                                color: AppColors.blue8,
                                borderRadius: BorderRadius.circular(100)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppIcon(
                                  icon: AppIcons.edit,
                                  color: AppColors.blue10,
                                ),
                                AppSpacing.gapW12,
                                Text(
                                  l10n.text_edit_contact,
                                  style: AppTextStyles.s16Base
                                      .toColor(AppColors.blue10),
                                )
                              ],
                            ),
                          ).clickable(() {
                            _onEditContact(controller.user);
                          }),
                        ),
                    ],
                  ),
                ),
              ),
              // const SliverToBoxAdapter(
              //   child: Column(
              //     children: [
              //       Padding(
              //         padding: AppSpacing.edgeInsetsH20,
              //         child: Divider(
              //           color: AppColors.subText2,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // SliverList.separated(
              //   itemCount: controller.isLoadingInit.value
              //       ? 3
              //       : controller.posts.length,
              //   itemBuilder: (context, index) {
              //     return controller.isLoadingInit.value
              //         ? const ShimmerLoadingPost()
              //         : PostItem(
              //             post: controller.posts[index],
              //             currentUser: controller.currentUser,
              //             onLike: (post) => controller.postController.likePost(
              //               post: post,
              //               posts: controller.posts,
              //             ),
              //             onUnLike: (post) =>
              //                 controller.postController.unLikePost(
              //               post: post,
              //               posts: controller.posts,
              //             ),
              //             onShare: (post) => sharePost(post: post),
              //             onReport: (post) {
              //               if (!post.isMine(currentUser.id)) {
              //                 controller.postController.onReport(post);
              //               }
              //             },
              //           );
              //   },
              //   separatorBuilder: (context, index) {
              //     return Container(height: 3, color: AppColors.grey6);
              //   },
              // ),
              // if (controller.posts.isEmpty)
              //   SliverFillRemaining(
              //     child: _buildNoPostsFound(),
              //   ),
              // const SliverToBoxAdapter(
              //   child: AppSpacing.gapH16,
              // ),
              // SliverToBoxAdapter(
              //   child: controller.isLoadingLoadMore.value
              //       ? const Center(
              //           child: AppDefaultLoading(
              //             color: AppColors.white,
              //           ),
              //         )
              //       : const SizedBox.shrink(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItem(
    SvgGenImage icon, {
    Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AppBlurryContainer(
        color: Colors.transparent,
        padding: AppSpacing.edgeInsetsAll12,
        borderRadius: 12,
        child: AppIcon(
          icon: icon,
        ),
      ),
    );
  }

  Widget buildAvatar() {
    return SizedBox(
      height: 0.3.sh,
      child: Stack(children: [
        if (controller.user.avatarPath != null &&
            controller.user.avatarPath!.isNotEmpty) ...[
          Image.network(
            controller.user.avatarPath ?? '',
            width: double.infinity,
            height: 0.3.sh,
            fit: BoxFit.cover,
          ),
        ] else ...[
          Container(
            color: AppColors.blue11,
            height: 0.3.sh,
            width: double.infinity,
          ),
        ],
        Positioned.fill(
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (controller.user.avatarPath != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: Sizes.s20,
                        bottom: Sizes.s12,
                      ),
                      child: Text(
                        controller.user.fullName,
                        style: AppTextStyles.s18w700.toColor(AppColors.white),
                      ),
                    ),
                  AppSpacing.gapW4,
                  // Container(
                  //   margin: const EdgeInsets.only(bottom: 5),
                  //   width: 10,
                  //   height: 10,
                  //   decoration: BoxDecoration(
                  //     shape: BoxShape.circle,
                  //     color: widget.chatHubController.isOnline
                  //         ? AppColors.positive
                  //         : AppColors.subText2,
                  //   ),
                  // ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  buildItem(
                    AppIcons.comment,
                    onTap: () {
                      controller.goToPrivateChat(controller.user.id);
                    },
                  ),
                  buildItem(
                    AppIcons.call,
                    onTap: () {
                      controller.onCallVoice(controller.user);
                    },
                  ),
                  buildItem(
                    AppIcons.video,
                    onTap: () {
                      controller.onVideoCall(controller.user);
                    },
                  ),
                  buildItem(
                    AppIcons.addContact,
                    onTap: () {
                      _onAddContact(controller.user);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildContainerInfo() {
    return Container(
      margin: AppSpacing.edgeInsetsAll20,
      padding: AppSpacing.edgeInsetsAll16,
      decoration: const BoxDecoration(
        color: AppColors.grey11,
        // border: Border.all(color: AppColors.border2, width: 0.5),
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'mobile',
            style: AppTextStyles.s14Base.text2Color,
          ),
          AppSpacing.gapH8,
          Text(
            controller.user.phone ?? '',
            style: AppTextStyles.s18w500.toColor(AppColors.text2),
          ),

          // const AppDivider(),
          const Divider(
            color: AppColors.subText2,
            thickness: 0.5,
          ),

          Text(
            'username',
            style: AppTextStyles.s14Base.text2Color,
          ),
          AppSpacing.gapH8,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '@${controller.user.nickname ?? ''}',
                style: AppTextStyles.s18w500.toColor(AppColors.text2),
              ),
              // AppIcon(
              //   icon: Icons.qr_code,
              //   size: Sizes.s20,
              //   padding: AppSpacing.edgeInsetsAll8,
              //   onTap: _showQRCodeDialog,
              // ),
            ],
          ),
          AppSpacing.gapH8,
          // const AppDivider(),
          // AppSpacing.gapH8,
          // GestureDetector(
          //   onTap: () {
          //     // widget.controller.onBlockChat(context);
          //   },
          //   child: Row(
          //     children: [
          //       Text(
          //         context.l10n.button__block_user,
          //         style: AppTextStyles.s18w400.toColor(AppColors.text2),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildConversationInfo(BuildContext context) {
    return Column(
      children: [
        AppCircleAvatar(
          url: controller.user.avatarPath ?? '',
          size: 100,
        ),
        AppSpacing.gapH12,
        Text(
          controller.user.fullName,
          style: AppTextStyles.s26w600.text2Color,
        ),
        // ContactDisplayNameText(
        //   user: controller.conversation.chatPartner()!,
        //   style: AppTextStyles.s26w600,
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
        controller.getInfoPartner().isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSpacing.gapH8,
                  Text(
                    controller.getInfoPartner(),
                    style: AppTextStyles.s14w400.text2Color,
                  ),
                ],
              )
            : const SizedBox.shrink(),
        Text(
          controller.user.email ?? '',
          style: AppTextStyles.s14w400.text2Color,
        ),
        // controller.getEmailPartner().isNotEmpty
        //     ? Column(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           AppSpacing.gapH4,
        //           Text(
        //             controller.getEmailPartner(),
        //             style: AppTextStyles.s14w400.subText2Color,
        //           ),
        //         ],
        //       )
        //     : const SizedBox.shrink(),
      ],
    );
  }

  void onDelete(BuildContext context, Post post) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: l10n.newsfeed__delete_post,
      message: l10n.newsfeed__delete_post_confirm,
      negativeText: l10n.button__delete,
      positiveText: l10n.button__cancel,
      onNegativePressed: () {
        // controller.postController
        //     .deletePost(post: post, posts: controller.posts);
      },
    );
  }

  Widget _buildNoPostsFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(
          icon: AppIcons.news,
          size: Sizes.s128,
        ),
        Text(
          l10n.newsfeed__no_posts_found,
          style: AppTextStyles.s16w500,
        ),
      ],
    );
  }

  void sharePost({required Post post}) {
    // if (controller.sharePostController.userContacts.isEmpty) {
    //   controller.sharePostController.getUserSharePost();
    // }

    // ViewUtil.showBottomSheet(
    //   child: SharePostView(
    //     post: post,
    //   ),
    //   isFullScreen: true,
    // );
  }

  void _onAddContact(User userContact) {
    // ViewUtil.showBottomSheet(
    //   child: AddContact(
    //     controller: controller,
    //     user: userContact,
    //     isAddContact: true,
    //   ),
    //   isScrollControlled: true,
    //   isFullScreen: true,
    // ).then((value) {
    //   controller.checkUserContact();
    // });
    // Get.to(
    //   () => AddContact(
    //     controller: controller,
    //     user: userContact,
    //     isAddContact: true,
    //   ),
    //   transition: Transition.cupertino,
    // );
  }

  void _onEditContact(User user) {
    // final contactController = Get.find<ContactController>();
    // final userContact = contactController.findUserContact(user);
    // ViewUtil.showBottomSheet(
    //   child: ContactInfoDetail(
    //     user: userContact!,
    //   ),
    //   isScrollControlled: true,
    //   isFullScreen: true,
    // ).then((value) {
    //   contactController.isoCode.value = '';
    //   contactController.phoneEdit.value = '';
    //   contactController.avatarUrl.value = '';
    //   contactController.phoneController.clear();
    //   contactController.changeIsEditContact = false;
    //   contactController.isAvatarLocal.value = false;
    //   controller.checkUserContact();
    // });

    // Get.to(
    //   () => AddContact(
    //     controller: controller,
    //     user: user,
    //     userContact: controller.currentUserContact,
    //   ),
    //   transition: Transition.cupertino,
    // );
  }
}
