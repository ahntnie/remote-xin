import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../base/base_view.dart';
import '../../../common_widgets/app_icon.dart';
import '../../../resource/gen/assets.gen.dart';
import '../../../resource/styles/app_colors.dart';
import '../../../resource/styles/gaps.dart';
import '../../../resource/styles/text_styles.dart';
import 'blogs/travel_blogs_widget.dart';
import 'explore_more_tours/explore_more_tours_widget.dart';
import 'on_going_promo/on_going_promo_widget.dart';
import 'tour_on_demand/tour_on_demand_widget.dart';
import 'travel_place_controller.dart';

class TravelPlaceView extends BaseView<TravelPlaceController> {
  const TravelPlaceView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: buildBanner(context),
        ),
        AppSpacing.gapH28,
        const TourOnDemandWidget(),
        AppSpacing.gapH28,
        const OngoingPromoWidget(),
        AppSpacing.gapH28,
        const TourOnDemandWidget(),
        AppSpacing.gapH28,
        const TourOnDemandWidget(),
        AppSpacing.gapH28,
        const ExploreMoreToursWidget(),
        AppSpacing.gapH28,
        const TravelBlogsWidget(),
        AppSpacing.gapH28,
      ],
    );
  }

  Widget buildBanner(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 15, 15),
        height: 200.h,
        decoration: BoxDecoration(
            color: AppColors.label,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border:
                Border.all(color: const Color(0xff63CEFF).withOpacity(0.52))),
        child: Row(
          children: [
            Assets.images.travelPlaceBannerMascot.image(),
            AppSpacing.gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"Explore the world easier with Travelia!”',
                    style: AppTextStyles.s16w700
                        .copyWith(color: AppColors.titleText),
                  ),
                  AppSpacing.gapH8,
                  Expanded(
                    child: Text(
                      'Your smart travel companion will help you plan the perfect trip, from choosing destinations, finding interesting tours, to booking services quickly.',
                      style: AppTextStyles.s12w500
                          .copyWith(color: AppColors.subText),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  AppSpacing.gapH8,
                  Container(
                      decoration: const BoxDecoration(
                        color: AppColors.titleText,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: AppIcon(
                        icon: Assets.icons.travelArrowNext,
                        size: 12,
                      ))
                ],
              ),
            )
          ],
        ));
  }
}
