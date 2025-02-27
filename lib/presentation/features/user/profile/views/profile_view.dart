import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../core/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/styles/styles.dart';
import '../../../../routing/routing.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends BaseView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  Widget _buildAvatar() {
    return Obx(
      () => Stack(
        children: [
          SizedBox(
            width: 110.w,
            height: 120.w,
          ),
          Container(
            child: controller.isAvatarLocal.value
                ? Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(
                          File(controller.imagePath.value),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : AppCircleAvatar(
                    size: 110.w,
                    url: controller.currentUser.avatarPath ?? '',
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: Sizes.s40,
              height: Sizes.s40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blue10,
                border: Border.all(color: AppColors.white, width: 3),
              ),
              child: Center(
                child: AppIcon(
                  icon: AppIcons.cameraChange,
                ),
              ),
            ).clickable(() {
              controller.getImageFromGallery();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldName(
    String label,
    TextEditingController controller,
    TextInputAction textInputAction, {
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.s20),
      child: AppTextField(
        textInputAction: textInputAction,
        controller: controller,
        label: label,
        contentPadding: const EdgeInsets.all(Sizes.s16),
        readOnly: readOnly,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.greyBorder),
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
        suffixIcon: readOnly
            ? AppIcon(
                icon: AppIcons.circleTick,
                color: const Color(0xff00970F),
                padding: const EdgeInsets.only(right: Sizes.s2),
              )
            : AppIcon(
                icon: AppIcons.editLight,
                color: AppColors.subText2,
                padding: const EdgeInsets.only(right: Sizes.s2),
              ),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextFieldPhoneNumber(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.s8),
          child: SizedBox(
            height: 24,
            child: Text(
              l10n.profile__phone_number,
              style: AppTextStyles.s16w400.text2Color
                  .copyWith(color: AppColors.pacificBlue),
            ),
          ),
        ),
        AppSpacing.gapH4,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: controller.isoCode.value),
          keyboardAction: TextInputAction.done,
          formatInput: false,
          textAlignVertical: TextAlignVertical.top,
          spaceBetweenSelectorAndTextField: 0,
          textFieldController: controller.phoneController,
          isEnabled: controller.currentUser.phone != null &&
                  controller.currentUser.phone!.isNotEmpty
              ? false
              : true,
          selectorConfig: const SelectorConfig(
            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
            leadingPadding: Sizes.s12,
            useBottomSheetSafeArea: true,
            setSelectorButtonAsPrefixIcon: true,
            trailingSpace: false,
          ),
          selectorTextStyle: AppTextStyles.s16w400.text2Color,
          textStyle: AppTextStyles.s16w400.text2Color,
          onInputChanged: (value) {
            if (value.phoneNumber != null && value.phoneNumber!.isNotEmpty) {
              controller.setDisableLoginBtn = false;
            }
            controller.phoneEdit.value = value.phoneNumber ?? '';

            if (controller.isoCode.value != value.isoCode) {
              controller.isoCode.value = value.isoCode ?? '';
              controller.phoneController.clear();
            }
          },
          validator: (controller.currentUser.phone != null &&
                  controller.currentUser.phone!.isNotEmpty)
              ? (value) {
                  if (value != null && value.isEmpty) {
                    return context.l10n.field_phone__error_invalid;
                  }

                  return null;
                }
              : null,
          errorMessage: controller.phoneEdit.value.isNotEmpty &&
                  controller.phoneEdit.value.replaceAll('+84', '').isNotEmpty
              ? l10n.field_phone__error_invalid
              : l10n.field_phone__error_empty,
          autoValidateMode: controller.currentUser.phone != null &&
                  controller.currentUser.phone!.isNotEmpty
              ? AutovalidateMode.disabled
              : AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: context.l10n.field_phone__label,
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            hintStyle: AppTextStyles.s16w400.copyWith(
              color: AppColors.subText2,
              fontStyle: FontStyle.italic,
            ),
            errorStyle: AppTextStyles.s14Base.negativeColor,
            errorMaxLines: 2,
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            disabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            suffixIcon: AppIcon(
              icon: controller.currentUser.phone != null &&
                      controller.currentUser.phone!.isNotEmpty
                  ? AppIcons.circleTick
                  : AppIcons.editLight,
              color: controller.currentUser.phone != null &&
                      controller.currentUser.phone!.isNotEmpty
                  ? const Color(0xff00970F)
                  : AppColors.subText2,
              padding: const EdgeInsets.only(right: Sizes.s16),
            ),
            suffixIconConstraints: const BoxConstraints(
              maxWidth: Sizes.s16 + Sizes.s24 + Sizes.s8,
            ),
          ),
        ),
      ],
    ).paddingOnly(bottom: Sizes.s16);
    // return Padding(
    //   padding: const EdgeInsets.only(bottom: Sizes.s20),
    //   child: AppTextField(
    //     textInputAction: TextInputAction.done,
    //     controller: controller.phoneController,
    //     label: l10n.profile__phone_number,
    //     readOnly: controller.currentUser.phone != null &&
    //         controller.currentUser.phone!.isNotEmpty,
    //     keyboardType: TextInputType.phone,
    //     contentPadding: const EdgeInsets.all(Sizes.s16),
    //     border: const OutlineInputBorder(
    //       borderSide: BorderSide.none,
    //       borderRadius: BorderRadius.all(Radius.circular(55)),
    //     ),
    //     suffixIcon: AppIcon(
    //       icon: controller.currentUser.phone != null &&
    //               controller.currentUser.phone!.isNotEmpty
    //           ? AppIcons.circleTick
    //           : AppIcons.editLight,
    //       color: controller.currentUser.phone != null &&
    //               controller.currentUser.phone!.isNotEmpty
    //           ? const Color(0xff00970F)
    //           : AppColors.subText2,
    //       padding: const EdgeInsets.only(right: Sizes.s2),
    //     ),
    //     prefixIcon: AppIcon(
    //       icon: AppIcons.flagVietnam,
    //       color: const Color(0xffF42F4C),
    //       padding: const EdgeInsets.only(right: Sizes.s2),
    //     ),
    //     validator: (value) {
    //       if (controller.validPhoneNumber(value!).isNotEmpty) {
    //         return controller.validPhoneNumber(value);
    //       }

    //       return null;
    //     },
    //     autovalidateMode: controller.currentUser.phone != null &&
    //             controller.currentUser.phone!.isNotEmpty
    //         ? null
    //         : AutovalidateMode.onUserInteraction,
    //     onChanged: (value) {
    //       if (controller.validPhoneNumber(value).isEmpty) {
    //         controller.setDisableLoginBtn = false;
    //       }
    //     },
    //   ),
    // );
  }

  Widget buildProfileItem(
    String title,
    String content,
    Function onTap,
    bool isRequired,
  ) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: AppColors.grey11,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: AppTextStyles.s18w500.text2Color,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isRequired)
                  Text(
                    '*',
                    style: AppTextStyles.s14w500.toColor(AppColors.negative),
                  ),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    content,
                    style: AppTextStyles.s18w500.toColor(AppColors.grey10),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.gapW4,
                AppIcon(
                  icon: AppIcons.arrowRight,
                  color: AppColors.text2,
                ),
              ],
            )
          ],
        ),
      ).clickable(() {
        onTap();
      });

  @override
  Widget buildPage(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (controller.isUpdateProfileFirstLogin) {
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: CommonScaffold(
        hideKeyboardWhenTouchOutside: true,
        backgroundGradientColor: AppColors.background6,
        appBar: CommonAppBar(
          titleType: AppBarTitle.none,
          titleWidget: Text(
            controller.isUpdateProfileFirstLogin
                ? l10n.profile__title_update
                : l10n.profile__title,
            style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
          ).clickable(() {
            Get.back();
          }),
          leadingIconColor: AppColors.text2,
          centerTitle: controller.isUpdateProfileFirstLogin,
          automaticallyImplyLeading:
              controller.isUpdateProfileFirstLogin ? false : true,
          onLeadingPressed: () {
            if (controller.isUpdateProfileFirstLogin) {
              Get.offNamed(AppPages.afterAuthRoute);
            } else {
              Get.back();
            }
          },
          actions: [
            // if (!controller.isUpdateProfileFirstLogin)
            //   AppIcon(
            //     icon: AppIcons.setting,
            //     color: AppColors.pacificBlue,
            //   ).clickable(() {
            //     Get.toNamed(Routes.setting);
            //   }),
            Text(
              l10n.button__continue,
              style: AppTextStyles.s16w600.toColor(AppColors.blue10),
            ).clickable(() => controller.updateProfile())
          ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Obx(
              () => Column(
                children: [
                  AppSpacing.gapH32,
                  _buildAvatar(),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: Sizes.s20),
                  //   child: Text(
                  //     (controller.currentUser.nickname ?? '').isNotEmpty
                  //         ? controller.currentUser.nickname ?? ''
                  //         : controller.currentUser.fullName,
                  //     style: AppTextStyles.s20w600.text2Color,
                  //   ),
                  // ),
                  AppSpacing.gapH32,
                  buildProfileItem(
                    context.l10n.text_first_name,
                    controller.firstName.value,
                    () {
                      controller.reload();
                      showBottomSheetTextField(
                          context,
                          context.l10n.text_first_name,
                          controller.firstNameController,
                          'first');
                    },
                    true,
                  ),
                  buildProfileItem(
                    controller.l10n.text_last_name,
                    controller.lastName.value,
                    () {
                      controller.reload();
                      showBottomSheetTextField(
                          context,
                          controller.l10n.text_last_name,
                          controller.lastNameController,
                          'last');
                    },
                    true,
                  ),
                  buildProfileItem(
                    controller.l10n.text_username,
                    controller.userName.value,
                    () {
                      controller.reload();
                      showBottomSheetTextField(
                          context,
                          controller.l10n.text_username,
                          controller.usernameController,
                          'user');
                    },
                    true,
                  ),

                  if (!controller.isUpdateProfileFirstLogin) ...[
                    AppSpacing.gapH20,
                    Column(
                      children: [
                        // (controller.currentUser.phone ?? '').isEmpty
                        //     ?
                        if (controller.homeController.isAllowVerifyPhone)
                          Obx(
                            () => buildProfileItem(
                              l10n.field_phone__hint,
                              controller.phoneEdit.value,
                              () {
                                controller.reload();
                                showBottomSheetPhone(context);
                              },
                              true,
                            ),
                          ),

                        // : buildProfileItem(
                        //     controller.l10n.text_enter_email,
                        //     controller.email.value,
                        //     () {
                        //       controller.reload();
                        //       showBottomSheetTextField(
                        //           context,
                        //           controller.l10n.field__email_label,
                        //           controller.emailController,
                        //           'email');
                        //     },
                        //     true,
                        //   ),

                        AppSpacing.gapH4,
                        if (controller.homeController.isAllowVerifyPhone)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Obx(
                              () => Row(
                                children: [
                                  controller.isVerify.value
                                      ? Container(
                                          decoration: const BoxDecoration(
                                              color: AppColors.green1,
                                              shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.check,
                                            size: 16,
                                          ),
                                        )
                                      : Container(
                                          decoration: const BoxDecoration(
                                              color: AppColors.negative,
                                              shape: BoxShape.circle),
                                          padding: const EdgeInsets.all(2),
                                          child: const Icon(
                                            Icons.clear,
                                            size: 16,
                                          ),
                                        ),
                                  AppSpacing.gapW8,
                                  controller.isVerify.value
                                      ? Text(
                                          l10n.otp__verify,
                                          style: AppTextStyles.s14w500.copyWith(
                                            color: AppColors.text2,
                                          ),
                                        )
                                      : Text(
                                          l10n.otp__verify_now,
                                          style: AppTextStyles.s14w500.copyWith(
                                            color: AppColors.pacificBlue,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppColors.pacificBlue,
                                          ),
                                        ).clickable(() {
                                          controller.sendOtp();
                                        }),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 20, vertical: 12),
                    //   color: AppColors.grey11,
                    //   child: Column(
                    //     children: [
                    //       // (controller.currentUser.phone ?? '').isEmpty
                    //       //     ?
                    //       buildProfileItem(
                    //         l10n.field_phone__hint,
                    //         controller.phoneEdit.value,
                    //         () {
                    //           controller.reload();
                    //           showBottomSheetPhone(context);
                    //         },
                    //         true,
                    //       )

                    //       // : buildProfileItem(
                    //       //     controller.l10n.text_enter_email,
                    //       //     controller.email.value,
                    //       //     () {
                    //       //       controller.reload();
                    //       //       showBottomSheetTextField(
                    //       //           context,
                    //       //           controller.l10n.field__email_label,
                    //       //           controller.emailController,
                    //       //           'email');
                    //       //     },
                    //       //     true,
                    //       //   ),
                    //       // AppSpacing.gapH4,
                    //       // Padding(
                    //       //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //       //   child: Row(
                    //       //     children: [
                    //       //       controller.isVerifyPhoneOrEmail.value
                    //       //           ? Container(
                    //       //               // decoration: const BoxDecoration(
                    //       //               //     color: AppColors.green1,
                    //       //               //     shape: BoxShape.circle),
                    //       //               child: const Icon(
                    //       //                 Icons.check_circle,
                    //       //                 size: 16,
                    //       //                 color: AppColors.green1,
                    //       //               ),
                    //       //             )
                    //       //           : Container(
                    //       //               decoration: const BoxDecoration(
                    //       //                   color: AppColors.negative,
                    //       //                   shape: BoxShape.circle),
                    //       //               padding: const EdgeInsets.all(2),
                    //       //               child: const Icon(
                    //       //                 Icons.clear,
                    //       //                 size: 16,
                    //       //               ),
                    //       //             ),
                    //       //       AppSpacing.gapW12,
                    //       //       controller.isVerifyPhoneOrEmail.value
                    //       //           ? Text(
                    //       //               l10n.otp__verify,
                    //       //               style: AppTextStyles.s14w500.copyWith(
                    //       //                 color: AppColors.text2,
                    //       //               ),
                    //       //             )
                    //       //           : Text(
                    //       //               l10n.otp__verify_now,
                    //       //               style: AppTextStyles.s14w500.copyWith(
                    //       //                 color: AppColors.pacificBlue,
                    //       //                 decoration: TextDecoration.underline,
                    //       //                 decorationColor:
                    //       //                     AppColors.pacificBlue,
                    //       //               ),
                    //       //             ).clickable(() {
                    //       //               controller.sendOtp();
                    //       //             }),
                    //       //     ],
                    //       //   ),
                    //       // ),
                    //     ],
                    //   ),
                    // )
                  ],

                  AppSpacing.gapH20,
                  buildProfileItem(
                    l10n.text_gender,
                    controller.gender.value,
                    () {
                      controller.reload();
                      showBottomSheetGender(context);
                    },
                    false,
                  ),
                  buildProfileItem(
                    l10n.text_birthday,
                    controller.birthday.value,
                    () {
                      controller.reload();
                      showBottomSheetBirthDay(context, 'birthday');
                    },
                    false,
                  ),
                  buildProfileItem(
                    l10n.text_location,
                    controller.location.value,
                    () {
                      controller.reload();
                      showBottomSheetTextField(context, l10n.text_location,
                          controller.locationController, 'location');
                    },
                    false,
                  ),
                  // const Text('sdsd').clickable(() {
                  //   controller.showBottomSheet();
                  // }),
                  // AppSpacing.gapH20,
                  // buildProfileItem(
                  //     context.l10n.text_cccd, controller.cccd.value, () {
                  //   controller.reload();
                  //   showBottomSheetTextField(context, context.l10n.text_cccd,
                  //       controller.cccdController, 'cccd');
                  // }),
                  // buildProfileItem(
                  //   controller.l10n.text_date_cccd,
                  //   controller.dateCccd.value,
                  //   () {
                  //     controller.reload();
                  //     showBottomSheetBirthDay(context, 'dateCccd');
                  //   },
                  // ),
                  // buildProfileItem(
                  //   controller.l10n.text_address_cccd,
                  //   controller.addressCccd.value,
                  //   () {
                  //     controller.reload();
                  //     showBottomSheetTextField(
                  //         context,
                  //         controller.l10n.text_address_cccd,
                  //         controller.addressCccdController,
                  //         'addressCccd');
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheetTextField(BuildContext context, String title,
          TextEditingController textController, String type) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => SingleChildScrollView(
          child: Container(
            padding: AppSpacing.edgeInsetsAll20,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              color: AppColors.white,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom, // Điều chỉnh bottom padding theo bàn phím
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: AppTextStyles.s20w700.toColor(AppColors.blue10),
                  ),
                  AppSpacing.gapH32,
                  AppTextField(
                    controller: textController,
                    style: AppTextStyles.s16w400.text2Color,
                    // hintText: 'Enter your email or phone number',
                    // hintStyle: AppTextStyles.s14w400.copyWith(
                    //   color: AppColors.subText3,
                    // ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.grey8,
                        )),
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      return null;
                    },
                    onChanged: (value) {},
                  ),
                  AppSpacing.gapH32,
                  AppButton.primary(
                    width: double.infinity,
                    label: l10n.button__save,
                    onPressed: () {
                      if (type == 'first') {
                        controller.firstName.value =
                            textController.text.trim().removeAllWhitespace;
                      }
                      if (type == 'last') {
                        controller.lastName.value =
                            textController.text.trim().removeAllWhitespace;
                      }
                      if (type == 'user') {
                        controller.userName.value =
                            textController.text.trim().removeAllWhitespace;
                      }
                      if (type == 'location') {
                        controller.location.value = textController.text.trim();
                      }
                      if (type == 'phone') {
                        controller.phoneEdit.value =
                            textController.text.trim().removeAllWhitespace;
                        controller.onChangeVerify();
                      }
                      if (type == 'cccd') {
                        controller.cccd.value =
                            textController.text.trim().removeAllWhitespace;
                      }
                      if (type == 'addressCccd') {
                        controller.addressCccd.value =
                            textController.text.trim().removeAllWhitespace;
                      }
                      if (type == 'email') {
                        controller.email.value =
                            textController.text.trim().removeAllWhitespace;
                        controller.onChangeVerify();
                      }
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void showBottomSheetBirthDay(BuildContext context, String type) {
    int selectedDay = DateTime.now().day;
    int selectedMonth = DateTime.now().month;
    int selectedYear = DateTime.now().year;

    final List<int> days = List<int>.generate(31, (index) => index + 1);
    final List<int> months = List<int>.generate(12, (index) => index + 1);
    final List<int> years =
        List<int>.generate(100, (index) => DateTime.now().year - 100 + index);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpacing.gapH20,
          Text(
            l10n.text_birthday,
            style: AppTextStyles.s20w700.toColor(AppColors.blue10),
          ),
          Container(
            height: 0.3.sh,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: selectedDay - 1),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (index) {
                      selectedDay = days[index];
                      HapticFeedback.lightImpact();
                    },
                    children: days
                        .map((day) => Center(
                                child: Text(
                              day.toString(),
                              style: AppTextStyles.s18w600.text2Color,
                            )))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: selectedMonth - 1),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (index) {
                      selectedMonth = months[index];
                      HapticFeedback.lightImpact();
                    },
                    children: months
                        .map((month) => Center(
                                child: Text(
                              month.toString(),
                              style: AppTextStyles.s18w600.text2Color,
                            )))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                        initialItem: selectedYear - years[0]),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (index) {
                      selectedYear = years[index];
                      HapticFeedback.lightImpact();
                    },
                    children: years
                        .map((year) => Center(
                                child: Text(
                              year.toString(),
                              style: AppTextStyles.s18w600.text2Color,
                            )))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSpacing.edgeInsetsAll20,
            child: AppButton.primary(
              label: l10n.button__save,
              width: double.infinity,
              color: AppColors.blue10,
              onPressed: () {
                if (type == 'birthday') {
                  controller.birthday.value =
                      '$selectedDay/$selectedMonth/$selectedYear';
                } else {
                  controller.dateCccd.value =
                      '$selectedDay/$selectedMonth/$selectedYear';
                }

                Get.back();
                // if ('$selectedDay/$selectedMonth/$selectedYear' !=
                //     currentUser.birthDay) {
                //   controller.birthDay.value =
                //       '$selectedDay/$selectedMonth/$selectedYear';
                // }
                // controller.setDisableSave();
                // Get.back();
              },
            ),
          )
        ],
      ),
    );
  }

  void showBottomSheetGender(BuildContext context) {
    final List<String> genders = [
      l10n.text_gender_male,
      l10n.text_gender_female
    ];
    String select = l10n.text_gender_male;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSpacing.gapH20,
          Text(
            l10n.text_gender,
            style: AppTextStyles.s20w700.toColor(AppColors.blue10),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (index) {
                      select = genders[index];
                      HapticFeedback.lightImpact();
                    },
                    children: genders
                        .map((gender) => Center(
                                child: Text(
                              gender.toString(),
                              style: AppTextStyles.s18w600.text2Color,
                            )))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSpacing.edgeInsetsAll20,
            child: AppButton.primary(
              label: l10n.button__save,
              width: double.infinity,
              color: AppColors.blue10,
              onPressed: () {
                Get.back<String>(result: select);
              },
            ),
          )
        ],
      ),
    ).then((value) {
      controller.gender.value = value;
      controller.update();
    });
  }

  void showBottomSheetPhone(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: AppSpacing.edgeInsetsAll20,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            color: AppColors.white,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Điều chỉnh bottom padding theo bàn phím
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSpacing.gapH20,
                Text(
                  l10n.field_phone__label,
                  style: AppTextStyles.s20w700.toColor(AppColors.blue10),
                ),
                SizedBox(
                  height: 120,
                  // padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InternationalPhoneNumberInput(
                          maxLength: 10,
                          autoFocus: true,
                          initialValue: PhoneNumber(
                              isoCode: controller.initIsoCode.value),
                          keyboardAction: TextInputAction.done,
                          formatInput: false,
                          cursorColor: Colors.black,
                          textAlignVertical: TextAlignVertical.top,
                          spaceBetweenSelectorAndTextField: 0,
                          textFieldController: controller.phoneController,
                          selectorConfig: const SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                            leadingPadding: Sizes.s12,
                            useBottomSheetSafeArea: true,
                            setSelectorButtonAsPrefixIcon: true,
                            trailingSpace: false,
                          ),
                          selectorTextStyle: AppTextStyles.s16w400.text2Color,
                          textStyle: AppTextStyles.s16w400.text2Color,
                          onInputChanged: (value) {
                            // controller.setIsPhone(value.parseNumber());
                            // // if (value.phoneNumber != null && value.phoneNumber!.isNotEmpty) {
                            // //   controller.setDisableLoginBtn = false;
                            // // }
                            // // controller.phoneEdit.value = value.phoneNumber ?? '';
                            if (controller.initIsoCode.value != value.isoCode) {
                              controller.initIsoCode.value =
                                  value.isoCode ?? 'VN';
                              controller.phoneController.clear();
                            }

                            // // if (controller.isoCode.value != value.isoCode) {
                            // //   controller.isoCode.value = value.isoCode ?? '';
                            // //   controller.phoneController.clear();
                            // // }
                            controller.phoneLogin.value =
                                value.phoneNumber ?? '';
                          },
                          // validator: (controller.currentUser.phone != null &&
                          //         controller.currentUser.phone!.isNotEmpty)
                          //     ? (value) {
                          //         if (value != null && value.isEmpty) {
                          //           return l10n.field_phone__error_invalid;
                          //         }

                          //         return null;
                          //       }
                          //     : null,
                          // errorMessage: controller.phoneEdit.value.isNotEmpty &&
                          //         controller.phoneEdit.value.replaceAll('+84', '').isNotEmpty
                          //     ? l10n.field_phone__error_invalid
                          //     : l10n.field_phone__error_empty,
                          // autoValidateMode: controller.currentUser.phone != null &&
                          //         controller.currentUser.phone!.isNotEmpty
                          //     ? AutovalidateMode.disabled
                          //     : AutovalidateMode.onUserInteraction,
                          inputDecoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            // hintText: context.l10n.field_phone__label,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            hintStyle: AppTextStyles.s16w400.copyWith(
                              color: AppColors.subText2,
                              fontStyle: FontStyle.italic,
                            ),
                            errorStyle: AppTextStyles.s14Base.negativeColor,
                            errorMaxLines: 2,
                            border: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.greyBorder),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.greyBorder),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                            disabledBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.greyBorder),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.greyBorder),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.greyBorder),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppButton.primary(
                  label: l10n.button__save,
                  width: double.infinity,
                  color: AppColors.blue10,
                  onPressed: () {
                    Get.back<String>(result: controller.phoneLogin.value);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    ).then((value) {
      controller.phoneEdit.value = value;
      controller.onChangeVerify();
      controller.update();
    });
  }
}
