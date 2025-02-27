import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import 'all.dart';
import 'widgets/choose_language_view.dart';
import 'widgets/choose_talk_language_view.dart';
import 'widgets/privacy_view.dart';

class SettingView extends BaseView<SettingController> {
  const SettingView({Key? key}) : super(key: key);

  Widget _buildDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Divider(
          color: Color(0xffdbdbdb),
          height: 1,
        ),
      );

  Widget buildContainerGroupItem(Widget child) => Container(
      padding: AppSpacing.edgeInsetsAll16,
      width: 0.85.sw,
      decoration: BoxDecoration(
        color: AppColors.grey11,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child);

  Widget builditemSetting(
          Object icon, Color color, String title, Function() onTap) =>
      Row(
        children: [
          AppIcon(
            icon: icon,
            color: color,
          ),
          AppSpacing.gapW12,
          Text(
            title,
            style: AppTextStyles.s16w600.toColor(color),
          ),
          const Spacer(),
          if (icon != AppIcons.trashMessage)
            AppIcon(
              icon: AppIcons.arrowRight,
              color: AppColors.text2,
            )
        ],
      ).clickable(() {
        onTap();
      });

  Widget _buildPrivacySettings() {
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
            // builditemSetting(
            //   AppIcons.networkPolicy,
            //   AppColors.text2,
            //   l10n.setting__policy,
            //   () => IntentUtils.openBrowserURL(url: AppConstants.policyURL),
            // ),
            builditemSetting(
              AppIcons.uiconsDocument,
              AppColors.text2,
              l10n.setting__terms_services,
              () => IntentUtils.openBrowserURL(url: AppConstants.termURL),
            ),
            _buildDivider(),
            builditemSetting(
              Assets.icons.lock,
              AppColors.text2,
              l10n.setting__privacy_label,
              () {
                Get.to(() => const PrivacyView());
              },
            ),
            // _buildDivider(),

            _buildDivider(),
            builditemSetting(
              AppIcons.language,
              AppColors.text2,
              l10n.setting__language,
              () => Get.to(() => const ChooseLanguageView()),
            ),
            _buildDivider(),
            builditemSetting(
              Assets.icons.translation,
              AppColors.text2,
              l10n.setting__talk_language,
              () => Get.to(() => const ChooseTalkLanguageView()),
            ),
            _buildDivider(),
            // builditemSetting(
            //   AppIcons.internet,
            //   AppColors.text2,
            //   l10n.setting__web_system,
            //   () => _openWebSystem(),
            // ),
            // _buildDivider(),
            builditemSetting(
              Assets.icons.settingDeleteAccount,
              AppColors.negative2,
              l10n.setting__delete_account,
              () => _buildDeleteAccount(),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildItem({
    required SvgGenImage icon,
    required String title,
    required VoidCallback onTap,
    bool isDivider = true,
    Color color = AppColors.text2,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: AppSpacing.edgeInsetsV12,
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AppIcon(
                        icon: icon,
                        color: color,
                      ),
                      const SizedBox(width: Sizes.s8),
                      Text(
                        title,
                        style: AppTextStyles.s14w400.copyWith(color: color),
                      ),
                    ],
                  ),
                ),
                AppIcon(
                  icon: AppIcons.arrowRight,
                  color: color,
                ),
              ],
            ),
          ),
          isDivider ? Divider(color: color) : const SizedBox.shrink(),
        ],
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      backgroundGradientColor: AppColors.background6,
      appBar: CommonAppBar(
        titleType: AppBarTitle.text,
        text: l10n.setting__title,
        centerTitle: false,
        titleWidget: Text(
          l10n.setting__title,
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
                  Column(
                    children: [
                      AppSpacing.gapH20,
                      _buildPrivacySettings(),
                    ],
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

  void _openWebSystem() {
    IntentUtils.openBrowserURL(url: AppConstants.webSystemURL);
  }

  void _buildDeleteAccount() {
    Get.bottomSheet(
      isScrollControlled: true,
      Obx(
        () => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(height: 1.sh, width: 1.sw).clickable(() {
              Get.back();
            }),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: AppSpacing.edgeInsetsAll20,
                child: Form(
                  key: controller.formKey,
                  child: Container(
                    decoration: BoxDecoration(
                      // color: AppColors.fieldBackground,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: Sizes.s24),
                            Center(
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.deepSkyBlue,
                                    AppColors.deepSkyBlue,
                                  ],
                                ).createShader(
                                  Rect.fromLTWH(
                                      0, 0, bounds.width, bounds.height),
                                ),
                                child: Text(
                                  l10n.setting__delete_account,
                                  style: AppTextStyles.s20w600,
                                ),
                              ),
                            ),
                            AppIcon(
                              icon: AppIcons.close,
                              color: AppColors.white,
                              onTap: Get.back,
                            ),
                          ],
                        ),
                        const SizedBox(height: Sizes.s24),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppCircleAvatar(
                                  url: currentUser.avatarPath ?? '',
                                  size: 80,
                                ),
                                const SizedBox(width: Sizes.s12),
                                Container(
                                  constraints: BoxConstraints(maxWidth: 100.w),
                                  child: Text(
                                    (currentUser.nickname ?? '').isNotEmpty
                                        ? currentUser.nickname!
                                        : currentUser.fullName,
                                    style: AppTextStyles.s16w600.text2Color,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Sizes.s24),
                            Text(
                              l10n.setting__delete_account_message,
                              style: AppTextStyles.s12w400.copyWith(
                                color: AppColors.text2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: Sizes.s24,
                        ),
                        AppTextField(
                          controller: controller.deleteController,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return l10n.field__delete_account_empty;
                            }

                            return null;
                          },
                          border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: AppColors.grey10),
                              borderRadius: BorderRadius.circular(30),
                              gapPadding: 0),
                        ),
                        const SizedBox(height: Sizes.s24),
                        AppButton.primary(
                          label: l10n.button__delete,
                          width: double.infinity,
                          onPressed: () async {
                            if (!controller.isLoadingBtnDeleteAccount.value) {
                              await controller.deleteAccount();
                            }
                          },
                        ),
                      ],
                    ).paddingAll(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
