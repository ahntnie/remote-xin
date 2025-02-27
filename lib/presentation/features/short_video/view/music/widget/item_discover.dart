import 'package:flutter/material.dart';

import '../../../modal/sound/sound.dart';

class ItemDiscover extends StatelessWidget {
  final List<SoundList> soundData;
  final Function onMoreClick;
  final Function? onPlayClick;

  const ItemDiscover(this.soundData, this.onMoreClick, this.onPlayClick,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        //   child: Row(
        //     children: [
        //       Expanded(
        //         child: Text(
        //           soundData.soundCategoryName ?? '',
        //           style: const TextStyle(
        //               color: ColorRes.colorTheme,
        //               overflow: TextOverflow.ellipsis,
        //               fontFamily: FontRes.fNSfUiSemiBold,
        //               fontSize: 16),
        //         ),
        //       ),
        //       InkWell(
        //         onTap: () {
        //           onMoreClick.call(soundData.soundList);
        //         },
        //         child: Row(
        //           children: [
        //             Text(
        //               LKey.more.tr,
        //               style: const TextStyle(
        //                 color: ColorRes.colorTextLight,
        //               ),
        //             ),
        //             const SizedBox(
        //               width: 8,
        //             ),
        //             const Image(
        //               width: 20,
        //               height: 20,
        //               image: AssetImage(icMenu),
        //               color: ColorRes.colorTheme,
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: soundData.length,
          itemBuilder: (context, index) {
            return null;

            // return null;

            // return MusicCard(
            //     soundList: soundData[index],
            //     onItemClick: (soundUrl) {
            //       onPlayClick!(soundUrl);
            //     },
            //     type: 1);
          },
        )
      ],
    );
  }
}
