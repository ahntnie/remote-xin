import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../custom_view/banner_ads_widget.dart';
import '../../languages/languages_keys.dart';
import '../../utils/colors.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import 'widget/chat_list.dart';
import 'widget/notification_list.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  PageController controller = PageController();

  @override
  void initState() {
    controller = PageController(
        initialPage: Provider.of<MyLoading>(context, listen: false)
            .getNotificationPageIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyLoading>(
      builder: (context, myLoading, child) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      myLoading.setNotificationPageIndex(0);
                      controller.animateToPage(0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.linear);
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(left: 15, top: 20, bottom: 15),
                      child: Text(
                        LKey.notifications.tr,
                        style: TextStyle(
                          color: myLoading.isDark
                              ? myLoading.getNotificationPageIndex == 0
                                  ? ColorRes.white
                                  : ColorRes.colorTextLight
                              : myLoading.getNotificationPageIndex == 0
                                  ? ColorRes.colorPrimaryDark
                                  : ColorRes.colorPrimaryDark.withOpacity(0.5),
                          fontFamily: FontRes.fNSfUiBold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 2,
                    color: myLoading.isDark
                        ? ColorRes.white
                        : ColorRes.colorPrimaryDark,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  InkWell(
                    onTap: () {
                      myLoading.setNotificationPageIndex(1);
                      controller.animateToPage(1,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.linear);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(
                        LKey.chats.tr,
                        style: TextStyle(
                          color: myLoading.isDark
                              ? myLoading.getNotificationPageIndex == 1
                                  ? ColorRes.white
                                  : ColorRes.colorTextLight
                              : myLoading.getNotificationPageIndex == 1
                                  ? ColorRes.colorPrimaryDark
                                  : ColorRes.colorPrimaryDark.withOpacity(0.5),
                          fontFamily: FontRes.fNSfUiBold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView(
                  controller: controller,
                  onPageChanged: (value) =>
                      myLoading.setNotificationPageIndex(value),
                  children: [
                    const NotificationList(),
                    ChatList(
                      myLoading: myLoading,
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const BannerAdsWidget()
            ],
          ),
        ),
      ),
    );
  }
}
