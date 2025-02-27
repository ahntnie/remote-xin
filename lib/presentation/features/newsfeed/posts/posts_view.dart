import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../common_widgets/app_divider.dart';
import '../../../common_widgets/status_view.dart';
import '../../../resource/resource.dart';
import '../../../routing/routing.dart';
import '../../all.dart';
import '../../search/views/widgets/_user_item.dart';
import '../widgets/post_item.dart';
import 'widgets/search_post_icon.dart';
import 'widgets/shimmer_loading_post.dart';

class PostsView extends BaseView<PostsController> {
  const PostsView({super.key});

  @override
  bool get allowLoadingIndicator => false;

  @override
  Widget buildPage(BuildContext context) {
    return Obx(
      () => RefreshIndicator(
        color: const Color.fromRGBO(14, 168, 255, 1),
        backgroundColor: Colors.white,
        onRefresh: () async {
          return controller.onRefreshNewsfeed();
        },
        child: CustomScrollView(
          // physics: const BouncingScrollPhysics(),
          controller: controller.scrollController,
          slivers: [
            SliverAppBar(
              floating: true,
              automaticallyImplyLeading: false,
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              title: controller.isSearch.value
                  ? AppSpacing.emptyBox
                  : const AppLogo(),
              actions: [
                Obx(
                  () => SearchPostIcon(
                    isExpand: controller.isSearch.value,
                  ),
                ),
                AppSpacing.gapW8,
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: controller.isSearch.value == false ? 44 : 0,
                    child: controller.isSearch.value == false
                        ? const NotificationsIcon()
                        : AppSpacing.emptyBox,
                  ),
                ),
                AppSpacing.gapW20,
              ],
            ),

            // SliverAppBar(
            //   automaticallyImplyLeading: false,
            //   toolbarHeight: controller.isSearch.value ? 0 : 68 + 12,
            //   flexibleSpace: _buildNewPostButton(context),
            //   pinned: controller.posts.isEmpty,
            // ),
            SliverToBoxAdapter(
              child: AnimatedContainer(
                height: controller.isSearch.value ? 0 : 70,
                duration: const Duration(milliseconds: 250),
                child: _buildNewPostButton(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(height: 3, width: 1.sw, color: AppColors.grey6),
            ),
            SliverToBoxAdapter(
              child: controller.isSearch.value
                  ? AppSpacing.emptyBox
                  : Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.userStorys.length + 1,
                        itemBuilder: (context, index) => Padding(
                          padding: EdgeInsets.only(
                              left: index == 0
                                  ? 20
                                  : controller.getUserStory(index).userId !=
                                          currentUser.id
                                      ? 20
                                      : 0),
                          child: index == 0
                              ? SizedBox(
                                  width: 70,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(
                                              controller.getMyStory() == null
                                                  ? 0
                                                  : 0.5),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 3,
                                                  color:
                                                      controller.getMyStory() ==
                                                              null
                                                          ? AppColors.grey6
                                                          : AppColors.blue10)),
                                          child: AppCircleAvatar(
                                            url: controller
                                                    .currentUser.avatarPath ??
                                                '',
                                            size: 57,
                                          ),
                                        ).clickable(() {
                                          if (controller.getMyStory() != null) {
                                            Get.toNamed(Routes.storyPage,
                                                arguments: {
                                                  'user':
                                                      controller.getMyStory(),
                                                  'userStorys':
                                                      controller.listUserStorys,
                                                  'index': controller
                                                      .getIndexMyStory(),
                                                });
                                          }
                                        }),
                                      ),
                                      Positioned(
                                        top: 38,
                                        right: 2,
                                        child: Container(
                                          height: 25,
                                          width: 25,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.blue10,
                                              border: Border.all(
                                                  width: 3,
                                                  color: AppColors.white)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(2),
                                            child: AppIcon(
                                              icon: AppIcons.plus,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        child: Text(
                                          'Your story',
                                          style: AppTextStyles
                                              .s14Base.subText2Color,
                                        ),
                                      )
                                    ],
                                  ),
                                ).clickable(() {
                                  Get.toNamed(Routes.createStory);
                                })
                              : controller.getUserStory(index).userId !=
                                      currentUser.id
                                  ? Column(
                                      children: [
                                        StatusView(
                                          radius: 30,
                                          spacing: 0,
                                          strokeWidth: 3,
                                          numberOfStatus: 5,
                                          padding: 4,
                                          centerImageUrl: controller
                                                  .getUserStory(index)
                                                  .avatar ??
                                              '',
                                          unSeenColor: AppColors.blue10,
                                        ).clickable(() {
                                          Get.toNamed(Routes.storyPage,
                                              arguments: {
                                                'user': controller
                                                    .getUserStory(index),
                                                'userStorys':
                                                    controller.listUserStorys,
                                                'index': index - 1,
                                              });
                                        }),
                                        const Spacer(),
                                        Text(
                                          controller.getUserStory(index).name ??
                                              '',
                                          style:
                                              AppTextStyles.s14w600.text2Color,
                                        ),
                                      ],
                                    )
                                  : const SizedBox(),
                        ),
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: controller.isSearch.value
                  ? AppSpacing.gapH8
                  : AppSpacing.emptyBox,
            ),
            SliverToBoxAdapter(
              child: controller.isSearch.value
                  ? AppSpacing.emptyBox
                  : Container(height: 3, width: 1.sw, color: AppColors.grey6),
            ),

            // if (controller.posts.isEmpty)
            //   SliverFillRemaining(
            //     child: _buildNoPostsFound(),
            //   ),
            SliverToBoxAdapter(
              child: controller.isSearch.value
                  ? _buildSearchResult()
                  : AppSpacing.emptyBox,
            ),
            SliverList.separated(
              itemCount: controller.isSearch.value
                  ? 0
                  : controller.isLoadingInit.value
                      ? 3
                      : controller.posts.length,
              itemBuilder: (context, index) {
                return controller.isLoadingInit.value
                    ? const ShimmerLoadingPost()
                    : PostItem(
                        post: controller.posts[index],
                        currentUser: controller.currentUser,
                        onLike: (post) => controller.likePost(
                          post: post,
                          posts: controller.posts,
                        ),
                        onUnLike: (post) => controller.unLikePost(
                          post: post,
                          posts: controller.posts,
                        ),
                        onReport: (post) async {
                          await controller.onReport(post);
                        },
                        onShare: (post) {
                          sharePost(post: post, context: context);
                        },
                        onEdit: (post) {
                          if (post.isMine(currentUser.id)) {
                            controller.onEditPost(
                              post: post,
                              posts: controller.posts,
                            );
                          }
                        },
                        onDelete: (post) {
                          if (post.isMine(currentUser.id)) {
                            Get.back();
                            onDelete(context, post);
                          }
                        },
                        onGoToPersonal: (user) {
                          if (user.id != currentUser.id) {
                            Get.toNamed(
                              Routes.posterPersonal,
                              arguments: {'user': user, 'isChat': false},
                            );
                          } else {
                            // click is mine post go to personal page
                            Get.find<HomeController>().setIsShowBottomBar(true);
                            controller.homeController.changeTab = 4;
                          }
                        },
                      );
              },
              separatorBuilder: (context, index) {
                // return AppBlurryContainer(
                //   padding: EdgeInsets.zero,
                //   borderRadius: 0,
                //   color: AppColors.text1,
                //   child: Container(
                //     color: AppColors.text1,
                //     height: Sizes.s16,
                //   ),
                // );
                // return const SizedBox(
                //   height: 6,
                // );
                return Container(height: 3, color: AppColors.grey6);
              },
            ),
            SliverToBoxAdapter(
              child: controller.isLoadingLoadMore.value
                  ? const Center(
                      child: AppDefaultLoading(
                        color: AppColors.white,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  CommonAppBar _buildNewsfeedAppBar() {
    return CommonAppBar(
      leadingIcon: LeadingIcon.none,
      automaticallyImplyLeading: false,
      centerTitle: false,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.white,
      // leadingWidth: Sizes.s60,
      // leadingIconWidget: _buildNotificationIcon(),
      // titleWidget: SlidingSwitch(
      //   value: false,
      //   textOn: 'Video',
      //   textOff: 'New Feeds',
      //   colorOn: AppColors.white,
      //   colorOff: AppColors.white,
      //   inactiveColor: AppColors.text4,
      //   contentSize: 14.sp,
      //   width: 220.w,
      //   height: 48.h,
      //   onChanged: (value) {
      //     print('value: $value');
      //   },
      //   onTap: () {},
      //   onSwipe: () {},
      // ),
      actions: const [
        NotificationsIcon(),
      ],
    );
  }

  Widget _buildNewPostButton(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: controller.isSearch.value
          ? AppSpacing.emptyBox
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacing.gapH20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.newsfeed__create_post_hint,
                      style: AppTextStyles.s16w500.text2Color,
                    ),
                    AppIcon(
                      icon: AppIcons.image,
                      color: AppColors.green1,
                      size: 28,
                    ).clickable(() async {
                      await controller.createPost(
                        posts: controller.posts,
                        isMedia: true,
                      );
                    }),
                  ],
                )
                    .paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s8)
                    .clickable(() async {
                  await controller.createPost(
                      posts: controller.posts, isFocus: true);
                }),

                // AppSpacing.gapH12,
                // Container(
                //   padding: AppSpacing.edgeInsetsAll12,
                //   decoration: BoxDecoration(
                //     border: Border(
                //       top: BorderSide(
                //         color: AppColors.grey1.withOpacity(0.67),
                //       ),
                //       bottom: BorderSide(
                //         color: AppColors.grey1.withOpacity(0.67),
                //       ),
                //     ),
                //   ),
                //   child: IntrinsicHeight(
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Expanded(
                //           child: _buildItemNewPost(
                //             icon: AppIcons.image,
                //             title: l10n.newsfeed__image,
                //             color: AppColors.green1,
                //             onTap: () async {
                //               await controller.createPost(
                //                 posts: controller.posts,
                //                 isMedia: true,
                //               );
                //             },
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.symmetric(vertical: 4),
                //           child: VerticalDivider(
                //               color: AppColors.grey1.withOpacity(0.67)),
                //         ),
                //         Expanded(
                //           child: _buildItemNewPost(
                //             icon: AppIcons.videoPost,
                //             title: l10n.newsfeed__video,
                //             color: AppColors.blue2,
                //             onTap: () async {
                //               await controller.createPost(
                //                 posts: controller.posts,
                //                 isMedia: true,
                //               );
                //             },
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
    );
  }

