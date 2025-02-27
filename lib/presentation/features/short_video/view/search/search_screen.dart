import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../languages/languages_keys.dart';
import '../../utils/colors.dart';
import '../../utils/my_loading/my_loading.dart';
import 'search_user_screen.dart';
import 'search_video_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final PageController _pageController = PageController();
  int pageIndex = 0;
  TextEditingController searchController = TextEditingController();

  Function(String)? onSearching;

  void searchText(Function(String) value) {
    onSearching = value;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_left, size: 35),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Container(
                        height: 45,
                        margin: const EdgeInsets.only(right: 15),
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, bottom: 5),
                        decoration: BoxDecoration(
                          color: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(50)),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: LKey.search.tr,
                              hintStyle: const TextStyle(fontSize: 15)),
                          onChanged: (value) {
                            onSearching?.call(searchController.text);
                            myLoading.setSearchText(value);
                          },
                          style: const TextStyle(fontSize: 15),
                          cursorColor: ColorRes.colorTextLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          searchController = TextEditingController();
                          onSearching?.call(searchController.text);
                          _pageController.animateToPage(0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.linear);
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: myLoading.isDark
                                ? ColorRes.colorPrimary
                                : ColorRes.greyShade100,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Center(
                            child: Text(
                              LKey.videos.tr,
                              style: TextStyle(
                                color: pageIndex == 0
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
                          searchController = TextEditingController();
                          onSearching?.call(searchController.text);
                          _pageController.animateToPage(1,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.linear);
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: myLoading.isDark
                                ? ColorRes.colorPrimary
                                : ColorRes.greyShade100,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Center(
                            child: Text(
                              LKey.users.tr,
                              style: TextStyle(
                                  color: pageIndex == 1
                                      ? ColorRes.colorTheme
                                      : ColorRes.colorTextLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return index == 0
                          ? SearchVideoScreen(
                              onCallback: searchText,
                            )
                          : SearchUserScreen(
                              onCallback: searchText,
                            );
                    },
                    onPageChanged: (value) {
                      pageIndex = value;
                      myLoading.setSearchPageIndex(value);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
