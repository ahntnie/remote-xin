import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../resource/resource.dart';
import '../../custom_view/data_not_found.dart';
import '../../modal/explore/explore_hash_tag.dart';
import '../../utils/key_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';
import 'item_explore.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  int start = 0;

  final ScrollController _scrollController = ScrollController();
  SessionManager sessionManager = SessionManager();
  List<ExploreData> exploreList = [];
  bool isLoading = true;
  bool isHaseMore = true;
  bool isFirstTime = true;

  bool isLogin = false;

  final shortVideoRepo = Get.find<ShortVideoRepository>();

  @override
  void initState() {
    prefData();
    callApiExploreHashTag();
    // _scrollController.addListener(() {
    //   if (_scrollController.offset >=
    //       _scrollController.position.maxScrollExtent) {
    //     if (!isLoading) {
    //       callApiExploreHashTag();
    //     }
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppSpacing.gapH40,
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : exploreList.isEmpty
                        ? const DataNotFound()
                        : ListView(
                            padding: const EdgeInsets.only(top: 15),
                            shrinkWrap: true,
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            children: List.generate(
                              exploreList.length,
                              (index) => ItemExplore(
                                  exploreData: exploreList[index],
                                  myLoading: myLoading),
                            ),
                          ),
              ),
              const SizedBox(
                height: 10,
              ),
              // const BannerAdsWidget()
            ],
          ),
        ),
      ),
    );
  }

  void callApiExploreHashTag() {
    // if (!isHaseMore) {
    //   return;
    // }
    isLoading = true;
    shortVideoRepo.getExplore().then((value) {
      // if (isFirstTime) {
      //   isFirstTime = false;
      // }
      // if ((value.data?.length ?? 0) < paginationLimit) {
      //   isHaseMore = false;
      // }
      exploreList.addAll(value);
      isLoading = false;
      setState(() {});
    });
  }

  Future<void> prefData() async {
    await sessionManager.initPref();
    isLogin = sessionManager.getBool(KeyRes.login) ?? false;
    setState(() {});
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
