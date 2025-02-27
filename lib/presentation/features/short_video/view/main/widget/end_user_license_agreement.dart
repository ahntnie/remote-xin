import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../languages/languages_keys.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/key_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../../utils/session_manager.dart';

class EndUserLicenseAgreement extends StatelessWidget {
  final SessionManager sessionManager;

  const EndUserLicenseAgreement({required this.sessionManager, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => Container(
        height: MediaQuery.of(context).size.height -
            AppBar().preferredSize.height * 1.5,
        decoration: BoxDecoration(
            color: myLoading.isDark ? ColorRes.colorPrimary : ColorRes.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15))),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Center(
                    child: Text(
                  LKey.endUserLicenseAgreement.tr,
                  style: const TextStyle(fontSize: 16),
                ))),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Expanded(
                child: WebView(
                    initialUrl: ConstRes.agreementUrl,
                    javascriptMode: JavascriptMode.unrestricted)),
            InkWell(
              onTap: () {
                sessionManager.saveBoolean(KeyRes.isAccepted, true);
                Navigator.pop(context);
              },
              child: Container(
                  alignment: Alignment.center,
                  height: 70,
                  color: myLoading.isDark
                      ? ColorRes.colorPrimary
                      : ColorRes.greyShade100,
                  child: SafeArea(
                      top: false,
                      child: Text(
                        LKey.accept.tr,
                      ))),
            ),
          ],
        ),
      ),
    );
  }
}
