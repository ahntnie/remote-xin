import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';

class CommonUI {
  static void showToast(
      {required String msg,
      ToastGravity? toastGravity,
      int duration = 1,
      Color? backGroundColor}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: toastGravity ?? ToastGravity.BOTTOM,
      timeInSecForIosWeb: duration,
      backgroundColor: backGroundColor ?? ColorRes.colorPink,
      textColor: ColorRes.white,
      fontSize: 15.0,
    );
  }

  static void showLoader(BuildContext context) {
    Get.dialog(const LoaderDialog());
  }
}

class LoaderDialog extends StatelessWidget {
  final double strokeWidth;

  const LoaderDialog({super.key, this.strokeWidth = 4});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: ColorRes.white,
        strokeWidth: strokeWidth,
      ),
    );
  }
}
