import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../custom_view/app_bar_custom.dart';
import '../../languages/languages_keys.dart';
import 'widget/setting_center_area.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBarCustom(title: LKey.settings.tr),
          const SettingCenterArea()
        ],
      ),
    );
  }
}
