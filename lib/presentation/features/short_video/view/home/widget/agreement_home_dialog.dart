import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../languages/languages_keys.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../webview/webview_screen.dart';

class AgreementHomeDialog extends StatelessWidget {
  const AgreementHomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => PopScope(
        canPop: false,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 55),
            backgroundColor: Colors.transparent,
            child: AspectRatio(
              aspectRatio: 1 / 1.2,
              child: Container(
                decoration: const BoxDecoration(
                  color: ColorRes.colorPrimaryDark,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      LKey.pleaseAccept.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: FontRes.fNSfUiSemiBold,
                        decoration: TextDecoration.none,
                        color: ColorRes.white,
                      ),
                    ),
                    const Spacer(),
                    Image(
                      image:
                          AssetImage(myLoading.isDark ? icLogo : icLogoLight),
                      height: 70,
                    ),
                    const Spacer(),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        LKey.pleaseCheckThesePrivacyEtc.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: FontRes.fNSfUiLight,
                          decoration: TextDecoration.none,
                          color: ColorRes.colorTextLight,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WebViewScreen(2),
                                ));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              LKey.termsConditions.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: FontRes.fNSfUiLight,
                                decoration: TextDecoration.none,
                                color: ColorRes.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 20,
                          width: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          color: ColorRes.white.withOpacity(0.5),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WebViewScreen(3),
                                ));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              LKey.privacyPolicy.tr,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: FontRes.fNSfUiLight,
                                decoration: TextDecoration.none,
                                color: ColorRes.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        myLoading.setIsHomeDialogOpen(false);
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 55,
                        decoration: const BoxDecoration(
                          color: ColorRes.colorPrimary,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)),
                        ),
                        child: Center(
                          child: Text(
                            LKey.accept.tr,
                            style: const TextStyle(
                                fontSize: 14,
                                fontFamily: FontRes.fNSfUiLight,
                                decoration: TextDecoration.none),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
