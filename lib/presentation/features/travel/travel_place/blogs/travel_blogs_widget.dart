import 'package:flutter/material.dart';

import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';
import 'travel_blogs_item.dart';

class TravelBlogsWidget extends StatelessWidget {
  const TravelBlogsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'Blogs',
            style: AppTextStyles.s18w700.copyWith(color: Colors.black),
          ),
        ),
        AppSpacing.gapH16,
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Số phần tử trên mỗi hàng
              crossAxisSpacing: 20, // Khoảng cách giữa các cột
              mainAxisSpacing: 20, // Khoảng cách giữa các hàng
              childAspectRatio: 0.65, // Tỷ lệ giữa chiều rộng và chiều cao
            ),
            itemCount: 8,
            itemBuilder: (context, index) {
              return const TravelBlogsItem();
            },
          ),
        ),
      ],
    );
  }
}
