import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/all.dart';
import '../../base/base_view.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import 'widgets/join_meeting_view.dart';
import 'widgets/start_meeting_view.dart';
import 'zoom_home_controller.dart';

class ZoomHomeView extends BaseView<ZoomHomeController> {
  const ZoomHomeView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      isRemoveBottomPadding: true,
      hideKeyboardWhenTouchOutside: true,
      appBar: CommonAppBar(
        leadingIconColor: AppColors.pacificBlue,
        automaticallyImplyLeading: true,
        titleWidget: const AppLogo(),
        centerTitle: false,
        actions: [
          // _buildSearchIcon(),
          // AppSpacing.gapW12,
          // _buildAssistantIcon(),
          Container(
            padding: const EdgeInsets.all(Sizes.s8),
            decoration: const BoxDecoration(
              color: AppColors.grey6,
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              icon: Assets.icons.refresh,
              color: Colors.black,
            ),
          ).clickable(() async {
            controller.isLoadingHistory.value = true;
            await Future.delayed(const Duration(milliseconds: 500));
            controller.isLoadingHistory.value = false;
          })
        ],
      ),
      body: Column(
        children: [
          AppSpacing.gapH24,
          groupButton(),
          AppSpacing.gapH12,
          refreshHistoryButton(),
          zoomList(),
        ],
      ),
    );
  }

  Widget groupButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      width: Get.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xffd9eff9),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                AppIcon(
                  icon: Assets.icons.startMeet,
                  color: AppColors.blue10,
                ),
                Text(
                  l10n.zoom__new,
                  style: AppTextStyles.s16w600.toColor(AppColors.blue10),
                )
              ]),
            ).clickable(() => Get.to(() => const StartMeetingView())),
          ),
          AppSpacing.gapW20,
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: const Color(0xffdafae1),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                AppIcon(
                  icon: Assets.icons.joinMeet,
                  color: const Color(0xff1eb940),
                ),
                Text(
                  l10n.zoom__join,
                  style: AppTextStyles.s16w600.toColor(const Color(0xff1eb940)),
                )
              ]),
            ).clickable(() => Get.to(() => const JoinMeetingView(
                  idMeeting: '',
                ))),
          )
        ],
      ),
    );
  }

  Widget refreshHistoryButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: AppSpacing.edgeInsetsV16H20,
          decoration: const BoxDecoration(border: Border.symmetric()),
          child: Row(
            children: [
              // Assets.icons.iconZoomRefreshHistory
              //     .image(color: const Color(0xff124984), scale: 2),
              // AppSpacing.gapW8,
              Text(l10n.zoom__recently,
                  style: AppTextStyles.s18w500.text2Color),
            ],
          ).clickable(() {
            controller.loadMeetingHistory();
          }),
        ),
      ],
    );
  }

  Widget zoomList() {
    return Expanded(
        child: Padding(
      padding: AppSpacing.edgeInsetsH20,
      child: Obx(
        () => controller.isLoadingHistory.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.blue10,
                ),
              )
            : ListView.builder(
                itemCount: controller.meetingHistoryList.length,
                itemBuilder: (context, index) => Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 110,
                      decoration: BoxDecoration(
                          color:
                              controller.meetingHistoryList[index].type == null
                                  ? const Color(0xff71d4ff)
                                  : controller.meetingHistoryList[index].type ==
                                          'new'
                                      ? const Color(0xff71d4ff)
                                      : const Color(0xff71ff99),
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    Container(
                      height: 110,
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.only(bottom: 12, top: 12),
                      decoration: BoxDecoration(
                          color: AppColors.grey11,
                          borderRadius: BorderRadius.circular(4)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.meetingHistoryList[index].type == null
                                ? l10n.zoom__start_meeting
                                : controller.meetingHistoryList[index].type ==
                                        'new'
                                    ? l10n.zoom__start_meeting
                                    : l10n.zoom__join_meeting_text,
                            style: AppTextStyles.s16Base.subText2Color,
                          ),
                          Expanded(
                            child: Text(
                              controller.meetingHistoryList[index].idMeeting,
                              style: AppTextStyles.s18w700
                                  .copyWith(color: AppColors.text2),
                            ),
                          ),
                          Row(
                            children: [
                              AppIcon(
                                icon: Assets.icons.timeline,
                                color: AppColors.subText2,
                                size: 20,
                              ),
                              AppSpacing.gapW8,
                              Text(
                                DateTimeUtil.timeAgo(
                                    context,
                                    DateTime.parse(controller
                                        .meetingHistoryList[index].time)),
                                style: AppTextStyles.s14w500
                                    .copyWith(color: AppColors.subText2),
                              ),
                              const Spacer(),
                              Text(
                                l10n.zoom__host,
                                style: AppTextStyles.s14w500
                                    .copyWith(color: AppColors.subText2),
                              ),
                              AppSpacing.gapW8,
                              AppCircleAvatar(
                                url: currentUser.avatarPath ?? '',
                                size: 28,
                              )
                            ],
                          ),
                        ],
                      ).paddingSymmetric(horizontal: 12),
                    ).clickable(() {
                      Get.to(() => JoinMeetingView(
                            idMeeting:
                                controller.meetingHistoryList[index].idMeeting,
                          ));
                    }),
                  ],
                ).paddingOnly(bottom: 16),
              ),
      ),
    ));
  }
}

class GroupButtonItem {
  String title;
  Color color;
  Function onTap;
  Object icon;

  GroupButtonItem(
      {required this.title,
      required this.color,
      required this.onTap,
      required this.icon});
}

class MeetingHistoryItem {
  String userId;
  String idMeeting;
  String time;
  String? type;

  MeetingHistoryItem(
      {required this.userId,
      required this.idMeeting,
      required this.time,
      this.type});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'idMeeting': idMeeting,
      'time': time,
      'type': type
    };
  }

  // Phương thức chuyển đổi từ Map thành đối tượng
  factory MeetingHistoryItem.fromMap(Map<String, dynamic> map) {
    return MeetingHistoryItem(
      userId: map['userId'] ?? '',
      idMeeting: map['idMeeting'] ?? '',
      time: map['time'] ?? '',
      type: map['type'] ?? 'new',
    );
  }
}
