import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../../../common_widgets/all.dart';
import '../../../routing/routing.dart';

class NumpadAppBar extends CommonAppBar {
  NumpadAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      titleType: AppBarTitle.none,
      actions: [
        AppIcon(
          icon: AppIcons.search,
          onTap: () {
            Get.toNamed(Routes.searchContact, arguments: {'type': 'chat'});
          },
        ),
      ],
    );
  }
}
