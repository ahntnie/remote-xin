import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../resource/resource.dart';

class MuteWidget extends StatelessWidget {
  final Widget child;
  final bool isMuted;

  const MuteWidget({required this.child, required this.isMuted, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: child),
        if (isMuted) AppSpacing.gapW4,
        if (isMuted) const Icon(Icons.volume_off, size: Sizes.s14),
      ],
    );
  }
}
