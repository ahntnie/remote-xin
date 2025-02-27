import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../../core/all.dart';
import '../../../../../models/user.dart';
import '../../../../base/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import 'search_contact_controller.dart';

class SearchContactView extends BaseView<SearchContactController> {
  const SearchContactView({super.key});

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(
        titleType: AppBarTitle.none,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => AppTextField(
                    controller: controller.searchController,
                    hintText: l10n.call__search_contact,
                    prefixIcon: AppIcon(
                      icon: AppIcons.search,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        controller.changeSearching = true;
                      } else if (value.isEmpty) {
                        controller.changeSearching = false;
                      }

                      controller.searchUserPagingController.refresh();
                    },
                    suffixIcon: controller.isSearching.value
                        ? AppIcon(
                            icon: AppIcons.close,
                            onTap: () {
                              controller.searchController.clear();
                              controller.searchUserPagingController.refresh();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Text(
                l10n.button__cancel,
                style: AppTextStyles.s16w500,
              ).paddingOnly(left: Sizes.s12).clickable(() {
                Get.back();
              }),
            ],
          ).paddingSymmetric(horizontal: Sizes.s20),
          Expanded(
            child: PagedListView<int, User>.separated(
              shrinkWrap: true,
              pagingController: controller.searchUserPagingController,
              builderDelegate: PagedChildBuilderDelegate<User>(
                animateTransitions: true,
                itemBuilder: (context, item, index) => _buildItemSearch(item),
              ),
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.stoke,
              ),
            ).paddingOnly(
              left: Sizes.s20,
              right: Sizes.s20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemSearch(User user) {
    return Row(
      children: [
        AppCircleAvatar(
          url: user.avatarPath ?? '',
          size: Sizes.s48,
        ).paddingOnly(right: Sizes.s12),
        Text(
          user.fullName,
          style: AppTextStyles.s16w400,
        ),
      ],
    ).paddingOnly(top: Sizes.s16, bottom: Sizes.s16);
  }
}
