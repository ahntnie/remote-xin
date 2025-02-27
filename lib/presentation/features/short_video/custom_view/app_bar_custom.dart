import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widgets/all.dart';
import '../../../resource/gen/assets.gen.dart';
import '../utils/colors.dart';
import '../utils/font_res.dart';
import '../utils/my_loading/my_loading.dart';

class AppBarCustom extends StatelessWidget {
  final String title;

  const AppBarCustom({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MyLoading>(
      builder: (context, value, child) => Container(
        color: ColorRes.white,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: AppIcon(
                        onTap: () => Get.back(),
                        icon: Assets.icons.arrowLeft,
                        color: Colors.black,
                      )).paddingSymmetric(horizontal: 20, vertical: 12),
                  const Text(
                    'Preview',
                    style: TextStyle(
                        fontSize: 20,
                        fontFamily: FontRes.fNSfUiMedium,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              height: 0.3,
              color: value.isDark
                  ? ColorRes.colorTextLight
                  : ColorRes.colorPrimaryDark,
            ),
          ],
        ),
      ),
    );
  }
}
