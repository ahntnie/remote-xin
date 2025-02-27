import 'dart:async';

import 'package:get/get.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../core/all.dart';
import '../presentation/features/chat/dashboard/controllers/dashboard_controller.dart';
import '../presentation/features/chat/shared_to_chat/shared_to_chat_view.dart';

class ReceiveSharingIntentService extends GetxService with LogMixin {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  @override
  void onClose() {
    _intentSub.cancel();
    super.onClose();
  }

  Future<void> _init() async {
    // Listen to media sharing coming from outside the app while the app is in the memory.
    _intentSub =
        ReceiveSharingIntent.instance.getMediaStream().listen((value) async {
      ViewUtil.showToast(
        title: Get.context?.l10n.notification__title ?? 'Notifiaction',
        message: Get.context?.l10n.global__loading ?? 'Loading...',
      );
      _sharedFiles.clear();
      _sharedFiles.addAll(value);

      final file =
          await MediaHelper.pickMultipleMediaFromGalleryShared(_sharedFiles);

      // add file shared to create post
      // final postController = Get.find<PostsController>();

      // postController.createPost(
      //   posts: postController.posts,
      //   listMediaShared: file,
      // );
      if (file.isNotEmpty) {
        Get.find<ChatDashboardController>().messageTextController.clear();
        await ViewUtil.showBottomSheet(
          isScrollControlled: true,
          isFullScreen: true,
          child: SharedToChatView(
            type: SharedToChatType.file,
            listMediaShared: file,
          ),
        );
      }

      LogUtil.i(_sharedFiles.map((f) => f.toMap()));
    }, onError: (err) {
      print('getIntentDataStream error: $err');
    });

    // Get the media sharing coming from outside the app while the app is closed.
    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      _sharedFiles.clear();
      _sharedFiles.addAll(value);
      LogUtil.i(_sharedFiles.map((f) => f.toMap()));

      // Tell the library that we are done processing the intent.
      ReceiveSharingIntent.instance.reset();
    });
  }
}
