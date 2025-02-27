import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/api_service.dart';
import '../../custom_view/app_bar_custom.dart';
import '../../custom_view/common_ui.dart';
import '../../languages/languages_keys.dart';
import '../../utils/assert_image.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  String photoWithId = '';
  String photoId = '';
  String idNumber = '';
  String nameOnId = '';
  String fullAddress = '';
  // InterstitialAd? interstitialAd;

  var sessionManager = SessionManager();

  @override
  void initState() {
    initPref();
    _ads();
    super.initState();
  }

  void _ads() {
    // CommonFun.interstitialAd((ad) {
    //   interstitialAd = ad;
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) => Scaffold(
        body: Column(
          children: [
            AppBarCustom(title: LKey.requestVerification.tr),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        LKey.yourPhotoHoldingYourIdCard.tr,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      ClipOval(
                        child: Image(
                          height: 125,
                          width: 125,
                          image: (photoWithId.isEmpty
                                  ? const AssetImage(icImgHoldingId)
                                  : FileImage(File(photoWithId)))
                              as ImageProvider<Object>,
                          fit: photoWithId.isEmpty
                              ? BoxFit.fitWidth
                              : BoxFit.cover,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 150,
                        height: 35,
                        child: TextButton(
                          onPressed: () {
                            ImagePicker()
                                .pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: imageQuality,
                                    maxHeight: maxHeight,
                                    maxWidth: maxWidth)
                                .then((value) {
                              photoWithId = value!.path;
                              setState(() {});
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                myLoading.isDark
                                    ? ColorRes.colorPrimary
                                    : ColorRes.greyShade100),
                          ),
                          child: Text(
                            LKey.capture.tr,
                            style: const TextStyle(
                              color: ColorRes.colorIcon,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        LKey.photoOfIdClearPhoto.tr,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Image(
                        image: (photoId.isEmpty
                                ? const AssetImage(icBgId)
                                : FileImage(File(photoId)))
                            as ImageProvider<Object>,
                        height: 95,
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 150,
                        height: 35,
                        child: TextButton(
                          onPressed: () {
                            ImagePicker()
                                .pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: imageQuality,
                                    maxHeight: maxHeight,
                                    maxWidth: maxWidth)
                                .then((value) {
                              photoId = value!.path;
                              setState(() {});
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                myLoading.isDark
                                    ? ColorRes.colorPrimary
                                    : ColorRes.greyShade100),
                          ),
                          child: Text(
                            LKey.attach.tr,
                            style: const TextStyle(
                              color: ColorRes.colorIcon,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          LKey.idNumber.tr,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                        ),
                        child: TextField(
                          onChanged: (value) => idNumber = value,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: LKey.enterIdNumber.tr,
                            hintStyle: const TextStyle(
                              color: ColorRes.colorTextLight,
                            ),
                          ),
                          style: const TextStyle(
                            color: ColorRes.colorTextLight,
                          ),
                          cursorColor: ColorRes.colorTextLight,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          LKey.nameOnId.tr,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                        ),
                        child: TextField(
                          onChanged: (value) => nameOnId = value,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: LKey.sameAsId.tr,
                            hintStyle: const TextStyle(
                              color: ColorRes.colorTextLight,
                            ),
                          ),
                          style: const TextStyle(
                            color: ColorRes.colorTextLight,
                          ),
                          cursorColor: ColorRes.colorTextLight,
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Text(
                          LKey.fullAddress.tr,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        height: 115,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          color: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                        ),
                        child: TextField(
                          onChanged: (value) => fullAddress = value,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: LKey.sameAsId.tr,
                            hintStyle: const TextStyle(
                              color: ColorRes.colorTextLight,
                            ),
                          ),
                          style: const TextStyle(
                            color: ColorRes.colorTextLight,
                          ),
                          cursorColor: ColorRes.colorTextLight,
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      InkWell(
                        onTap: () {
                          if (photoWithId.isEmpty) {
                            CommonUI.showToast(msg: LKey.pleaseCaptureImage.tr);
                          } else if (photoId.isEmpty) {
                            CommonUI.showToast(
                                msg: LKey.pleaseAttachYourIdCard.tr);
                          } else if (idNumber.isEmpty) {
                            CommonUI.showToast(
                                msg: LKey.pleaseEnterYourIdNumber.tr);
                          } else if (nameOnId.isEmpty) {
                            CommonUI.showToast(
                                msg: LKey.pleaseEnterYourName.tr);
                          } else if (fullAddress.isEmpty) {
                            CommonUI.showToast(
                                msg: LKey.pleaseEnterYourFullAddress.tr);
                          } else {
                            CommonUI.showLoader(context);
                            ApiService()
                                .verifyRequest(idNumber, nameOnId, fullAddress,
                                    File(photoWithId), File(photoId))
                                .then((value) {
                              if (value.status == 200) {
                                CommonUI.showToast(
                                    msg: LKey
                                        .requestForVerificationSuccessfully.tr);
                                Provider.of<MyLoading>(context, listen: false)
                                    .setUser(sessionManager.getUser());
                                // if (interstitialAd != null) {
                                //   interstitialAd?.show().then((value) {
                                //     Navigator.pop(context);
                                //     Navigator.pop(context);
                                //   });
                                // } else {
                                //   Navigator.pop(context);
                                //   Navigator.pop(context);
                                // }
                              }
                            });
                          }
                        },
                        child: Container(
                          height: 40,
                          width: 175,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            gradient: LinearGradient(
                              colors: [
                                ColorRes.colorTheme,
                                ColorRes.colorPink,
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              LKey.submit.tr.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: FontRes.fNSfUiSemiBold,
                                  letterSpacing: 1,
                                  color: ColorRes.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
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

  Future<void> initPref() async {
    await sessionManager.initPref();
  }
}
