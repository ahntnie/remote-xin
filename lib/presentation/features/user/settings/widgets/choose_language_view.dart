import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../base/base_view.dart';
import '../../../../common_controller.dart/language_controller.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';

class ChooseLanguageView extends BaseView<LanguageController> {
  const ChooseLanguageView({Key? key}) : super(key: key);
  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      hideKeyboardWhenTouchOutside: true,
      backgroundGradientColor: AppColors.background6,
      appBar: CommonAppBar(
        titleType: AppBarTitle.text,
        centerTitle: false,
        titleWidget: Text(
          context.l10n.setting__language,
          style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
        ).clickable(() => Get.back()),
        leadingIconColor: AppColors.text2,
        actions: [
          Text(
            l10n.button__save,
            style: AppTextStyles.s16w600.copyWith(color: AppColors.blue10),
          ).clickable(() => Get.back())
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.edgeInsetsAll20,
          child: Column(
            children: [
              chooseLanguageWidget(),
              SizedBox(height: Get.height * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget chooseLanguageWidget() {
    final languages = controller.languages;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            ...languages.map((lanItem) {
              final index = languages.indexOf(lanItem);
              return Column(children: [
                Padding(
                    padding: AppSpacing.edgeInsetsV8,
                    child: Row(
                      children: [
                        CircleFlag(
                            size: 28, languages[index]['flagCode'] ?? ''),
                        AppSpacing.gapW12,
                        Text(
                          languages[index]['title'] ?? '',
                          style: AppTextStyles.s16w500.text2Color,
                        ),
                        const Spacer(),
                        // Obx(() => CheckBoxButton(
                        //       value: index == controller.currentIndex.value,
                        //       onChanged: (p0) {
                        //         controller.currentIndex.value = index;
                        //         controller.changeLanguage(
                        //             languages[index]['langCode'] ?? '');
                        //       },
                        //       // size: 20,
                        //     ))
                        Obx(() => Icon(
                              Icons.check,
                              color: index == controller.currentIndex.value
                                  ? AppColors.blue10
                                  : AppColors.white,
                            ))
                      ],
                    )).clickable(() {
                  controller.currentIndex.value = index;
                  controller.changeLanguage(languages[index]['langCode'] ?? '');
                }),
                if (index != languages.length - 1) ...[
                  Divider(color: const Color(0xffa6a6a6).withOpacity(0.4)),
                ],
              ]);
            }),
          ],
        ),
      ],
    );
  }
}
