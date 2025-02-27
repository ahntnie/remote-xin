import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/all.dart';
import '../../base/all.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import 'all.dart';

class ReportView extends BaseView<ReportController> {
  const ReportView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        text: context.l10n.newsfeed__report_title,
        titleType: AppBarTitle.text,
      ),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList.builder(
                    itemCount: controller.categories.length,
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];

                      return CheckboxListTile(
                        title: Text(
                          category.name,
                          style: AppTextStyles.s14w400.text2Color,
                        ),
                        contentPadding: EdgeInsets.zero,
                        value: category.isSelected,
                        onChanged: (value) {
                          controller.changeSelectedCategory(index);
                        },
                        checkColor: AppColors.text1,
                        activeColor: AppColors.pacificBlue,
                      );
                    },
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.newsfeed__other_reasons,
                          style: AppTextStyles.s14w400.text2Color,
                        ),
                        AppSpacing.gapH16,
                        AppTextField(
                          controller: controller.reportController,
                          hintText: l10n.newsfeed__other_reasons_hint,
                          hintStyle: AppTextStyles.s14w400.subText2Color,
                          maxLines: 3,
                          borderRadius: 30,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(width: 0.5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppButton.primary(
              label: context.l10n.button__report,
              width: double.infinity,
              onPressed: controller.report,
            ).paddingSymmetric(vertical: Sizes.s20),
          ],
        ),
      ).paddingSymmetric(horizontal: Sizes.s20),
    );
  }
}
