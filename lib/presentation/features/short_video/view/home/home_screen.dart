import 'dart:developer';
import 'dart:io';

import 'package:bubbly_camera/bubbly_camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../../core/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../../routing/routing.dart';
import '../../../all.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';
import '../camera/camera_screen.dart';
import 'following_screen.dart';
import 'for_u_screen.dart';
import 'widget/agreement_home_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SessionManager sessionManager = SessionManager();
  int pageIndex = 0;
  final PageController controller = PageController();
  final ScrollController _scrollController = ScrollController();
  final appController = Get.find<AppController>();

  @override
  void initState() {
    // _homeAgreementDialog();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        // Provider.of<ForUController>(context, listen: false).init();
      },
    );
    super.initState();
  }

  void scrollToSelectedTab() {
    double offset = pageIndex * 100.0;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) {
        return Scaffold(
          body: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: 3,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      //Lấy ra short video đề xuất cho người dùng
                      return ForYouScreen();
                    case 1:
                      //Lấy ra short video từ người dùng user follow
                      return FollowingScreen();
                    case 2:
                    //Lấy ra short video từ bạn bè người dùng
                    default:
                      return ForYouScreen();
                  }
                },
                onPageChanged: (value) {
                  pageIndex = value;
                  scrollToSelectedTab();
                  myLoading.setIsForYouSelected(value == 1);
                },
              ),
              // const ForYouScreen(),
              SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20)
                          .copyWith(right: 12),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    controller.animateToPage(0,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInToLinear);
                                  },
                                  child: Text(
                                    context.l10n.for_you,
                                    style: TextStyle(
                                      fontSize: pageIndex == 0 ? 16 : 12,
                                      fontWeight: pageIndex == 0
                                          ? FontWeight.w800
                                          : FontWeight.w400,
                                      fontFamily: FontRes.fNSfUiSemiBold,
                                      color: pageIndex == 0
                                          ? AppColors.white
                                          : const Color(0xffdbdad6),
                                    ),
                                  ),
                                ),
                                AppSpacing.gapW16,
                                InkWell(
                                  onTap: () {
                                    controller.animateToPage(1,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInToLinear);
                                  },
                                  child: Text(
                                    context.l10n.following,
                                    style: TextStyle(
                                        fontSize: pageIndex == 1 ? 16 : 12,
                                        fontWeight: pageIndex == 1
                                            ? FontWeight.w800
                                            : FontWeight.w400,
                                        fontFamily: FontRes.fNSfUiSemiBold,
                                        color: pageIndex == 1
                                            ? AppColors.white
                                            : const Color(0xffdbdad6)),
                                  ),
                                ),
                                AppSpacing.gapW16,
                                InkWell(
                                  onTap: () {
                                    controller.animateToPage(2,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeInToLinear);
                                  },
                                  child: Text(
                                    context.l10n.short_video_from_friend,
                                    style: TextStyle(
                                        fontSize: pageIndex == 2 ? 16 : 12,
                                        fontWeight: pageIndex == 2
                                            ? FontWeight.w800
                                            : FontWeight.w400,
                                        fontFamily: FontRes.fNSfUiSemiBold,
                                        color: pageIndex == 2
                                            ? AppColors.white
                                            : const Color(0xffdbdad6)),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Spacer(),
                      AppIcon(
                        icon: AppIcons.search,
                        color: Colors.white,
                        size: 32,
                        onTap: () {
                          Get.toNamed(Routes.search,
                              arguments: {'type': 'reels'});
                        },
                      ),
                      AppSpacing.gapW16,

                      // Container(
                      //   decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       border: Border.all(color: Colors.white)),
                      //   child: AppCircleAvatar(
                      //     url: appController.lastLoggedUser?.avatarPath ?? '',
                      //     size: 28,
                      //   ).clickable(() {
                      //     Get.to(
                      //         () => ProfileScreen(
                      //               avatar: appController
                      //                       .lastLoggedUser?.avatarPath ??
                      //                   '',
                      //               nickname: appController
                      //                       .lastLoggedUser?.nickname ??
                      //                   '',
                      //               fullName: appController
                      //                       .lastLoggedUser?.fullName ??
                      //                   '',
                      //               userId:
                      //                   appController.lastLoggedUser?.id ?? 0,
                      //             ),
                      //         transition: Transition.cupertino);
                      //   }),
                      // ),
                      AppIcon(
                        icon: AppIcons.camera,
                        color: Colors.white,
                        size: 34,
                        onTap: () async {
                          log('${Get.find<HomeController>().isAllowVerifyPhone}4343');
                          if (Get.find<HomeController>().isAllowVerifyPhone) {
                            log('${Get.find<AppController>().lastLoggedUser!.isPhoneVerified}1212');
                            if (Get.find<AppController>()
                                    .lastLoggedUser!
                                    .isPhoneVerified ==
                                true) {
                              onCamera(context);
                            } else {
                              ViewUtil.showToast(
                                  title: context.l10n.global__error_title,
                                  message: context
                                      .l10n.you_need_to_verify_phone_number);
                            }
                          } else {
                            onCamera(context);
                          }
                        },
                      ),
                      AppSpacing.gapW16,
                      AppIcon(
                        icon: Assets.icons.userShort,
                        color: Colors.white,
                        size: 30,
                        onTap: () {
                          Get.toNamed(Routes.myProfile, arguments: {
                            'isMine': true,
                            'user': Get.find<AppController>().currentUser,
                            'isAddContact': false,
                          });
                        },
                      ),

                      // AppIcon(
                      //   icon: Icons.person,
                      //   size: 35,
                      //   onTap: () {
                      //     Get.to(
                      //         () => ProfileScreen(
                      //               avatar: appController
                      //                       .lastLoggedUser?.avatarPath ??
                      //                   '',
                      //               nickname: appController
                      //                       .lastLoggedUser?.nickname ??
                      //                   '',
                      //               fullName: appController
                      //                       .lastLoggedUser?.fullName ??
                      //                   '',
                      //               userId:
                      //                   appController.lastLoggedUser?.id ?? 0,
                      //             ),
                      //         transition: Transition.cupertino);
                      //   },
                      // )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _homeAgreementDialog() async {
    await Future.delayed(Duration.zero);
    Provider.of<MyLoading>(context, listen: false).getIsHomeDialogOpen
        ? showDialog(
            context: context,
            builder: (context) {
              return const AgreementHomeDialog();
            })
        : const SizedBox();
  }

  Future<void> _afterCameraScreenOff() async {
    await Future.delayed(const Duration(seconds: 1));
    await BubblyCamera.cameraDispose;
  }

  Future<void> onCamera(BuildContext context) async {
    if (await _requestCameraAndMicrophonePermissions()) {
      if (Platform.isAndroid) {
        await _handleAndroidPermissions(context);
      } else {
        _navigateToCameraScreen(context);
      }
    }
  }

  Future<bool> _requestCameraAndMicrophonePermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();
    return cameraStatus.isGranted && microphoneStatus.isGranted;
  }

  Future<void> _handleAndroidPermissions(BuildContext context) async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;

    if (androidInfo.version.sdkInt >= 33) {
      if (await _requestAndroid13Permissions()) {
        _navigateToCameraScreen(context);
      }
    } else {
      if (await _requestStoragePermission()) {
        _navigateToCameraScreen(context);
      }
    }
  }

  Future<bool> _requestAndroid13Permissions() async {
    final photosStatus = await Permission.photos.request();
    final videosStatus = await Permission.videos.request();
    return photosStatus.isGranted && videosStatus.isGranted;
  }

  Future<bool> _requestStoragePermission() async {
    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  void _navigateToCameraScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    ).then((value) {
      _afterCameraScreenOff();
    });
  }
}
