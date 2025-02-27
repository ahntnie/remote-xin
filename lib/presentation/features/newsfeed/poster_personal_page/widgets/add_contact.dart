import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../user/my_profile/controllers/my_profile_controller.dart';

class AddContact extends StatefulWidget {
  final User user;
  final bool isAddContact;
  final bool isEditContact;
  final MyProfileController controller;
  final UserContact? userContact;

  const AddContact({
    required this.controller,
    required this.user,
    this.isAddContact = false,
    this.isEditContact = false,
    this.userContact,
    super.key,
  });

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String isoCode = 'VN';

  Future<void> getRegionInfoFromPhoneNumber(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      isoCode = 'VN';

      return;
    }

    final PhoneNumber phoneNumberParse =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber);

    final String phoneParsableNumber =
        await PhoneNumber.getParsableNumber(phoneNumberParse);

    isoCode = phoneNumberParse.isoCode ?? '';
    _phoneController.text = phoneParsableNumber;
  }

  @override
  void initState() {
    _phoneController.text = widget.user.phone ?? '';
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;

    if (widget.isAddContact == false) {
      _firstNameController.text = widget.userContact?.contactFirstName ?? '';
      _lastNameController.text = widget.userContact?.contactLastName ?? '';
    }

    getRegionInfoFromPhoneNumber(widget.user.phone ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        onLeadingPressed: () {
          Get.back();
        },
        titleType: AppBarTitle.none,
        titleWidget: Text(
          context.l10n.call__contact,
          style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
        ).clickable(() => Get.back()),
        leadingIconColor: AppColors.text2,
        centerTitle: false,
        actions: [
          Text(
            context.l10n.button__done,
            style: AppTextStyles.s16w400.text2Color,
          ).clickable(() async {
            if (widget.isAddContact) {
              final UserContact userContact = UserContact(
                contactId: widget.user.id,
                contactPhoneNumber: widget.user.phone ?? '',
                contactFirstName: _firstNameController.text,
                contactLastName: _lastNameController.text,
              );

              widget.controller.onAddContactClick(userContact: userContact);
            } else {
              final UserContact userContact = UserContact(
                id: widget.controller.currentUserContact?.id ?? 0,
                contactPhoneNumber: widget.user.phone ?? '',
                contactFirstName: _firstNameController.text,
                contactLastName: _lastNameController.text,
              );

              widget.controller.updateContact(userContact);
            }
          }),
        ],
      ),
      body: Container(
        color: AppColors.text1,
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.s32,
        ),
        child: GestureDetector(
          onTap: () {
            ViewUtil.hideKeyboard(context);
          },
          child: Column(
            children: [
              // Expanded(
              //   child: ListView(
              //     children: [
              //       _buildAvatar(
              //         widget.user.avatarPath ?? '',
              //       ),
              //       _buildTextFieldName(
              //         label: context.l10n.contact__last_name,
              //         controller: _lastNameController,
              //         textInputAction: TextInputAction.next,
              //       ),
              //       _buildTextFieldName(
              //         label: context.l10n.contact__first_name,
              //         controller: _firstNameController,
              //         textInputAction: TextInputAction.next,
              //       ),
              //       _buildTextFieldPhone(
              //         context,
              //         user: widget.user,
              //         textEditingController: _phoneController,
              //         isoCode: isoCode,
              //         enabled: false,
              //       ),
              //       AppSpacing.gapH28,
              //     ],
              //   ),
              // ),
              Column(
                children: [
                  Row(
                    children: [
                      AppCircleAvatar(
                        size: 80,
                        url: widget.user.avatarPath ?? '',
                      ),
                      AppSpacing.gapW20,
                      Expanded(
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _firstNameController,
                              border: InputBorder.none,
                              style: AppTextStyles.s18Base.text2Color,
                              hintText: context.l10n.text_first_name,
                              hintStyle: AppTextStyles.s16Base.subText2Color,
                              contentPadding: EdgeInsets.zero,
                            ),
                            Divider(
                              height: 0.5,
                              color: AppColors.grey3.withOpacity(0.5),
                            ),
                            AppTextField(
                              controller: _lastNameController,
                              border: InputBorder.none,
                              style: AppTextStyles.s18Base.text2Color,
                              hintText: context.l10n.text_last_name,
                              hintStyle: AppTextStyles.s16Base.subText2Color,
                              contentPadding: EdgeInsets.zero,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InternationalPhoneNumberInput(
                          initialValue: PhoneNumber(isoCode: isoCode),
                          keyboardAction: TextInputAction.done,
                          textAlignVertical: TextAlignVertical.top,
                          spaceBetweenSelectorAndTextField: 0,
                          textFieldController: _phoneController,
                          formatInput: false,
                          // focusNode: controller.phoneFocus,
                          isEnabled: false,
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
                            // controller.phoneEdit.value =
                            //     value.phoneNumber ?? '';
                            // LogUtil.e(value.phoneNumber);
                            // if (controller.isoCode.value != value.isoCode) {
                            //   controller.isoCode.value = value.isoCode ?? '';
                            //   controller.phoneController.clear();
                            // }
                            _phoneController.text = value.phoneNumber ?? '';

                            if (isoCode != value.isoCode) {
                              isoCode = value.isoCode ?? '';
                              _phoneController.clear();
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
                          // autoValidateMode:
                          //     AutovalidateMode.onUserInteraction,
                          inputDecoration: InputDecoration(
                              fillColor: AppColors.text1,
                              filled: true,
                              hintText: context.l10n.field_phone__label,
                              contentPadding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 16),
                              hintStyle: AppTextStyles.s16w500.subText2Color,
                              errorStyle: AppTextStyles.s14Base.negativeColor,
                              errorMaxLines: 2,
                              border: InputBorder.none),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required void Function() action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.l10n.button__cancel,
          style: AppTextStyles.s16w400.text2Color,
        ).clickable(Get.back),
        Text(
          context.l10n.button__done,
          style: AppTextStyles.s16w400.text2Color,
        ).clickable(action),
      ],
    );
  }

  Widget _buildAvatar(String avatarUrl) {
    return Align(
      child: AppCircleAvatar(
        url: avatarUrl,
        size: 100,
      ),
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
    required User user,
    required TextEditingController textEditingController,
    required String isoCode,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: Sizes.s16),
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
            _phoneController.text = value.phoneNumber ?? '';

            if (isoCode != value.isoCode) {
              isoCode = value.isoCode ?? '';
              _phoneController.clear();
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
              borderSide: BorderSide(color: AppColors.greyBorder),
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
}
