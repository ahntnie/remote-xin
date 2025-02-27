import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/all.dart';
import '../../../../../../models/nft_number.dart';
import '../../../../../../repositories/all.dart';
import '../../../../../common_controller.dart/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../common_widgets/app_check_box.dart';
import '../../../../../common_widgets/app_divider.dart';
import '../../../../../resource/resource.dart';

class BottomSheetChooseNumber extends StatefulWidget {
  final User currentUser;
  final String type;
  const BottomSheetChooseNumber({
    required this.currentUser,
    required this.type,
    super.key,
  });

  @override
  State<BottomSheetChooseNumber> createState() =>
      _BottomSheetChooseNumberState();
}

class _BottomSheetChooseNumberState extends State<BottomSheetChooseNumber> {
  TextEditingController searchController = TextEditingController();
  int? currentIndex;
  List<NftNumber> phoneNumbers = [];
  bool isLoading = true;
  bool isLoadingButton = false;
  final AuthRepository authService = Get.find();

  @override
  void initState() {
    super.initState();
    getListPhoneNumber();
  }

  Future getListPhoneNumber() async {
    setState(() {
      isLoading = true;
    });

    phoneNumbers =
        await authService.getListNumber(widget.currentUser.email ?? '');

    setState(() {
      isLoading = false;
    });
  }

  Future updateNFTNumber() async {
    setState(() {
      isLoadingButton = true;
    });
    final data = await authService.updateNFTNumber(
      widget.currentUser.email ?? '',
      phoneNumbers[currentIndex ?? 0].id,
      phoneNumbers[currentIndex ?? 0].number,
    );
    if (data) {
      Get.back();
      ViewUtil.showToast(
        title: context.l10n.global__success_title,
        message: context.l10n.profile__updated_success,
      );
      final UserRepository userRepo = Get.find();
      final User currentUser =
          await userRepo.getUserById(widget.currentUser.id);
      Get.find<AppController>().setLoggedUser(currentUser);
    } else {
      ViewUtil.showToast(
        title: context.l10n.global__success_title,
        message: context.l10n.profile__updated_error,
      );
    }
  }

  Widget _buildBackground() => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
      );

  Widget _buildAppbar() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.gapH36,
          Text(
            Get.context!.l10n.text_choose_number,
            style: AppTextStyles.s26w700.toColor(AppColors.blue10),
          ),
          AppSpacing.gapH8,
          Text(
            Get.context!.l10n.text_description_choose_number,
            style: AppTextStyles.s14w500.toColor(AppColors.grey8),
          ),
          AppSpacing.gapH36,
        ],
      ).paddingOnly(left: 12);

  // Widget _buildSearch() => Container(
  //       padding: const EdgeInsets.only(left: Sizes.s16),
  //       margin: const EdgeInsets.all(Sizes.s8),
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         color: Colors.transparent,
  //         border: Border.all(
  //           color: AppColors.border3,
  //         ),
  //         borderRadius: BorderRadius.circular(100),
  //       ),
  //       child: Row(
  //         children: [
  //           AppIcon(
  //             icon: AppIcons.searchLg,
  //             color: AppColors.border3,
  //           ),
  //           AppSpacing.gapW8,
  //           Expanded(
  //             child: TextField(
  //               controller: searchController,
  //               keyboardType: TextInputType.number,
  //               style: const TextStyle(color: Colors.black),
  //               decoration: InputDecoration(
  //                 hintStyle: const TextStyle(color: AppColors.border2),
  //                 border: InputBorder.none,
  //                 hintText: Get.context!.l10n.global__search,
  //               ),
  //               cursorColor: AppColors.border3,
  //               onChanged: (value) {
  //                 setState(() {});
  //               },
  //             ),
  //           ),
  //           AppIcon(icon: AppIcons.refresh).clickable(() {
  //             getListPhoneNumber();
  //           }),
  //           IconButton(
  //             icon: AppIcon(icon: AppIcons.close),
  //             onPressed: () {
  //               setState(() {
  //                 searchController.clear();
  //               });
  //             },
  //           ),
  //         ],
  //       ),
  //     );

  Widget _buildListNumber() => Expanded(
        child: isLoading
            ? const Center(
                child: AppDefaultLoading(),
              )
            : Padding(
                padding: AppSpacing.edgeInsetsH12,
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(left: 12, right: 30),
                    child: AppDivider(
                      color: AppColors.subText3,
                      height: 1,
                    ),
                  ),
                  itemCount: phoneNumbers.length,
                  itemBuilder: (context, index) {
                    return searchController.text == '' ||
                            phoneNumbers[index]
                                .number
                                .contains(searchController.text)
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                            child: Row(
                              children: [
                                AppSpacing.gapW12,
                                Expanded(
                                  child: Text(
                                    phoneNumbers[index].number,
                                    style: AppTextStyles.s16Base.text2Color,
                                  ),
                                ),
                                AppCheckBox(
                                  value: currentIndex == index,
                                  onChanged: (value) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                ),
                              ],
                            ),
                          )
                        : Container();
                  },
                ),
              ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackground(),
          Padding(
            padding: const EdgeInsets.all(Sizes.s8),
            child: Column(
              children: [_buildAppbar(), _buildListNumber()],
            ),
          ),
        ],
      ),
      floatingActionButton: AppButton.primary(
        onPressed: () {
          if (widget.type == 'login') {
            updateNFTNumber();
          } else {
            ViewUtil.showAppSnackBar(context, 'register');
          }
        },
        label: context.l10n.choose,
        width: 0.8.sw,
        isDisabled: currentIndex == null,
        isLoading: isLoadingButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
