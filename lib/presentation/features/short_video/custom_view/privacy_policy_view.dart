import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_res.dart';
import '../utils/colors.dart';
import '../utils/const_res.dart';
import '../utils/font_res.dart';
import '../utils/my_loading/my_loading.dart';
import '../view/webview/webview_screen.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: RichText(
          text: TextSpan(
              text: AppRes.policy1,
              style: const TextStyle(
                  color: ColorRes.colorTextLight,
                  fontSize: 12,
                  fontFamily: FontRes.fNSfUiLight,
                  height: 1.5),
              children: [
                const TextSpan(
                  text: '$appName\'s ',
                  style: TextStyle(
                    color: ColorRes.colorTextLight,
                    fontSize: 12,
                    fontFamily: FontRes.fNSfUiLight,
                  ),
                ),
                TextSpan(
                  text: AppRes.policy2,
                  style: TextStyle(
                    color: !myLoading.isDark
                        ? ColorRes.colorPink
                        : ColorRes.greyShade100,
                    fontSize: 12,
                    fontFamily: FontRes.fNSfUiBold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewScreen(2),
                          ),
                        ),
                ),
                const TextSpan(
                  text: AppRes.policy3,
                  style: TextStyle(
                    color: ColorRes.colorTextLight,
                    fontSize: 12,
                    fontFamily: FontRes.fNSfUiLight,
                  ),
                ),
                TextSpan(
                  text: AppRes.policy4,
                  style: TextStyle(
                    color: !myLoading.isDark
                        ? ColorRes.colorPink
                        : ColorRes.greyShade100,
                    fontSize: 12,
                    fontFamily: FontRes.fNSfUiBold,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewScreen(3),
                          ),
                        ),
                )
              ]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
