import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../api/api_service.dart';
import '../../custom_view/app_bar_custom.dart';
import '../../custom_view/common_ui.dart';
import '../../languages/languages_keys.dart';
import '../../modal/setting/setting.dart';
import '../../modal/wallet/my_wallet.dart';
import '../../utils/app_res.dart';
import '../../utils/assert_image.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';
import '../redeem/redeem_screen.dart';
import 'dialog_coins_plan.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  MyWalletData? _myWalletData;
  SessionManager sessionManager = SessionManager();
  SettingData? settingData;

  bool isLoading = true;

  @override
  void initState() {
    prefData();
    getMyWalletData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyLoading>(builder: (context, myLoading, child) {
      return Scaffold(
        body: Column(
          children: [
            AppBarCustom(title: LKey.wallet.tr),
            Expanded(
              child: isLoading
                  ? const LoaderDialog()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(colors: [
                                ColorRes.colorTheme,
                                ColorRes.colorPink
                              ]),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                  color: ColorRes.white,
                                  value: (_myWalletData?.myWallet ?? 0) /
                                      (settingData?.minRedeemCoins ?? 0),
                                  minHeight: 2,
                                  borderRadius: BorderRadius.circular(10),
                                  backgroundColor:
                                      ColorRes.white.withOpacity(0.40),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Minimum :${settingData?.minRedeemCoins ?? 0}',
                                      style: const TextStyle(
                                        fontFamily: FontRes.fNSfUiLight,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            NumberFormat.compact(
                                              locale: 'en',
                                            ).format(
                                                _myWalletData?.myWallet ?? 0),
                                            style: const TextStyle(
                                                color: ColorRes.white,
                                                fontFamily:
                                                    FontRes.fNSfUiSemiBold,
                                                fontSize: 35),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '$appName ${LKey.youHave.tr}',
                                            style: TextStyle(
                                                color: ColorRes.white
                                                    .withOpacity(0.8),
                                                fontFamily:
                                                    FontRes.fNSfUiRegular,
                                                fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Get.bottomSheet(const DialogCoinsPlan())
                                            .then((value) {
                                          getMyWalletData();
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 15),
                                        decoration: BoxDecoration(
                                          color: ColorRes.colorPrimaryDark,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '${LKey.add.tr} $appName',
                                          style: const TextStyle(
                                              color: ColorRes.white,
                                              fontSize: 15,
                                              fontFamily:
                                                  FontRes.fNSfUiRegular),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                    height:
                                        AppBar().preferredSize.height * 1.2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppRes.redeemTitle(
                                            (settingData?.coinValue ?? 0.0)
                                                .toStringAsFixed(2)),
                                        style: const TextStyle(
                                            fontFamily: FontRes.fNSfUiRegular,
                                            fontSize: 13,
                                            color: ColorRes.white),
                                      ),
                                    ),
                                    Image.asset(icLogo, height: 36, width: 36)
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                              color: ColorRes.white.withOpacity(0.1),
                              endIndent: 15,
                              indent: 15),
                          Container(
                            height: 58,
                            margin: const EdgeInsets.all(15),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: myLoading.isDark
                                  ? ColorRes.colorPrimary
                                  : ColorRes.greyShade100,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: const LinearGradient(colors: [
                                      ColorRes.colorTheme,
                                      ColorRes.colorPink
                                    ]),
                                  ),
                                  child: Text(
                                    "+${NumberFormat.compact(locale: 'en').format(settingData?.rewardVideoUpload ?? 0)}",
                                    style: const TextStyle(
                                      color: ColorRes.white,
                                      fontSize: 18,
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: FontRes.fNSfUiMedium,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    LKey.wheneverYouUploadVideo.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontFamily: FontRes.fNSfUiMedium,
                                        fontSize: 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: ColorRes.white.withOpacity(0.1),
                            endIndent: 15,
                            indent: 15,
                          ),
                        ],
                      ),
                    ),
            ),
            InkWell(
              onTap: () {
                if ((_myWalletData?.myWallet ?? 0) <=
                    (settingData?.minRedeemCoins ?? 0)) {
                  CommonUI.showToast(msg: LKey.insufficientBalance.tr);
                  CommonUI.showToast(msg: LKey.insufficientBalance.tr);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RedeemScreen()),
                  ).then((value) {
                    getMyWalletData();
                  });
                }
              },
              child: Container(
                height: 54,
                margin:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  gradient: LinearGradient(
                    colors: [ColorRes.colorTheme, ColorRes.colorPink],
                  ),
                ),
                child: Center(
                  child: Text(
                    LKey.requestRedeem.tr,
                    style: const TextStyle(
                        color: ColorRes.white,
                        fontSize: 17,
                        fontFamily: FontRes.fNSfUiMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void getMyWalletData() {
    isLoading = true;
    ApiService().getMyWalletCoin().then((value) {
      _myWalletData = value.data;
      isLoading = false;
      setState(() {});
    });
  }

  Future<void> prefData() async {
    await sessionManager.initPref();
    settingData = sessionManager.getSetting()?.data;
    setState(() {});
  }
}
