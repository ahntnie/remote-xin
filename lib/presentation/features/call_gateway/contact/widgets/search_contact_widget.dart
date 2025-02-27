import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/styles/styles.dart';
import '../all.dart';

class SearchContactWidget extends BaseView<ContactController> {
  const SearchContactWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.s16,
              vertical: Sizes.s16,
            ),
            child: buildAppBar(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.s16,
            ),
            child: CustomSearchBar(
              autofocus: false,
              hintText: context.l10n.global__search,
              onClear: () {
                controller.searchContact('');
              },
              prefixIcon: AppIcon(
                icon: AppIcons.search,
                color: AppColors.subText2,
              ),
              onChanged: (value) {
                controller.changeSearching = value.isNotEmpty;

                controller.searchContact(value);
              },
            ),
          ),
          buildListContact(),
        ],
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: AppIcon(
            icon: AppIcons.arrowLeft,
            color: AppColors.pacificBlue,
          ),
        ),
        Text(
          context.l10n.call__search_contact,
          style: AppTextStyles.s20w600.copyWith(color: AppColors.pacificBlue),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  Widget buildListContact() {
    return Obx(
      () => Expanded(
        child: controller.isSearching.value
            ? ListView.builder(
                padding:
                    const EdgeInsets.only(top: Sizes.s16, bottom: Sizes.s16),
                itemCount: controller.contactsSearching.length,
                itemBuilder: (context, index) {
                  final user = controller.contactsSearching[index];

                  return _buildItemContact(
                    user: user,
                    isLast: index == controller.usersList.length - 1,
                  );
                },
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.only(top: Sizes.s16, bottom: Sizes.s16),
                itemCount: controller.usersList.length,
                itemBuilder: (context, index) {
                  final user = controller.usersList[index];

                  return _buildItemContact(
                    user: user,
                    isLast: index == controller.usersList.length - 1,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildItemContact({
    required UserContact user,
    bool isLast = false,
  }) {
    final name = user.fullName.removeAllWhitespace.isNotEmpty
        ? user.fullName
        : user.contactPhoneNumber;

    final Widget header = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.s16,
      ),
      child: Row(
        children: [
          AppCircleAvatar(
            url: user.contactAvatarPath ?? '',
            size: Sizes.s48,
          ),
          const SizedBox(width: Sizes.s8),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.s16w500.copyWith(color: AppColors.text2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return GetBuilder<ContactController>(
      init: controller,
      builder: (controller) {
        return GestureDetector(
          onTap: () {
            controller.updateExpanded(user);
          },
          child: Container(
            decoration: BoxDecoration(
              color: user.isExpanded
                  ? const Color(0xff9493AC).withOpacity(0.08)
                  : Colors.transparent,
            ),
            child: Column(
              children: [
                AppSpacing.gapH12,
                header,
                AnimatedCrossFade(
                  firstChild: Container(height: 0.0),
                  secondChild: _buildExpandedItemContact(
                    user: user,
                    isLast: isLast,
                  ),
                  firstCurve: const Interval(
                    0.0,
                    0.6,
                    curve: Curves.fastOutSlowIn,
                  ),
                  secondCurve: const Interval(
                    0.4,
                    1.0,
                    curve: Curves.fastOutSlowIn,
                  ),
                  sizeCurve: Curves.fastOutSlowIn,
                  crossFadeState: user.isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                ),
                AppSpacing.gapH12,
                if (user.isExpanded) ...[
                  const Divider(
                    color: AppColors.grey6,
                    height: 1,
                  ),
                ] else ...[
                  if (!isLast) ...[
                    const Divider(
                      color: AppColors.grey6,
                      height: 1,
                      indent: 64,
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedItemContact({
    required UserContact user,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 68,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.gapH4,
          Text(
            user.contactPhoneNumber,
            style: AppTextStyles.s16w500.copyWith(color: AppColors.text2),
          ),
          AppSpacing.gapH4,
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  controller.onCallVoice(user);
                },
                child: Container(
                  padding: const EdgeInsets.all(Sizes.s8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepSkyBlue,
                  ),
                  child: AppIcon(icon: AppIcons.call),
                ),
              ),
              AppSpacing.gapW24,
              GestureDetector(
                onTap: () {
                  controller.onVideoCall(user);
                },
                child: Container(
                  padding: const EdgeInsets.all(Sizes.s8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepSkyBlue,
                  ),
                  child: AppIcon(
                    icon: AppIcons.video,
                  ),
                ),
              ),
              AppSpacing.gapW24,
              GestureDetector(
                onTap: () {
                  controller.goToPrivateChat(user);
                },
                child: Container(
                  padding: const EdgeInsets.all(Sizes.s8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepSkyBlue,
                  ),
                  child: AppIcon(
                    icon: AppIcons.chat,
                  ),
                ),
              ),
              // if (user.isExpanded)
            ],
          ),
        ],
      ),
    );
  }
}
