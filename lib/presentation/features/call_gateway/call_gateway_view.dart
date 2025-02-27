import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/all.dart';
import '../../base/all.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import '../../routing/routers/app_pages.dart';
import '../all.dart';
import '../home/views/widgets/_home_more_bottom_sheet.dart';
import 'call_gateway_controller.dart';
import 'call_history/call_history_appbar.dart';
import 'contact/all.dart';

class CallGatewayView extends BaseView<CallGatewayController> {
  const CallGatewayView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      // applyAutoPaddingBottom: true,
      isRemoveBottomPadding: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppSpacing.gapH12,
            Padding(
              padding: AppSpacing.edgeInsetsAll20,
              child: searchWidget(context),
            ),
            AppSpacing.gapH12,
            _buildBody(),
          ],
        ),
      ),
      // body: SafeArea(
      //   child: DefaultTabController(
      //     length: 3,
      //     child: Column(
      //       children: [
      //         // ChatDashBoardAppBar(),
      //         AppSpacing.gapH12,
      //         Padding(
      //           padding: AppSpacing.edgeInsetsAll20,
      //           child: searchWidget(context),
      //         ),
      //         // AppSpacing.gapH12,
      //         // buildTabBar(context),
      //         AppSpacing.gapH12,
      //         Expanded(child: _buildBody()),
      //       ],
      //     ),
      //   ),
      // ),
      // bottomNavigationBar: BottomAppBar(
      //   height: 90.h,
      //   color: Colors.white,
      //   elevation: 0,
      //   padding: EdgeInsets.only(
      //     top: 10.h,
      //     left: 20.w,
      //     right: 20.w,
      //   ),
      //   child: Obx(
      //     () => Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
      //       children: [
      //         _buildItemBottomBar(
      //           icon: AppIcons.contacts,
      //           title: l10n.call__contact,
      //           isSelected: controller.currentIndex.value == 0,
      //           action: () => controller.changeTab = 0,
      //         ),
      //         MessageNavItemWidget(
      //           child: _buildItemBottomBar(
      //             icon: AppIcons.chat,
      //             title: l10n.call__chat,
      //             isSelected: controller.currentIndex.value == 1,
      //             action: () => controller.changeTab = 1,
      //           ),
      //         ),
      //         // _buildItemBottomBar(
      //         //   icon: AppIcons.keyboard,
      //         //   title: l10n.call__numpad,
      //         //   isSelected: controller.currentIndex.value == 2,
      //         //   action: () => controller.changeTab = 2,
      //         // ),
      //         _buildItemBottomBar(
      //           icon: AppIcons.history,
      //           title: l10n.call__history,
      //           isSelected: controller.currentIndex.value == 2,
      //           action: () => controller.changeTab = 2,
      //         ),

      //         // _buildItemBottomBar(
      //         //   icon: AppIcons.addTab,
      //         //   title: l10n.home__more_title,
      //         //   isSelected: controller.currentIndex.value == 3,
      //         //   action: _showMoreBottomSheet,
      //         // ),
      //         // _buildPersonalItem(
      //         //   onTap: () {
      //         //     controller.changeTab = 3;
      //         //   },
      //         //   title: l10n.navigation__account,
      //         //   isSelected: controller.currentIndex.value == 3,
      //         // ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }

  Widget searchWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: AppSpacing.edgeInsetsAll8,
            decoration: BoxDecoration(
              color: AppColors.blue7.withOpacity(0.42),
              border: Border.all(
                color: AppColors.blue6.withOpacity(0.31),
              ),
              borderRadius: BorderRadius.circular(62),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 5, 24, 5),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    icon: AppIcons.search,
                    color: AppColors.subText2,
                  ),
                  AppSpacing.gapW8,
                  Text(
                    context.l10n.global__search,
                    style: AppTextStyles.s16w400.copyWith(
                        fontStyle: FontStyle.italic, color: AppColors.zambezi),
                  )
                ],
              ),
            ),
          ).clickable(() {
            Get.toNamed(Routes.search, arguments: {'type': 'chat'});
          }),
        ),
      ],
    );
  }

  Widget buildTabBar(BuildContext context) => Container(
        margin: AppSpacing.edgeInsetsH40,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.blue5.withOpacity(0.17)),
          borderRadius: BorderRadius.circular(80),
        ),
        // padding: const EdgeInsets.all(5),
        child: TabBar(
          onTap: (value) {
            controller.tabController.index = value;
          },
          controller: controller.tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(80),
            color: AppColors.deepSkyBlue,
          ),
          unselectedLabelColor: AppColors.zambezi,
          labelColor: AppColors.text1,
          labelStyle: AppTextStyles.s14w400,
          tabs: [
            Tab(text: context.l10n.home__bottom_sheet_message),
            Tab(text: context.l10n.call__contact),
            Tab(text: context.l10n.call__history),
          ],
        ),
      );

  Widget _buildPersonalItem({
    required VoidCallback onTap,
    required String title,
    required bool isSelected,
  }) {
    return Column(
      children: [
        Obx(
          () => Container(
            padding: AppSpacing.edgeInsetsH4.r,
            child: AppCircleAvatar(
              url: controller.currentUser.avatarPath ?? '',
              size: Sizes.s32,
            ),
          ),
        ),
        Text(
          title,
          style: AppTextStyles.s12w400
              .copyWith(color: isSelected ? AppColors.text4 : AppColors.white),
        ).paddingOnly(top: 6.w),
      ],
    ).clickable(onTap);
  }

  void _showMoreBottomSheet() {
    Get.bottomSheet(
      HomeMoreBottomSheet(
        controller: Get.find<HomeController>(),
      ),
    );
  }

  CommonAppBar _buildAppBar() {
    switch (controller.currentIndex.value) {
      case 0:
        return ChatDashBoardAppBar();

      case 1:
        return ContactAppBar();

      // case 2:
      //   return CommonAppBar(
      //     automaticallyImplyLeading: false,
      //     titleType: AppBarTitle.none,
      //   );
      case 3:
        return CallHistoryAppBar();

      // case 3:
      //   return PersonalPageHiddenNewfeedsAppBarView();
      default:
        return CommonAppBar(
          // automaticallyImplyLeading: false,
          leadingIcon: LeadingIcon.none,
          automaticallyImplyLeading: false,
          centerTitle: false,
          // actions: const [
          //   NotificationsIcon(),
          // ],
        );
    }
  }

  Widget _buildItemBottomBar({
    required SvgGenImage icon,
    required String title,
    required bool isSelected,
    required Function() action,
  }) {
    return Column(
      children: [
        AppIcon(
          icon: icon,
          color: isSelected ? AppColors.pacificBlue : Colors.black,
          size: 34.w,
        ),
        Text(
          title,
          style: AppTextStyles.s12w400.copyWith(
              color: isSelected ? AppColors.pacificBlue : AppColors.text2),
        ).paddingOnly(top: 6.w),
      ],
    ).clickable(action);
  }

  Widget _buildBody() {
    return const ChatDashboardView();
    // return Expanded(
    //   child: TabBarView(
    //     controller: controller.tabController,
    //     children: const <Widget>[
    //       ChatDashboardView(),
    //        ContactBody(),
    //        CallHistoryBody(),
    //     ],
    //   ),
    // );
    // return PageView(
    //   controller: controller.pageController,
    //   physics: const NeverScrollableScrollPhysics(),
    //   onPageChanged: (index) => controller.changeTab = index,
    //   children: const [
    //     ContactBody(),
    //     ChatDashboardView(),
    //     // NumpadView(),
    //     CallHistoryBody(),
    //     // PersonalPageHiddenNewfeedView(),
    //     // AppSpacing.emptyBox,
    //   ],
    // );
  }
}
