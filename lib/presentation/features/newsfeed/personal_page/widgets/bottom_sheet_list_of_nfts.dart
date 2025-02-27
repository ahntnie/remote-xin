import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../common_widgets/app_check_box.dart';
import '../../../../common_widgets/app_divider.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';

class BottomSheetListOfNFTs extends StatefulWidget {
  const BottomSheetListOfNFTs({
    super.key,
  });

  @override
  State<BottomSheetListOfNFTs> createState() => _BottomSheetListOfNFTsState();
}

class _BottomSheetListOfNFTsState extends State<BottomSheetListOfNFTs> {
  TextEditingController searchController = TextEditingController();
  final AuthRepository authService = Get.find();
  final UserRepository _userRepo = Get.find();
  final currentUser = Get.find<PersonalPageController>().currentUser;
  int? currentIndex;
  List<String> phoneNumbers = [];
  bool isLoading = true;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    getListPhoneNumber();
  }

  Future getListPhoneNumber() async {
    try {
      setState(() {
        isLoading = true;
      });

      phoneNumbers = await authService.getMyListNFT();

      currentIndex = phoneNumbers.indexOf(currentUser.nftNumber ?? '');
      setState(() {});
    } catch (e) {
      LogUtil.e(e);
      ViewUtil.showToast(
        title: Get.context!.l10n.global__error_title,
        message: Get.context!.l10n.global__error_has_occurred,
      );

      Navigator.of(Get.context!).pop();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    try {
      await _userRepo.updateProfile(
        id: currentUser.id,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        phone: currentUser.phone ?? '',
        avatarPath: currentUser.avatarPath ?? '',
        nickname: currentUser.nickname ?? '',
        email: currentUser.email ?? '',
        gender: currentUser.gender ?? '',
        birthday: currentUser.birthday ?? '',
        location: currentUser.location ?? '',
        isSearchGlobal: currentUser.isSearchGlobal ?? true,
        isShowEmail: currentUser.isShowEmail ?? true,
        isShowPhone: currentUser.isShowPhone ?? true,
        isShowGender: currentUser.isShowGender ?? true,
        isShowNft: currentUser.isShowNft ?? true,
        isShowBirthday: currentUser.isShowBirthday ?? true,
        isShowLocation: currentUser.isShowLocation ?? true,
        nftNumber: phoneNumbers[currentIndex ?? 0],
        talkLanguage: currentUser.talkLanguage ?? '',
      );
      Get.back();
      ViewUtil.showToast(
        title: Get.context!.l10n.global__success_title,
        message: Get.context!.l10n.profile__updated_success,
      );

      final userUpdated = await _userRepo.getUserById(currentUser.id);

      Get.find<AppController>().setLoggedUser(userUpdated);
    } catch (e) {
      log(e.toString());
      ViewUtil.showToast(
        title: Get.context!.l10n.global__error_title,
        message: Get.context!.l10n.profile__updated_error,
      );
    }
  }

  Widget _buildAppbar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: AppIcon(
              icon: AppIcons.arrowLeft,
              color: AppColors.text2,
            ),
          ),
          Text(
            Get.context!.l10n.personal_page__list_nft,
            style: AppTextStyles.s20w600.text2Color,
          ),
          const SizedBox(
            width: 32,
          ),
        ],
      );

  Widget _buildListNumber() => Expanded(
        child: isLoading
            ? const Center(
                child: AppDefaultLoading(
                  color: AppColors.blue10,
                ),
              )
            : Padding(
                padding: AppSpacing.edgeInsetsH12,
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.only(left: 12, right: 30),
                    child: AppDivider(
                      color: AppColors.subText2,
                      height: 1,
                    ),
                  ),
                  itemCount: phoneNumbers.length,
                  itemBuilder: (context, index) {
                    return searchController.text == '' ||
                            phoneNumbers[index].contains(searchController.text)
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
                                    phoneNumbers[index],
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(Sizes.s8),
            child: Column(
              children: [_buildAppbar(), AppSpacing.gapH20, _buildListNumber()],
            ),
          ),
        ],
      ),
      floatingActionButton: AppButton.primary(
        onPressed: () async {
          await updateProfile();
        },
        label: context.l10n.choose,
        width: 0.8.sw,
        isDisabled: (currentIndex == null || currentIndex == -1) ||
            phoneNumbers[currentIndex ?? 0] == currentUser.nftNumber,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
