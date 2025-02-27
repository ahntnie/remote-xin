import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../custom_view/image_place_holder.dart';
import '../../../languages/languages_keys.dart';
import '../../../modal/user_video/user_video.dart';
import '../../../utils/app_res.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/font_res.dart';

class ItemFollowing extends StatelessWidget {
  final Data data;
  final VideoPlayerController? videoPlayerController;

  const ItemFollowing(this.data, this.videoPlayerController, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) {
        //       return ProfileScreen(
        //         type: 1,
        //         userId: "${data.userId ?? '-1'}",
        //       );
        //     },
        //   ),
        // );
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: VisibilityDetector(
              onVisibilityChanged: (VisibilityInfo info) {
                final visiblePercentage = info.visibleFraction * 100;
                if (visiblePercentage > 50) {
                  videoPlayerController?.play();
                } else {
                  videoPlayerController?.pause();
                }
              },
              key: Key('ke1${ConstRes.itemBaseUrl}${data.postVideo!}'),
              child: videoPlayerController != null
                  ? VideoPlayer(videoPlayerController!)
                  : const SizedBox(),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height / 4,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  end: const Alignment(0.0, -1),
                  begin: const Alignment(0.0, 0.3),
                  colors: <Color>[
                    ColorRes.colorPrimaryDark,
                    ColorRes.colorPrimaryDark.withOpacity(0.0)
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20))),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: ColorRes.white),
                          shape: BoxShape.circle),
                      child: ClipOval(
                        child: Image.network(
                          ConstRes.itemBaseUrl + data.userProfile!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return ImagePlaceHolder(
                              heightWeight: 40,
                              name: data.fullName ?? '',
                              fontSize: 20,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.fullName?.capitalize ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontFamily: FontRes.fNSfUiSemiBold,
                                color: ColorRes.white),
                          ),
                          Text(
                            '${AppRes.atSign}${data.userName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: ColorRes.greyShade100,
                              fontFamily: FontRes.fNSfUiLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                TextButton(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(const EdgeInsets.all(0)),
                  ),
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) {
                    //       return ProfileScreen(
                    //         type: 1,
                    //         userId: "${data.userId ?? '-1'}",
                    //       );
                    //     },
                    //   ),
                    // );
                  },
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(7),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          ColorRes.colorTheme,
                          ColorRes.colorPink,
                        ],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      LKey.follow.tr,
                      style: const TextStyle(
                          fontSize: 16,
                          fontFamily: FontRes.fNSfUiSemiBold,
                          color: ColorRes.white),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
