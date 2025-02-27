import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../modal/explore/explore_hash_tag.dart';
import '../../utils/app_res.dart';
import '../../utils/colors.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../hashtag/videos_by_hashtag.dart';

class ItemExplore extends StatefulWidget {
  final ExploreData exploreData;
  final MyLoading myLoading;

  const ItemExplore(
      {required this.exploreData, required this.myLoading, super.key});

  @override
  _ItemExploreState createState() => _ItemExploreState();
}

class _ItemExploreState extends State<ItemExplore> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return VideosByHashTagScreen(widget.exploreData.hashTagName);
        }));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                      '${AppRes.hashTag}${widget.exploreData.hashTagName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.s18w700),
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideosByHashTagScreen(widget.exploreData.hashTagName),
                    ),
                  ),
                  child: Text(
                    'View all (${widget.exploreData.hashTagVideosCount})',
                    style: const TextStyle(
                      fontSize: 13,
                      color: ColorRes.colorTextLight,
                      fontFamily: FontRes.fNSfUiLight,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                )
              ],
            ),
            AppSpacing.gapH8,
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(
                widget.exploreData.hashTagProfile ?? '',
                height: 165,
                width: 1.sw,
                loadingBackgroundColor: Colors.transparent,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}
