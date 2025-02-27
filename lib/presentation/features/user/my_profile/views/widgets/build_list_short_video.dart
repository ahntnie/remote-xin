import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/user.dart';
import '../../../../../common_widgets/app_icon.dart';
import '../../../../../resource/resource.dart';
import '../../../../short_video/view/profile/profile_video_screen.dart';

/// Widget for rendering list of short videos
///
/// [scrollController] is the controller for the scroll view
///
/// [pageController] is the controller for the page view
///
/// [currentUser] is the user object with type [User], which contains user information
class BuildListShortVideo extends StatefulWidget {
  final ScrollController scrollController;
  final PageController pageController;
  final User currentUser;

  const BuildListShortVideo(
      {required this.scrollController,
      required this.pageController,
      required this.currentUser,
      super.key});

  @override
  State<BuildListShortVideo> createState() => _BuildListShortVideoState();
}

class _BuildListShortVideoState extends State<BuildListShortVideo> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 0.58.sh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: widget.scrollController,
            slivers: [
              // SliverPersistentHeader(
              //   delegate: SliverAppBarDelegate(),
              // ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AppSpacing.gapH8,
                    const Divider(
                      color: AppColors.grey10,
                      height: 0.5,
                      thickness: 0.5,
                    ).paddingSymmetric(horizontal: 20),
                    AppSpacing.gapH12,
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: index == 0
                                ? AppColors.grey7
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              AppIcon(
                                icon: index == 0
                                    ? Assets.icons.addVideoFill
                                    : Assets.icons.addVideoOutline,
                                color: Colors.black,
                                size: 18,
                              ),
                              AppSpacing.gapW8,
                              Text(
                                context.l10n.text_posted,
                                style: AppTextStyles.s14w400.text2Color,
                              )
                            ],
                          ),
                        ).clickable(() {
                          setState(() {
                            index = 0;
                          });
                        }),
                        AppSpacing.gapW12,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: index == 1
                                ? AppColors.grey7
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              AppIcon(
                                icon: index == 1
                                    ? Assets.icons.heartFillShort
                                    : Assets.icons.heartProfile,
                                color: Colors.black,
                                size: 18,
                              ),
                              AppSpacing.gapW8,
                              Text(
                                context.l10n.text_liked,
                                style: AppTextStyles.s14w400.text2Color,
                              )
                            ],
                          ),
                        ).clickable(() {
                          setState(() {
                            index = 1;
                          });
                        }),
                        AppSpacing.gapW12,
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: index == 2
                                ? AppColors.grey7
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            children: [
                              AppIcon(
                                icon: index == 2
                                    ? Assets.icons.bookmarkFill
                                    : Assets.icons.bookmarkOutline,
                                color: Colors.black,
                                size: 18,
                              ),
                              AppSpacing.gapW8,
                              Text(
                                context.l10n.global__saved_label,
                                style: AppTextStyles.s14w400.text2Color,
                              )
                            ],
                          ),
                        ).clickable(() {
                          setState(() {
                            index = 2;
                          });
                        }),
                      ],
                    ).paddingOnly(left: 20),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 0.5.sh,
                  child: Container(
                    color: AppColors.white,
                    child: ProfileVideoScreen(
                      index,
                      widget.currentUser.id,
                      true,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
