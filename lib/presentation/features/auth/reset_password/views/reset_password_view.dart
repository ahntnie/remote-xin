import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/extensions/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends BaseView<ResetPasswordController> {
  const ResetPasswordView({
    Key? key,
  }) : super(key: key);

  @override
  bool get allowLoadingIndicator => false;

  Widget _buildTextFieldPassword() {
    return AppTextField(
      autofocus: true,
      controller: controller.passwordController,
      label: l10n.password__new_pass,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      hintText: controller.l10n.text_enter_password,
      hintStyle: AppTextStyles.s14w400.copyWith(
        color: AppColors.subText3,
      ),
      // validator: controller.validatePassword,
      obscureText: controller.isShowPassword.value,
      onChanged: (value) {
        controller.setDisableSubmitBtn =
            !controller.formKey.currentState!.validate();
        controller.validatePassword(value);
      },
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.grey8,
          )),
      suffixIcon: AppIcon(
        icon: controller.isShowPassword.value
            ? AppIcons.eyeClose
            : AppIcons.eyeOpen,
        color: AppColors.subText3,
      ),
      onSuffixIconPressed: () {
        controller.isShowPassword.toggle();
      },
    );
  }

  Widget _buildTextFieldConfirmPassword(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 28.h),
      child: AppTextField(
        autofocus: true,
        controller: controller.confirmPasswordController,
        label: l10n.password__confirm,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        hintText: controller.l10n.text_enter_password,
        hintStyle: AppTextStyles.s14w400.copyWith(
          color: AppColors.subText3,
        ),
        validator: controller.validateConfirmPassword,
        obscureText: controller.isShowConfirmPassword.value,
        onChanged: (value) {
          controller.setDisableSubmitBtn =
              !controller.formKey.currentState!.validate();
        },
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.grey8,
            )),
        suffixIcon: AppIcon(
          icon: controller.isShowConfirmPassword.value
              ? AppIcons.eyeClose
              : AppIcons.eyeOpen,
          color: AppColors.subText3,
        ),
        onSuffixIconPressed: () {
          controller.isShowConfirmPassword.toggle();
        },
      ),
    );
  }

  Widget _buildSubmitBtn() {
    final loginController = Get.find<LoginController>();
    return AppButton.primary(
      label: !loginController.isRegister.value
          ? l10n.button__reset_password
          : l10n.button__confirm,
      width: double.infinity,
      onPressed: () {
        controller.submit();
      },
      isLoading: controller.isLoading,
      isDisabled: controller.isDisableSubmitBtn.value,
    );
  }

  Widget _buildValidator() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: AppIcon(
              icon: AppIcons.checkBroken,
              color: controller.isValidator.value
                  ? AppColors.green2
                  : AppColors.subText3,
              padding: EdgeInsets.zero,
            ),
            title: Text(
              l10n.password__condition,
              style: AppTextStyles.s16Base.copyWith(
                color: controller.isValidator.value
                    ? AppColors.green2
                    : AppColors.subText3,
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: AppIcon(
              icon: AppIcons.checkBroken,
              color: controller.is8Lenght.value
                  ? AppColors.green2
                  : AppColors.subText3,
              padding: EdgeInsets.zero,
            ),
            title: Text(
              l10n.password__min_8_length,
              style: AppTextStyles.s16Base.copyWith(
                color: controller.is8Lenght.value
                    ? AppColors.green2
                    : AppColors.subText3,
              ),
            ),
          ),
        ],
      );

  @override
  Widget buildPage(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.gapH20,
          GetBuilder<LoginController>(builder: (controller) {
            return Text(
              !controller.isRegister.value
                  ? l10n.button__reset_password
                  : l10n.reset_pass__create_pass,
              style: AppTextStyles.s26w700.toColor(AppColors.blue10),
            );
          }),
          AppSpacing.gapH32,
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextFieldPassword(),
                _buildValidator(),
                _buildTextFieldConfirmPassword(context),
                _buildSubmitBtn(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
