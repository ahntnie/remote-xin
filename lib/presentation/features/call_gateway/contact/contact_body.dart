import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/resource.dart';
import 'contact_controller.dart';
import 'widgets/add_contact_widget.dart';
import 'widgets/contact_info_detail.dart';
import 'widgets/shimmer_loading_contact.dart';

class ContactBody extends BaseView<ContactController> {
  const ContactBody({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ViewUtil.hideKeyboard(context);
      },
      child: RefreshIndicator(
        color: AppColors.deepSkyBlue,
        backgroundColor: Colors.white,
        onRefresh: () async {
          controller.getUserContacts(isLoading: false);
        },
        child: CommonScaffold(
          isRemoveBottomPadding: true,
          appBar: CommonAppBar(
            onLeadingPressed: () {
              Get.back();
            },
            titleType: AppBarTitle.none,
            titleWidget: Text(
              context.l10n.call__contact,
              style: AppTextStyles.s18w700.copyWith(color: AppColors.text2),
            ),
            leadingIconColor: AppColors.text2,
            centerTitle: false,
            actions: [
              AppIcon(
                icon: AppIcons.plus,
                color: AppColors.text2,
                onTap: () => Get.to(
                        () => AddContactWidget(
                              isAddContact: true,
                              user: UserContact(
                                  contactFirstName: '',
                                  contactLastName: '',
                                  contactPhoneNumber: ''),
                            ),
                        transition: Transition.rightToLeft)!
                    .then(
                  (value) {
                    controller.isoCode.value = '';
                    controller.phoneEdit.value = '';
                    controller.avatarUrl.value = '';
                    controller.phoneController.clear();
                    controller.changeIsEditContact = false;
                    controller.isAvatarLocal.value = false;
                  },
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.gapH24,
                // CustomSearchBar(
                //   autofocus: false,
                //   hintText: controller.l10n.global__search,
                //   onChanged: (value) {
                //     controller.searchContact(value);
                //   },
                //   prefixIcon: AppIcon(
                //     icon: AppIcons.search,
                //     color: AppColors.grey8,
                //   ),
                //   // searchController: controller.searchController,
                // ),

                SizedBox(
                  height: 44,
                  child: AppTextField(
                    controller: controller.searchController,
                    hintStyle: AppTextStyles.s16w400.subText2Color,
                    onChanged: (value) {
                      controller.searchContact(value);
                    },
                    prefixIcon: AppIcon(
                      icon: AppIcons.search,
                      color: AppColors.subText2,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    fillColor: AppColors.grey6,
                    borderRadius: 100,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
                AppSpacing.gapH16,
                Obx(
                  () {
                    if (controller.isSearching.value) {
                      if (controller.contactsSearching.value.isEmpty) {
                        return _buildNoContactsWidget(context);
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.contactsSearching.value.length,
                        itemBuilder: (context, index) {
                          final element =
                              controller.contactsSearching.value[index];
                          return _buildItemSearch(element).marginOnly(
                            bottom: 12,
                            top: 12,
                          );
                        },
                      );

                      return GroupedListView<UserContact, String>(
                        // controller: controller.scrollController,
                        // ignore: invalid_use_of_protected_member
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        elements: controller.contactsSearching.value.toList(),
                        groupBy: (element) => element.fullName
                            .trim()
                            .toUpperCase()
                            .toString()
                            .substring(0, 1),
                        groupSeparatorBuilder: (String groupByValue) => Text(
                          groupByValue,
                          style: AppTextStyles.s18w700.text2Color,
                        ).paddingOnly(top: Sizes.s8, bottom: Sizes.s4),
                        itemBuilder: (context, dynamic element) =>
                            _buildItemSearch(element),
                        separator: AppSpacing.gapH12,
                      );
                    } else {
                      if (controller.isLoadingInit.value) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: ListView.builder(
                            itemCount: 3,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return const ShimmerLoadingContact();
                            },
                          ),
                        );
                      }
                      if (controller.usersList.isEmpty) {
                        return _buildNoContactsWidget(context);
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.usersList.value.length,
                        itemBuilder: (context, index) {
                          final element = controller.usersList.value[index];
                          return _buildItemSearch(element)
                              .marginOnly(bottom: 12, top: 12);
                        },
                      );

                      return GroupedListView<UserContact, String>(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,

                        // physics: const AlwaysScrollableScrollPhysics(),
                        // controller: controller.scrollController,
                        // ignore: invalid_use_of_protected_member
                        elements: controller.usersList.value,
                        groupBy: (element) => element.fullName.isNotEmpty
                            ? element.fullName
                                .trim()
                                .toUpperCase()
                                .toString()
                                .substring(0, 1)
                            : '',
                        groupSeparatorBuilder: (String groupByValue) => Text(
                          groupByValue,
                          style: AppTextStyles.s18w700
                              .copyWith(color: AppColors.zambezi),
                        ).paddingOnly(top: Sizes.s8, bottom: Sizes.s4),
                        itemBuilder: (context, dynamic element) =>
                            _buildItemSearch(element),
                        separator: AppSpacing.gapH12,
                      );
                    }
                  },
                ),
              ],
            ).paddingOnly(left: 20, right: 20, bottom: 10),
          ),
        ),
      ),
    );
  }

