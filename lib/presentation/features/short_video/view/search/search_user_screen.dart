import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../custom_view/common_ui.dart';
import '../../custom_view/data_not_found.dart';
import '../../modal/search/search_user.dart';
import '../../utils/const_res.dart';
import 'widget/item_search_user.dart';

class SearchUserScreen extends StatefulWidget {
  final Function(Function(String) value) onCallback;

  const SearchUserScreen({required this.onCallback, Key? key})
      : super(key: key);
  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  String keyWord = '';
  ApiService apiService = ApiService();

  int start = 0;
  final ScrollController _scrollController = ScrollController();

  List<SearchUserData> searchUserList = [];
  bool isApiCallFirstTime = true;
  bool isLoading = true;

  @override
  void initState() {
    widget.onCallback.call((p0) {
      setState(() {
        keyWord = p0;
        searchUserList = [];
        callApiForSearchUsers(keyWord);
      });
    });
    callApiForSearchUsers(keyWord);
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        if (!isLoading) {
          isLoading = true;
          callApiForSearchUsers(keyWord);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isApiCallFirstTime
        ? const LoaderDialog()
        : searchUserList.isEmpty
            ? const DataNotFound()
            : ListView(
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 10, bottom: 20),
                children: List.generate(
                  searchUserList.length,
                  (index) => ItemSearchUser(searchUserList[index]),
                ),
              );
  }

  void callApiForSearchUsers(String value) {
    if (isApiCallFirstTime) {
      isApiCallFirstTime = true;
    }
    apiService
        .getSearchUser(
            searchUserList.length.toString(), paginationLimit.toString(), value)
        .then((value) {
      isApiCallFirstTime = false;
      start += paginationLimit;
      isLoading = false;
      final List<String> searchIds =
          searchUserList.map((e) => e.userId.toString()).toList();

      if (mounted) {
        setState(() {
          value.data?.forEach((element) {
            if (!searchIds.contains('${element.userId}')) {
              searchUserList.add(element);
            }
          });
        });
      }
    });
  }
}
