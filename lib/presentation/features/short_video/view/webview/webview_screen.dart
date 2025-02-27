import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../custom_view/app_bar_custom.dart';
import '../../custom_view/common_ui.dart';
import '../../languages/languages_keys.dart';
import '../../utils/url_res.dart';

class WebViewScreen extends StatefulWidget {
  final int type;

  const WebViewScreen(this.type, {super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    return Scaffold(
      body: Column(
        children: [
          AppBarCustom(title: getTitle()),
          Expanded(
            child: Stack(
              children: [
                WebView(
                  initialUrl: getWebUrl(),
                  javascriptMode: JavascriptMode.unrestricted,
                  onPageStarted: (url) {
                    isLoading = true;
                    setState(() {});
                  },
                  onPageFinished: (url) {
                    isLoading = false;
                    setState(() {});
                  },
                ),
                isLoading ? LoaderDialog() : const SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getTitle() {
    String title = '';
    if (widget.type == 2) {
      title = LKey.termsOfUse.tr;
    } else if (widget.type == 3) {
      title = LKey.privacyPolicy.tr;
    }
    return title;
  }

  String getWebUrl() {
    String title = '';
    if (widget.type == 2) {
      title = UrlRes.termAndCondition;
    } else if (widget.type == 3) {
      title = UrlRes.privacyPolicy;
    }
    return title;
  }
}
