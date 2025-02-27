import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/all.dart';
import '../../../../resource/styles/text_styles.dart';

class ShareTimerWidget extends StatefulWidget {
  final Function onSharePost;
  final ValueNotifier<String> shareText;

  const ShareTimerWidget(
      {required this.onSharePost, required this.shareText, super.key});

  @override
  State<StatefulWidget> createState() {
    return ShareTimerWidgetState();
  }
}

class ShareTimerWidgetState extends State<ShareTimerWidget> {
  Timer? timer;
  final maxSec = 5;
  int _sec = 5;

  @override
  void initState() {
    timer = null;
    super.initState();
  }

  void startTimer() {
    resetTimer();
    widget.shareText.value = context.l10n.newsfeed__share_action_undo;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sec > 0) {
        _sec--;
      } else if (_sec == 0) {
        stopTimer();
        widget.onSharePost();
        widget.shareText.value = context.l10n.newsfeed__share_action_sent;

        return;
      } else {
        stopTimer();
      }
    });
  }

  void resetTimer() {
    _sec = maxSec;
    setState(() {});
  }

  void stopTimer({
    ValueNotifier<String>? shareText,
  }) {
    if (shareText != null) {
      shareText.value = context.l10n.newsfeed__share_action_send;
    }

    timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.shareText,
      builder: (BuildContext context, String text, child) {
        return GestureDetector(
          onTap: () {
            if (text == context.l10n.newsfeed__share_action_send) {
              startTimer();
            } else if (text == context.l10n.newsfeed__share_action_undo) {
              stopTimer();
              widget.shareText.value = context.l10n.newsfeed__share_action_send;
              setState(() {});
            }
          },
          child: Text(
            text,
            style: AppTextStyles.s14Base.text2Color,
          ),
        );
      },
    );
  }
}
