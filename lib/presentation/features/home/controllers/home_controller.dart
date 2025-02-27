import 'dart:async';
import 'dart:io';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../repositories/all.dart';
import '../../../../repositories/short-video/short_video_repo.dart';
import '../../../base/all.dart';
import '../../../common_controller.dart/app_controller.dart';
import '../../../common_controller.dart/language_controller.dart';
import '../../../resource/resource.dart';
import '../../auth/login/views/widgets/bottom_sheet_choose_number.dart';
import '../../call/call.dart';
import '../../short_video/modal/user_video/user_video.dart';

class HomeController extends BaseController {
  RxInt currentIndex = 0.obs;
  PageController pageController = PageController(initialPage: 0);
  RxBool isShowBottomBar = true.obs;
  var timeScrollBottomNavItem = 0.obs;
  final shortVideoRepo = Get.find<ShortVideoRepository>();
  bool isAllowVerifyPhone = false;
  final _authRepository = Get.find<AuthRepository>();

  set changeTab(int index) {
    if (index == currentIndex.value) {
      return;
    }

    if ((index - currentIndex.value).abs() > 1) {
      // Khoảng cách quá lớn, sử dụng jumpToPage
      pageController.jumpToPage(index);
      timeScrollBottomNavItem.value = 260 * (index - currentIndex.value).abs();
      if ((index - currentIndex.value).abs() == 4) {
        timeScrollBottomNavItem.value = 0;
      }
    } else {
      // Khoảng cách nhỏ, sử dụng animateToPage
      // pageController.animateToPage(
      //   index,
      //   duration: const Duration(milliseconds: 400),
      //   curve: Curves.linear,
      // );
      pageController.jumpToPage(index);
      timeScrollBottomNavItem.value = 500;
    }
    currentIndex.value = index;
  }

  @override
  void onInit() {
    checkSystemAlertWindowPermission();
    checkPermissionFullScreen();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkNFT();
    });
    CallKitManager.instance.checkCallFromAppTerminatedState();
    super.onInit();

    updateUserTalkLanguageDefault();
    unawaited(getVerify());
    cacheVideoReels();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void setIsShowBottomBar(bool value) {
    isShowBottomBar.value = value;
  }

  Future checkNFT() async {
    if (currentUser.nftNumber == null ||
        currentUser.nftNumber!.isEmpty ||
        currentUser.nftNumber == 'null') {
      await showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        enableDrag: false,
        useRootNavigator: true,
        isDismissible: false,
        builder: (context) => BottomSheetChooseNumber(
          currentUser: currentUser,
          type: 'login',
        ),
        useSafeArea: true,
      );
    }
  }

  Future cacheVideoReels() async {
    final initReels = await shortVideoRepo.readInitReels();
    if (initReels) {
      unawaited(shortVideoRepo.cacheVideo(
        'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734280369/IMG_1083_bzbax0.mp4',
        onProgress: (received, total) {
          logError(received);
        },
      ));
      unawaited(shortVideoRepo.writeVideo(Data(
        postId: 97,
        userId: 1505,
        fullName: 'Hồ Quang',
        userName: 'Quang',
        userProfile:
            'https://minio.xintel.info/backend/uploads/public/673/573/223/673573223c4d4579529089.jpg',
        postVideo: '',
        soundId: 1,
        videoLikesOrNot: 0,
        sound:
            'https://res.cloudinary.com/dxgbkcpvy/video/upload/v1734591664/videoplayback_mp3cut.net_grdr6r.m4a',
        soundImage:
            'https://photo-resize-zmp3.zmdcdn.me/w256_r1x1_jpeg/cover/8/c/1/6/8c166e2b9a0e45ca9a6c7bef40a81f74.jpg',
        singer: 'Dương Domic',
        soundTitle: 'Mất Kết Nối',
        postLikesCount: 10,
      )));

      unawaited(shortVideoRepo.writeInitReels());
    }
  }

  Future getVerify() async {
    final code = await _authRepository.getIsVerify();
    isAllowVerifyPhone = code;
  }

  Future checkPermissionFullScreen() async {
    final canUseFullScreenIntent =
        await ConnectycubeFlutterCallKit.canUseFullScreenIntent();

    if (!canUseFullScreenIntent) {
      await ConnectycubeFlutterCallKit.provideFullScreenIntentAccess();
    }
  }

  Future<void> checkSystemAlertWindowPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 31) {
        if (await Permission.systemAlertWindow.isDenied) {
          unawaited(
            Get.dialog(
              AlertDialog(
                backgroundColor: AppColors.white,
                title: Text(
                  l10n.permission_required__title,
                  style: AppTextStyles.s20w600.copyWith(color: AppColors.text2),
                ),
                content: Text(
                  l10n.call__permission_system_alert,
                  style: AppTextStyles.s18w600.copyWith(color: AppColors.text2),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Permission.systemAlertWindow.request().then((status) {
                        if (status.isGranted) {
                          Get.back();
                        }
                      });
                    },
                    child: Text(
                      l10n.allow,
                      style: AppTextStyles.s16w600
                          .copyWith(color: AppColors.text2),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text(
                      l10n.later,
                      style: AppTextStyles.s16w600
                          .copyWith(color: AppColors.text2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
  }

  final UserRepository _userRepo = Get.find();

  Future<void> updateUserTalkLanguageDefault() async {
    if (currentUser.talkLanguage != null &&
        currentUser.talkLanguage!.isNotEmpty &&
        currentUser.talkLanguage != 'null') {
      return;
    }
    final languageController = Get.find<LanguageController>();

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
      isSearchGlobal: currentUser.isSearchGlobal ?? true,
      isShowEmail: currentUser.isShowEmail ?? true,
      isShowPhone: currentUser.isShowPhone ?? true,
      isShowNft: currentUser.isShowNft ?? true,
      isShowGender: currentUser.isShowGender ?? true,
      isShowBirthday: currentUser.isShowBirthday ?? true,
      isShowLocation: currentUser.isShowLocation ?? true,
      talkLanguage:
          languages[languageController.currentIndex.value]['talkCode'] ?? '',
      nftNumber: currentUser.nftNumber ?? '',
    );

    if (rowSuccess == 1) {
      final userUpdated = await _userRepo.getUserById(currentUser.id);

      Get.find<AppController>().setLoggedUser(userUpdated);
    }
  }
}
