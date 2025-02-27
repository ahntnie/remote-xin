import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/all.dart';
import '../../../models/notification/notification.dart';
import '../../base/all.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import 'all.dart';

class NotificationView extends BaseView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      backgroundGradientColor: AppColors.background6,
      appBar: CommonAppBar(
        titleType: AppBarTitle.text,
        centerTitle: false,
        titleTextStyle: AppTextStyles.s18w700,
        titleWidget: Text(
          l10n.notification__title,
          style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
        ).clickable(() {
          Get.back();
        }),
        leadingIconColor: AppColors.text2,
      ),
      body: Obx(
        () {
          if (controller.isLoading && controller.notifications.isEmpty) {
            return const AppDefaultLoading();
          }

          return RefreshIndicator(
            color: AppColors.deepSkyBlue,
            backgroundColor: Colors.white,
            onRefresh: () async {
              controller.refreshNotifications();
            },
            child: CustomScrollView(
              controller: controller.scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (controller.notifications.isEmpty)
                  SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                            icon: AppIcons.bell,
                            size: 100,
                            color: AppColors.pacificBlue),
                        AppSpacing.gapH16,
                        Text(
                          l10n.notification__no_notification,
                          style: AppTextStyles.s16w400
                              .copyWith(color: AppColors.pacificBlue),
                        ),
                      ],
                    ),
                  ),
                SliverList.separated(
                  itemBuilder: (context, index) {
                    final notification = controller.notifications[index];

                    return _buildNotificationItem(
                      context: context,
                      index: index,
                      notification: notification,
                    );
                  },
                  separatorBuilder: (context, index) => AppSpacing.emptyBox,
                  itemCount: controller.notifications.length,
                ),
                SliverToBoxAdapter(
                  child: controller.isLoadingLoadMore.value
                      ? Container(
                          padding: const EdgeInsets.all(Sizes.s12),
                          child: const AppDefaultLoading(
                            color: AppColors.white,
                          ),
                        )
                      : const SizedBox(
                          height: Sizes.s24,
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required NotificationModel notification,
    required int index,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (index == 0 && notification.createdAt!.day == DateTime.now().day)
          Text(
            'Today',
            style: AppTextStyles.s18w700.text2Color,
          ).paddingOnly(left: 20),
        if (controller.indexFirstDayDifferent() == index)
          Text(
            'Before',
            style: AppTextStyles.s18w700.text2Color,
          ).paddingOnly(left: 20),
        Container(
          color: notification.isRead ? AppColors.white : AppColors.blue12,
          padding: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
          child: Row(
            children: [
              AppCircleAvatar(
                url: notification.author!.avatarPath ?? '',
                size: 70,
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    notification.title,
                    style: AppTextStyles.s16w600.text2Color,
                  ).paddingOnly(bottom: 8),
                  subtitle: Row(
                    children: [
                      Text(
                        DateTimeUtil.timeAgo(
                          context,
                          notification.createdAt ?? DateTime.now(),
                        ),
                        style: AppTextStyles.s12w400.subText2Color,
                      ),
                      AppSpacing.gapW4,
                      AppIcon(
                        icon: AppIcons.public,
                        color: AppColors.subText2,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              // if (!notification.isRead)
              //   Container(
              //     height: 8,
              //     width: 8,
              //     margin: const EdgeInsets.only(right: 12),
              //     decoration: BoxDecoration(
              //       color: !notification.isRead
              //           ? AppColors.negative
              //           : Colors.transparent,
              //       shape: BoxShape.circle,
              //     ),
              //   ),
            ],
          ),
        ).clickable(() {
          controller.onTapNotification(
            notification: notification,
            index: index,
          );
        }),
      ],
    );
    // return AppBlurryContainer(
    //   padding: const EdgeInsets.all(12),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Row(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Container(
    //             margin: const EdgeInsets.only(right: 12, top: 16),
    //             padding: AppSpacing.edgeInsetsAll4,
    //             decoration: BoxDecoration(
    //               color: !notification.isRead
    //                   ? AppColors.negative
    //                   : Colors.transparent,
    //               shape: BoxShape.circle,
    //             ),
    //           ),
    //           Expanded(
    //             child: Column(
    //               mainAxisSize: MainAxisSize.min,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Text(
    //                   notification.title,
    //                   style: AppTextStyles.s16w600.text2Color,
    //                 ),
    //                 AppSpacing.gapH4,
    //                 Text(
    //                   notification.contentText,
    //                   style: AppTextStyles.s14w400.text2Color,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //       AppSpacing.gapH4,
    //       Align(
    //         alignment: Alignment.centerRight,
    //         child: Text(
    //           DateTimeUtil.timeAgo(
    //             context,
    //             notification.createdAt ?? DateTime.now(),
    //           ),
    //           style: AppTextStyles.s12w400.text2Color,
    //         ),
    //       ),
    //     ],
    //   ),
    // ).clickable(() {
    //   controller.onTapNotification(
    //     notification: notification,
    //     index: index,
    //   );
    // });
  }
}
