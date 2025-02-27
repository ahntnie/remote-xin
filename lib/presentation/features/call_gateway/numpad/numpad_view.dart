import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../base/all.dart';
import '../../../common_widgets/all.dart';
import '../../../resource/styles/styles.dart';
import 'numpad_controller.dart';
import 'widgets/numpad_widget.dart';

class NumpadView extends BaseView<NumpadController> {
  const NumpadView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              AppTextField(
                controller: controller.textEditingController,
                border: const OutlineInputBorder(borderSide: BorderSide.none),
                fillColor: Colors.transparent,
                keyboardType: TextInputType.none,
                showCursor: false,
                textAlign: TextAlign.center,
                style: AppTextStyles.s28w500,
              ).paddingOnly(top: Sizes.s16, bottom: Sizes.s32),
              NumPadWidget(
                backgroundColor: Colors.transparent,
                onTap: (value) {
                  if (value == 'delete') {
                    if (controller.textEditingController.text.isNotEmpty) {
                      controller.textEditingController.text =
                          controller.textEditingController.text.substring(
                        0,
                        controller.textEditingController.text.length - 1,
                      );
                    }
                  } else {
                    controller.textEditingController.text += value;
                  }
                },
                onTapCall: (value) {
                  controller.checkPhoneNumberIsExists();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
