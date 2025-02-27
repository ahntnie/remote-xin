import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../languages/languages_keys.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import 'bottom_delete_bar.dart';

class BottomInputBar extends StatelessWidget {
  final TextEditingController msgController;
  final VoidCallback onShareBtnTap;
  final VoidCallback onAddBtnTap;
  final VoidCallback onCameraTap;
  final List<String> timeStamp;
  final VoidCallback onDeleteBtnClick;
  final VoidCallback cancelBtnClick;

  const BottomInputBar(
      {required this.msgController,
      required this.onShareBtnTap,
      required this.onAddBtnTap,
      required this.onCameraTap,
      required this.timeStamp,
      required this.onDeleteBtnClick,
      required this.cancelBtnClick,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) {
        return SafeArea(
          top: false,
          child: timeStamp.isNotEmpty
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: const Offset(0, 0.0),
                        ).animate(
                          CurvedAnimation(
                              parent: animation, curve: Curves.fastOutSlowIn),
                        ),
                        child: child);
                  },
                  child: BottomDeleteBar(
                    timeStamp: timeStamp,
                    deleteBtnClick: onDeleteBtnClick,
                    cancelBtnClick: cancelBtnClick,
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: const Offset(0, 0.0),
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastOutSlowIn,
                          ),
                        ),
                        child: child);
                  },
                  child: myLoading.getIsUserBlockOrNot
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 38, vertical: 8),
                          decoration: BoxDecoration(
                              color: myLoading.isDark
                                  ? ColorRes.colorPrimary
                                  : ColorRes.greyShade100,
                              borderRadius: BorderRadius.circular(5)),
                          margin: const EdgeInsets.symmetric(vertical: 9),
                          child: Text(LKey.youBlockThisUser.tr,
                              style: const TextStyle(
                                  color: ColorRes.colorTextLight,
                                  fontSize: 12)),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      color: myLoading.isDark
                                          ? ColorRes.colorPrimary
                                          : ColorRes.greyShade100),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: msgController,
                                          textInputAction:
                                              TextInputAction.newline,
                                          minLines: 1,
                                          maxLines: 5,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 15, bottom: 3),
                                            border: InputBorder.none,
                                            hintText: LKey.typeSomething.tr,
                                            hintStyle: const TextStyle(
                                                fontSize: 14,
                                                color: ColorRes.colorTextLight,
                                                fontFamily:
                                                    FontRes.fNSfUiRegular),
                                          ),
                                          style: const TextStyle(
                                              color: ColorRes.colorTextLight,
                                              fontFamily:
                                                  FontRes.fNSfUiRegular),
                                          cursorColor: ColorRes.colorTextLight,
                                          cursorHeight: 17,
                                          cursorRadius:
                                              const Radius.circular(5),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: onShareBtnTap,
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          height: 35,
                                          width: 35,
                                          margin: const EdgeInsets.all(2),
                                          padding: const EdgeInsets.all(10),
                                          alignment: const AlignmentDirectional(
                                              0.2, 0),
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                ColorRes.colorPink,
                                                ColorRes.colorIcon
                                              ],
                                            ),
                                          ),
                                          child: Image.asset(backArrow),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: onAddBtnTap,
                                child: Container(
                                  width: 25,
                                  height: 25,
                                  decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          colors: [
                                            ColorRes.colorPink,
                                            ColorRes.colorTheme
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter)),
                                  child: const Icon(Icons.add_rounded,
                                      color: ColorRes.white),
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: onCameraTap,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 15,
                                      height: 15,
                                      decoration: const BoxDecoration(
                                          color: ColorRes.white,
                                          shape: BoxShape.circle),
                                    ),
                                    Image.asset(cameraIcon,
                                        height: 26, width: 26),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
        );
      },
    );
  }
}
