import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bubbly_camera/bubbly_camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../languages/languages_keys.dart';
import '../../main.dart';
import '../../utils/assert_image.dart';
import '../../utils/colors.dart';
import '../../utils/font_res.dart';
import '../../utils/key_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';
import '../camera/camera_screen.dart';
import '../explore/explore_screen.dart';
import '../home/home_screen.dart';
import '../login/login_sheet.dart';
import '../notification/notifiation_screen.dart';
import 'widget/end_user_license_agreement.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final List<Widget> mListOfWidget = [
    const HomeScreen(),
    const ExploreScreen(),
    const NotificationScreen(),
    // ProfileScreen(
    //   type: 0,
    //   userId: SessionManager.userId.toString(),
    // ),
  ];

  final SessionManager _sessionManager = SessionManager();
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    initPref();
    // initBranchIO();
  }

  // void initBranchIO() {
  //   FlutterBranchSdk.initSession().listen(
  //     (data) {
  //       if (data.containsKey('+clicked_branch_link') &&
  //           data['+clicked_branch_link'] == true) {
  //         if (data[UrlRes.postId] != null) {
  //           final String postId = '${data[UrlRes.postId]}';
  //           ApiService().getPostByPostId(postId).then((value) {
  //             final List<Data> list = List<Data>.generate(
  //               1,
  //               (index) {
  //                 return Data.fromJson(
  //                   value.data?.toJson(),
  //                 );
  //               },
  //             );
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) {
  //                 return VideoListScreen(
  //                   list: list,
  //                   index: 0,
  //                   type: 6,
  //                 );
  //               }),
  //             );
  //           });
  //         } else if (data[UrlRes.userId] != null) {
  //           // Navigator.push(
  //           //   context,
  //           //   MaterialPageRoute(
  //           //     builder: (context) => ProfileScreen(
  //           //       type: 1,
  //           //       userId: data[UrlRes.userId],
  //           //     ),
  //           //   ),
  //           // );
  //         }
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Consumer<MyLoading>(
        builder: (context, myLoading, child) {
          return BottomNavigationBar(
            backgroundColor:
                myLoading.isDark ? ColorRes.colorPrimaryDark : ColorRes.white,
            selectedItemColor: ColorRes.colorIcon,
            unselectedItemColor: ColorRes.colorTextLight,
            type: BottomNavigationBarType.fixed,
            onTap: (value) async {
              myLoading.setSelectedItem(value);
              isLogin = sessionManager.getBool(KeyRes.login) ?? false;
              if (value > 1 && SessionManager.userId == -1 || !isLogin) {
                log(value.toString());
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return LoginSheet();
                  },
                ).then((value) {
                  myLoading.setSelectedItem(0);
                });
              } else {
                if (value == 2) {
                  final PermissionStatus status =
                      await Permission.camera.request();
                  if (Platform.isAndroid && status.isGranted) {
                    final PermissionStatus micro =
                        await Permission.microphone.request();
                    if (micro.isGranted) {
                      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                      final AndroidDeviceInfo androidInfo =
                          await deviceInfo.androidInfo;
                      if (androidInfo.version.sdkInt >= 33) {
                        final PermissionStatus photo =
                            await Permission.photos.request();
                        final PermissionStatus video =
                            await Permission.videos.request();
                        if (photo.isGranted == true &&
                            video.isGranted == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return const CameraScreen();
                            }),
                          ).then((value) async {
                            _afterCameraScreenOff();
                          });
                        }
                      } else {
                        final PermissionStatus status =
                            await Permission.storage.request();
                        if (status.isGranted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScreen(),
                            ),
                          ).then((value) async {
                            _afterCameraScreenOff();
                          });
                        }
                      }
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CameraScreen(),
                      ),
                    ).then((value) async {
                      _afterCameraScreenOff();
                    });
                  }
                }
              }
            },
            selectedLabelStyle: const TextStyle(
                fontFamily: FontRes.fNSfUiLight,
                color: ColorRes.colorIcon,
                height: 1.5,
                fontSize: 11),
            unselectedLabelStyle: const TextStyle(
                fontFamily: FontRes.fNSfUiLight, height: 1.5, fontSize: 11),
            showUnselectedLabels: true,
            showSelectedLabels: true,
            currentIndex: myLoading.getSelectedItem,
            items: [
              BottomNavigationBarItem(
                  icon: Image(
                      height: 22,
                      width: 22,
                      image: const AssetImage(icHome),
                      color: myLoading.getSelectedItem == 0
                          ? ColorRes.colorIcon
                          : ColorRes.colorTextLight),
                  label: LKey.home.tr),
              BottomNavigationBarItem(
                  icon: Image(
                      height: 22,
                      width: 22,
                      image: const AssetImage(icExplore),
                      color: myLoading.getSelectedItem == 1
                          ? ColorRes.colorIcon
                          : ColorRes.colorTextLight),
                  label: LKey.explore.tr),
              BottomNavigationBarItem(
                  icon: Container(
                    height: 25,
                    width: 25,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [ColorRes.colorTheme, ColorRes.colorPink]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: ColorRes.white, size: 25),
                  ),
                  label: LKey.create.tr),
              BottomNavigationBarItem(
                  icon: Image(
                      height: 22,
                      width: 22,
                      image: const AssetImage(icNotification),
                      color: myLoading.getSelectedItem == 3
                          ? ColorRes.colorIcon
                          : ColorRes.colorTextLight),
                  label: LKey.notification.tr),
              BottomNavigationBarItem(
                  icon: Image(
                      height: 22,
                      width: 22,
                      image: const AssetImage(icUser),
                      color: myLoading.getSelectedItem == 4
                          ? ColorRes.colorIcon
                          : ColorRes.colorTextLight),
                  label: LKey.profile.tr),
            ],
          );
        },
      ),
      body: Consumer<MyLoading>(
        builder: (context, value, child) {
          return mListOfWidget[value.getSelectedItem >= 2
              ? value.getSelectedItem - 1
              : value.getSelectedItem];
        },
      ),
    );
  }

  Future<void> initPref() async {
    await _sessionManager.initPref();
    isLogin = _sessionManager.getBool(KeyRes.login) ?? false;
    if (Platform.isIOS && !_sessionManager.getBool(KeyRes.isAccepted)!) {
      Timer(
        const Duration(seconds: 1),
        () {
          Get.bottomSheet(
            EndUserLicenseAgreement(sessionManager: _sessionManager),
            isScrollControlled: true,
            isDismissible: false,
            backgroundColor: Colors.transparent,
            enableDrag: false,
          );
        },
      );
    }
  }

  Future<void> _afterCameraScreenOff() async {
    Provider.of<MyLoading>(context, listen: false).setSelectedItem(1);
    await Future.delayed(const Duration(seconds: 1));
    await BubblyCamera.cameraDispose;
  }
}
