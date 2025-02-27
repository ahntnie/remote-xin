import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

import '../../../../../core/all.dart';
import '../../../../../models/user.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../common_widgets/status_view.dart';
import '../../../../resource/resource.dart';
import '../../../../routing/routers/app_pages.dart';
import '../../../call_gateway/call_history/call_history_body.dart';
import '../../../call_gateway/call_history/call_history_controller.dart';
import '../../../call_gateway/contact/contact_body.dart';
import '../../../call_gateway/contact/contact_controller.dart';
import '../../../search_user/all.dart';
import '../controllers/dashboard_controller.dart';
// import 'widgets/_archived_item.dart';
import 'widgets/_archived_item.dart';
import 'widgets/_conversation_item.dart';
import 'widgets/shimmer_loading_conversation.dart';

class ChatDashboardView extends BaseView<ChatDashboardController> {
  const ChatDashboardView({super.key});

  @override
  bool get allowLoadingIndicator => true;

  @override
  Widget buildPage(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.deepSkyBlue,
      backgroundColor: Colors.white,
      onRefresh: () {
        controller.isLoadingInit.value = true;

        return controller.onRefresh();
      },
      child: CommonScaffold(
        isRemoveBottomPadding: true,
        body: SlidableAutoCloseBehavior(
          child: Obx(
            () {
              if (controller.isLoadingInit.value) {
                return Padding(
                  padding: AppSpacing.edgeInsetsOnlyTop8,
                  child: ListView.builder(
                    itemCount: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return const ShimmerLoadingConversation();
                    },
                  ),
                );
              }
              // if (controller.conversations.isEmpty) {
              //   return _buildNoMessageWidget(context);
              // }
              return Obx(() {
                final conversations = controller.conversations;
                final hasArchived = controller.archivedConversations.isNotEmpty;
                return SmoothListView.builder(
                  duration: const Duration(milliseconds: 200),
                  itemCount: conversations.length + 1 + (hasArchived ? 1 : 0),
                  cacheExtent: 1.sh * 3,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return RepaintBoundary(
                        child: Padding(
                          padding: AppSpacing.edgeInsetsH20,
                          child: Column(
                            children: [
                              AppSpacing.gapH16,
                              searchWidget(context),
                              AppSpacing.gapH12,
                              SizedBox(
                                height: 90,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.userStorys.length + 1,
                                  itemBuilder: (context, index) => Padding(
                                    padding: EdgeInsets.only(
                                        left: index == 0
                                            ? 0
                                            : controller
                                                        .getUserStory(index)
                                                        .userId !=
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
                                                  child: Obx(
                                                    () => Container(
                                                      padding: EdgeInsets.all(
                                                          controller.getMyStory() ==
                                                                  null
                                                              ? 0
                                                              : 0.5),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                              width: 3,
                                                              color: controller
                                                                          .getMyStory() ==
                                                                      null
                                                                  ? AppColors
                                                                      .grey6
                                                                  : AppColors
                                                                      .blue10)),
                                                      child: AppCircleAvatar(
                                                        url: controller
                                                                .currentUser
                                                                .avatarPath ??
                                                            '',
                                                        size: 57,
                                                      ),
                                                    ).clickable(() {
                                                      if (controller
                                                              .getMyStory() !=
                                                          null) {
                                                        Get.toNamed(
                                                            Routes.storyPage,
                                                            arguments: {
                                                              'user': controller
                                                                  .getMyStory(),
                                                              'userStorys':
                                                                  controller
                                                                      .listUserStorys,
                                                              'index': controller
                                                                  .getIndexMyStory(),
                                                            });
                                                      } else {
                                                        Get.toNamed(
                                                            Routes.createStory);
                                                      }
                                                    }),
                                                  ),
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
                                                            color: AppColors
                                                                .white)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2),
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
                                        : controller
                                                    .getUserStory(index)
                                                    .userId !=
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
                                                    unSeenColor:
                                                        AppColors.blue10,
                                                  ).clickable(() {
                                                    Get.toNamed(
                                                        Routes.storyPage,
                                                        arguments: {
                                                          'user': controller
                                                              .getUserStory(
                                                                  index),
                                                          'userStorys': controller
                                                              .listUserStorys,
                                                          'index': index - 1,
                                                        });
                                                  }),
                                                  const Spacer(),
                                                  Text(
                                                    controller
                                                            .getUserStory(index)
                                                            .name ??
                                                        '',
                                                    style: AppTextStyles
                                                        .s14w600.text2Color,
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (hasArchived && index == 1) {
                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 8),
                          child: ArchivedItem(
                            controller: controller,
                          ),
                        ),
                      );
                    }

                    final conversation =
                        conversations[hasArchived ? index - 2 : index - 1];

                    return RepaintBoundary(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: ConversationItem(
                          key: ValueKey(conversation.id),
                          conversation: conversation,
                          controller: controller,
                        ),
                      ),
                    );
                  },
                );
              });
            },
          ),
        ),
      ),
    ).clickable(() {
      controller.isSearching.value = false;
    });
  }

  Widget searchWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: AppSpacing.edgeInsetsAll8,
            decoration: BoxDecoration(
              color: AppColors.grey6,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    icon: AppIcons.search,
                    color: AppColors.grey8,
                  ),
                  AppSpacing.gapW8,
                  Text(
                    context.l10n.global__search,
                    style:
                        AppTextStyles.s16w400.copyWith(color: AppColors.grey8),
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

  Widget _buildNoMessageWidget(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.deepSkyBlue,
      backgroundColor: Colors.white,
      onRefresh: controller.onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.edgeInsetsH32.copyWith(top: 0.2.sh),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon: AppIcons.chat,
              size: 80.w,
              color: AppColors.zambezi,
            ),
            AppSpacing.gapH12,
            Text(
              context.l10n.chat__no_message_title,
              style: AppTextStyles.s16w500.toColor(AppColors.subText2),
              textAlign: TextAlign.center,
            ),
            AppSpacing.gapH4,
            Text(
              context.l10n.chat__no_message_message,
              style: AppTextStyles.s12w400.subText2Color,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      decelerationRate: ScrollDecelerationRate.fast,
      parent: AlwaysScrollableScrollPhysics(),
    );
  }
}

