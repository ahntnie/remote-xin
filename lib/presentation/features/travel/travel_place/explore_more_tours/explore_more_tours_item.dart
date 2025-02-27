import 'package:flutter/material.dart';

import '../../../../resource/styles/text_styles.dart';

class ExploreMoreToursItem extends StatelessWidget {
  const ExploreMoreToursItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            image: const DecorationImage(
              image: NetworkImage(
                  'https://lh3.googleusercontent.com/proxy/sge-fK0sytl3pozcChXcUwHgmaadzYJInHn-WxYuEND8IBJVvPWA9te0ZJmbVOcZde6URzsbHyF2ewJNCRn1BIk4oKYzqqSOR0JsnQ_eubw_C_POqGUZcw'), // Đường dẫn tới ảnh nền của bạn
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        Positioned(
          child: Text(
            'Da Lat',
            style: AppTextStyles.s14w700,
          ),
        ),
      ],
    );
  }
}
