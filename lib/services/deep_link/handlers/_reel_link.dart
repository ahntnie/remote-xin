import 'dart:async';

import 'package:get/get.dart';

import '../../../core/enums/item_video_from_page_enums.dart';
import '../../../presentation/features/short_video/view/video/video_list_screen.dart';
import '../../../repositories/short-video/short_video_repo.dart';
import '../deep_link_service.dart';

class ReelLinkHandler extends DeepLinkHandler {
  final shortVideoRepo = Get.find<ShortVideoRepository>();

  @override
  String get prefix => '/general/reels';

  @override
  Future<void> handle(dynamic id) async {
    final video = await shortVideoRepo.getDetailVideo(int.tryParse(id) ?? -1);
    unawaited(
      Get.to(() => VideoListScreen(
            list: [video],
            index: 0,
            type: 2,
            onComment: (index, count) {},
            onLike: (index, isLiked, count) {},
            onDelete: (p0) {},
            onPinned: (id, value) {},
            onBookmark: (index, value) {},
            onFollowed: (index, value) {},
            fromPage: ItemVideoFromPageEnum.deeplink,
          )),
    );
  }
}
