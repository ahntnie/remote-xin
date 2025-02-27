import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../models/call_history.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import 'call_history_controller.dart';

class CallHistoryBody extends BaseView<CallHistoryController> {
  const CallHistoryBody({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.deepSkyBlue,
      backgroundColor: Colors.white,
      onRefresh: () async {
        controller.allHistoryPagingController.refresh();
      },
      child: CommonScaffold(
        isRemoveBottomPadding: true,
        hideKeyboardWhenTouchOutside: true,
        appBar: CommonAppBar(
          onLeadingPressed: () {
            Navigator.of(context).pop();
          },
          titleType: AppBarTitle.none,
          titleWidget: Text(
            context.l10n.call__history,
            style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
          ).clickable(() {
            Get.back();
          }),
          leadingIconColor: AppColors.text2,
          centerTitle: false,
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Obx(
            () => Column(
              children: [
                RefreshIndicator(
                  color: AppColors.deepSkyBlue,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    controller.allHistoryPagingController.refresh();
                  },
                  child: Visibility(
                    visible: !controller.isEmpty.value,
                    child: Container(
                      color: Colors.white,
                      padding: AppSpacing.edgeInsetsH20.copyWith(top: 8.0),
                      child: PagedListView<int, CallHistory>.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        pagingController: controller.allHistoryPagingController,
                        builderDelegate: PagedChildBuilderDelegate<CallHistory>(
                          animateTransitions: true,
                          itemBuilder: (context, item, index) {
                            if (item.call == null) {
                              return const SizedBox.shrink();
                            }

                            return _buildItemCallHistory(item);
                          },
                          firstPageProgressIndicatorBuilder: (context) =>
                              const AppDefaultLoading(
                            color: AppColors.pacificBlue,
                          ),
                        ),
                        separatorBuilder: (context, index) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                RefreshIndicator(
                  color: AppColors.deepSkyBlue,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    controller.missedHistoryPagingController.refresh();
                  },
                  child: Visibility(
                    visible: !controller.isEmpty.value,
                    child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(Sizes.s20),
                        child: PagedListView<int, CallHistory>.separated(
                          pagingController:
                              controller.missedHistoryPagingController,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          builderDelegate:
                              PagedChildBuilderDelegate<CallHistory>(
                                  animateTransitions: true,
                                  itemBuilder: (context, item, index) {
                                    if (item.call == null) {
                                      return const SizedBox.shrink();
                                    }

                                    return _buildItemCallHistory(item);
                                  },
                                  firstPageProgressIndicatorBuilder:
                                      (context) => const SizedBox.shrink()),
                          separatorBuilder: (context, index) =>
                              const SizedBox(),
                        )),
                  ),
                ),
                if (controller.isEmpty.value) _buildNoHistoryWidget(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoHistoryWidget(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.deepSkyBlue,
      backgroundColor: Colors.white,
      onRefresh: () async {
        controller.missedHistoryPagingController.refresh();
        controller.allHistoryPagingController.refresh();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AppIcon(
              //   icon: AppIcons.history,
              //   size: 80.w,
              //   color: AppColors.subText2,
              // ),
              // AppSpacing.gapH12,
              Text(
                context.l10n.history__empty,
                style: AppTextStyles.s16w500.copyWith(
                  color: AppColors.subText2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 0.3.sh),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCallHistory(CallHistory callHistory) {
    if (callHistory.status == 'outgoing' || callHistory.status == 'canceled') {
      if (callHistory.call!.isGroup ?? false) {
        controller.getConversationById(callHistory.call!.chatChannelId);

        return Obx(() => _buildWidgetItemCallHistory(
              avatarPath: controller.avatarGroup.value,
              fullName: controller.nameGroup.value,
              status: callHistory.status,
              createdAt: callHistory.call?.createdAt ?? DateTime.now(),
              isVideo: callHistory.call?.isVideo ?? false,
              timeCall: callHistory.duration,
              onTap: () => controller.onCallAction(callHistory, true),
            ));
      }

      final User? receiver = callHistory.call!.receivers.isNotEmpty
          ? callHistory.call!.receivers.first.user
          : null;

      return _buildWidgetItemCallHistory(
        avatarPath: receiver?.avatarPath ?? '',
        fullName: receiver?.contactName ?? 'unknown',
        status: callHistory.status,
        createdAt: callHistory.call?.createdAt ?? DateTime.now(),
        isVideo: callHistory.call?.isVideo ?? false,
        timeCall: callHistory.duration,
        onTap: () => controller.onCallAction(callHistory, true),
      );
    } else if (callHistory.status == 'incoming' ||
        callHistory.status == 'declined' ||
        callHistory.status == 'missed') {
      if (callHistory.call!.isGroup ?? false) {
        controller.getConversationById(callHistory.call!.chatChannelId);

        return Obx(() => _buildWidgetItemCallHistory(
              avatarPath: controller.avatarGroup.value,
              fullName: controller.nameGroup.value,
              status: callHistory.status,
              createdAt: callHistory.call?.createdAt ?? DateTime.now(),
              isVideo: callHistory.call?.isVideo ?? false,
              timeCall: callHistory.duration,
              onTap: () => controller.onCallAction(callHistory, false),
            ));
      }

      final User? caller = callHistory.call!.callers.isNotEmpty
          ? callHistory.call!.callers.first.user
          : null;

      return _buildWidgetItemCallHistory(
        avatarPath: caller?.avatarPath ?? '',
        fullName: caller?.fullName ?? '',
        status: callHistory.status,
        createdAt: callHistory.call?.createdAt ?? DateTime.now(),
        isVideo: callHistory.call?.isVideo ?? false,
        timeCall: callHistory.duration,
        onTap: () => controller.onCallAction(callHistory, false),
      );
    }

    return const SizedBox();
  }

  Widget _buildWidgetItemCallHistory({
    required String avatarPath,
    required String fullName,
    required String status,
    required DateTime createdAt,
    required bool isVideo,
    required int timeCall,
    Function()? onTap,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  // AppCircleAvatar(
                  //   url: avatarPath,
                  //   size: 50.w,
                  // ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          fullName,
                          style: AppTextStyles.s16w600.text2Color,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(
                          height: Sizes.s2,
                        ),
                        _buildStatusCall(
                          status,
                          DateTimeUtil.formatSecondsToTime(timeCall),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              DateTimeUtil.timeAgo(
                Get.context!,
                createdAt,
              ),
              style: AppTextStyles.s12w400.copyWith(
                color: AppColors.subText2,
              ),
            ),
            // GestureDetector(
            //   onTap: onTap,
            //   child: Container(
            //     width: Sizes.s40,
            //     height: Sizes.s40,
            //     decoration: const BoxDecoration(
            //       color: AppColors.deepSkyBlue,
            //       shape: BoxShape.circle,
            //     ),
            //     child: AppIcon(
            //       icon: isVideo ? AppIcons.video : AppIcons.phoneVoice,
            //       color: AppColors.white,
            //       padding: const EdgeInsets.all(Sizes.s8),
            //     ),
            //   ),
            // ),
          ],
        ).paddingOnly(bottom: Sizes.s8, top: Sizes.s8).clickable(() {
          if (onTap != null) {
            onTap();
          }
        }),
        Divider(
          height: 0.5,
          color: AppColors.grey3.withOpacity(0.5),
        ).paddingSymmetric(vertical: 4),
      ],
    );
  }

  Widget _buildStatusCall(String status, String time) {
    Widget result = const SizedBox();
    switch (status) {
      case 'outgoing':
        result = buildItemStatusCall(
          AppIcons.phoneOut,
          AppLocalizations.of(Get.context!)!.call_history__outgoing,
          AppColors.green3,
          time,
        );
        break;
      case 'incoming':
        result = buildItemStatusCall(
          AppIcons.phoneIn,
          AppLocalizations.of(Get.context!)!.call_history__incoming,
          AppColors.green3,
          time,
        );
        break;
      case 'missed':
        result = buildItemStatusCall(
          AppIcons.phoneIn,
          AppLocalizations.of(Get.context!)!.call_history__missed,
          AppColors.negative,
          time,
        );
        break;
      case 'canceled':
        result = buildItemStatusCall(
          AppIcons.phoneOut,
          AppLocalizations.of(Get.context!)!.call_history__outgoing,
          AppColors.green3,
          time,
        );
      case 'declined':
        result = buildItemStatusCall(
          AppIcons.phoneIn,
          AppLocalizations.of(Get.context!)!.call_history__missed,
          AppColors.negative,
          time,
        );
        break;
    }

    return result;
  }

  Widget buildItemStatusCall(
    SvgGenImage icon,
    String title,
    Color color,
    String time,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          icon: icon,
          size: Sizes.s20,
          color: color,
        ),
        const SizedBox(
          width: Sizes.s4,
        ),
        Text(
          title,
          style: AppTextStyles.s12w400.copyWith(color: color),
        ),
      ],
    );
  }
}
