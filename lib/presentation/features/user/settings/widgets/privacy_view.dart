import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../base/base_view.dart';
import '../../../../common_widgets/common_app_bar.dart';
import '../../../../common_widgets/common_scaffold.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/gaps.dart';
import '../../../../resource/styles/text_styles.dart';
import '../setting_controller.dart';

class PrivacyView extends BaseView<SettingController> {
  const PrivacyView({Key? key}) : super(key: key);

  Widget _buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Divider(
          color: Color(0xffdbdbdb),
          height: 1,
        ),
      );

  Widget buildContainerGroupItem(Widget child) => Container(
      padding: AppSpacing.edgeInsetsAll16,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey11,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child);

  Widget builditemSetting(String title, bool itemValue, Function() onTap) =>
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.s16w600.toColor(AppColors.text2),
            ),
          ),
          AppSpacing.gapW12,
          CupertinoSwitch(
              activeColor: AppColors.pacificBlue,
              trackColor: AppColors.subText2,
              value: itemValue,
              onChanged: (value) {
                onTap();
              }),
        ],
      );

  Widget _buildSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setting__general,
          style:
              AppTextStyles.s16w700.copyWith(color: AppColors.text2).copyWith(
                  // shadows: [
                  //   Shadow(
                  //     color: const Color(0xff000000).withOpacity(0.25),
                  //     blurRadius: 4,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                  ),
        ),
        const SizedBox(height: Sizes.s16),
        buildContainerGroupItem(Column(
          children: [
            builditemSetting(
              l10n.setting__privacy_search_global,
              controller.currentUser.isSearchGlobal ?? true,
              () {
                controller.updatePrivacy(UpdatePrivacyType.globalSearch);
              },
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.setting__privacy_discrible,
          style:
              AppTextStyles.s16w700.copyWith(color: AppColors.text2).copyWith(
                  // shadows: [
                  //   Shadow(
                  //     color: const Color(0xff000000).withOpacity(0.25),
                  //     blurRadius: 4,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                  ),
        ),
        const SizedBox(height: Sizes.s16),
        buildContainerGroupItem(Column(
          children: [
            builditemSetting(
              l10n.field__email_label,
              controller.currentUser.isShowEmail ?? true,
              () {
                controller.updatePrivacy(UpdatePrivacyType.showEmail);
              },
            ),
            _buildDivider(),
            builditemSetting(
              l10n.field_phone__label,
              controller.currentUser.isShowPhone ?? true,
              () {
                controller.updatePrivacy(UpdatePrivacyType.showPhone);
              },
            ),
            _buildDivider(),
            builditemSetting(
              'NFT number',
              controller.currentUser.isShowNft ?? true,
              () {
                controller.updatePrivacy(UpdatePrivacyType.showNft);
              },
            ),
            _buildDivider(),
            builditemSetting(
              l10n.text_gender,
              controller.currentUser.isShowGender ?? true,
              () {
                controller.updatePrivacy(UpdatePrivacyType.showGender);
              },
            ),
            _buildDivider(),
            builditemSetting(
              l10n.text_birthday,
              controller.currentUser.isShowBirthday ?? true,
              () {
                controller.updatePrivacy(UpdatePrivacyType.showBirthDay);
              },
            ),
            _buildDivider(),
            builditemSetting(
              l10n.text_location,
              controller.currentUser.isShowLocation ?? true,
              () {
                controller.updatePrivacy(UpdatePrivacyType.showLocation);
              },
            ),
          ],
        )),
      ],
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      backgroundGradientColor: AppColors.background6,
      appBar: CommonAppBar(
        titleType: AppBarTitle.text,
        text: l10n.setting__privacy_label,
        centerTitle: false,
        titleWidget: Text(
          l10n.setting__privacy_label,
          style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
        ).clickable(() {
          Get.back();
        }),
        leadingIconColor: AppColors.text2,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.s20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Obx(
                    () => Column(
                      children: [
                        AppSpacing.gapH20,
                        _buildSettings(),
                        AppSpacing.gapH20,
                        _buildPrivacySettings(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Obx(
            //   () => Padding(
            //     padding: const EdgeInsets.all(Sizes.s24),
            //     child: Text(
            //       'Version ${controller.version.value}',
            //       style: AppTextStyles.s18w400.text2Color,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
