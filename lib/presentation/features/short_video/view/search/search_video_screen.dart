import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../custom_view/common_ui.dart';
import '../../custom_view/data_not_found.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/const_res.dart';
import '../../utils/session_manager.dart';
import 'widget/item_search_video.dart';

class SearchVideoScreen extends StatefulWidget {
  final Function(Function(String) value) onCallback;

  const SearchVideoScreen({
    required this.onCallback,
    Key? key,
  }) : super(key: key);

  @override
  _SearchVideoScreenState createState() => _SearchVideoScreenState();
}

class _SearchVideoScreenState extends State<SearchVideoScreen> {
  String keyWord = '';
  ApiService apiService = ApiService();

  int start = 0;
  final ScrollController _scrollController = ScrollController();
  bool isApiCallFirstTime = true;
  List<Data> searchPostList = [];

  bool isLoading = true;

  @override
  void initState() {
    widget.onCallback.call((p0) {
      setState(() {
        keyWord = p0;
        searchPostList = [];
        callApiForPostList(keyWord);
      });
    });
    print(keyWord);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        if (!isLoading) {
          isLoading = true;
          callApiForPostList(keyWord);
        }
      }
    });
    callApiForPostList(keyWord);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isApiCallFirstTime
        ? LoaderDialog()
        : searchPostList.isEmpty
            ? DataNotFound()
            : GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1 / 1.4,
                ),
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 10, bottom: 20),
                children: List.generate(
                  searchPostList.length,
                  (index) => ItemSearchVideo(
                      videoData: searchPostList[index],
                      postList: searchPostList,
                      type: 5,
                      keyWord: keyWord),
                ),
              );
  }

  void callApiForPostList(String value) {
    if (isApiCallFirstTime) {
      isApiCallFirstTime = true;
    }
    apiService
        .getSearchPostList('${searchPostList.length}', '$paginationLimit',
            '${SessionManager.userId}', value)
        .then(
      (value) {
        isApiCallFirstTime = false;

        start += paginationLimit;
        isLoading = false;
        final List<String> searchPostIds =
            searchPostList.map((e) => e.userId.toString()).toList();

        if (mounted) {
          setState(() {
            value.data?.forEach((element) {
              if (!searchPostIds.contains('${element.userId}')) {
                searchPostList.add(element);
              }
            });
          });
        }
      },
    );
  }
}
