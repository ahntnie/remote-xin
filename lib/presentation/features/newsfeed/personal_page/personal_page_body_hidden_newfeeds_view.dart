// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';

// import '../../../base/all.dart';
// import '../../../common_widgets/all.dart';
// import '../../../resource/resource.dart';
// import 'personal_page_hidden_newfeed_controller.dart';
// import 'widgets/_personal_shared_link.dart';
// import 'widgets/mana_mission_widget.dart';

// class PersonalPageHiddenNewfeedView
//     extends BaseView<PersonalPageHiddenNewfeedController> {
//   const PersonalPageHiddenNewfeedView({super.key});

//   @override
//   Widget buildPage(BuildContext context) {
//     return Obx(
//       () => RefreshIndicator(
//         onRefresh: () async {
//           await controller.onRefreshPostPersonalPage();
//         },
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           controller: controller.scroll,
//           slivers: [
//             SliverAppBar(
//               automaticallyImplyLeading: false,
//               expandedHeight: 395.h,
//               backgroundColor: Colors.transparent,
//               flexibleSpace: const FlexibleSpaceBar(
//                 background: ManaMissionWidget(),
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: controller.isLoadingLoadMore.value
//                   ? const Center(
//                       child: AppDefaultLoading(
//                         color: AppColors.white,
//                       ),
//                     )
//                   : const SizedBox.shrink(),
//             ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: AppSpacing.edgeInsetsAll16,
//                 child: InviteChatLinkAndRefID(
//                   controller: controller,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoPostsFound() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         AppIcon(
//           icon: AppIcons.news,
//           size: Sizes.s128,
//         ),
//         Text(
//           l10n.newsfeed__no_posts_found,
//           style: AppTextStyles.s16w500,
//         ),
//       ],
//     );
//   }
// }
