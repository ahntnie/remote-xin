import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import '../controllers/intro_controller.dart';

class IntroView extends BaseView<IntroController> {
  const IntroView({Key? key}) : super(key: key);

  Widget _buildSkipBtn() {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => controller.skip(),
            child: Text(
              l10n.intro__skip,
              style: AppTextStyles.s16w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroStep1() {
    return Padding(
      padding: EdgeInsets.only(
        top: 40.h,
        bottom: 20.h,
      ),
      child: Assets.images.introStep1.image(
        height: 0.5.sh,
      ),
    );
  }

  Widget _buildIntroStep2() {
    return Padding(
      padding: EdgeInsets.only(
        top: 40.h,
        bottom: 20.h,
      ),
      child: Assets.images.introStep2.image(
        height: 0.5.sh,
      ),
    );
  }

  Widget _buildIntroStep3() {
    return Padding(
      padding: EdgeInsets.only(
        top: 40.h,
        bottom: 20.h,
      ),
      child: Assets.images.introStep3.image(
        height: 0.5.sh,
      ),
    );
  }

  Widget _buildIntroImage() {
    return Obx(() {
      switch (controller.currentIndex.value) {
        case 0:
          return _buildIntroStep1();
        case 1:
          return _buildIntroStep2();
        case 2:
          return _buildIntroStep3();
        default:
          return _buildIntroStep1();
      }
    });
  }

  Widget _buildSwichStep() {
    return SizedBox(
      height: 9.h,
      child: Center(
        child: GetBuilder<IntroController>(
          init: controller,
          builder: (context) {
            return ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  width: controller.currentIndex.value == index ? 51 : 9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: controller.currentIndex.value == index
                        ? AppColors.stoke
                        : AppColors.button.first.withOpacity(0.58),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroTitleStep(String title, String subTitle) {
    return Container(
      width: ScreenUtil().screenWidth,
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.s20w600.merge(
              const TextStyle(
                color: AppColors.text4,
              ),
            ),
          ),
          SizedBox(
            height: 20.h,
          ),
          Text(
            subTitle,
            style: AppTextStyles.s14w400,
          ),
        ],
      ),
    );
  }

  Widget _buildNextBtn() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 20),
        child: AppButton.primary(
          label: controller.textButton(),
          width: double.infinity,
          onPressed: () {
            controller.nextStep();
          },
          isLoading: controller.isLoading,
        ),
      ),
    );
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: Column(
                        children: [
                          _buildIntroImage(),
                          _buildSwichStep(),
                          _buildIntroTitleStep(
                            controller.textTitle(),
                            controller.subTitle(),
                          ),
                          AppSpacing.gapH16,
                        ],
                      ),
                    ),
                  ),
                ),
                _buildNextBtn(),
              ],
            ),
            _buildSkipBtn(),
          ],
        ),
      ),
    );
  }
}
