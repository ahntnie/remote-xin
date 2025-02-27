import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/all.dart';
import '../../base/base_view.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import '../../routing/routing.dart';
import 'travel_controller.dart';
import 'travel_place/travel_place_view.dart';

class TravelView extends BaseView<TravelController> {
  const TravelView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return RefreshIndicator(
      color: const Color.fromRGBO(14, 168, 255, 1),
      backgroundColor: Colors.white,
      onRefresh: () async {
        // return controller.onRefreshNewsfeed();
      },
      child: CustomScrollView(
        // physics: const BouncingScrollPhysics(),
        // controller: controller.scrollController,
        slivers: [
          const SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            title: AppLogo(),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildYourLocation(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: AppSpacing.edgeInsetsAll20,
              child: _buildOption(context),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildYourLocation(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/proxy/sge-fK0sytl3pozcChXcUwHgmaadzYJInHn-WxYuEND8IBJVvPWA9te0ZJmbVOcZde6URzsbHyF2ewJNCRn1BIk4oKYzqqSOR0JsnQ_eubw_C_POqGUZcw'), // Đường dẫn tới ảnh nền của bạn
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your current Location',
                style: AppTextStyles.s14w600,
              ),
              AppSpacing.gapH12,
              Text(
                'Vietnam',
                style: AppTextStyles.s20w700,
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xffD9EFF9),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                AppIcon(
                  icon: Assets.icons.travelLocation,
                  size: 20,
                  color: const Color(0xff008BCB),
                ),
                AppSpacing.gapW4,
                Text(
                  'See Other Destinations',
                  style: AppTextStyles.s14w600.copyWith(
                    color: const Color(0xff008BCB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).clickable(() {
      Get.toNamed(Routes.travelLocation);
    });
  }

  Widget _buildOption(BuildContext context) {
    return Container(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        optionItem(
          icon: Assets.icons.travelPlace,
          title: 'Travel Place',
          onTap: () {},
          index: 0,
          currentIndex: 0,
        ),
        optionItem(
          icon: Assets.icons.travelTourGuide,
          title: 'Tour Guide',
          onTap: () {},
          index: 1,
          currentIndex: 0,
        ),
        optionItem(
          icon: Assets.icons.travelHotel,
          title: 'Hotels',
          onTap: () {},
          index: 2,
          currentIndex: 0,
        ),
        optionItem(
          icon: Assets.icons.travelRestaurant,
          title: 'Restaurants',
          onTap: () {},
          index: 3,
          currentIndex: 0,
        ),
      ],
    ));
  }

  Widget optionItem({
    required Object icon,
    required String title,
    required Function onTap,
    required int index,
    required int currentIndex,
  }) {
    return Column(
      children: [
        AppIcon(
          icon: icon,
          color: (index == currentIndex) ? AppColors.pacificBlue : Colors.black,
        ),
        AppSpacing.gapH8,
        Text(
          title,
          style: AppTextStyles.s14w600.copyWith(
            color:
                (index == currentIndex) ? AppColors.pacificBlue : Colors.black,
          ),
        )
      ],
    ).clickable(() {
      onTap();
    });
  }

  Widget _buildBody(BuildContext context) {
    return const TravelPlaceView();
  }
}