// ignore: prefer-single-widget-per-file
class ChatDashBoardAppBar extends CommonAppBar {
  ChatDashBoardAppBar({super.key});

  void _onSearchPressed() {
    Get.toNamed(Routes.search, arguments: {'type': 'chat'});
  }

  void _onCreateConversationPressed(BuildContext context) {
    final controller = Get.find<ChatDashboardController>();
    ViewUtil.showBottomSheet<List<User>>(
      isScrollControlled: true,
      isFullScreen: true,
      child: const CreateChatSearchUsersBottomSheet(),
    ).then(
      (selectedUsers) {
        if (selectedUsers != null) {
          controller.createConversationAndGotoChatHub(selectedUsers);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      // automaticallyImplyLeading: false,
      // automaticallyImplyLeading: !isHomePage,
      titleWidget: const AppLogo(),
      leadingIconColor: AppColors.pacificBlue,
      leadingIcon: LeadingIcon.none,
      automaticallyImplyLeading: false,
      centerTitle: false,
      backgroundColor: Colors.white,
      actions: [
        // Obx(
        //   () => controller.isSearching.value
        //       ? AppSpacing.emptyBox
        //       : AppIcon(
        //           padding: AppSpacing.edgeInsetsAll12,
        //           icon: AppIcons.search,
        //           onTap: _onSearchPressed,
        //           color: AppColors.pacificBlue,
        //         ),
        // ),

        _buildIcon(
            icon: Assets.icons.zoomIcon,
            onTap: () {
              Get.toNamed(Routes.XINMeeting);
            }),
        AppSpacing.gapW8,

        _buildIcon(
          icon: Assets.icons.contact,
          onTap: () {
            // Get.find<ContactController>().getUserContacts();
            Get.lazyPut<ContactController>(() => ContactController());
            Get.to(() => const ContactBody());
          },
        ),
        AppSpacing.gapW8,
        _buildIcon(
          icon: Assets.icons.chatHistory,
          onTap: () {
            // Get.find<CallHistoryController>()
            //     .allHistoryPagingController
            //     .refresh();
            Get.put<CallHistoryController>(CallHistoryController());
            Get.to(() => const CallHistoryBody());
          },
        ),
        AppSpacing.gapW8,
        _buildIcon(
          icon: AppIcons.plus,
          onTap: () {
            _onCreateConversationPressed(context);
          },
        ),
      ],
    );
  }

  Widget _buildIcon({
    required SvgGenImage icon,
    required Function() onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(Sizes.s8),
      decoration: const BoxDecoration(
        color: AppColors.grey6,
        shape: BoxShape.circle,
      ),
      child: AppIcon(
        icon: icon,
        color: Colors.black,
      ),
    ).clickable(() {
      onTap();
    });
  }

// Widget _buildTitleWidget(BuildContext context) {
//   final controller = Get.find<ChatDashboardController>();

//   return Obx(
//     () {
//       if (controller.isSearching.value) {
//         return CustomSearchBar(
//           onChanged: (value) {
//             controller.filterConversations(value);
//           },
//           onClear: () {
//             controller.clearSearch();
//           },
//         );
//       }

//       return SlidingSwitch(
//         value: controller.showGroupConversations.value,
//         textOn: context.l10n.chat__group_label,
//         textOff: context.l10n.chat__private_label,
//         colorOn: AppColors.white,
//         colorOff: AppColors.white,
//         inactiveColor: AppColors.text4,
//         contentSize: 14,
//         width: 184.w,
//         height: 55.h,
//         onChanged: (value) {
//           controller.updateShowGroupConversations(value);
//         },
//         onTap: () {},
//         onSwipe: () {},
//       );
//     },
//   );
// }
}
