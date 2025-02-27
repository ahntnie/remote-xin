import 'package:flutter/material.dart';

import '../../../../../resource/styles/app_colors.dart';
import '../../../../../resource/styles/gaps.dart';
import '../../../../../resource/styles/text_styles.dart';
import './size_config.dart';

class BottomNavBTN extends StatefulWidget {
  final Function(int) onPressed;
  final Widget icon;
  final Widget iconSelected;
  final int index;
  final int currentIndex;
  final String title;
  final bool isReel;

  const BottomNavBTN({
    required this.icon,
    required this.iconSelected,
    required this.onPressed,
    required this.index,
    required this.currentIndex,
    required this.title,
    this.isReel = false,
    super.key,
  });

  @override
  State<BottomNavBTN> createState() => _BottomNavBTNState();
}

class _BottomNavBTNState extends State<BottomNavBTN> {
  double _opacity = 1.0; // Độ mờ ban đầu

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startBlinkEffect() async {
    // Chuyển sang mờ dần
    setState(() {
      _opacity = 0.5;
    });

    // Chờ 500 milliseconds rồi chuyển về trạng thái ban đầu
    await Future.delayed(const Duration());

    // Trở về trạng thái hiện ban đầu
    setState(() {
      _opacity = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().init(context);
    return InkWell(
      onTap: () {
        if (widget.index < 4) {
          _startBlinkEffect();
        }

        widget.onPressed(widget.index);
      },
      child: SizedBox(
        height: AppSizes.blockSizeHorizontal,
        width: AppSizes.blockSizeHorizontal,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // (currentIndex == index)
                //     ? Positioned(
                //         left: AppSizes.blockSizeHorizontal * 4,
                //         bottom: AppSizes.blockSizeHorizontal * 1.5,
                //         child: Icon(
                //           icon,
                //           color: Colors.black,
                //           size: AppSizes.blockSizeHorizontal * 8,
                //         ),
                //       )
                //     : Container(),
                AnimatedOpacity(
                    opacity: widget.currentIndex == widget.index ? _opacity : 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    child: widget.iconSelected),
                AnimatedOpacity(
                  opacity: widget.currentIndex != widget.index ? _opacity : 0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  child: widget.icon,
                ),
              ],
            ),
            AppSpacing.gapH4,
            Text(
              widget.title,
              style: (widget.currentIndex == widget.index)
                  ? AppTextStyles.s12w500.copyWith(
                      color: widget.isReel
                          ? AppColors.white
                          : AppColors.pacificBlue)
                  : AppTextStyles.s12w500.copyWith(color: AppColors.zambezi),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
