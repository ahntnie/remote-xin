import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/extensions/all.dart';
import '../../core/utils/view_util.dart';
import '../resource/styles/styles.dart';

class CommonScaffold extends StatelessWidget {
  const CommonScaffold({
    required this.body,
    Key? key,
    this.appBar,
    this.backgroundColor = Colors.white,
    this.hideKeyboardWhenTouchOutside = false,
    this.applyAutoPaddingBottom = false,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundGradientColor,
    this.isRemoveBottomPadding,
    this.drawer,
    this.isShowLinearBackground = false,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  final Drawer? drawer;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color backgroundColor;
  final bool hideKeyboardWhenTouchOutside;
  final bool applyAutoPaddingBottom;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final List<Color>? backgroundGradientColor;
  final bool? isRemoveBottomPadding;
  final bool isShowLinearBackground;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final scaffold = Stack(
      children: [
        Visibility(
          visible: isShowLinearBackground,
          child: Container(
            width: 1.sw,
            height: 1.sh,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundGradientColor ??
                    [const Color(0xFF7BC0FF), const Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        // Container(
        //   decoration: BoxDecoration(
        //     image: DecorationImage(
        //       image: ResizeImage(
        //         Assets.images.bg.provider(),
        //         width: 1.sw.toInt().cacheSize(context),
        //         height: 1.sh.toInt().cacheSize(context),
        //       ),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
        Scaffold(
          backgroundColor:
              isShowLinearBackground ? Colors.transparent : backgroundColor,
          appBar: appBar,
          body: Padding(
            padding: _getBottomPadding(context),
            child: body,
          ),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          drawer: drawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        ),
      ],
    );

    return hideKeyboardWhenTouchOutside
        ? GestureDetector(
            onTap: () => ViewUtil.hideKeyboard(context),
            child: scaffold,
          )
        : scaffold;
  }

  EdgeInsetsGeometry _getBottomPadding(BuildContext context) {
    if (!applyAutoPaddingBottom) {
      return EdgeInsets.zero;
    }

    var bottomPadding = context.bottomPadding;
    if (context.bottomViewInsets == 0) {
      bottomPadding = Sizes.s16;
    }

    return EdgeInsets.only(
        bottom: (isRemoveBottomPadding ?? false) ? 0 : bottomPadding);
  }
}
