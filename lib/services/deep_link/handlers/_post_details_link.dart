import 'dart:async';

import 'package:get/get.dart';

import '../../../presentation/routing/routers/app_pages.dart';
import '../../all.dart';

class PostDetailsLinkHandler extends DeepLinkHandler {
  // final _newsfeedRepo = Get.find<NewsfeedRepository>();

  @override
  String get prefix => '/post';

  @override
  Future<void> handle(dynamic id) async {
    // final post = await _newsfeedRepo.getPostById(id);

    unawaited(Get.toNamed(
      Routes.postDetail,
      arguments: {'postId': id},
    ));
  }
}
