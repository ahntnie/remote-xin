import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../models/user_story.dart';
import '../../../../base/all.dart';

class StoryViewController extends BaseController {
  final UserStory user = Get.arguments['user'];
  final int index = Get.arguments['index'];
  late PageController pageController;

  List<UserStory> userStorys = Get.arguments['userStorys'];

  @override
  void onInit() {
    super.onInit();

    pageController = PageController(initialPage: index);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }
}
