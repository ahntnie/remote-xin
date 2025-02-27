import 'package:flutter/material.dart';

import '../../../../base/all.dart';
import '../controllers/story_controller.dart';
import 'widget/story_widget.dart';

class StoryViewNewFeed extends BaseView<StoryViewController> {
  const StoryViewNewFeed({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        // if (controller.isUpdateProfileFirstLogin) {
        //   return Future.value(false);
        // }

        return Future.value(true);
      },
      child: PageView(
        controller: controller.pageController,
        children: controller.userStorys
            .map(
              (user) => StoryWidget(
                user: user,
                controller: controller.pageController,
                storyController: controller,
              ),
            )
            .toList(),
      ),
    );
  }
}
