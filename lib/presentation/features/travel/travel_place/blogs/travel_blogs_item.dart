import 'package:flutter/material.dart';

import '../../../../common_widgets/all.dart';
import '../../../../resource/gen/assets.gen.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';

class TravelBlogsItem extends StatelessWidget {
  const TravelBlogsItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/proxy/sge-fK0sytl3pozcChXcUwHgmaadzYJInHn-WxYuEND8IBJVvPWA9te0ZJmbVOcZde6URzsbHyF2ewJNCRn1BIk4oKYzqqSOR0JsnQ_eubw_C_POqGUZcw'), // Đường dẫn tới ảnh nền của bạn
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: SizedBox(
                  width: double
                      .infinity, // Đảm bảo text chiếm hết chiều rộng của parent
                  child: Text(
                    'Exploring Unique Cultures and Stunning Sights',
                    style: AppTextStyles.s12w700.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.gapH8,
          Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://lh3.googleusercontent.com/proxy/sge-fK0sytl3pozcChXcUwHgmaadzYJInHn-WxYuEND8IBJVvPWA9te0ZJmbVOcZde6URzsbHyF2ewJNCRn1BIk4oKYzqqSOR0JsnQ_eubw_C_POqGUZcw'), // Đường dẫn tới ảnh nền của bạn
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              AppSpacing.gapW8,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quinn Bailey',
                    style: AppTextStyles.s12w700
                        .copyWith(fontSize: 10, color: Colors.black),
                  ),
                  Text(
                    '3 hours ago',
                    style: AppTextStyles.s12w400
                        .copyWith(fontSize: 10, color: AppColors.zambezi),
                  ),
                ],
              ),
              const Spacer(),
              AppIcon(
                icon: Assets.icons.travelEyes,
                color: AppColors.zambezi,
                size: 16,
              ),
              AppSpacing.gapW4,
              Text(
                '25.9K',
                style: AppTextStyles.s12w600.copyWith(color: AppColors.zambezi),
              ),
            ],
          )
        ],
      ),
    );
  }
}
