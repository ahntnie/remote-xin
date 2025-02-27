import 'dart:developer';
import 'dart:io';

import 'package:bubbly_camera/bubbly_camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../common_widgets/app_icon.dart';
import '../../../modal/user/user.dart';
import '../../camera/camera_screen.dart';

class TopBarProfile extends StatelessWidget {
  final bool isDarkMode;

  final UserData? userData;
  final bool isMyProfile;
  final bool isBlock;
  final VoidCallback onBlockApiCall;

  const TopBarProfile(
      {required this.isDarkMode,
      required this.isMyProfile,
      required this.isBlock,
      required this.onBlockApiCall,
      Key? key,
      this.userData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          AppIcon(
            icon: AppIcons.arrowLeft,
            color: Colors.black,
            onTap: () => Get.back(),
          ),
          const Spacer(),
          if (isMyProfile)
            AppIcon(
              icon: AppIcons.addTab,
              color: Colors.black,
              onTap: () async {
                final PermissionStatus status =
                    await Permission.camera.request();
                if (Platform.isAndroid && status.isGranted) {
                  final PermissionStatus micro =
                      await Permission.microphone.request();
                  if (micro.isGranted) {
                    final PermissionStatus photo =
                        await Permission.photos.request();
                    final PermissionStatus video =
                        await Permission.videos.request();
                    if (photo.isGranted && video.isGranted) {
                      log('message');
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
              },
            )
        ],
      ),
    );
  }

  Future<void> _afterCameraScreenOff() async {
    await Future.delayed(const Duration(seconds: 1));
    await BubblyCamera.cameraDispose;
  }
}
