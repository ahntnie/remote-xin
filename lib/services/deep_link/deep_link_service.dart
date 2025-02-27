import 'dart:async';
import 'dart:developer';

import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';

import '../../core/mixins/log_mixin.dart';
import 'handlers/all.dart';

const _kClickedBranchLinkKey = '+clicked_branch_link';
const _kPathKey = '\$deeplink_path';

const kDeepLinkPrefix = 'https://xintravel.app.link';

class DeepLinkService extends GetxService with LogMixin {
  StreamSubscription? _sessionListStreamSubscription;

  final _handlers = [
    InviteGroupChatLinkHandler(),
    UserProfileLinkHandler(),
    PostDetailsLinkHandler(),
    ReelLinkHandler(),
  ];

  @override
  void onInit() {
    super.onInit();
    _initDeepLink();
  }

  @override
  void onClose() {
    _sessionListStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initDeepLink() async {
    await FlutterBranchSdk.init();
    // FlutterBranchSdk.validateSDKIntegration();

    _sessionListStreamSubscription = FlutterBranchSdk.listSession().listen(
      (Map<dynamic, dynamic> data) {
        log(data.toString());
        if (data.containsKey(_kClickedBranchLinkKey) &&
            data[_kClickedBranchLinkKey]) {
          final path = data[_kPathKey];

          if (path == null) {
            return;
          }

          for (final handler in _handlers) {
            handler.execute(path: path);
          }
        }
      },
    );
  }

  bool handleDeepLink(String url) {
    FlutterBranchSdk.handleDeepLink(url);

    return true;
  }
}

abstract class DeepLinkHandler {
  String get prefix;

  Future<void> handle(dynamic id);

  Future<void> execute({required String path}) async {
    if (!path.startsWith(prefix)) {
      return;
    }

    final id = path.substring(prefix.length + 1);

    await handle(id);
  }
}
