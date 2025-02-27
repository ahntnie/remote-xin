import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../../../core/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../../routing/routers/app_pages.dart';
import '../../all.dart';
import '../../user/settings/widgets/choose_language_view.dart';
import '../../user/settings/widgets/privacy_binding.dart';
import '../../user/settings/widgets/privacy_view.dart';
import 'widgets/bottom_sheet_list_of_nfts.dart';
import 'widgets/edit_profile_widget.dart';
import 'widgets/mana_mission_widget.dart';
import 'widgets/profile_card_widget.dart';

class PersonalPageView extends BaseView<PersonalPageController> {
  const PersonalPageView({super.key});

  @override
  bool get allowLoadingIndicator => false;

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      body: Obx(
        () => RefreshIndicator(
          color: AppColors.deepSkyBlue,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await controller.onRefreshPostPersonalPage();
          },
          child: CustomScrollView(
            // physics: const BouncingScrollPhysics(),
            controller: controller.scroll,
            slivers: [
              SliverToBoxAdapter(
                child: EditProfileWidget(
                  avatarPath: controller.currentUser.avatarPath ?? '',
                  fullName: controller.currentUser.fullName,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.gapH20,
                    buildCardInfo(),
                    const ManaMissionWidget(),
                    optionContainerWidget(),
                    optionWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget optionContainerWidget() {
    return Row(
      children: [
        // Container(
        //   width: 0.5.sw - 20 - 10,
        //   padding: AppSpacing.edgeInsetsAll12.copyWith(top: 8, bottom: 8),
        //   margin: const EdgeInsets.only(left: 20),
        //   decoration: BoxDecoration(
        //     color: AppColors.pacificBlue.withOpacity(0.1),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Assets.images.shortVideo.image(width: 32, height: 32),
        //       AppSpacing.gapH12,
        //       Text(
        //         'Reels',
        //         style: AppTextStyles.s16w600.text2Color,
        //       ),
        //     ],
        //   ),
        // ).clickable(() {
        //   Get.to(() => const HomeScreen());
        // }),
        Container(
          width: 0.5.sw - 20 - 10,
          padding: AppSpacing.edgeInsetsAll12.copyWith(top: 8, bottom: 8),
          margin: const EdgeInsets.only(left: 20),
          decoration: BoxDecoration(
            color: AppColors.pacificBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.images.xinLocation.image(width: 32, height: 32),
              AppSpacing.gapH12,
              Text(
                'XIN Location',
                style: AppTextStyles.s16w600.text2Color,
              ),
            ],
          ),
        ).clickable(() async {
          await Get.dialog(
            AlertDialog(
              backgroundColor: AppColors.white,
              icon: Assets.images.location.image(width: 100, height: 100),
              title: Text(
                l10n.location__permission_system_alert,
                style: AppTextStyles.s18w600.copyWith(color: AppColors.text2),
              ),
              content: Text(
                l10n.location__permission_system_content,
                style: AppTextStyles.s14w400.copyWith(color: AppColors.text2),
              ),
              actions: [
                AppButton.primary(
                  width: double.infinity,
                  label: l10n.allow,
                  onPressed: () async {
                    final Location locationController = Location();
                    PermissionStatus permissionGranted;
                    permissionGranted =
                        await locationController.hasPermission();
                    log(permissionGranted.toString());
                    if (permissionGranted == PermissionStatus.denied &&
                        Platform.isIOS) {
                      permissionGranted =
                          await locationController.requestPermission();
                      if (permissionGranted != PermissionStatus.granted) {
                        return;
                      } else {
                        await Get.toNamed(Routes.mapLinking)?.whenComplete(() {
                          Navigator.of(Get.overlayContext!).pop();
                        });
                      }
                    }
                    await Get.toNamed(Routes.mapLinking)?.whenComplete(() {
                      Navigator.of(Get.overlayContext!).pop();
                    });
                  },
                )
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget optionWidget() {
    return Column(
      children: [
        AppSpacing.gapH16,
        _buildDivider(),
        builditemSetting(
            Assets.icons.nft,
            AppColors.text2,
            l10n.personal_page__list_nft,
            () => showBottomSheetListOfNFTs(Get.context)),
        _buildDivider(),
        builditemSetting(
          Assets.icons.settingLanguage,
          AppColors.text2,
          l10n.setting__language,
          () => Get.to(() => const ChooseLanguageView()),
        ),
        _buildDivider(),
        builditemSetting(
          Assets.icons.settingPolicy,
          AppColors.text2,
          l10n.setting__terms_services,
          () => IntentUtils.openBrowserURL(url: AppConstants.policyURL),
        ),
        _buildDivider(),
        builditemSetting(
          Assets.icons.lock,
          AppColors.text2,
          l10n.setting__privacy_label,
          () => Get.to(() => const PrivacyView(), binding: PrivacyBinding()),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: const BoxDecoration(
              color: AppColors.grey11,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              Assets.icons.settingWebDdapp.image(width: 40, height: 40),
              AppSpacing.gapW12,
              Text(
                l10n.setting__web_system,
                style: AppTextStyles.s14w600.text2Color,
              ),
            ],
          ),
        ).paddingSymmetric(vertical: 20).clickable(() {
          IntentUtils.openBrowserURL(url: AppConstants.webSystemURL);
        }),
        AppSpacing.gapH20,
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppColors.negative2,
              borderRadius: BorderRadius.circular(100)),
          child: Text(
            l10n.home__bottom_sheet_logout,
            style: AppTextStyles.s16w700.text1Color,
            textAlign: TextAlign.center,
          ),
        ).clickable(() {
          controller.logout();
        }),
        AppSpacing.gapH28,
      ],
    ).paddingSymmetric(horizontal: 20);
  }

  Widget builditemSetting(
          Object icon, Color color, String title, Function() onTap) =>
      Row(
        children: [
          AppIcon(
            icon: icon,
            color: color,
          ),
          AppSpacing.gapW12,
          Text(
            title,
            style: AppTextStyles.s16w600.toColor(color),
          ),
          const Spacer(),
          if (icon != AppIcons.trashMessage)
            AppIcon(
              icon: AppIcons.arrowRight,
              color: AppColors.text2,
            )
        ],
      ).clickable(() {
        onTap();
      });

  Widget _buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Divider(
          color: Color(0xffdbdbdb),
          height: 1,
        ),
      );

  Widget buildCardInfo() {
    return Padding(
      padding: AppSpacing.edgeInsetsH20,
      child: ProfileCardWidget(
        xinId: currentUser.webUserId ?? '',
        userName: currentUser.contactName,
        email: currentUser.email ?? '',
        // phoneNumber: currentUser.phone ?? '',
        phoneNumber: currentUser.nftNumber ?? '',
      ),
    );
  }

  // void onDelete(BuildContext context, Post post) {
  //   ViewUtil.showAppCupertinoAlertDialog(
  //     title: l10n.newsfeed__delete_post,
  //     message: l10n.newsfeed__delete_post_confirm,
  //     negativeText: l10n.button__delete,
  //     positiveText: l10n.button__cancel,
  //     onNegativePressed: () {
  //       controller.postController
  //           .deletePost(post: post, posts: controller.posts);
  //     },
  //   );
  // }

  // Widget _buildNoPostsFound() {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       AppIcon(
  //         icon: AppIcons.news,
  //         size: Sizes.s128,
  //         color: AppColors.pacificBlue,
  //       ),
  //       Text(
  //         l10n.newsfeed__no_posts_found,
  //         style: AppTextStyles.s16w500.copyWith(color: AppColors.pacificBlue),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildNewPostButton(BuildContext context) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       AppSpacing.gapH36,
  //       Row(
  //         children: [
  //           // AppCircleAvatar(
  //           //   url: currentUser.avatarPath ?? '',
  //           //   size: Sizes.s44,
  //           // ),
  //           // AppSpacing.gapW12,
  //           Text(
  //             l10n.newsfeed__create_post_hint,
  //             style: AppTextStyles.s14w500.copyWith(color: AppColors.zambezi),
  //           ),
  //         ],
  //       )
  //           .paddingSymmetric(horizontal: Sizes.s20, vertical: Sizes.s8)
  //           .clickable(() async {
  //         await controller.postController
  //             .createPost(posts: controller.posts, isFocus: true);
  //       }),
  //       AppSpacing.gapH12,
  //       Container(
  //         padding: AppSpacing.edgeInsetsAll12,
  //         decoration: BoxDecoration(
  //           border: Border(
  //             top: BorderSide(color: AppColors.grey1.withOpacity(0.67)),
  //             bottom: BorderSide(color: AppColors.grey1.withOpacity(0.67)),
  //           ),
  //         ),
  //         child: IntrinsicHeight(
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Expanded(
  //                 child: _buildItemNewPost(
  //                   color: AppColors.green1,
  //                   icon: AppIcons.image,
  //                   title: l10n.newsfeed__image,
  //                   onTap: () async {
  //                     await controller.postController.createPost(
  //                       posts: controller.posts,
  //                       isMedia: true,
  //                     );
  //                   },
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.symmetric(vertical: 4),
  //                 child:
  //                     VerticalDivider(color: AppColors.grey1.withOpacity(0.67)),
  //               ),
  //               Expanded(
  //                 child: _buildItemNewPost(
  //                   color: AppColors.pacificBlue,
  //                   icon: AppIcons.videoPost,
  //                   title: l10n.newsfeed__video,
  //                   onTap: () async {
  //                     await controller.postController.createPost(
  //                       posts: controller.posts,
  //                       isMedia: true,
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget _buildItemNewPost({
  //   required String title,
  //   required Object icon,
  //   required Color color,
  //   required Function() onTap,
  // }) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       AppIcon(icon: icon, color: color),
  //       AppSpacing.gapW4,
  //       Text(title,
  //           style: AppTextStyles.s16w500.copyWith(color: AppColors.zambezi)),
  //     ],
  //   ).paddingSymmetric(vertical: Sizes.s12).clickable(() => onTap());
  // }

  // void sharePost({required Post post}) {
  //   if (controller.sharePostController.userContacts.isEmpty) {
  //     controller.sharePostController.getUserSharePost();
  //   }

  //   ViewUtil.showBottomSheet(
  //     child: SharePostView(
  //       post: post,
  //     ),
  //     isFullScreen: true,
  //   );
  // }

  void showBottomSheetListOfNFTs(BuildContext? context) =>
      showCupertinoModalBottomSheet(
        expand: true,
        context: context!,
        topRadius: const Radius.circular(20),
        builder: (context) => const BottomSheetListOfNFTs(),
      );
}
