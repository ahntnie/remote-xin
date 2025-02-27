import 'package:flutter/material.dart';

import '../../../../resource/resource.dart';

class ProfileCardWidget extends StatelessWidget {
  final String xinId;
  final String userName;
  final String email;
  final String phoneNumber;
  const ProfileCardWidget({
    required this.xinId,
    required this.userName,
    required this.email,
    required this.phoneNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FittedBox(
          fit: BoxFit.fill,
          child: Assets.images.cardBackgroundColorNormal.image(),
        ),
        FittedBox(
          fit: BoxFit.fill,
          child: Assets.images.cardBackgroundNormal.image(),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Assets.images.cardLogoNormal.image(width: 50),
        ),
        Positioned(
            top: 10,
            left: 10,
            child: Column(
              children: [
                Text(
                  'XINTEL',
                  style: AppTextStyles.s24w700
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Assets.images.cardIconNormal.image(width: 120),
              ],
            )),
        Positioned(
          bottom: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (xinId.isNotEmpty)
                GradientText(
                  'XIN ID: $xinId',
                  style: AppTextStyles.s16w700,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffFFFFFF),
                      Color(0xffB8B8B8),
                      Color(0xffFFFFFF),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              // Text(
              //   'XIN ID: $xinId',
              //   style: AppTextStyles.s18w700,
              // ),
              Text('@$userName', style: AppTextStyles.s14w400),
              // Text(email, style: AppTextStyles.s14w400),
              GradientText(
                phoneNumber,
                style: AppTextStyles.s16w700,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xffFFFFFF),
                    Color(0xffB8B8B8),
                    Color(0xffFFFFFF),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    super.key,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
