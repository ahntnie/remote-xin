import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/extensions/all.dart';
import '../resource/styles/gaps.dart';
import 'app_icon.dart';

class DisabledDialogWrapper extends StatelessWidget {
  final Widget child;
  final Key? dismissibleKey;

  const DisabledDialogWrapper({
    required this.child,
    this.dismissibleKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 1.sw,
            height: 1.sh,
          ).clickable(Get.back),
          Center(
            child: Dismissible(
              key: dismissibleKey ?? UniqueKey(),
              direction: DismissDirection.down,
              onDismissed: (_) => Get.back(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: child,
              ),
            ),
          ),
          Positioned(
            bottom: Sizes.s48.h,
            left: 0,
            right: 0,
            child: AppIcon(
              icon: AppIcons.close,
              onTap: Get.back,
              isCircle: true,
              padding: AppSpacing.edgeInsetsAll8,
              backgroundColor: Colors.white70,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
