import 'dart:async';

import 'package:get/get.dart';

import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../../services/newsfeed_interact_service.dart';
import '../../../base/all.dart';
import '../../all.dart';

class PostDetailController extends BaseController {
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  final postController = Get.find<PostsController>();
  final personalPageController = Get.find<PersonalPageController>();
  final sharePostController = Get.find<SharePostController>();

  late int postId;
  late bool isShowComment;
  late bool isPostInHome;
  late bool isFocus;

  RxList<Post> postDetail = <Post>[].obs;

  @override
  Future<void> onInit() async {
    postId = Get.arguments['postId'] as int;
    isShowComment = Get.arguments['isShowComment'] as bool? ?? false;
    isPostInHome = Get.arguments['isPostInHome'] as bool? ?? false;
    isFocus = Get.arguments['isFocus'] as bool? ?? false;
    Get.find<NewsfeedInteractService>().viewPost(postId);

    super.onInit();
    await getPostDetail();
  }

  Future<void> getPostDetail() async {
    await runAction(
      action: () async {
        final Post result = await _newsFeedRepository.getPostDetail(postId);

        postDetail.add(result);
        update();
      },
      onError: (exception) {},
    );
  }
}
