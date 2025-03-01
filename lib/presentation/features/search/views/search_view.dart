import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/user.dart';
import '../../../../repositories/all.dart';
import '../../../base/all.dart';
import '../../../common_controller.dart/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../../routing/routing.dart';
import '../../chat/dashboard/views/widgets/_conversation_item.dart';
import '../../short_video/modal/user_video/user_video.dart';
import '../../short_video/view/hashtag/videos_by_hashtag.dart';
import '../../short_video/view/profile/item_post.dart';
import '../controllers/search_controller.dart';
import 'demo.dart';
import 'widgets/_user_item.dart';

class SearchView extends BaseView<SearchController> {
  const SearchView({Key? key}) : super(key: key);

  Future<void> _onUserTapped(User user) async {
    if (controller.type == 'chat') {
      controller.goToPrivateChat(user);
    } else {
      // Get.toNamed(
      //   Routes.posterPersonal,
      //   arguments: {'user': user, 'isChat': false},
      // );
      final ContactRepository contactRepository = Get.find();
      final AppController appController = Get.find();

      final resultContactList = await contactRepository.checkContactExist(
        phoneNumber: user.phone ?? '',
        userId: appController.lastLoggedUser!.id,
      );
      Get.toNamed(Routes.myProfile, arguments: {
        'isMine': false,
        'user': user,
        'isAddContact': resultContactList.isEmpty,
      });
    }
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      applyAutoPaddingBottom: true,
      hideKeyboardWhenTouchOutside: true,
      backgroundGradientColor: AppColors.background6,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  CommonAppBar _buildAppBar() {
    return CommonAppBar(
      text: l10n.search__title,
      titleType: AppBarTitle.text,
      titleWidget: Text(
        l10n.search__title,
        style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
      ).clickable(() => Get.back()),
      leadingIconColor: AppColors.text2,
      centerTitle: false,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchField().paddingSymmetric(horizontal: 20),
        AppSpacing.gapH8,
        Expanded(
            child: controller.type == 'reels'
                ? _buildSearchResultReels()
                : _buildSearchResult(controller.type)
                    .paddingSymmetric(horizontal: 20)),
      ],
    );
  }

  Widget _buildSearchField() {
    return CustomSearchBar(
      hintText: l10n.search__search,
      // onChanged: controller.search,
      textInputAction: TextInputAction.search,
      onChanged: (text) {
        if (text != controller.textSearch) {
          controller.initUser = true;
          controller.initVideo = true;
          controller.initHashtag = true;
          controller.textSearch = text;
          controller.search(text);
        }
      },
      onSubmit: (text) {
        if (text != controller.textSearch) {
          controller.initUser = true;
          controller.initVideo = true;
          controller.initHashtag = true;
          controller.textSearch = text;
          controller.search(text);
        }
      },
    );
  }

  Widget _buildSearchResultReels() => Obx(() => controller.isLoadingSearch.value
      ? const Center(
          child: CircularProgressIndicator(
            color: AppColors.blue10,
          ),
        )
      : Column(
          children: [
            TabBar(
              indicatorWeight: 1,
              labelStyle: AppTextStyles.s16w600.toColor(AppColors.blue10),
              dividerColor: AppColors.grey7,
              dividerHeight: 1,
              controller: controller.tabController,
              indicatorColor: AppColors.blue10,
              indicatorSize: TabBarIndicatorSize.label,
              unselectedLabelColor: AppColors.grey5,
              tabs: [
                const Tab(text: 'Video'),
                Tab(text: Get.context!.l10n.search__users_label),
                const Tab(text: 'Hashtag'),
              ],
            ),
            Expanded(
                child: Obx(() => TabBarView(
                      controller: controller.tabController,
                      children: [
                        _buildVideoList(),
                        _buildUsersList('reels')
                            .paddingSymmetric(horizontal: 20),
                        _buildHashtagList().paddingSymmetric(horizontal: 20),
                      ],
                    ))),
          ],
        ));

