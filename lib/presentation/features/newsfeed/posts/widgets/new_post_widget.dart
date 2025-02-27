import 'dart:math';

import 'package:flutter/material.dart';

class NewPostWidget extends SliverPersistentHeaderDelegate {
  Widget widget;
  final double minHeight;
  final double maxHeight;

  NewPostWidget({
    required this.widget,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: widget);
  }

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(NewPostWidget oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        widget != oldDelegate.widget;
  }
}
