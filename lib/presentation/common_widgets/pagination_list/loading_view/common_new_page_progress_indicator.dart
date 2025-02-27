import 'package:flutter/material.dart';

import '../../../resource/styles/gaps.dart';
import '../../all.dart';

class CommonNewPageProgressIndicator extends StatelessWidget {
  const CommonNewPageProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsAll8,
        child: AppDefaultLoading(),
      ),
    );
  }
}
