import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../custom_view/image_place_holder.dart';
import '../../languages/languages_keys.dart';
import '../../modal/user/user.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import 'item_followers_page.dart';

class FollowerScreen extends StatelessWidget {
  final UserData? userData;

  const FollowerScreen(this.userData, {super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController(
        initialPage: Provider.of<MyLoading>(context, listen: false)
            .getFollowerPageIndex);
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 55,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 35,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      constraints: const BoxConstraints(minWidth: 110),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(500),
                            child: Image.network(
                              ConstRes.itemBaseUrl + userData!.userProfile!,
                              fit: BoxFit.cover,
                              height: 30,
                              width: 30,
                              errorBuilder: (context, error, stackTrace) {
                                return ImagePlaceHolder(
                                  name: userData?.fullName,
                                  heightWeight: 25,
                                  fontSize: 20,
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            '@${userData!.userName}',
                            style: const TextStyle(
                                fontSize: 20, fontFamily: FontRes.fNSfUiBold),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 0,
            color: ColorRes.colorTextLight,
            margin: const EdgeInsets.only(bottom: 5),
          ),
          Consumer<MyLoading>(
            builder: (BuildContext context, value, Widget? child) {
              return Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        pageController.animateToPage(0,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear);
                      },
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(
                            color: ColorRes.colorPrimary,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Center(
                          child: Text(
                            '${userData!.followersCount} ${LKey.followers.tr}',
                            style: TextStyle(
                              color: value.getFollowerPageIndex == 0
                                  ? ColorRes.colorTheme
                                  : ColorRes.colorTextLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.linear);
                      },
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(
                            color: ColorRes.colorPrimary,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Center(
                          child: Text(
                            '${userData!.followingCount} ${LKey.following.tr}',
                            style: TextStyle(
                              color: value.getFollowerPageIndex == 1
                                  ? ColorRes.colorTheme
                                  : ColorRes.colorTextLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const BouncingScrollPhysics(),
              children: [
                ItemFollowersPage(userData?.userId, 0),
                ItemFollowersPage(userData?.userId, 1),
              ],
              onPageChanged: (value) {
                Provider.of<MyLoading>(context, listen: false)
                    .setFollowerPageIndex(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
