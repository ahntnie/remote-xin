import 'package:flutter/material.dart';

const double _kSwipeToReplySensitive = 30.0;
const double _kAdjustSwipeValue = 4;

class SwipeToReply extends StatefulWidget {
  const SwipeToReply({
    required this.child,
    required this.onReply,
    required this.isMyMessage,
    super.key,
  });

  final Widget child;
  final VoidCallback? onReply;
  final bool isMyMessage;

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<double> _dragPositionNotifier =
      ValueNotifier<double>(0.0);

  double _dragStartPoint = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragDown: (detail) {
        _dragStartPoint = detail.globalPosition.dx;
      },
      onHorizontalDragUpdate: (detail) {
        if (detail.delta.dx > 0) {
          return;
        }

        double update = detail.globalPosition.dx - _dragStartPoint;
        // make update value physical
        update = update / _kAdjustSwipeValue;

        // if (!widget.isMyMessage && update > 0) {
        //   _dragPositionNotifier.value = update;
        // } else if (widget.isMyMessage && update < 0) {
        //   _dragPositionNotifier.value = update;
        // }

        _dragPositionNotifier.value = update;
      },
      onHorizontalDragEnd: (detail) {
        if (_dragPositionNotifier.value.abs() > _kSwipeToReplySensitive) {
          widget.onReply?.call();
          _dragPositionNotifier.value = 0.0;
        }
        _dragPositionNotifier.value = 0.0;
      },
      child: ValueListenableBuilder(
        valueListenable: _dragPositionNotifier,
        builder: (_, double value, __) {
          return Align(
            alignment: widget.isMyMessage
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Transform.translate(
              offset: Offset(value, 0.0),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }

  // Widget _buildSwipeToReplyIcon(double value) {
  //   if (value == 0.0 || value.abs() < _kSwipeToReplySensitive) {
  //     return AppSpacing.emptyBox;
  //   }

  //   return Align(
  //     alignment: value > 0 ? Alignment.centerLeft : Alignment.centerRight,
  //     child: Container(
  //       padding: AppSpacing.edgeInsetsAll8,
  //       child: const Icon(Icons.reply),
  //     ),
  //   );
  // }
}