  Widget _buildItemSearch(UserContact user) {
    return _buildExpansion(user);
  }

  void _onInfoPressed(UserContact user) {
    ViewUtil.showBottomSheet(
      child: ContactInfoDetail(
        user: user,
      ),
      isScrollControlled: true,
      isFullScreen: true,
    ).then((value) {
      controller.isoCode.value = '';
      controller.phoneEdit.value = '';
      controller.avatarUrl.value = '';
      controller.phoneController.clear();
      controller.changeIsEditContact = false;
      controller.isAvatarLocal.value = false;
    });
  }

  Widget _buildBtnIcon({required Object icon, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppColors.blue10),
        child: AppIcon(
          icon: icon,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildNoContactsWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              icon: AppIcons.contacts,
              size: 80.w,
              color: AppColors.subText2,
            ),
            AppSpacing.gapH12,
            Text(
              context.l10n.contact__no_contacts,
              style: AppTextStyles.s16w500.copyWith(
                color: AppColors.subText2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpansion(UserContact user) {
    final Widget header = GestureDetector(
      onTap: () {
        // controller.updateExpanded(user);
        controller.goToPrivateChat(user);
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: Sizes.s48,
                ),
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      AppCircleAvatar(
                        url: user.user?.avatarPath ?? '',
                        size: Sizes.s48,
                      ).paddingOnly(right: Sizes.s12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.fullName.isNotEmpty
                                ? user.fullName.trim()
                                : user.contactPhoneNumber,
                            style: AppTextStyles.s16w400.text2Color,
                          ),
                          Text(
                            (user.user?.nickname ?? '').isNotEmpty
                                ? user.user?.nickname ?? ''
                                : user.user?.fullName ?? '',
                            style: AppTextStyles.s12w400.subText2Color,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return GetBuilder<ContactController>(
      init: controller,
      builder: (controller) {
        return Column(
          children: <Widget>[
            header,
            AnimatedCrossFade(
              firstChild: Container(height: 0.0),
              secondChild: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBtnIcon(
                    icon: AppIcons.callAudio,
                    onTap: () => controller.onCallVoice(user),
                  ),
                  _buildBtnIcon(
                    icon: AppIcons.videoOn,
                    onTap: () => controller.onVideoCall(user),
                  ),
                  _buildBtnIcon(
                    icon: AppIcons.chat,
                    onTap: () {
                      controller.goToPrivateChat(user);
                    },
                  ),
                  _buildBtnIcon(
                    icon: AppIcons.info,
                    onTap: () {
                      // _onInfoPressed(user);
                      Get.to(
                              () => AddContactWidget(
                                    user: user,
                                  ),
                              transition: Transition.rightToLeft)!
                          .then(
                        (value) {
                          controller.isoCode.value = '';
                          controller.phoneEdit.value = '';
                          controller.avatarUrl.value = '';
                          controller.phoneController.clear();
                          controller.changeIsEditContact = false;
                          controller.isAvatarLocal.value = false;
                        },
                      );
                    },
                  ),
                ],
              ).paddingOnly(top: Sizes.s12),
              firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
              secondCurve:
                  const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
              sizeCurve: Curves.fastOutSlowIn,
              crossFadeState: user.isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 500),
            ),
          ],
        );
      },
    );
  }
}
