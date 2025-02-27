import 'package:flutter/material.dart';

import '../../api/api_service.dart';
import '../../custom_view/data_not_found.dart';
import '../../modal/sound/sound.dart';

class SearchMusic extends StatefulWidget {
  final List<SoundList> soundList;
  final Function onSoundClick;
  final Function(Function(String)) onSearchTextChange;

  const SearchMusic(
      {required this.soundList,
      required this.onSoundClick,
      required this.onSearchTextChange,
      super.key});

  @override
  _SearchMusicState createState() => _SearchMusicState();
}

class _SearchMusicState extends State<SearchMusic> {
  bool isSearch = true;
  ApiService apiService = ApiService();
  List<SoundList> soundList = [];
  List<SoundList> filterList = [];

  @override
  void initState() {
    if (widget.soundList.isNotEmpty) {
      soundList = widget.soundList;
      filterList = widget.soundList;
      widget.onSearchTextChange((value) {
        filterList = [];
        filterList = soundList.where((element) {
          return element.soundTitle!.contains(value) ||
              element.soundTitle!.toLowerCase().contains(value);
        }).toList();
      });
      setState(() {});
    } else {
      widget.onSearchTextChange((value) {
        filterList = [];
        getSearchSoundList(value);
      });
      getSearchSoundList('');
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return filterList.isNotEmpty
        ? ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: filterList.length,
            itemBuilder: (context, index) {
              return null;

              // return MusicCard(
              //   soundList: filterList[index],
              //   onItemClick: (soundUrl) {
              //     widget.onSoundClick(soundUrl);
              //   },
              //   type: 3,
              // );
            },
          )
        : const DataNotFound();
  }

  void getSearchSoundList(String keyword) {
    print('🛑');
    apiService.getSearchSoundList(keyword).then((value) {
      print('============ ${value.data?.length}');
      final List<String> searchIds =
          filterList.map((e) => '${e.soundId}').toList();

      value.data?.map((e) {
        if (!searchIds.contains('${e.soundId}')) {
          filterList.add(e);
        }
        setState(() {});
      });
    });
  }
}
