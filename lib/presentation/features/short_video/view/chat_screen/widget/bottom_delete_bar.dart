import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../languages/languages_keys.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';

class BottomDeleteBar extends StatelessWidget {
  final List<String> timeStamp;
  final VoidCallback deleteBtnClick;
  final VoidCallback cancelBtnClick;

  const BottomDeleteBar(
      {required this.timeStamp,
      required this.deleteBtnClick,
      required this.cancelBtnClick,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(30)),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                cancelBtnClick();
              },
              child: Text(
                LKey.cancel.tr,
                style: const TextStyle(
                    fontSize: 15,
                    color: ColorRes.colorTheme,
                    fontFamily: FontRes.fNSfUiSemiBold),
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                '${timeStamp.length} ',
                key: ValueKey<int>(timeStamp.length),
                style: const TextStyle(
                  fontFamily: FontRes.fNSfUiBold,
                  fontSize: 15,
                  color: ColorRes.white,
                ),
              ),
            ),
            Text(
              LKey.selected.tr,
              style: const TextStyle(
                  fontSize: 15,
                  color: ColorRes.white,
                  fontFamily: FontRes.fNSfUiSemiBold),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                deleteBtnClick();
              },
              child: const Icon(
                Icons.delete,
                color: ColorRes.colorPink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
