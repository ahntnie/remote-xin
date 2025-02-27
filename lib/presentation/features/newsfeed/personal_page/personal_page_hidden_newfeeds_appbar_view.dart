// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';

// import '../../../../core/all.dart';
// import '../../../common_widgets/all.dart';
// import '../../../resource/gen/assets.gen.dart';
// import '../../../resource/styles/app_colors.dart';
// import '../../../resource/styles/gaps.dart';
// import '../../../resource/styles/text_styles.dart';
// import '../../../routing/routing.dart';
// import 'personal_page_hidden_newfeed_controller.dart';

// class PersonalPageHiddenNewfeedsAppBarView extends CommonAppBar {
//   PersonalPageHiddenNewfeedsAppBarView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<PersonalPageHiddenNewfeedController>(
//       init: Get.find<PersonalPageHiddenNewfeedController>(),
//       builder: (controller) {
//         return CommonAppBar(
//           backgroundColor: const Color(0xff226EA6),
//           automaticallyImplyLeading: false,
//           titleType: AppBarTitle.none,
//           centerTitle: false,
//           flexibleSpace: Container(
//             padding: EdgeInsets.only(
//               left: Sizes.s20,
//               right: Sizes.s20,
//               top: Sizes.s44.h,
//             ),
//             child: Obx(
//               () => Row(
//                 children: [
//                   AppCircleAvatar(
//                     url: controller.currentUserRx.value?.avatarPath ?? '',
//                   ),
//                   AppSpacing.gapW12,
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         (controller.currentUserRx.value?.nickname ?? '')
//                                 .isNotEmpty
//                             ? controller.currentUserRx.value?.nickname ?? ''
//                             : controller.currentUserRx.value?.fullName ?? '',
//                         style: AppTextStyles.s18w600.copyWith(fontSize: 18.sp),
//                       ),
//                       Text(
//                         controller.phoneNumber.value,
//                         style: AppTextStyles.s14w600.copyWith(
//                           fontSize: 14.sp,
//                           color: AppColors.subText2,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Expanded(child: SizedBox.shrink()),
//                   _buildIcon(
//                     icon: AppIcons.edit,
//                     onTap: () {
//                       Get.toNamed(
//                         Routes.profile,
//                         arguments: {'isUpdateProfileFirstLogin': false},
//                       );
//                     },
//                   ),
//                   AppSpacing.gapW12,
//                   _buildIcon(
//                     icon: AppIcons.setting,
//                     onTap: () {
//                       Get.toNamed(Routes.setting);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildIcon({
//     required SvgGenImage icon,
//     required Function() onTap,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(Sizes.s12),
//       decoration: const BoxDecoration(
//         color: AppColors.fieldBackground,
//         shape: BoxShape.circle,
//       ),
//       child: AppIcon(
//         icon: icon,
//       ),
//     ).clickable(() {
//       onTap();
//     });
//   }
// }
