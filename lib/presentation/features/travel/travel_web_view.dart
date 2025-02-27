import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../base/all.dart';
import '../../common_widgets/all.dart';
import '../../resource/resource.dart';
import 'travel_controller.dart';

class TravelWebView extends BaseView<TravelController> {
  const TravelWebView({Key? key}) : super(key: key);

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const WebView(
            initialUrl: 'https://travel.xintel.info/',
            javascriptMode: JavascriptMode.unrestricted,
            userAgent:
                "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Mobile Safari/537.36",
          ),
          Positioned(
            top: 0,
            right: 10,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: AppColors.white.withOpacity(0.9),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppIcon(
                      size: 18,
                      icon: AppIcons.menuRegular,
                      color: AppColors.text2,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 20,
                      color: AppColors.text2.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    AppIcon(
                      onTap: () => Get.back(),
                      size: 18,
                      icon: AppIcons.close,
                      color: AppColors.text2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
