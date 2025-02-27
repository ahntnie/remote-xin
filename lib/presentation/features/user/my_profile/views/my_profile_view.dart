import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/user.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../../routing/routing.dart';
import '../../../newsfeed/personal_page/widgets/invite_link_widget.dart';
import '../../../newsfeed/personal_page/widgets/profile_card_widget.dart';
import '../../../newsfeed/poster_personal_page/widgets/add_contact.dart';
import '../../../short_video/utils/app_res.dart';
import '../../../short_video/utils/colors.dart';
import '../../../short_video/utils/font_res.dart';
import '../controllers/my_profile_controller.dart';
import 'widgets/build_list_short_video.dart';
import 'widgets/build_user_info.dart';

class MyProfileView extends BaseView<MyProfileController> {
  const MyProfileView({Key? key}) : super(key: key);

  final colorDivider = const Color(0xffc9ccd1);

  @override
  Widget buildPage(BuildContext context) {
    return Obx(() => CommonScaffold(
          appBar: CommonAppBar(
            centerTitle: false,
            titleWidget: Text(
              context.l10n.setting__my_profile,
              style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
            ).clickable(() => Get.back()),
            actions: [
              // AppIcon(
              //   icon: Assets.icons.editIcon,
              //   color: AppColors.pacificBlue,
              //   size: 20,
              // ).clickable(() {
              //   Get.toNamed(Routes.profile, arguments: {
              //     'isUpdateProfileFirstLogin': false,
              //   });
              // }),
              if (controller.isMine)
                AppIcon(
                  icon: Assets.icons.qr,
                  color: AppColors.text2,
                  onTap: () {
                    Get.to(() => const InviteLinkWidget(),
                        transition: Transition.rightToLeft);
                  },
                )
            ],
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            controller: controller.scroll,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: AppSpacing.edgeInsetsH20,
                  child: SizedBox(
                    // height: 0.13.sh,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.gapH12,
                        Row(
                          children: [
                            AppCircleAvatar(
                                size: 86,
                                url: controller.user.avatarPath ?? ''),
                            Expanded(
                                child: Column(
                              children: [
                                Text(
                                  controller.userStatistics.value.totalLikes
                                      .toString(),
                                  style: AppTextStyles.s16w700.text2Color,
                                ),
                                Text(
                                  context.l10n.newsfeed__like,
                                  style: AppTextStyles.s14w400.text2Color,
                                ),
                              ],
                            )),
                            Expanded(
                                child: Column(
                              children: [
                                Text(
                                  controller.userStatistics.value.totalComments
                                      .toString(),
                                  style: AppTextStyles.s16w700.text2Color,
                                ),
                                Text(
                                  context.l10n.newsfeed__comment,
                                  style: AppTextStyles.s14w400.text2Color,
                                ),
                              ],
                            )),
                            Expanded(
                                child: Column(
                              children: [
                                Text(
                                  controller.userStatistics.value.totalShares
                                      .toString(),
                                  style: AppTextStyles.s16w700.text2Color,
                                ),
                                Text(
                                  context.l10n.newsfeed__share,
                                  style: AppTextStyles.s14w400.text2Color,
                                ),
                              ],
                            ))
                          ],
                        ),
                        AppSpacing.gapH12,
                        // Obx(
                        //   () => Text(
                        //     controller.userNameText.value,
                        //     style: AppTextStyles.s16w700.text2Color
                        //         .copyWith(fontSize: 18),
                        //     overflow: TextOverflow.ellipsis,
                        //   ),
                        // ),
                        ContactDisplayNameText(
                          user: controller.user,
                          style: AppTextStyles.s18w700.text2Color,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${AppRes.atSign}${controller.user.nickname}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ColorRes.colorTextLight,
                            fontFamily: FontRes.fNSfUiMedium,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // SliverToBoxAdapter(
              //   child:
              //       Container(height: 3, width: 1.sw, color: AppColors.grey6),
              // ),
              // SliverToBoxAdapter(
              //   child: Container(
              //     height: 12.h,
              //   ),
              // ),
              const SliverToBoxAdapter(
                child: AppSpacing.gapH20,
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: AppSpacing.edgeInsetsH20.copyWith(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                      color: AppColors.blue10,
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      controller.isMine
                          ? AppIcon(
                              icon: AppIcons.editLight,
                              color: AppColors.text1,
                            )
                          : Obx(
                              () => AppIcon(
                                icon: controller.isAddContact.value
                                    ? AppIcons.addContact
                                    : AppIcons.edit,
                                color: AppColors.text1,
                              ),
                            ),
                      AppSpacing.gapW12,
                      controller.isMine
                          ? Text(
                              l10n.profile__edit,
                              style: AppTextStyles.s16w700
                                  .toColor(AppColors.text1)
                                  .copyWith(fontSize: 17),
                            )
                          : Obx(() => Text(
                                controller.isAddContact.value
                                    ? l10n.text_add_contact
                                    : l10n.text_edit_contact,
                                style: AppTextStyles.s16w700
                                    .toColor(AppColors.text1)
                                    .copyWith(fontSize: 17),
                              )),
                    ],
                  ),
                ).clickable(() {
                  if (controller.isMine) {
                    Get.toNamed(
                      Routes.profile,
                      arguments: {'isUpdateProfileFirstLogin': false},
                    );
                  } else if (controller.isAddContact.value) {
                    onAddContact(controller.user);
                  } else {
                    onEditContact(controller.user);
                  }
                }),
              ),

              SliverToBoxAdapter(
                child: Divider(
                  height: 5,
                  thickness: 5,
                  color: colorDivider,
                ),
              ),
              SliverToBoxAdapter(
                child: buildButtonSegment(context),
              ),
              SliverToBoxAdapter(child: buildSwitchCaseWidget(context)),
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              //     child: Text(
              //       l10n.setting__your_posts,
              //       style: AppTextStyles.s18w700.text2Color,
              //     ),
              //   ),
              // ),
              // // SliverAppBar(
              // //   automaticallyImplyLeading: false,
              // //   toolbarHeight: 80,
              // //   flexibleSpace: _buildNewPostButton(context),
              // // ),
              // SliverToBoxAdapter(
              //   child: _buildNewPostButton(context),
              // ),
              // SliverToBoxAdapter(
              //   child:
              //       Container(height: 3, width: 1.sw, color: AppColors.grey6),
              // ),
              // const SliverToBoxAdapter(
              //   child: AppSpacing.gapH16,
              // ),
              // if (controller.posts.isEmpty)
              //   SliverFillRemaining(
              //     child: _buildNoPostsFound(),
              //   ),
              // SliverList.separated(
              //   itemCount: controller.posts.length,
              //   itemBuilder: (context, index) {
              //     return PostItem(
              //       post: controller.posts[index],
              //       currentUser: controller.currentUser,
              //       onLike: (post) => controller.postController.likePost(
              //         post: post,
              //         posts: controller.posts,
              //       ),
              //       onUnLike: (post) => controller.postController.unLikePost(
              //         post: post,
              //         posts: controller.posts,
              //       ),
              //       onDelete: (post) {
              //         if (post.isMine(currentUser.id)) {
              //           Get.back();
              //           // onDelete(context, post);
              //         }
              //       },

              //       onEdit: (post) {
              //         if (post.isMine(currentUser.id)) {
              //           controller.postController.onEditPost(
              //             post: post,
              //             posts: controller.posts,
              //           );
              //         }
              //       },
              //       // onShare: (post) => sharePost(post: post),
              //       onGoToPersonal: (user) {
              //         if (user.id != currentUser.id) {
              //           // Get.toNamed(
              //           //   Routes.posterPersonal,
              //           //   arguments: {'user': user},
              //           // );
              //         }
              //       },
              //     );
              //   },
              //   separatorBuilder: (context, index) {
              //     return Container(
              //       height: 3,
              //       color: AppColors.grey6,
              //     );
              //   },
              // ),
            ],
          ),
        ));
  }

  Widget buildCardInfo() {
    return ProfileCardWidget(
      xinId: currentUser.phone ?? '',
      userName: currentUser.contactName,
      email: currentUser.email ?? '',
      phoneNumber: currentUser.phone ?? '',
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

  // Widget _buildNewPostButton(BuildContext context) {
  //   return Container(
  //     color: Colors.white,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       // mainAxisSize: MainAxisSize.min,
  //       children: [
  //         AppSpacing.gapH20,
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             // Row(
  //             //   children: [
  //             //     AppCircleAvatar(
  //             //       url: currentUser.avatarPath ?? '',
  //             //       size: Sizes.s44,
  //             //     ),
  //             //     AppSpacing.gapW12,
  //             //     Text(
  //             //       l10n.newsfeed__create_post_hint,
  //             //       style: AppTextStyles.s16w500.text2Color,
  //             //     ),
  //             //   ],
  //             // ),
  //             Text(
  //               l10n.newsfeed__create_post_hint,
  //               style: AppTextStyles.s16w500.text2Color,
  //             ),
  //             AppIcon(
  //               icon: AppIcons.image,
  //               color: AppColors.green1,
  //               size: 28,
  //             ).clickable(() async {
  //               await controller.postController.createPost(
  //                 posts: controller.posts,
  //                 isMedia: true,
  //               );
  //             }),
  //           ],
  //         )
  //             .paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s8)
  //             .clickable(() async {
  //           await controller.postController
  //               .createPost(posts: controller.posts, isFocus: true);
  //         }),
  //         AppSpacing.gapH20,
  //         // Container(
  //         //   decoration: const BoxDecoration(
  //         //     border: Border(
  //         //       top: BorderSide(
  //         //         color: AppColors.grey6,
  //         //       ),
  //         //       bottom: BorderSide(
  //         //         color: AppColors.grey6,
  //         //       ),
  //         //     ),
  //         //   ),
  //         //   child: IntrinsicHeight(
  //         //     child: Row(
  //         //       mainAxisAlignment: MainAxisAlignment.center,
  //         //       children: [
  //         //         Expanded(
  //         //           child: _buildItemNewPost(
  //         //             icon: AppIcons.image,
  //         //             title: l10n.newsfeed__image,
  //         //             onTap: () async {
  //         //               await controller.postController.createPost(
  //         //                 posts: controller.posts,
  //         //                 isMedia: true,
  //         //               );
  //         //             },
  //         //           ),
  //         //         ),
  //         //         const VerticalDivider(
  //         //           color: AppColors.grey6,
  //         //         ),
  //         //         Expanded(
  //         //           child: _buildItemNewPost(
  //         //             icon: AppIcons.videoPost,
  //         //             title: l10n.newsfeed__video,
  //         //             onTap: () async {
  //         //               await controller.postController.createPost(
  //         //                 posts: controller.posts,
  //         //                 isMedia: true,
  //         //               );
  //         //             },
  //         //           ),
  //         //         ),
  //         //       ],
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildItemNewPost({
    required String title,
    required Object icon,
    required Function() onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(
          icon: icon,
          color: Colors.black,
        ),
        AppSpacing.gapW12,
        Text(title, style: AppTextStyles.s16w500.text2Color),
      ],
    ).paddingSymmetric(vertical: Sizes.s12).clickable(() => onTap());
  }

  /// function for rendering button segment to show other widget
  Widget buildButtonSegment(BuildContext context) {
    return Row(
      children: [
        AppSpacing.gapW16,
        TextButton(
          onPressed: () {
            controller.selectedButtonSegmentIndex.value = 0;
          },
          style: TextButton.styleFrom(
            backgroundColor: controller.selectedButtonSegmentIndex.value == 0
                ? AppColors.blue8
                : null,
          ),
          // TODO: add localization
          child: Text(
            l10n.text_introduction,
            style: controller.selectedButtonSegmentIndex.value == 0
                ? AppTextStyles.s16w600.copyWith(color: AppColors.blue10)
                : AppTextStyles.s16w600.text2Color,
          ),
        ),
        AppSpacing.gapW12,
        TextButton(
          onPressed: () {
            controller.selectedButtonSegmentIndex.value = 1;
          },
          style: TextButton.styleFrom(
            backgroundColor: controller.selectedButtonSegmentIndex.value == 1
                ? AppColors.blue8
                : null,
          ),
          // TODO: add localization
          child: Text(
            l10n.text_video,
            style: controller.selectedButtonSegmentIndex.value == 1
                ? AppTextStyles.s16w600.copyWith(color: AppColors.blue10)
                : AppTextStyles.s16w600.text2Color,
          ),
        ),
      ],
    ).paddingOnly(top: 12);
  }

  Widget buildSwitchCaseWidget(BuildContext context) {
    switch (controller.selectedButtonSegmentIndex.value) {
      case 0:
        return BuildUserInfo(
          currentUser: controller.user,
        );
      case 1:
        return BuildListShortVideo(
          scrollController: controller.shortScrollController,
          pageController: controller.pageController,
          currentUser: controller.user,
        );
      default:
        return BuildUserInfo(
          currentUser: controller.user,
        );
    }
  }

  void onAddContact(User userContact) {
    Get.to(
      () => AddContact(
        controller: controller,
        user: userContact,
        isAddContact: true,
      ),
      transition: Transition.cupertino,
    );
  }

  void onEditContact(User user) {
    Get.to(
      () => AddContact(
        controller: controller,
        user: user,
        userContact: controller.currentUserContact,
      ),
      transition: Transition.cupertino,
    );
  }
}
