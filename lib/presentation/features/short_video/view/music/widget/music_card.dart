import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../../modal/sound/sound.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../../utils/session_manager.dart';

class MusicCard extends StatefulWidget {
  final SoundList soundList;
  final Function onItemClick;
  final int type;
  final Function? onFavouriteCall;
  final Function onPlay;
  final bool isPlay;

  const MusicCard(
      {required this.soundList,
      required this.onItemClick,
      required this.type,
      required this.onPlay,
      required this.isPlay,
      super.key,
      this.onFavouriteCall});

  @override
  _MusicCardState createState() => _MusicCardState();
}

class _MusicCardState extends State<MusicCard> {
  final SessionManager sessionManager = SessionManager();

  @override
  void initState() {
    initSessionManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onItemClick(widget.soundList);
      },
      child: Container(
        height: 70,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<MyLoading>(
              builder: (context, value, child) => Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: AppNetworkImage(
                        widget.soundList.soundImage ?? '',
                        width: 70,
                        height: 70,
                      )),
                  // Visibility(
                  //   visible: value.lastSelectSoundId ==
                  //       '${widget.soundList.sound!}${widget.type}',
                  //   child: Align(
                  //     child: Container(
                  //       height: 30,
                  //       width: 30,
                  //       decoration: const BoxDecoration(
                  //         color: Colors.black54,
                  //         shape: BoxShape.circle,
                  //       ),
                  //       child: Icon(
                  //         !value.getLastSelectSoundIsPlay
                  //             ? Icons.play_arrow_rounded
                  //             : Icons.pause_rounded,
                  //         color: ColorRes.white,
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.soundList.soundTitle ?? '',
                    style: const TextStyle(
                        fontSize: 16,
                        fontFamily: FontRes.fNSfUiSemiBold,
                        color: ColorRes.colorTextLight),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    widget.soundList.singer ?? '',
                    style: const TextStyle(
                        color: ColorRes.colorTextLight, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    widget.soundList.duration!,
                    style: const TextStyle(
                      color: ColorRes.colorTextLight,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
            ),
            Icon(
              widget.isPlay ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColors.blue10,
              size: 30,
            ).clickable(() {
              widget.onPlay();
            }),
            // InkWell(
            //   onTap: () {
            //     sessionManager
            //         .saveFavouriteMusic(widget.soundList.soundId.toString());
            //     widget.onFavouriteCall?.call();
            //     setState(() {});
            //   },
            //   child: Icon(
            //     sessionManager
            //             .getFavouriteMusic()
            //             .contains(widget.soundList.soundId.toString())
            //         ? Icons.bookmark
            //         : Icons.bookmark_border_rounded,
            //     color: ColorRes.colorTheme,
            //   ),
            // ),
            // Consumer<MyLoading>(
            //   builder: (context, value, child) => Visibility(
            //     visible: value.lastSelectSoundId ==
            //         widget.soundList.sound! + widget.type.toString(),
            //     child: InkWell(
            //       onTap: () async {
            //         Provider.of<MyLoading>(context, listen: false)
            //             .setIsDownloadClick(true);
            //         widget.onItemClick(widget.soundList);
            //       },
            //       child: Container(
            //         width: 50,
            //         height: 25,
            //         margin: const EdgeInsets.only(left: 10),
            //         decoration: const BoxDecoration(
            //           borderRadius: BorderRadius.all(Radius.circular(5)),
            //           color: ColorRes.colorTheme,
            //         ),
            //         child: const Icon(
            //           Icons.check_rounded,
            //           color: ColorRes.white,
            //           size: 20,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> initSessionManager() async {
    sessionManager.initPref().then((value) {
      setState(() {});
    });
  }
}
