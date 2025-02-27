import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';

class InviteLinkWidget extends StatelessWidget {
  const InviteLinkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PersonalPageController>();
    return CommonScaffold(
        isShowLinearBackground: true,
        appBar: CommonAppBar(
          titleType: AppBarTitle.none,
          titleWidget: Text(
            context.l10n.text_back,
            style: AppTextStyles.s16w700.copyWith(color: AppColors.text2),
          ).clickable(() => Get.back()),
          centerTitle: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 0.16.sw),
                    padding: EdgeInsets.all(0.07.sw),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.white),
                    child: AppQrCodeView(
                      controller.shareLink,
                      size: 0.5.sw,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Assets.images.logoSquareShort
                            .image(height: 0.2.sw, width: 0.2.sw)),
                  )
                ],
              ),
            ),
            AppSpacing.gapH20,
            Text(
              context.l10n.text_invite_link,
              style: AppTextStyles.s16w700.text2Color,
            ).paddingOnly(left: 20),
            AppSpacing.gapH12,
            Container(
              margin: AppSpacing.edgeInsetsH20,
              padding: AppSpacing.edgeInsetsAll16,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.shareLink,
                      style: AppTextStyles.s14Base.text2Color,
                    ),
                  ),
                  Text(
                    context.l10n.text_copy,
                    style: AppTextStyles.s16Base.toColor(AppColors.blue10),
                  ).clickable(() {
                    ViewUtil.copyToClipboard(controller.shareLink).then((_) {
                      ViewUtil.showAppSnackBarNewFeeds(
                        title: context.l10n.global__copied_to_clipboard,
                      );
                    });
                  })
                ],
              ),
            )
          ],
        ));
  }
}
