import 'package:flutter/material.dart';

import '../../../../resource/gen/assets.gen.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';

class OngoingPromoWidget extends StatelessWidget {
  const OngoingPromoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            'On-going promo',
            style: AppTextStyles.s18w700.copyWith(color: Colors.black),
          ),
        ),
        AppSpacing.gapH8,
        SizedBox(
          height: 165,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsets.only(
                      left: 20, bottom: 10, right: index == 4 ? 20 : 0),
                  child:
                      Assets.images.travelOnGoingPromoCard.image(height: 165),
                );
              }),
        ),
      ],
    );
  }
}
