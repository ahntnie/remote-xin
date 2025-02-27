import 'package:flutter/material.dart';

import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../utils/my_loading/my_loading.dart';

class TabBarViewCustom extends StatefulWidget {
  final PageController pageController;
  final MyLoading myLoading;

  const TabBarViewCustom(
      {required this.pageController, required this.myLoading, Key? key})
      : super(key: key);

  @override
  State<TabBarViewCustom> createState() => _TabBarViewCustomState();
}

class _TabBarViewCustomState extends State<TabBarViewCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: !widget.myLoading.isDark
          ? ColorRes.greyShade100
          : ColorRes.colorPrimary,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (widget.pageController.hasClients) {
                        widget.pageController.animateToPage(
                          0,
                          curve: Curves.easeOut,
                          duration: const Duration(milliseconds: 200),
                        );
                      }

                      widget.myLoading.setProfilePageIndex(0);
                    },
                    child: Image.asset(
                      icCategory,
                      height: 16,
                      color: widget.myLoading.getProfilePageIndex == 0
                          ? ColorRes.white
                          : ColorRes.greyShade100.withOpacity(0.5),
                    ),
                  ),
                ),
                Container(
                    height: 20,
                    width: 1,
                    color: widget.myLoading.isDark
                        ? ColorRes.white
                        : ColorRes.colorPrimary),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (widget.pageController.hasClients) {
                        widget.pageController.animateToPage(1,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.linear);
                      }
                      widget.myLoading.setProfilePageIndex(1);
                    },
                    child: Image(
                      height: 18,
                      image: const AssetImage(icHeart),
                      color: widget.myLoading.getProfilePageIndex == 1
                          ? ColorRes.white
                          : ColorRes.greyShade100.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 0.5,
            width: double.infinity,
            color: widget.myLoading.isDark
                ? ColorRes.white
                : ColorRes.colorPrimary,
          ),
        ],
      ),
    );
  }
}
