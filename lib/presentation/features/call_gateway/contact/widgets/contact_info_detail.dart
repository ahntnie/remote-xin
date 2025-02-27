import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/styles/styles.dart';
import '../all.dart';

class ContactInfoDetail extends StatelessWidget {
  ContactInfoDetail({
    required this.user,
    this.isAddContact = false,
    Key? key,
  }) : super(key: key);

  final UserContact user;
  final bool isAddContact;
  final contactController = Get.find<ContactController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.text1,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.s32,
        vertical: Sizes.s28,
      ),
      child: GetBuilder(
        init: contactController,
        initState: (state) {
          contactController.avatarUrl.value = user.contactAvatarPath ?? '';
          contactController.phoneEdit.value = user.contactPhoneNumber;
          contactController.firstNameController.text = user.contactFirstName;
          contactController.lastNameController.text = user.contactLastName;
          contactController
              .getRegionInfoFromPhoneNumber(user.contactPhoneNumber);
        },
        builder: (controller) {
          return GestureDetector(
            onTap: () {
              ViewUtil.hideKeyboard(context);
            },
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  _buildHeader(
                    context,
                    controller: controller,
                    action: () {
                      if (!controller.isEditContact.value) {
                        controller.changeIsEditContact = true;
                      } else if (isAddContact) {
                        if (!controller.isDisabledBtnAdd.value) {
                          // controller.addContact();
                          Get.back();
                        }
                      } else {
                        if (!controller.isDisabledBtnEdit.value) {
                          controller.updateContact(user);
                          Get.back();
                        }
                      }
                    },
                  ),
                  AppSpacing.gapH24,
                  Expanded(
                    child: ListView(
                      children: [
                        _buildAvatar(
                          user.user?.avatarPath ?? '',
                          controller: controller,
                        ),
                        AppSpacing.gapH12,
                        _buildTextFieldName(
                          label: context.l10n.contact__last_name,
                          controller: controller.lastNameController,
                          textInputAction: TextInputAction.next,
                          enabled: controller.isEditContact.value,
                        ),
                        _buildTextFieldName(
                          label: context.l10n.contact__first_name,
                          controller: controller.firstNameController,
                          textInputAction: TextInputAction.next,
                          enabled: controller.isEditContact.value,
                        ),
                        _buildTextFieldPhone(
                          context,
                          controller: controller,
                          user: user,
                          textEditingController: controller.phoneController,
                          isoCode: controller.isoCode.value,
                          // enabled: controller.isEditContact.value,
                          enabled: isAddContact ? true : false,
                        ),
                        AppSpacing.gapH28,
                        !controller.isEditContact.value
                            ? _buildDeletePhoneNumberBtn(
                                context,
                                user: user,
                                controller: controller,
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required ContactController controller,
    required void Function() action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.button__cancel,
          style: AppTextStyles.s16w400.subText2Color,
        ).clickable(Get.back),
        Text(
          !controller.isEditContact.value
              ? context.l10n.button__change
              : context.l10n.button__done,
          style: AppTextStyles.s16w400.subText2Color,
        ).clickable(action),
      ],
    );
  }

  Widget _buildAvatar(
    String avatarUrl, {
    required ContactController controller,
  }) {
    return controller.isAvatarLocal.value
        ? Container(
            width: 120,
            height: 120,
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
            size: 120,
            url: avatarUrl,
          );
  }

  Widget _buildTextFieldName({
    required String label,
    required TextEditingController controller,
    required TextInputAction textInputAction,
    String? Function(String?)? validator,
    Function(String)? onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Sizes.s20),
      child: AppTextField(
        enabled: enabled,
        textInputAction: textInputAction,
        controller: controller,
        label: label,
        contentPadding: const EdgeInsets.all(Sizes.s16),
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.greyBorder),
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
        suffixIcon: enabled
            ? AppIcon(
                icon: AppIcons.editLight,
                color: AppColors.subText2,
                padding: const EdgeInsets.only(right: Sizes.s2),
              )
            : null,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextFieldPhone(
    BuildContext context, {
    required ContactController controller,
    required UserContact user,
    required TextEditingController textEditingController,
    required String isoCode,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.s8),
          child: SizedBox(
            height: 24,
            child: Text(context.l10n.field_phone__label,
                style: AppTextStyles.s16w500.text2Color),
          ),
        ),
        AppSpacing.gapH4,
        InternationalPhoneNumberInput(
          initialValue: PhoneNumber(isoCode: isoCode),
          keyboardAction: TextInputAction.done,
          textAlignVertical: TextAlignVertical.top,
          spaceBetweenSelectorAndTextField: 0,
          textFieldController: textEditingController,
          formatInput: false,
          // focusNode: controller.phoneFocus,
          isEnabled: enabled,
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
            controller.phoneEdit.value = value.phoneNumber ?? '';

            if (controller.isoCode.value != value.isoCode) {
              controller.isoCode.value = value.isoCode ?? '';
              controller.phoneController.clear();
            }
          },
          // validator: (value) {
          //   if (value != null && value.isEmpty) {
          //     return context.l10n.field_phone__error_empty;
          //   }
          //   if (value != null && int.tryParse(value) == null) {
          //     return context.l10n.field_phone__error_invalid;
          //   }
          //   return null;
          // },
          errorMessage: context.l10n.field_phone__error_invalid,
          autoValidateMode: AutovalidateMode.onUserInteraction,
          inputDecoration: InputDecoration(
            fillColor: AppColors.text1,
            filled: true,
            hintText: context.l10n.field_phone__label,
            contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            hintStyle: AppTextStyles.s16w400.subText1Color,
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
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            suffixIcon: enabled
                ? AppIcon(
                    icon: AppIcons.editLight,
                    color: AppColors.subText2,
                    padding: const EdgeInsets.only(right: Sizes.s20),
                  )
                : null,
            suffixIconConstraints: const BoxConstraints(
              maxWidth: Sizes.s16 + Sizes.s24 + Sizes.s8,
            ),
          ),
        ),
      ],
    ).paddingOnly(bottom: Sizes.s16);
  }

  Widget _buildDeletePhoneNumberBtn(
    BuildContext context, {
    required UserContact user,
    required ContactController controller,
  }) {
    return AppButton.primary(
      label: context.l10n.contact__delete_contact,
      width: double.infinity,
      onPressed: () {
        controller.deleteContact(user.id!);
        Get.back();
      },
      isLoading: controller.isLoading,
    );
  }

  Widget _buildChangeAvatarBtn(
    BuildContext context, {
    required ContactController controller,
    bool isAddContact = false,
  }) {
    return isAddContact
        ? const SizedBox.shrink()
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(Sizes.s2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.text4,
                  ),
                ),
                child: AppIcon(
                  icon: AppIcons.addTab,
                  color: AppColors.text4,
                  size: Sizes.s16,
                ),
              ),
              Text(
                // isAddContact
                //     ? context.l10n.contact__add_photo
                //     :
                context.l10n.contact__change_photo,
                style: AppTextStyles.s16w400.text4Color,
              ).paddingOnly(left: Sizes.s12),
            ],
          ).paddingOnly(bottom: Sizes.s24).clickable(() {
            controller.getImageFromGallery();
          });
  }
}
