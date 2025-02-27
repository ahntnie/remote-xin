import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common_widgets/app_icon.dart';
import '../../../../resource/gen/assets.gen.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';

class OngoingPromoItem extends StatelessWidget {
  const OngoingPromoItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (1.sw - 20 * 3) / 2,
      height: 286,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.12), // Màu bóng #000000 với độ mờ 12%
            offset: const Offset(2, 2), // X = 2, Y = 2
            blurRadius: 4, // Độ mờ là 4
          ),
        ],
      ),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/proxy/sge-fK0sytl3pozcChXcUwHgmaadzYJInHn-WxYuEND8IBJVvPWA9te0ZJmbVOcZde6URzsbHyF2ewJNCRn1BIk4oKYzqqSOR0JsnQ_eubw_C_POqGUZcw'), // Đường dẫn tới ảnh nền của bạn
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                    top: 8,
                    right: 8,
                    child: AppIcon(
                      icon: Assets.icons.travelBookmark,
                    )),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Da Nang City and Hoi An Ancient Town',
                    style: AppTextStyles.s14w600.copyWith(color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.gapH4,
                  Row(
                    children: [
                      AppIcon(
                        icon: Assets.icons.travelStar,
                        color: const Color(0xffFFD600),
                        size: 14,
                      ),
                      AppSpacing.gapW2,
                      Text(
                        '4.5/5.0',
                        style: AppTextStyles.s12w600
                            .copyWith(color: AppColors.pacificBlue),
                      ),
                      AppSpacing.gapW2,
                      Text(
                        '(2003)',
                        style: AppTextStyles.s12w400
                            .copyWith(color: AppColors.zambezi),
                      )
                    ],
                  ),
                  AppSpacing.gapH4,
                  Text(
                    '\$ 200.00',
                    style: AppTextStyles.s14w400
                        .copyWith(color: AppColors.zambezi),
                  ),
                  AppSpacing.gapH4,
                  Text(
                    '\$ 170.00',
                    style: AppTextStyles.s18w700
                        .copyWith(color: const Color(0xff22B630)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
