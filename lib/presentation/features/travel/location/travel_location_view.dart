import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../base/base_view.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../../../routing/routers/app_pages.dart';
import '../travel_place/explore_more_tours/explore_more_tours_widget.dart';
import 'travel_location_controller.dart';

class TravelLocationView extends BaseView<TravelLocationController> {
  const TravelLocationView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        leadingIconColor: Colors.black,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your location',
              style: AppTextStyles.s14w600.copyWith(color: AppColors.grey10),
            ),
            AppSpacing.gapH4,
            Row(
              children: [
                AppIcon(
                  icon: Assets.icons.travelLocation,
                  color: AppColors.reacted,
                ),
                AppSpacing.gapW8,
                Text(
                  'Viet Nam',
                  style: AppTextStyles.s16w600.copyWith(color: AppColors.text2),
                ),
              ],
            )
          ],
        ),
        centerTitle: false,
        actions: [
          AppIcon(
            icon: Assets.icons.callFill,
            color: Colors.black,
          ).clickable(() {
            Get.toNamed(Routes.travelLocationFilter);
          }),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.gapH12,
          _buildSearchWidget(context),
          AppSpacing.gapH12,
          _buildRecentlyFeaturedWidget(context),
          AppSpacing.gapH24,
          const ExploreMoreToursWidget(),
        ],
      ),
    );
  }

  Widget _buildSearchWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: AppColors.grey6,
        borderRadius: BorderRadius.circular(42),
      ),
      child: Row(
        children: [
          AppIcon(
            icon: Assets.icons.searchIcon,
            color: AppColors.grey10,
          ),
          AppSpacing.gapW8,
          Expanded(
            child: Text(
              'Search for country, region, city or area',
              style: AppTextStyles.s16w400.copyWith(color: AppColors.grey10),
            ),
          ),
        ],
      ),
    ).marginSymmetric(horizontal: 20);
  }

  Widget _buildRecentlyFeaturedWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Recently Featured',
            style: AppTextStyles.s18w700.copyWith(color: Colors.black),
          ),
        ),
        AppSpacing.gapH8,
        Wrap(
          spacing: 10, // Horizontal space between items
          runSpacing: 10, // Vertical space between items
          children: List.generate(
            5,
            (index) {
              return IntrinsicWidth(
                child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.labelTravelUnSelected,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(999)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                              0.12), // Màu bóng #000000 với độ mờ 12%
                          offset: const Offset(2, 2), // X = 2, Y = 2
                          blurRadius: 4, // Độ mờ là 4
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Center(
                      child: Text(
                        'Da Nang',
                        style: AppTextStyles.s14w600
                            .copyWith(color: AppColors.titleText),
                      ),
                    )),
              );
            },
          ),
        ).paddingSymmetric(horizontal: 20),
      ],
    );
  }
}
