import 'package:flutter/rendering.dart';

import '../../presentation/base/all.dart';
import '../../presentation/common_widgets/anchor_scroll/all.dart';

mixin AnchorScrollMixin on BaseController {
  int currentIndex = 0;
  late AnchorScrollController anchorScrollController;

  @override
  void onInit() {
    anchorScrollController = AnchorScrollController(
      onIndexChanged: (index, userScroll) {
        currentIndex = index;
      },
    );
    super.onInit();
    anchorScrollController.addListener(_listener);
  }

  bool _canFetchBottom = true;

  bool _canFetchTop = true;

  void _listener() {
    if (anchorScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // Scrolling down
      onShowButtonScrollDown();
    }
    if (anchorScrollController.position.atEdge) {
      _checkIfCanLoadMore();
    }
  }

  Future<void> _checkIfCanLoadMore() async {
    if (anchorScrollController.position.pixels == 0) {
      if (!_canFetchTop) {
        return;
      }
      _canFetchTop = false;
      await onTopScroll();
      _canFetchTop = true;
    } else {
      if (!_canFetchBottom) {
        return;
      }
      _canFetchBottom = false;
      await onEndScroll();
      _canFetchBottom = true;
    }
  }

  Future<void> onEndScroll();

  Future<void> onTopScroll();

  Future<void> onShowButtonScrollDown();

  Future<void> onHideButtonScrollDown();

  @override
  void onClose() {
    super.onClose();
    anchorScrollController.removeListener(_listener);
  }
}
