import 'dart:async';

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/widgets.dart';

class FlagTalkLanguage extends StatefulWidget {
  final String flagCode;
  const FlagTalkLanguage({required this.flagCode, super.key});

  @override
  State<FlagTalkLanguage> createState() => _FlagTalkLanguageState();
}

class _FlagTalkLanguageState extends State<FlagTalkLanguage> {
  int _counter = 30;
  Timer? _timer;

  void _startTimer() {
    _counter = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _counter == 30
        ? CircleFlag(
            widget.flagCode,
            size: 40,
          )
        : Text(
            '$_counter',
          );
  }
}
