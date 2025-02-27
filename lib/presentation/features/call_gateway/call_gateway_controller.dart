import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/all.dart';
import 'contact/all.dart';

const _kInitialIndex = 2;

class CallGatewayController extends BaseController
    with GetTickerProviderStateMixin {
  final _contactController = Get.put(ContactController());

  RxInt currentIndex = _kInitialIndex.obs;
  PageController pageController = PageController(initialPage: _kInitialIndex);

  RxBool initFirstTimeGetContact = true.obs;

  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    currentIndex.value = 0;
    tabController.addListener(() {
      currentIndex.value = tabController.index;
      if (tabController.index == 1 && initFirstTimeGetContact.value) {
        _contactController.getUserContacts();
        initFirstTimeGetContact.value = false;
      }
    });
    update();

    initFirstTimeGetContact.value = true;
    super.onInit();
  }

  set changeTab(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
    update();

    // Load contact list when user switch to contact tab
    if (index == 0 && initFirstTimeGetContact.value) {
      _contactController.getUserContacts();
      initFirstTimeGetContact.value = false;
    }
  }
}
