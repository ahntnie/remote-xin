import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../common_widgets/all.dart';
import '../../../common_widgets/app_header.dart';
import '../../../resource/resource.dart';
import '../../all.dart';
import '../controllers/search_user_controller.dart';
import 'widgets/_user_item.dart';

class CreateChatSearchUsersBottomSheet extends StatefulWidget {
  const CreateChatSearchUsersBottomSheet({
    Key? key,
    this.allowSelectMultiple = true,
    this.title,
    this.hintText,
  }) : super(key: key);

  final bool allowSelectMultiple;
  final String? title;
  final String? hintText;

  @override
  State<CreateChatSearchUsersBottomSheet> createState() =>
      _CreateChatSearchUsersBottomSheetState();
}

class _CreateChatSearchUsersBottomSheetState
    extends State<CreateChatSearchUsersBottomSheet> {
  bool _isCreatingGroup = false;
  FocusNode nameGroup = FocusNode();

  void _onCreateGroup() {
    nameGroup.requestFocus();
    setState(() {
      _isCreatingGroup = true;
    });
  }

  final List<User> _selectedUsers = [];

  void _onSelected(User user) {
    if (!_isCreatingGroup) {
      Get.back(result: [user]);
    }

    setState(() {
      _selectedUsers.contains(user)
          ? _selectedUsers.remove(user)
          : _selectedUsers.add(user);
    });
  }

  void _onSubmit() {
    Get.back(result: _selectedUsers);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return GetBuilder(
      init: SearchUserController(),
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            ViewUtil.hideKeyboard(context);
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.s20,
              vertical: Sizes.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: AppHeader()),
                AppSpacing.gapH20,
                _buildHeader(context),
                AppSpacing.gapH20,
                if (_isCreatingGroup) _buildNameGroupField(),
                if (_isCreatingGroup) AppSpacing.gapH4,
                _buildSearchField(context, controller),
                AppSpacing.gapH12,
                // Visibility(
                //     visible: _isCreatingGroup, child: _buildConversationTitle()),
                if (widget.allowSelectMultiple)
                  _buildCreateGroupButton(context),
                if (!_isCreatingGroup) AppSpacing.gapH20,
                if (!_isCreatingGroup)
                  Text(
                    context.l10n.text_suggest,
                    style: AppTextStyles.s18w600.text2Color,
                  ),
                if (!_isCreatingGroup) AppSpacing.gapH12,
                if (_selectedUsers.isNotEmpty)
                  Visibility(
                    visible: !keyboardVisible,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedUsers.length,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.only(right: 30),
                          width: 60,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      bottom: 0,
                                      child: AppCircleAvatar(
                                          size: 57,
                                          url: _selectedUsers[index]
                                                  .avatarPath ??
                                              ''),
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.grey11),
                                        child: AppIcon(
                                            icon: AppIcon(
                                          icon: AppIcons.close,
                                          color: AppColors.text2,
                                        )),
                                      ).clickable(() {
                                        _onSelected(_selectedUsers[index]);
                                      }),
                                    )
                                  ],
                                ),
                              ),
                              AppSpacing.gapH4,
                              Expanded(
                                child: Text(
                                  _selectedUsers[index]
                                          .fullName
                                          .trim()
                                          .isNotEmpty
                                      ? _selectedUsers[index].fullName.trim()
                                      : _selectedUsers[index].phone ?? '',
                                  style: AppTextStyles.s12w500.text2Color,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                Expanded(
                  child: Obx(
                    () => Container(
                      margin: _isCreatingGroup
                          ? const EdgeInsets.only(top: 12)
                          : EdgeInsets.zero,
                      padding: _isCreatingGroup
                          ? AppSpacing.edgeInsetsAll16
                          : EdgeInsets.zero,
                      decoration: _isCreatingGroup
                          ? BoxDecoration(
                              color: AppColors.grey11,
                              borderRadius: BorderRadius.circular(12))
                          : null,
                      child: ListView.separated(
                        itemCount: controller.users.length,
                        separatorBuilder: (context, index) => AppSpacing.gapH20,
                        itemBuilder: (context, index) {
                          final user = controller.users[index];

                          return UserItem(
                            key: ValueKey(user.id),
                            user: user,
                            isSelected: _selectedUsers.contains(user),
                            isSelectable: _isCreatingGroup,
                            onTap: () {
                              _onSelected(user);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConversationTitle() {
    final controller = Get.find<ChatDashboardController>();
    return _buildTextFieldName(
      label: context.l10n.create_group_chat__name,
      controller: controller.conversationNameController,
      textInputAction: TextInputAction.next,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        prefixIcon: enabled
            ? AppIcon(
                icon: AppIcons.edit,
                color: AppColors.subText2,
                padding: const EdgeInsets.only(right: Sizes.s2),
              )
            : null,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.greyBorder),
          borderRadius: BorderRadius.all(Radius.circular(53)),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        AppIcon(
          icon: AppIcons.arrowLeft,
          color: Colors.black,
          onTap: () => Get.back(),
        ),
        AppSpacing.gapW8,
        Text(
          widget.title != null
              ? widget.title ?? ''
              : !_isCreatingGroup
                  ? context.l10n.text_new_message
                  : context.l10n.text_new_group,
          style: AppTextStyles.s16w700.text2Color,
        ).clickable(() {
          Get.back();
        }),
        const Spacer(),
        Opacity(
          opacity: _isCreatingGroup ? 1 : 0,
          child: IgnorePointer(
            ignoring: !_isCreatingGroup,
            child: Text(
              context.l10n.button__create,
              style: AppTextStyles.s16w400.toColor(
                _selectedUsers.isNotEmpty
                    ? AppColors.blue10
                    : AppColors.subText2,
              ),
            ).clickable(_onSubmit),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    SearchUserController controller,
  ) {
    return CustomSearchBar(
      hintText: context.l10n.text_find_people,
      onChanged: controller.searchUser,
      prefixIcon: AppIcon(
        icon: AppIcons.search,
        color: AppColors.grey10,
      ),
    );
  }

  Widget _buildNameGroupField() {
    final controller = Get.find<ChatDashboardController>();
    return AppTextField(
      focusNode: nameGroup,
      controller: controller.conversationNameController,
      contentPadding: const EdgeInsets.only(bottom: 10),
      border: InputBorder.none,
      hintText: context.l10n.text_name_group,
      hintStyle: AppTextStyles.s16w400.subText2Color,
    );
  }

  Widget _buildCreateGroupButton(BuildContext context) {
    if (_isCreatingGroup) {
      return AppSpacing.emptyBox;
    }

    return Row(
      children: [
        AppIcon(
          isCircle: true,
          icon: AppIcons.createGroup,
          color: Colors.black,
        ),
        AppSpacing.gapW8,
        Text(
          context.l10n.chat_create__create_group_label,
          style: AppTextStyles.s16w400
              .copyWith(color: AppColors.text2, fontWeight: FontWeight.w300),
        ),
      ],
    ).clickable(_onCreateGroup);
  }
}
