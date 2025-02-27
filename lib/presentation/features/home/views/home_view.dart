import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../services/app_handle_permission_service.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../../routing/routers/app_pages.dart';
import '../../all.dart';
import '../../short_video/view/home/home_screen.dart';
import '../../travel/travel_controller.dart';
import '../../travel/travel_view.dart';
import '../../travel/travel_web_view.dart';
import '../../zoom/zoom_home_controller.dart';
import '../../zoom/zoom_home_view.dart';
import 'widgets/all.dart';
import 'widgets/custom_bottom_navigation_bar/bottom_nav_btn.dart';
import 'widgets/custom_bottom_navigation_bar/constants.dart';
import 'widgets/custom_bottom_navigation_bar/size_config.dart';

class HomeView extends BaseView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  void _showMoreBottomSheet() {
    Get.bottomSheet(HomeMoreBottomSheet(controller: controller));
  }

  void _goToCallGateway() {
    Get.toNamed(Routes.callGateway);
  }

  void _goToCreateShortVideoScreen() {
    Get.toNamed(Routes.cameraScreen);
  }

  void _goToTravelMiniApp() {
    Get.toNamed(Routes.travelMiniApp);
  }

  @override
  Widget buildPage(BuildContext context) {
    AppSizes().init(context);

    return WillPopScope(
      onWillPop: () async {
        // Disable the back button behavior
        return false;
      },
      child: Obx(
        () => CommonScaffold(
          applyAutoPaddingBottom: true,
          backgroundGradientColor: controller.currentIndex.value == 0
              ? [Colors.white, Colors.white]
              : AppColors.background6,
          isRemoveBottomPadding: true,
          // drawer: _buildDrawer(context),
          appBar: _buildAppBar(),
          body: _buildBody(),
          bottomNavigationBar: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: controller.isShowBottomBar.value ? 80 : 0,
            // padding: EdgeInsets.only(
            //   left: 20.w,
            //   right: 20.w,
            // ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.text2.withOpacity(0.27),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: bottomNav(context),
          ),
        ),
      ),
    );
  }

  Widget bottomNav(BuildContext context) {
    return Container(
      color: controller.currentIndex.value == 0 ? Colors.black : Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home Bottom Bar Item
                  BottomNavBTN(
                    onPressed: (val) {
                      controller.changeTab = 0;
                    },
                    isReel: true,
                    currentIndex: controller.currentIndex.value,
                    index: 0,
                    title: l10n.homepage_title,
                    icon: AppIcon(
                      icon: Assets.icons.houseRegular,
                      size: 28.w,
                      color: AppColors.zambezi,
                    ),
                    iconSelected: AppIcon(
                      icon: Assets.icons.houseRegular,
                      size: 24.w,
                      color: AppColors.white,
                    ),
                  ),

                  // Chat Bottom Bar Item
                  BottomNavBTN(
                    onPressed: (val) {
                      controller.changeTab = 1;
                    },
                    currentIndex: controller.currentIndex.value,
                    index: 1,
                    title: l10n.chat_menu_title,
                    icon: AppIcon(
                      icon: Assets.icons.chatIcon,
                      size: 28.w,
                      color: controller.currentIndex.value == 0
                          ? AppColors.zambezi
                          : AppColors.text2,
                    ),
                    iconSelected: AppIcon(
                      icon: Assets.icons.chatIconFill,
                      size: 28.w,
                      color: AppColors.pacificBlue,
                    ),
                  ),

                  // Create Short Video (Không thay đổi index khi click vào)
                  BottomNavBTN(
                    icon: AppIcon(
                      icon: Assets.icons.createVideo,
                      size: 28.w,
                      color: controller.currentIndex.value == 0
                          ? AppColors.white
                          : AppColors.zambezi,
                    ),
                    iconSelected: AppIcon(
                      icon: Assets.icons.createVideo,
                      color: AppColors.white,
                    ),
                    onPressed: (val) async {
                      await AppHandlePermissionService().sendPermissionRequest(
                          permission:
                              AppHandlePermissionService.PERMISSION_CAMERA);
                      await AppHandlePermissionService().sendPermissionRequest(
                          permission:
                              AppHandlePermissionService.PERMISSION_MICROPHONE);
                      await AppHandlePermissionService()
                          .sendStoragePermissionRequest();

                      if (await AppHandlePermissionService()
                          .checkAllPermissionGranted()) {
                        _goToCreateShortVideoScreen();
                      }
                    },
                    index: 2,
                    currentIndex: controller.currentIndex.value,
                    title: l10n.create_short_video_title,
                  ),

                  // Travel Bottom Bar Item
                  BottomNavBTN(
                    onPressed: (val) {
                      Get.put<TravelController>(TravelController());
                      _goToTravelMiniApp();
                    },
                    currentIndex: controller.currentIndex.value,
                    index: 3,
                    title: l10n.travel_getaway_payment,
                    icon: AppIcon(
                      icon: Assets.icons.travelIcon,
                      size: 28.w,
                      color: controller.currentIndex.value == 0
                          ? AppColors.zambezi
                          : AppColors.text2,
                    ),
                    iconSelected: AppIcon(
                      icon: Assets.icons.travelIconFill,
                      size: 28.w,
                      color: AppColors.pacificBlue,
                    ),
                  ),

                  // User Bottom Bar Item
                  BottomNavBTN(
                    onPressed: (val) {
                      controller.changeTab = 4;
                      Get.find<PersonalPageController>().init();
                    },
                    icon: AppCircleAvatar(
                      url: controller.currentUser.avatarPath ?? '',
                      size: Sizes.s28,
                    ),
                    iconSelected: Stack(
                      children: [
                        AppCircleAvatar(
                          url: controller.currentUser.avatarPath ?? '',
                          size: Sizes.s28,
                        ),
                        Container(
                          width: Sizes.s28,
                          height: Sizes.s28,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.pacificBlue,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    currentIndex: controller.currentIndex.value,
                    index: 4,
                    title: controller.l10n.menu__label,
                  ),
                ],
              ),
            ),

            // Đường kẻ line chỉ hiển thị khi index != 2
            if (controller.currentIndex.value != 2)
              AnimatedPositioned(
                duration: Duration(
                    milliseconds: controller.timeScrollBottomNavItem.value),
                curve: Curves.decelerate,
                top: 0,
                left:
                    animatedPositionedLeftValue(controller.currentIndex.value),
                child: Column(
                  children: [
                    SizedBox(
                      height: AppSizes.blockSizeHorizontal * 1.22,
                      width: AppSizes.blockSizeHorizontal,
                    ),
                    Container(
                      height: 2,
                      width: AppSizes.blockSizeHorizontal,
                      decoration: BoxDecoration(
                        color: AppColors.pacificBlue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

// Hàm tính toán vị trí của đường line
  double animatedPositionedLeftValue(int index) {
    switch (index) {
      case 0:
        return 0;
      case 1:
        return 80;
      case 2:
      case 3:
        return animatedPositionedLeftValue(controller.currentIndex.value);
      case 4:
        return 300;
      default:
        return 0;
    }
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      elevation: 100,
      shape: const RoundedRectangleBorder(),
      backgroundColor: AppColors.grey4,
      child: Padding(
        padding: AppSpacing.edgeInsetsAll20,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            AppSpacing.gapH20,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Assets.images.logo1.image(height: 82.w),
                AppIcons.close
                    .svg(width: 20, color: AppColors.grey5)
                    .clickable(() {
                  Navigator.of(context).pop();
                }),
              ],
            ),
            AppSpacing.gapH40,
            drawerItem(
              AppIcons.news,
              l10n.home__news_feed_title,
              0,
              context,
              () {
                controller.changeTab = 0;
                // Get.find<PostsController>().onTopScroll();
              },
            ),
            AppSpacing.gapH28,
            drawerItem(
                Assets.icons.chat, l10n.home__bottom_sheet_message, 1, context,
                () {
              controller.changeTab = 1;
            }),
            AppSpacing.gapH28,
            drawerItem(Assets.icons.reels, l10n.reels, 2, context, () {
              // controller.changeTab = 1;
            }),
            AppSpacing.gapH28,
            drawerItem(Assets.icons.mining, l10n.mining, 3, context, () {
              // controller.changeTab = 1;
            }),
            AppSpacing.gapH28,
            drawerItem(Assets.icons.dating, l10n.dating, 4, context, () {
              // controller.changeTab = 1;
            }),
            AppSpacing.gapH28,
            drawerItem(
                Assets.icons.stream, l10n.kols_streaming_only_fans, 5, context,
                () {
              // controller.changeTab = 1;
            }),
            AppSpacing.gapH28,
            drawerItem(Assets.icons.wallet, l10n.wallet, 6, context, () {
              // controller.changeTab = 1;
            }),
            AppSpacing.gapH28,
            drawerItem(
                Assets.icons.travel, l10n.travel_getaway_payment, 7, context,
                () {
              // controller.changeTab = 1;
            }),
            AppSpacing.gapH28,
            drawerItem(Assets.icons.promotion, l10n.promotion, 8, context, () {
              // controller.changeTab = 1;
            }),
          ],
        ),
      ),
    );
  }

  Widget drawerItem(SvgGenImage icon, String title, int index,
      BuildContext context, Function onTap) {
    Widget child = Container(
      padding: AppSpacing.edgeInsetsH12,
      child: Row(
        children: [
          icon.svg(color: AppColors.grey5, width: 30),
          AppSpacing.gapW8,
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.s16w500.copyWith(color: AppColors.grey5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (index == controller.currentIndex.value) {
      child = Container(
        padding: AppSpacing.edgeInsetsAll12,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: AppColors.button5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            icon.svg(color: AppColors.text1, width: 30),
            AppSpacing.gapW8,
            Text(
              title,
              style: AppTextStyles.s16w500.copyWith(color: AppColors.text1),
            ),
          ],
        ),
      );
    }
    return child.clickable(() {
      Navigator.of(context).pop();
      onTap();
    });
  }

  CommonAppBar? _buildAppBar() {
    switch (controller.currentIndex.value) {
      case 0:
      case 2:
      case 3:
        return null;
      case 1:
        return ChatDashBoardAppBar();
      case 4:
        return PersonalPageAppBarView();
      default:
        return _buildCommonAppBar();
    }
  }

  CommonAppBar _buildCommonAppBar() {
    return CommonAppBar(
      leadingIconColor: AppColors.pacificBlue,
      leadingIcon: LeadingIcon.none,
      automaticallyImplyLeading: false,
      centerTitle: false,
      // leadingIcon: LeadingIcon.custom,
      // leadingIconWidget: const SizedBox(),
      // leadingWidth: Sizes.s60,

      actions: const [
        // _buildSearchIcon(),
        // AppSpacing.gapW12,
        // _buildAssistantIcon(),
      ],
    );
  }

  CommonAppBar travelAppBar() {
    return CommonAppBar(
      leadingIconColor: AppColors.pacificBlue,
      leadingIcon: LeadingIcon.none,
      automaticallyImplyLeading: false,
      titleWidget: const AppLogo(),
      centerTitle: false,
      // leadingIcon: LeadingIcon.custom,
      // leadingIconWidget: const SizedBox(),
      // leadingWidth: Sizes.s60,

      actions: const [
        // _buildSearchIcon(),
        // AppSpacing.gapW12,
        // _buildAssistantIcon(),
      ],
    );
  }

  Widget _buildSearchIcon() {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(left: Sizes.s20),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey6,
      ),
      padding: AppSpacing.edgeInsetsAll12,
      child: AppIcon(
        icon: AppIcons.search,
        color: Colors.black,
      ),
    ).clickable(() {
      Get.toNamed(Routes.search, arguments: {'type': 'chat'});
    });
  }

  Widget _buildAssistantIcon() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.grey6,
      ),
      padding: AppSpacing.edgeInsetsAll12,
      child: AppIcon(
        icon: AppIcons.assistant,
        color: Colors.black,
      ),
    ).clickable(() {
      Get.toNamed(
        Routes.createPost,
        arguments: {
          'is_focus': false,
          'is_media': false,
        },
        // Tùy chỉnh thời gian của hiệu ứng
      );
    });
  }

  Widget _buildNavItem({
    required String title,
    required Object icon,
    required int index,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => Padding(
        padding: AppSpacing.edgeInsetsH4.r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon: icon,
              size: 28.w,
              color: controller.currentIndex.value == index
                  ? AppColors.pacificBlue
                  : AppColors.zambezi,
            ),
            // SvgPicture.asset(
            //   'assets/icons/chat.svg', // Đường dẫn tới file SVG của bạn
            //   color: Colors.red, // Màu bạn muốn tô
            //   width: 28, // Đặt chiều rộng (tùy chỉnh)
            //   height: 28, // Đặt chiều cao (tùy chỉnh)
            // ),
            AppSpacing.gapH4,
            Text(
              title,
              style: controller.currentIndex.value == index
                  ? AppTextStyles.s12w500
                      .merge(const TextStyle(color: AppColors.pacificBlue))
                  : AppTextStyles.s12w500.copyWith(color: AppColors.zambezi),
            ),
          ],
        ),
      ).clickable(onTap),
    );
  }

  Obx _buildPersonalItem({
    required VoidCallback onTap,
    required int index,
  }) {
    return Obx(
      () => Padding(
        padding: AppSpacing.edgeInsetsH4.r,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppCircleAvatar(
              url: controller.currentUser.avatarPath ?? '',
              size: Sizes.s28,
            ),
            AppSpacing.gapH4,
            Text(
              controller.l10n.menu__label,
              style: controller.currentIndex.value == index
                  ? AppTextStyles.s12w500
                      .merge(const TextStyle(color: AppColors.pacificBlue))
                  : AppTextStyles.s12w500.copyWith(color: AppColors.zambezi),
            ),
          ],
        ),
      ).clickable(() {
        onTap();
      }),
    );
  }

  Widget _buildBody() {
    // if (controller.currentIndex.value == -1) {
    //   return const ChatDashboardView();
    // }

    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: controller.pageController,
      onPageChanged: (index) => controller.changeTab = index,
      children: [
        HomeScreen(),
        ChatDashboardView(),
        Container(),
        Container(),
        PersonalPageView(),
      ],
    );
  }

  Widget _buildBodyComingSoon(AssetGenImage image, String subTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Sizes.s20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          50.verticalSpace,
          image.image(width: 0.6.sw),
          const SizedBox(
            height: Sizes.s32,
          ),
          Text(
            l10n.home__coming_soon,
            style: AppTextStyles.s24w500.text2Color,
          ),
          const SizedBox(
            height: Sizes.s32,
          ),
          Text(
            subTitle,
            style: AppTextStyles.s14w400.text2Color,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  CommonAppBar _buildNewsfeedAppBar() {
    return CommonAppBar(
      leadingIcon: LeadingIcon.none,
      automaticallyImplyLeading: false,
      centerTitle: false,
      backgroundColor: AppColors.white,
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
      // actions: const [
      //   SearchPostIcon(),
      //   NotificationsIcon(),
      // ],
    );
  }
}
