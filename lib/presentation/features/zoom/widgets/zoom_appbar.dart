import 'package:flutter/material.dart';

import '../../../../core/all.dart';
import '../../../common_widgets/all.dart';

class ZoomAppBar extends CommonAppBar {
  ZoomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      titleType: AppBarTitle.text,
      text: context.l10n.zoom__meeting,
    );
  }
}
