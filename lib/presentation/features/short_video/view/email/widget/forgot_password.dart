import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../languages/languages_keys.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';

class ForgotPassword extends StatelessWidget {
  final VoidCallback onResetBtnClick;
  final TextEditingController resetPassController;
  final FocusNode resetFocusNode;

  const ForgotPassword(
      {required this.onResetBtnClick,
      required this.resetPassController,
      required this.resetFocusNode,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: myLoading.isDark
                      ? ColorRes.colorPrimaryDark
                      : ColorRes.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
              child: SingleChildScrollView(
                child: AspectRatio(
                  aspectRatio: 1 / 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 55,
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              LKey.forgotPassword.tr,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: FontRes.fNSfUiMedium),
                              textAlign: TextAlign.center,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(
                        thickness: 0.5,
                        height: 0.5,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Text(
                          LKey.enterYourMailOnWhichYouHaveCreatedNanAccount.tr,
                          style: const TextStyle(
                              fontFamily: FontRes.fNSfUiMedium,
                              color: ColorRes.colorTextLight),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 25),
                        child: Text(
                          LKey.email.tr,
                          style: const TextStyle(
                              fontFamily: FontRes.fNSfUiSemiBold,
                              color: ColorRes.colorTextLight),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                            color: myLoading.isDark
                                ? ColorRes.colorPrimary
                                : ColorRes.greyShade100,
                            borderRadius: BorderRadius.circular(5)),
                        child: TextField(
                          controller: resetPassController,
                          focusNode: resetFocusNode,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                          ),
                          cursorColor: ColorRes.colorTextLight,
                          cursorHeight: 15,
                          style:
                              const TextStyle(color: ColorRes.colorTextLight),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: InkWell(
                          onTap: onResetBtnClick,
                          child: Material(
                            elevation: 3,
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 25, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                LKey.reset.tr,
                                style: const TextStyle(color: ColorRes.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
