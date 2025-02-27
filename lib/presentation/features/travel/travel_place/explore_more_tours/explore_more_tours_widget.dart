import 'package:flutter/material.dart';

import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';
import 'explore_more_tours_item.dart';

class ExploreMoreToursWidget extends StatelessWidget {
  const ExploreMoreToursWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Explore more tours',
            style: AppTextStyles.s18w700.copyWith(color: Colors.black),
          ),
        ),
        AppSpacing.gapH8,
        SizedBox(
          height: 46,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(
                      left: 20, bottom: 10, right: index == 4 ? 20 : 0),
                  child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.pacificBlue,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: Center(
                        child: Text(
                          'Da Nang',
                          style: AppTextStyles.s14w600
                              .copyWith(color: Colors.white),
                        ),
                      )),
                );
              }),
        ),
        AppSpacing.gapH8,
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Số phần tử trên mỗi hàng
              crossAxisSpacing: 20, // Khoảng cách giữa các cột
              mainAxisSpacing: 10, // Khoảng cách giữa các hàng
              childAspectRatio: 2, // Tỷ lệ giữa chiều rộng và chiều cao
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return const ExploreMoreToursItem();
            },
          ),
        ),
      ],
    );
  }
}
