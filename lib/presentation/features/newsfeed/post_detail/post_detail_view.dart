import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../all.dart';
import '../comments/bindings/comments_binding.dart';
import '../comments/views/comment_input_post_detail.dart';
import '../widgets/post_item.dart';

class PostDetailView extends BaseView<PostDetailController> {
  const PostDetailView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.postDetail.isEmpty
                  ? AppSpacing.emptyBox
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          automaticallyImplyLeading: false,
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: AppIcon(
                              icon: AppIcons.arrowLeft,
                              color: AppColors.text2,
                            ),
                          ).clickable(() {
                            Get.back();
                          }),
                          leadingWidth: 38,
                          toolbarHeight: 60,
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          title: Stack(
                            children: [
                              Row(
                                children: [
                                  AppCircleAvatar(
                                    size: 52,
                                    url: controller
                                            .postDetail[0].author.avatarPath ??
                                        '',
                                  ).clickable(() {
                                    // widget.onGoToPersonal?.call(post.author);
                                  }),
                                  AppSpacing.gapW12,
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller
                                            .postDetail[0].author.fullName,
                                        style: AppTextStyles.s16w700
                                            .copyWith(color: AppColors.text2),
                                      ).clickable(() {
                                        // widget.onGoToPersonal?.call(post.author);
                                      }),
                                      const SizedBox(
                                        height: 6,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            DateTimeUtil.timeAgo(
                                                context,
                                                controller
                                                    .postDetail[0].createdAt),
                                            style: AppTextStyles.s12w500
                                                .toColor(AppColors.zambezi),
                                          ),
                                          AppSpacing.gapW4,
                                          AppIcon(
                                            icon: AppIcons.public,
                                            color: AppColors.zambezi,
                                            size: 16,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Expanded(
                                    child: SizedBox(),
                                  ),
                                ],
                              ).paddingOnly(
                                  right: Sizes.s20,
                                  top: Sizes.s16,
                                  bottom: Sizes.s8),
                              Positioned(
                                right: 0,
                                top: 16,
                                child: Container(
                                  // color: Colors.amber,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 16, 0, 20),
                                  child: AppIcon(
                                    icon: Assets.icons.postOption,
                                    color: AppColors.text2,
                                    size: 6,
                                    onTap: () {},
                                  ),
                                ).clickable(() {
                                  _buildShowBottomSheetMore(
                                      controller.postDetail[0],
                                      context: context);
                                }),
                              ),
                            ],
                          ),
                        ),
                        if (controller.postDetail.isEmpty)
                          SliverFillRemaining(
                            child: _buildNoPostsFound(),
                          ),
                        const SliverToBoxAdapter(
                          child: AppSpacing.gapH20,
                        ),
                        SliverList.builder(
                          itemCount: controller.postDetail.length,
                          itemBuilder: (context, index) {
                            return PostItem(
                              isPostDetail: true,
                              post: controller.postDetail[index],
                              currentUser: controller.currentUser,
                              onLike: (post) =>
                                  controller.postController.likePost(
                                post: post,
                                posts: controller.postDetail,
                              ),
                              onUnLike: (post) =>
                                  controller.postController.unLikePost(
                                post: post,
                                posts: controller.postDetail,
                              ),
                              onShare: (post) => sharePost(post: post),
                              onReport: (post) {
                                if (!post.isMine(currentUser.id)) {
                                  controller.postController.onReport(post);
                                }
                              },
                              onDelete: (post) {
                                if (post.isMine(currentUser.id)) {
                                  Get.back();
                                  onDelete(context, post);
                                }
                              },
                              onEdit: (post) {
                                if (post.isMine(currentUser.id)) {
                                  controller.postController.onEditPost(
                                    post: post,
                                    posts: controller.postDetail,
                                  );
                                }
                              },
                              isShowComment: controller.isShowComment,
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: CommentView(
                            bindingCreator: () => CommentsBinding(),
                            isPostDetail: true,
                            postId: controller.postDetail[0].id,
                            isMyPost: controller.postDetail[0].author.id ==
                                controller.currentUser.id,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          Obx(
            () => (controller.postDetail.isNotEmpty)
                ? CommentInputPostDetail(
                    bindingCreator: () => CommentsBinding(),
                    isPostDetail: true,
                    isFocus: controller.isFocus,
                    postId: controller.postDetail[0].id,
                    isMyPost: controller.postDetail[0].author.id ==
                        controller.currentUser.id,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void onTapComment(bool autoFocus, post) {
    ViewUtil.showBottomSheet(
      isFullScreen: true,
      isScrollControlled: true,
      settings: RouteSettings(
        arguments: CommentsArguments(
          postId: post.id,
          isMyPost: post.author.id == currentUser.id,
          autoFocus: autoFocus,
        ),
      ),
      child: CommentView(bindingCreator: () => CommentsBinding()),
    );
  }

  void onDelete(BuildContext context, Post post) {
    final posts = controller.isPostInHome
        ? controller.postController.posts
        : controller.personalPageController.posts;

    ViewUtil.showAppCupertinoAlertDialog(
      title: l10n.newsfeed__delete_post,
      message: l10n.newsfeed__delete_post_confirm,
      negativeText: l10n.button__delete,
      positiveText: l10n.button__cancel,
      onNegativePressed: () {
        controller.postController.deletePost(
          post: post,
          posts: posts,
          isPostDetail: true,
        );
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
          l10n.newsfeed__post_deleted_title,
          style: AppTextStyles.s16w500,
        ),
      ],
    );
  }

  void sharePost({required Post post}) {
    if (controller.sharePostController.userContacts.isEmpty) {
      controller.sharePostController.getUserSharePost();
    }

    ViewUtil.showBottomSheet(
      child: SharePostView(
        post: post,
      ),
      isFullScreen: true,
    );
  }

  void _buildShowBottomSheetMore(Post post, {required BuildContext context}) {
    Get.bottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 4,
            margin: const EdgeInsets.only(bottom: Sizes.s16, top: Sizes.s12),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: AppColors.text2,
            ),
          ),
          post.isMine(currentUser.id)
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemMore(
                      title: context.l10n.newsfeed__edit_title,
                      icon: AppIcons.edit,
                      onTap: () => controller.postController.onEditPost(
                        post: post,
                        posts: controller.postDetail,
                      ),
                    ),
                    _buildItemMore(
                      title: context.l10n.newsfeed__delete_title,
                      icon: AppIcons.delete,
                      onTap: () {
                        Get.back();
                        onDelete(context, post);
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink(),
          post.isMine(currentUser.id)
              ? const SizedBox.shrink()
              : _buildItemMore(
                  title: context.l10n.newsfeed__report_title,
                  icon: AppIcons.report,
                  onTap: () => controller.postController.onReport(post),
                ),
        ],
      ).paddingOnly(bottom: Sizes.s20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      backgroundColor: AppColors.white,
    );
  }

  Widget _buildItemMore({
    required String title,
    required SvgGenImage icon,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          AppIcon(icon: icon, color: AppColors.text2),
          AppSpacing.gapW12,
          Text(title,
              style: AppTextStyles.s16w500.copyWith(color: AppColors.text2)),
        ],
      ).paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s12),
    );
  }
}
