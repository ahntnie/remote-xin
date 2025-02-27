import 'package:flutter/material.dart';

import '../../../api/api_service.dart';
import '../../../modal/sound/sound.dart';

class FavouritePage extends StatefulWidget {
  final Function? onClick;

  const FavouritePage({super.key, this.onClick});

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  List<SoundList> favMusicList = [];

  @override
  void initState() {
    getFavouriteSoundList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 5),
      itemCount: favMusicList.length,
      itemBuilder: (context, index) {
        return null;

        // return MusicCard(
        //   soundList: favMusicList[index],
        //   onItemClick: (sound) {
        //     widget.onClick!(sound);
        //   },
        //   onFavouriteCall: () {
        //     favMusicList.remove(favMusicList[index]);
        //     setState(() {});
        //   },
        //   type: 2,
        // );
      },
    );
  }

  void getFavouriteSoundList() {
    ApiService().getFavouriteSoundList().then((value) {
      favMusicList = value.data ?? [];
      setState(() {});
    });
  }
}
