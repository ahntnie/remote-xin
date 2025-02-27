import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../../modal/live_stream/live_stream.dart';
import '../../../view/live_stream/model/broad_cast_screen_view_model.dart';

class AudienceTopBar extends StatelessWidget {
  final BroadCastScreenViewModel model;
  final LiveStreamUser user;

  const AudienceTopBar({required this.model, required this.user, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppCircleAvatar(
                      url: user.userImage ?? '',
                      size: 40,
                    ),
                    AppSpacing.gapW4,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName ?? '',
                          style: AppTextStyles.s12w600.text2Color
                              .copyWith(fontSize: 13),
                        ).paddingOnly(right: 4),
                        Row(
                          children: [
                            // AppIcon(
                            //   icon: Assets.images.diamond,
                            //   size: 12,
                            // ),
                            AppSpacing.gapW4,
                            Text(
                              (model.liveStreamUser?.collectedDiamond ?? 0)
                                  .toString(),
                              style: AppTextStyles.s12w400
                                  .copyWith(fontSize: 11, color: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    // AppIcon(
                    //   icon: Assets.icons.eye,
                    //   color: Colors.white,
                    //   size: 18,
                    // ),
                    AppSpacing.gapW4,
                    Text(
                      (model.liveStreamUser?.watchingCount ?? 0).toString(),
                      style: AppTextStyles.s14w500.text2Color
                          .copyWith(fontSize: 12),
                    )
                  ],
                ),
              ),
              AppSpacing.gapW8,
              AppIcon(
                icon: Assets.icons.close,
                color: AppColors.white,
                size: 28,
                onTap: model.audienceExit,
              )
            ],
          ).paddingSymmetric(horizontal: 12),
        ],
      ),
    );
    // return Container(
    //   child: Column(
    //     children: [
    //       BlurTab(
    //         height: 65,
    //         radius: 15,
    //         child: Container(
    //           padding: const EdgeInsets.symmetric(horizontal: 10),
    //           child: Row(
    //             children: [
    //               InkWell(
    //                 onTap: () {
    //                   model.onUserTap(context);
    //                 },
    //                 child: ClipOval(
    //                   child: Image.network(
    //                     "${ConstRes.itemBaseUrl}${user.userImage}",
    //                     fit: BoxFit.cover,
    //                     height: 45,
    //                     width: 45,
    //                     errorBuilder: (context, error, stackTrace) {
    //                       return ImagePlaceHolder(
    //                         name: user.fullName,
    //                         heightWeight: 45,
    //                         fontSize: 25,
    //                       );
    //                     },
    //                   ),
    //                 ),
    //               ),
    //               const SizedBox(
    //                 width: 10,
    //               ),
    //               Expanded(
    //                 child: InkWell(
    //                   onTap: () {
    //                     model.onUserTap(context);
    //                   },
    //                   child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     crossAxisAlignment: CrossAxisAlignment.start,
    //                     children: [
    //                       Row(
    //                         children: [
    //                           Text(
    //                             user.fullName ?? '',
    //                             style: const TextStyle(
    //                                 color: ColorRes.white,
    //                                 fontFamily: FontRes.fNSfUiMedium),
    //                           ),
    //                           Visibility(
    //                             visible: user.isVerified ?? false,
    //                             child: Image.asset(
    //                               icVerify,
    //                               height: 15,
    //                               width: 15,
    //                             ),
    //                           )
    //                         ],
    //                       ),
    //                       const SizedBox(
    //                         height: 2,
    //                       ),
    //                       Text(
    //                         '${user.followers ?? 0} ${LKey.followers.tr}',
    //                         style: TextStyle(
    //                             color: ColorRes.white.withOpacity(0.5),
    //                             fontFamily: FontRes.fNSfUiMedium),
    //                       ),
    //                     ],
    //                   ),
    //                 ),
    //               ),
    //               InkWell(
    //                 onTap: () {
    //                   showModalBottomSheet(
    //                     context: context,
    //                     builder: (context) => ReportScreen(2, '${user.userId}'),
    //                     isScrollControlled: true,
    //                     backgroundColor: Colors.transparent,
    //                   );
    //                 },
    //                 child: Image.asset(
    //                   icMenu,
    //                   height: 20,
    //                   width: 20,
    //                   color: ColorRes.white,
    //                 ),
    //               ),
    //               const SizedBox(
    //                 width: 10,
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //       const SizedBox(
    //         height: 5,
    //       ),
    //       BlurTab(
    //         height: 40,
    //         child: Row(
    //           children: [
    //             const SizedBox(
    //               width: 10,
    //             ),
    //             Image.asset(
    //                 Provider.of<MyLoading>(context).isDark
    //                     ? icLogo
    //                     : icLogoLight,
    //                 height: 20),
    //             const Text(
    //               ' LIVE',
    //               style: TextStyle(
    //                   fontFamily: FontRes.fNSfUiSemiBold,
    //                   fontSize: 16,
    //                   color: ColorRes.white),
    //             ),
    //             const Spacer(),
    //             Text(
    //               "${NumberFormat.compact(locale: 'en').format(double.parse('${model.liveStreamUser?.watchingCount ?? '0'}'))} Viewers",
    //               style: const TextStyle(
    //                   fontFamily: FontRes.fNSfUiRegular,
    //                   fontSize: 15,
    //                   color: ColorRes.white),
    //             ),
    //             const Spacer(),
    //             InkWell(
    //               onTap: model.audienceExit,
    //               child: Row(
    //                 children: [
    //                   Image.asset(
    //                     exit,
    //                     height: 20,
    //                     width: 20,
    //                     color: ColorRes.white,
    //                   ),
    //                   const SizedBox(
    //                     width: 10,
    //                   ),
    //                   const Text(
    //                     'Exit',
    //                     style: TextStyle(
    //                         fontSize: 15,
    //                         color: ColorRes.white,
    //                         fontFamily: FontRes.fNSfUiMedium),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             const SizedBox(
    //               width: 10,
    //             ),
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
