import 'dart:io';
import 'dart:ui' as ui;

import 'package:bubbly_camera/bubbly_camera.dart';
// import 'package:ffmpeg_kit_flutter_full/ffmpeg_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../custom_view/common_ui.dart';
import '../../../modal/user_video/user_video.dart';
import '../../../utils/app_res.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../../utils/url_res.dart';

class SocialLinkShareSheet extends StatefulWidget {
  final Data videoData;

  const SocialLinkShareSheet({required this.videoData, super.key});

  @override
  State<SocialLinkShareSheet> createState() => _SocialLinkShareSheetState();
}

class _SocialLinkShareSheetState extends State<SocialLinkShareSheet> {
  List<String> shareIconList = [
    icDownloads,
    icWhatsapp,
    icInstagram,
    icCopy,
    icMore
  ];
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => Wrap(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              RepaintBoundary(
                key: globalKey,
                child: Column(
                  children: [
                    Image.asset(
                      myLoading.isDark ? icLogo : icLogoLight,
                      width: 30,
                      fit: BoxFit.fitHeight,
                    ),
                    Text(
                      '@${widget.videoData.userName ?? appName}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: ColorRes.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: AppBar().preferredSize.height),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                    color: myLoading.isDark
                        ? ColorRes.colorPrimary
                        : ColorRes.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20))),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Text(
                          'Share This video',
                          style: TextStyle(
                              fontFamily: FontRes.fNSfUiMedium, fontSize: 16),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close)),
                        )
                      ],
                    ),
                    const Divider(color: ColorRes.colorTextLight),
                    Wrap(
                      children: List.generate(shareIconList.length, (index) {
                        return InkWell(
                          onTap: () => _onTap(index),
                          child: Container(
                            height: 40,
                            width: 40,
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  ColorRes.colorTheme,
                                  ColorRes.colorIcon
                                ],
                              ),
                            ),
                            child: Image.asset(
                              shareIconList[index],
                              color: ColorRes.white,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: AppBar().preferredSize.height)
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _onTap(int index) async {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    if (index == 0) {
      CommonUI.showToast(msg: 'Video downloading started!');
      final File waterMarkPath = await _capturePng();
      final File videoUrlPath = await getFileFromUrl(
          url: '${ConstRes.itemBaseUrl}${widget.videoData.postVideo}');
      final directory = await getApplicationDocumentsDirectory();
      final outputPath =
          '${directory.path}/${DateTime.now().microsecondsSinceEpoch}.mp4';
      // FFmpegKit.execute(
      //   '-i ${videoUrlPath.path} -i ${waterMarkPath.path} -filter_complex "[1][0]scale2ref=w=\'iw*15/100\':h=\'ow/mdar\'[wm][vid];[vid][wm]overlay=x=(main_w-overlay_w-10):y=(main_h-overlay_h-10)" -qscale 0 -y $outputPath',
      // ).then((session) {
      //   ImageGallerySaver.saveFile(outputPath).then((value) {
      //     CommonUI.showToast(msg: 'Video saved successfully...');
      //   });
      // });
    } else if (index == 1) {
      Get.dialog(const LoaderDialog());
      _shareBranchLink().then((value) async {
        Get.back();
        if (!await launchUrl(Uri.parse('whatsapp://send?text=$value'))) {}
      });
    } else if (index == 2) {
      Get.dialog(const LoaderDialog());
      _shareBranchLink().then((value) async {
        Get.back();
        if (Platform.isIOS) {
          if (!await launchUrl(
              Uri.parse('instagram://sharesheet?text=$value'))) {}
        } else {
          BubblyCamera.shareToInstagram(value);
        }
      });
    } else if (index == 3) {
      Get.dialog(const LoaderDialog());
      _shareBranchLink().then((value) {
        Get.back();
        Clipboard.setData(ClipboardData(text: value));
      });
    } else if (index == 4) {
      Get.dialog(const LoaderDialog());
      _shareBranchLink().then((value) {
        Get.back();
        Share.share(
          AppRes.checkOutThisAmazingProfile(value),
          subject: '${AppRes.look} ${widget.videoData.userName}',
        );
      });
    }
  }

  Future<String> _shareBranchLink() async {
    final BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch',
      title: widget.videoData.userName ?? '',
      imageUrl: ConstRes.itemBaseUrl + widget.videoData.postImage!,
      contentMetadata: BranchContentMetaData()
        ..addCustomMetadata(
          UrlRes.postId,
          widget.videoData.postId,
        ),
    );

    final BranchLinkProperties lp = BranchLinkProperties(
        channel: 'facebook',
        feature: 'sharing',
        stage: 'new share',
        tags: ['one', 'two', 'three']);
    lp.addControlParam('url', 'http://www.google.com');
    lp.addControlParam('url2', 'http://flutter.dev');
    final BranchResponse response =
        await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    if (response.success) {
      return response.result;
    } else {
      return '';
    }
  }

  Future<File> getFileFromUrl({required String url}) async {
    try {
      final data = await http.get(
        Uri.parse(url),
      );

      final bytes = data.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final File file =
          File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.mp4');

      final File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception('Error opening url file');
    }
  }

  Future<File> _capturePng() async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;

    final ui.Image image = await boundary.toImage(pixelRatio: 10);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    final Directory dir = await getApplicationDocumentsDirectory();

    final File file = File('${dir.path}/wallpaper.png');
    return await file.writeAsBytes(pngBytes);
  }
}
