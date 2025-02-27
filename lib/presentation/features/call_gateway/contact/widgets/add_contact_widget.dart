import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../all.dart';

class AddContactWidget extends StatelessWidget {
  AddContactWidget({required this.user, this.isAddContact = false, super.key});

  final UserContact user;
  final bool isAddContact;
  final contactController = Get.find<ContactController>();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return GetBuilder(
      init: contactController,
      initState: (state) {
        contactController.avatarUrl.value = user.contactAvatarPath ?? '';
        contactController.phoneEdit.value = user.contactPhoneNumber;
        contactController.firstNameController.text = user.contactFirstName;
        contactController.lastNameController.text = user.contactLastName;
        contactController.getRegionInfoFromPhoneNumber(user.contactPhoneNumber);
      },
      builder: (controller) {
        return CommonScaffold(
          appBar: CommonAppBar(
            onLeadingPressed: () {
              Get.back();
            },
            titleType: AppBarTitle.none,
            titleWidget: Text(
              context.l10n.text_new_contact,
              style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
            ).clickable(() => Get.back()),
            leadingIconColor: AppColors.text2,
            centerTitle: false,
            actions: [
              Obx(() => Text(
                    isAddContact
                        ? context.l10n.text_create
                        : context.l10n.button__change,
                    style: AppTextStyles.s16w500.text2Color.copyWith(
                      color: controller.isValidForm.value
                          ? AppColors.pacificBlue
                          : null,
                    ),
                  ).clickable(() {
                    if (formKey.currentState!.validate()) {
                      if (isAddContact) {
                        controller.addContact();
                      } else {
                        controller.updateContact(user);
                      }
                      Get.back();
                    }
                  })),
            ],
          ),
          body: Padding(
            padding: AppSpacing.edgeInsetsAll20,
            child: Column(
              children: [
                Row(
                  children: [
                    controller.isAvatarLocal.value
                        ? Container(
                            width: 80,
                            height: 80,
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
                        : isAddContact
                            ? CircleAvatar(
                                backgroundColor: AppColors.blue11,
                                radius: 40,
                                child: AppIcon(
                                  icon: AppIcons.camera,
                                  size: 32,
                                ),
                              ).clickable(() {
                                controller.getImageFromGallery();
                              })
                            : AppCircleAvatar(
                                size: 80,
                                url: user.user?.avatarPath ?? '',
                              ),
                    AppSpacing.gapW20,
                    Expanded(
                      child: Column(
                        children: [
                          AppTextField(
                            controller: controller.firstNameController,
                            border: InputBorder.none,
                            style: AppTextStyles.s18Base.text2Color,
                            hintText: context.l10n.text_first_name,
                            hintStyle: AppTextStyles.s16Base.subText2Color,
                            contentPadding: EdgeInsets.zero,
                            // validator: (value) {
                            //   if (value != null && value.isEmpty) {
                            //     return context
                            //         .l10n.field__first_name_error_empty;
                            //   }

                            //   return null;
                            // },
                            // autovalidateMode: AutovalidateMode.always,
                          ),
                          Obx(
                            () => controller.isValidFirstName.value
                                ? const SizedBox()
                                : AppSpacing.gapH12,
                          ),
                          AppSpacing.gapH12,
                          Divider(
                            height: 0.5,
                            color: AppColors.grey3.withOpacity(0.5),
                          ),
                          AppTextField(
                            controller: controller.lastNameController,
                            border: InputBorder.none,
                            style: AppTextStyles.s18Base.text2Color,
                            hintText: context.l10n.text_last_name,
                            hintStyle: AppTextStyles.s16Base.subText2Color,
                            contentPadding: EdgeInsets.zero,
                            // autovalidateMode: AutovalidateMode.always,
                            // validator: (value) {
                            //   if (value != null && value.isEmpty) {
                            //     return context
                            //         .l10n.field__last_name_error_empty;
                            //   }

                            //   return null;
                            // },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: formKey,
                        child: InternationalPhoneNumberInput(
                          initialValue:
                              PhoneNumber(isoCode: controller.isoCode.value),
                          cursorColor: AppColors.text2,
                          keyboardAction: TextInputAction.done,
                          textAlignVertical: TextAlignVertical.top,
                          spaceBetweenSelectorAndTextField: 0,
                          textFieldController: controller.phoneController,
                          formatInput: false,
                          // focusNode: controller.phoneFocus,
                          isEnabled: isAddContact ? true : false,
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
                            controller.phoneEdit.value =
                                value.phoneNumber ?? '';
                            LogUtil.e(value.phoneNumber);
                            if (controller.isoCode.value != value.isoCode) {
                              controller.isoCode.value = value.isoCode ?? '';
                              controller.phoneController.clear();
                            }
                          },
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return context.l10n.field_phone__error_empty;
                            }
                            final String result =
                                value?.replaceAll(' ', '') ?? '';
                            if (int.tryParse(result) == null) {
                              return context.l10n.field_phone__error_invalid;
                            }
                            return null;
                          },
                          errorMessage: context.l10n.field_phone__error_invalid,
                          // autoValidateMode: AutovalidateMode.always,
                          inputDecoration: InputDecoration(
                            fillColor: AppColors.text1,
                            filled: true,
                            hintText: context.l10n.field_phone__label,
                            contentPadding:
                                const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            hintStyle: AppTextStyles.s16w500.subText2Color,
                            errorStyle: AppTextStyles.s14Base.negativeColor,
                            errorMaxLines: 2,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