  Widget _buildItemNewPost({
    required String title,
    required Object icon,
    required Color color,
    required Function() onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(icon: icon, color: color),
        AppSpacing.gapW4,
        Text(title,
            style: AppTextStyles.s16w500.copyWith(color: AppColors.zambezi)),
      ],
    ).paddingSymmetric(vertical: Sizes.s12).clickable(() => onTap());
  }

  Future<void> sharePost({
    required Post post,
    required BuildContext context,
  }) async {
    if (controller.sharePostController.userContacts.isEmpty) {
      controller.sharePostController.getUserSharePost();
    }

    final result = await ViewUtil.showBottomSheet(
      child: SharePostView(
        post: post,
      ),
      // isFullScreen: true,
    );

    if (result != null) {
      // ignore: use_build_context_synchronously
      ViewUtil.showAppSnackBarNewFeeds(
          title: l10n.newsfeed__share_post_success);
    }
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

  Widget _buildSearchResult() {
    return Obx(
      () {
        if (controller.searchText.value.isEmpty) {
          return _buildHistorySearch();
        }
        if (controller.users.isEmpty) {
          return _buildEmptyResult();
        }

        return _buildUsersList();
      },
    );
  }

  Widget _buildHistorySearch() {
    if (controller.isLoadingHistory.value) {
      return const Column(
        children: [
          AppSpacing.gapH24,
          Center(
              child: CircularProgressIndicator(
            color: AppColors.pacificBlue,
          )),
        ],
      );
    }

    if (controller.historyList.value.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.search_history__lasted,
          style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
        ),
        AppSpacing.gapH12,
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.historyList.value.length,
          itemBuilder: (context, index) {
            final history = controller.historyList.value[index];

            return Row(
              children: [
                Expanded(
                  child: UserItem(
                      key: ValueKey(history.user?.id),
                      user: history.user!,
                      onTap: () {
                        _onUserTapped(history.user!);
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppIcon(
                    size: 20,
                    icon: history.isPin
                        ? Assets.icons.pinSearch
                        : Assets.icons.moreOption,
                    color: AppColors.text2,
                  ),
                ).clickable(() {
                  if (history.isPin == false) {
                    Get.bottomSheet(
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 65,
                            height: 4,
                            margin: const EdgeInsets.only(
                                bottom: Sizes.s16, top: Sizes.s12),
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: AppColors.text2,
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                AppCircleAvatar(
                                  url: history.user?.avatarPath ?? '',
                                  size: 60,
                                ),
                                AppSpacing.gapW24,
                                Text(
                                  history.user?.fullName ?? '',
                                  style: AppTextStyles.s16w500
                                      .copyWith(color: AppColors.text2),
                                ),
                              ],
                            ),
                          ).paddingAll(20),
                          const AppDivider(
                            height: 1,
                            color: AppColors.grey10,
                          ).paddingSymmetric(horizontal: 20),
                          _buildItemMore(
                            title: context.l10n.button__delete,
                            icon: Assets.icons.bin,
                            discrible:
                                context.l10n.search_history__delete_subtext,
                            onTap: () {
                              controller
                                  .deleteHistorySearchUser(history.user!.id);
                              Get.back();
                            },
                          ),
                          _buildItemMore(
                            title: context.l10n.search_history__pin_lable,
                            icon: Assets.icons.pinSearch,
                            discrible: context.l10n.search_history__pin_subtext,
                            onTap: () {
                              final value = HistorySearchUser(
                                user: history.user,
                                isPin: true,
                              );

                              controller.updateHistorySearchUser(value);
                            },
                          ),
                          AppSpacing.gapH24,
                        ],
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(30.r)),
                      ),
                      backgroundColor: AppColors.white,
                    );
                  } else {
                    final value = history;
                    value.isPin = false;
                    controller.updateHistorySearchUser(value);
                  }
                }),
              ],
            ).marginOnly(bottom: 12);
          },
        ),
      ],
    ).paddingAll(20);
  }

  Widget _buildItemMore({
    required String title,
    required String discrible,
    required SvgGenImage icon,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.grey6,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              icon: icon,
              color: AppColors.text2,
              size: 20,
            ),
          ),
          AppSpacing.gapW12,
          SizedBox(
            width: 0.75.sw,
            height: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.s14w500.copyWith(color: AppColors.text2),
                ),
                Text(
                  discrible,
                  style:
                      AppTextStyles.s14w400.copyWith(color: AppColors.grey10),

                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Xử lý tràn văn bản
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s4),
    );
  }

  Widget _buildEmptyResult() {
    return SizedBox(
      height: 0.7.sh,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(
            icon: AppIcons.search,
            size: Sizes.s48,
            color: AppColors.pacificBlue,
          ),
          AppSpacing.gapH20,
          Text(
            l10n.search__no_result,
            style: AppTextStyles.s18w500.copyWith(color: AppColors.pacificBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (controller.users.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.search__users_label,
          style: AppTextStyles.s16w500.text2Color,
        ),
        AppSpacing.gapH8,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.users.length,
          separatorBuilder: (context, index) => AppSpacing.gapH8,
          itemBuilder: (context, index) {
            final user = controller.users[index];

            return UserItem(
                key: ValueKey(user.id),
                user: user,
                onTap: () {
                  _onUserTapped(user);
                  controller
                      .addHistorySearchUser(HistorySearchUser(user: user));
                });
          },
        ),
        AppSpacing.gapH20,
      ],
    );
  }

  void _onUserTapped(User user) {
    Get.toNamed(
      Routes.posterPersonal,
      arguments: {'user': user, 'isChat': false},
    );
  }

  void onDelete(BuildContext context, Post post) {
    ViewUtil.showAppCupertinoAlertDialog(
      title: l10n.newsfeed__delete_post,
      message: l10n.newsfeed__delete_post_confirm,
      negativeText: l10n.button__delete,
      positiveText: l10n.button__cancel,
      onNegativePressed: () {
        controller.deletePost(post: post, posts: controller.posts);
      },
    );
  }
}