  Widget _buildSearchResult(String type) {
    return Obx(
      () {
        if (controller.users.isEmpty && controller.conversations.isEmpty) {
          return _buildEmptyResult();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              if (controller.type == 'chat') _buildConversationsList(),
              _buildUsersList(type),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyResult() {
    const String videoUrls =
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   children: [
    //     AppIcon(
    //       icon: AppIcons.search,
    //       size: Sizes.s48,
    //       color: AppColors.grey8,
    //     ),
    //     AppSpacing.gapH20,
    //     Text(
    //       l10n.search__no_result,
    //       style: AppTextStyles.s18w500.copyWith(color: AppColors.grey8),
    //     ),
    //   ],
    // );
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 6,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return _buildDemo(videoUrls[index], index);
      },
    );
  }

  Widget _buildConversationsList() {
    if (controller.conversations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.search__conversations_label,
          style: AppTextStyles.s16w500.text2Color,
        ),
        AppSpacing.gapH8,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.conversations.length,
          separatorBuilder: (context, index) => AppSpacing.gapH8,
          itemBuilder: (context, index) {
            final conversation = controller.conversations[index];

            return ConversationItem(
              key: ValueKey(conversation.id),
              conversation: conversation,
              showChildOnly: true,
              contentPadding: EdgeInsets.zero,
              beforeGoToChat: Get.back,
            );
          },
        ),
      ],
    );
  }

  Widget _buildUsersList(String type) {
    if (controller.users.isEmpty) {
      return _buildEmptyResult();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        type == 'reels'
            ? const SizedBox()
            : Text(
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
              onTap: () => _onUserTapped(user),
            );
          },
        ),
        AppSpacing.gapH20,
      ],
    );
  }

  Widget _buildVideoList() {
    return controller.videos.isEmpty ? _buildEmptyResult() : _buildGridView();
  }

  Widget _buildGridView() {
    return GridView.builder(
      itemCount: controller.videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 12,
        crossAxisCount: 2,
        childAspectRatio: 1 / 2,
      ),
      itemBuilder: (context, index) {
        return _buildGridItem(index);
      },
    ).paddingSymmetric(horizontal: 12);
  }

  Widget _buildDemo(String videoURL, int index) {
    return VideoGridItem(
      index: index,
      key: ValueKey(index),
      videoUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4',
    );
  }

  Widget _buildGridItem(int index) {
    final item = controller.videos[index];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemPost(item),
          AppSpacing.gapH8,
          _buildDescription(item),
          _buildUserInfoRow(item),
        ],
      ),
    );
  }

  Widget _buildItemPost(Data item) {
    return SizedBox(
      height: 1.sw - 19 - 120,
      child: ItemPost(
        onComment: (indexComment, count) {
          controller.updateComment(indexComment, count);
        },
        onLike: (indexLike, liked, count) {
          controller.updateLike(indexLike, liked, count);
        },
        onPinned: (id, value) {
          controller.updatePinned(id, value);
        },
        onBookmark: (indexBookmark, value) {
          controller.updateBookmark(indexBookmark, value);
        },
        onFollowed: (indexFollow, value) {
          controller.updateFollow(indexFollow, value);
        },
        data: item,
        list: controller.videos,
        onDelete: (int videoId) {},
        onTap: () {},
        userId: item.userId,
      ),
    );
  }

  Widget _buildDescription(Data item) {
    return item.postDescription == null
        ? const SizedBox()
        : Row(
            children: [
              Flexible(
                child: Text(
                  item.postDescription ?? '',
                  style: AppTextStyles.s18w500.text2Color,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
  }

  Widget _buildUserInfoRow(Data item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Row(
            children: [
              AppCircleAvatar(size: Sizes.s24, url: item.userProfile ?? ''),
              AppSpacing.gapW4,
              Flexible(
                child: Text(
                  item.fullName ?? '',
                  style: AppTextStyles.s14Base.text4Color,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${item.postLikesCount}',
          style: AppTextStyles.s14w500.copyWith(
            color: AppColors.grey8,
          ),
        ),
        AppSpacing.gapW4,
        AppIcon(
          icon: Assets.icons.heart,
          size: Sizes.s16,
          color: AppColors.grey8,
        ),
      ],
    );
  }

  Widget _buildHashtagList() => controller.hashtags.isEmpty
      ? _buildEmptyResult()
      : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.hashtags.length,
          itemBuilder: (context, index) {
            return hashtagItem(index);
          },
        );

  Widget hashtagItem(int index) => Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: const BoxDecoration(
              color: AppColors.grey7,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AppIcon(
                icon: Assets.icons.hastag,
                color: Colors.black,
              ),
            ),
          ),
          AppSpacing.gapW12,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.hashtags[index].hashTagName,
                style: AppTextStyles.s16w600.copyWith(color: AppColors.text2),
              ),
              Text(
                '${controller.hashtags[index].videosCount} videos',
                style: AppTextStyles.s12w400.copyWith(color: AppColors.text2),
              ),
            ],
          )
        ],
      ).paddingOnly(top: 12).clickable(() {
        Navigator.push(Get.context!, MaterialPageRoute(builder: (context) {
          return VideosByHashTagScreen(controller.hashtags[index].hashTagName);
        }));
      });
}
