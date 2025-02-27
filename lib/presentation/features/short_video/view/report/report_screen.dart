import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../api/api_service.dart';
import '../../custom_view/common_ui.dart';
import '../../languages/languages_keys.dart';
import '../../utils/app_res.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../webview/webview_screen.dart';

class ReportScreen extends StatefulWidget {
  final int reportType;
  final String? id;

  const ReportScreen(this.reportType, this.id, {super.key});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String? currentValue;
  String reason = '';
  String description = '';
  String contactInfo = '';

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return Container(
        margin: EdgeInsets.only(top: AppBar().preferredSize.height),
        decoration: BoxDecoration(
          color: myLoading.isDark ? ColorRes.colorPrimaryDark : ColorRes.white,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(AppRes.whatReport(widget.reportType),
                      style: const TextStyle(fontSize: 18)),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.2, color: ColorRes.colorTextLight),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        LKey.selectReason.tr,
                        style: const TextStyle(
                            fontSize: 15, fontFamily: FontRes.fNSfUiMedium),
                      ),
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding:
                            const EdgeInsets.only(right: 15, left: 15, top: 2),
                        decoration: BoxDecoration(
                          color: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: DropdownButton<String>(
                          value: currentValue,
                          underline: Container(),
                          isExpanded: true,
                          elevation: 16,
                          style:
                              const TextStyle(color: ColorRes.colorTextLight),
                          dropdownColor: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                          borderRadius: BorderRadius.circular(10),
                          onChanged: (String? newValue) {
                            currentValue = newValue;
                            setState(() {});
                          },
                          items: reportReasons
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                    fontFamily: FontRes.fNSfUiMedium),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Text(
                        LKey.howItHurtsYou.tr,
                        style: const TextStyle(
                          fontFamily: FontRes.fNSfUiMedium,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 150,
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 2),
                        decoration: BoxDecoration(
                          color: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            hintText: LKey.explainBriefly.tr,
                            hintStyle: const TextStyle(
                                color: ColorRes.colorTextLight,
                                fontFamily: FontRes.fNSfUiLight),
                            border: InputBorder.none,
                          ),
                          style:
                              const TextStyle(fontFamily: FontRes.fNSfUiMedium),
                          onChanged: (value) {
                            description = value;
                          },
                          cursorColor: ColorRes.colorTextLight,
                          maxLines: 7,
                          scrollPhysics: const BouncingScrollPhysics(),
                        ),
                      ),
                      Text(
                        LKey.contactDetailMailOrMobile.tr,
                        style: const TextStyle(
                            fontSize: 15, fontFamily: FontRes.fNSfUiMedium),
                      ),
                      Container(
                        width: double.infinity,
                        height: 55,
                        margin: const EdgeInsets.only(top: 5, bottom: 20),
                        padding:
                            const EdgeInsets.only(right: 15, left: 15, top: 2),
                        decoration: BoxDecoration(
                          color: myLoading.isDark
                              ? ColorRes.colorPrimary
                              : ColorRes.greyShade100,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: InputBorder.none,
                            hintText: LKey.mailOrPhone.tr,
                            hintStyle: const TextStyle(
                                color: ColorRes.colorTextLight,
                                fontFamily: FontRes.fNSfUiLight),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            contactInfo = value;
                          },
                          style: const TextStyle(
                              color: ColorRes.white,
                              fontFamily: FontRes.fNSfUiMedium),
                          scrollPhysics: const BouncingScrollPhysics(),
                          cursorColor: ColorRes.colorTextLight,
                        ),
                      ),
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: 175,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              if (currentValue == null ||
                                  currentValue!.isEmpty) {
                                CommonUI.showToast(
                                    msg: LKey.pleaseSelectReason.tr);
                                return;
                              }
                              if (description.isEmpty) {
                                CommonUI.showToast(
                                    msg: LKey.pleaseEnterDescription.tr);
                                return;
                              }
                              if (contactInfo.isEmpty) {
                                CommonUI.showToast(
                                    msg: LKey.pleaseEnterContactDetail.tr);
                                return;
                              }
                              CommonUI.showLoader(context);
                              ApiService()
                                  .reportUserOrPost(
                                      reportType:
                                          widget.reportType == 1 ? '2' : '1',
                                      postIdOrUserId: widget.id,
                                      reason: currentValue,
                                      description: description,
                                      contactInfo: contactInfo)
                                  .then((value) {
                                print(value.status);
                                Navigator.pop(context);
                                Navigator.pop(context);
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(ColorRes.colorTheme),
                              shape: WidgetStateProperty.all(
                                const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            child: Text(
                              LKey.submit.tr.toUpperCase(),
                              style: const TextStyle(
                                color: ColorRes.white,
                                fontSize: 15,
                                fontFamily: FontRes.fNSfUiMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                        child: Text(
                          LKey.byClickingThisSubmitButtonYouAgreeThatNYouAreTakingAll
                              .tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: ColorRes.colorTextLight,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WebViewScreen(3)),
                        ),
                        child: Center(
                          child: Text(
                            LKey.policyCenter.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: ColorRes.colorTheme,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
