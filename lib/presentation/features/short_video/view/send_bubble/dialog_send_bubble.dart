import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../api/api_service.dart';
import '../../custom_view/common_ui.dart';
import '../../custom_view/send_coin_result.dart';
import '../../languages/languages_keys.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/assert_image.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';

class DialogSendBubble extends StatelessWidget {
  final Data? videoData;

  const DialogSendBubble(this.videoData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AspectRatio(
            aspectRatio: 0.67,
            child: Container(
              decoration: BoxDecoration(
                color:
                    myLoading.isDark ? ColorRes.colorPrimary : ColorRes.white,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  Text(
                    '${LKey.send.tr} $appName',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const Spacer(),
                  Image.asset(myLoading.isDark ? icLogo : icLogoLight,
                      height: 50),
                  const Spacer(),
                  Text(
                    LKey.creatorWillBeNotifiedNAboutYourLove.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: ColorRes.colorTextLight, fontSize: 15),
                  ),
                  const Spacer(),
                  ItemSendBubble(5, videoData, myLoading),
                  ItemSendBubble(10, videoData, myLoading),
                  ItemSendBubble(15, videoData, myLoading),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        LKey.cancel.tr,
                        style: const TextStyle(
                            fontFamily: FontRes.fNSfUiMedium,
                            color: ColorRes.colorTextLight,
                            fontSize: 18),
                      )),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class ItemSendBubble extends StatelessWidget {
  final int bubblesCount;
  final Data? videoData;
  final MyLoading myLoading;
  final SessionManager sessionManager = SessionManager();

  ItemSendBubble(this.bubblesCount, this.videoData, this.myLoading,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final user = myLoading.getUser;
    initPref();
    return GestureDetector(
      onTap: () {
        if ((user?.data?.myWallet ?? 0) > bubblesCount) {
          CommonUI.showLoader(context);
          ApiService()
              .sendCoin(bubblesCount.toString(), videoData!.userId.toString())
              .then(
            (value) {
              Navigator.pop(context);
              Navigator.pop(context);
              myLoading.setUser(sessionManager.getUser());
              showDialog(
                  context: context,
                  builder: (context) => SendCoinsResult(value.status == 200));
            },
          );
        } else {
          CommonUI.showToast(msg: LKey.insufficientBalance.tr);
        }
      },
      child: FittedBox(
        child: Container(
          height: 55,
          width: MediaQuery.of(context).size.width / 2,
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: myLoading.isDark
                ? ColorRes.colorPrimaryDark
                : ColorRes.greyShade100,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                  image: AssetImage(myLoading.isDark ? icLogo : icLogoLight),
                  width: 40,
                  height: 40),
              const SizedBox(width: 15),
              Text(
                '$bubblesCount $appName',
                style: const TextStyle(
                    fontSize: 16, color: ColorRes.colorTextLight),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initPref() async {
    await sessionManager.initPref();
  }
}
