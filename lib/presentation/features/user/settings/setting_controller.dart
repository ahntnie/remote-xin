import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../data/preferences/app_preferences.dart';
import '../../../../repositories/all.dart';
import '../../../../services/all.dart';
import '../../../base/all.dart';
import '../../../common_controller.dart/all.dart';
import '../../../routing/routing.dart';

class SettingController extends BaseController {
  final AuthRepository _authRepository = Get.find();
  final UserRepository _userRepo = Get.find();
  RxString version = ''.obs;

  RxBool isLoadingBtnDeleteAccount = false.obs;

  TextEditingController deleteController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void onReady() {
    // getVerSion();
    super.onReady();
  }

  Future<void> getVerSion() async {
    final version = await AppUtil.getVersion();
    this.version.value = version;
  }

  Future<void> deleteAccount() async {
    isLoadingBtnDeleteAccount.value = true;
    update();

    try {
      if (formKey.currentState!.validate() &&
          deleteController.text == 'Delete') {
        final String code = await _authRepository.deleteAccount();

        if (code == 'user_delete_success') {
          Get.find<ChatSocketService>().disconnectSocket();
          await Get.find<AppPreferences>().deleteAllTokens();
          Get.find<AppController>().setLoggedUser(null);
          Get.find<AppController>().setLogged(false);
          await Get.offAllNamed(Routes.authOption);
        } else {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.error__delete_account,
          );
        }
      }
    } catch (e) {
      ViewUtil.showToast(
        title: l10n.global__error_title,
        message: l10n.global__error_has_occurred,
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isLoadingBtnDeleteAccount.value = false;
        update();
      });
    }
  }

  void updatePrivacy(UpdatePrivacyType type) {
    runAction(
      action: () async {
        final isSearchGlobal = currentUser.isSearchGlobal ?? true;
        final isShowEmail = currentUser.isShowEmail ?? true;
        final isShowPhone = currentUser.isShowPhone ?? true;
        final isShowNft = currentUser.isShowNft ?? true;

        final isShowGender = currentUser.isShowGender ?? true;
        final isShowBirthday = currentUser.isShowBirthday ?? true;
        final isShowLocation = currentUser.isShowLocation ?? true;

        final rowSuccess = await _userRepo.updateProfile(
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
          isSearchGlobal: (type == UpdatePrivacyType.globalSearch)
              ? !isSearchGlobal
              : isSearchGlobal,
          isShowEmail: (type == UpdatePrivacyType.showEmail)
              ? !isShowEmail
              : isShowEmail,
          isShowPhone: (type == UpdatePrivacyType.showPhone)
              ? !isShowPhone
              : isShowPhone,
          isShowGender: (type == UpdatePrivacyType.showGender)
              ? !isShowGender
              : isShowGender,
          isShowBirthday: (type == UpdatePrivacyType.showBirthDay)
              ? !isShowBirthday
              : isShowBirthday,
          isShowLocation: (type == UpdatePrivacyType.showLocation)
              ? !isShowLocation
              : isShowLocation,
          isShowNft:
              (type == UpdatePrivacyType.showNft) ? !isShowNft : isShowNft,
          nftNumber: currentUser.nftNumber ?? '',
          talkLanguage: currentUser.talkLanguage ?? '',
        );

        if (rowSuccess == 1) {
          ViewUtil.showToast(
            title: l10n.global__success_title,
            message: l10n.profile__updated_success,
          );

          final userUpdated = await _userRepo.getUserById(currentUser.id);

          Get.find<AppController>().setLoggedUser(userUpdated);

          update();
        }
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.profile__updated_error,
        );
      },
    );
  }
}

enum UpdatePrivacyType {
  globalSearch,
  showEmail,
  showPhone,
  showGender,
  showBirthDay,
  showLocation,
  showNft,
}
