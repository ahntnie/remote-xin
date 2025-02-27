import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../common_widgets/text_field.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../../../resource/styles/text_styles.dart';
import '../../utils/colors.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';

class UploadScreen extends StatefulWidget {
  final String? postVideo;
  final String? thumbNail;
  final String? sound;
  final int? soundId;

  const UploadScreen(
      {super.key, this.postVideo, this.thumbNail, this.sound, this.soundId});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  ValueNotifier<int> textSize = ValueNotifier<int>(0);
  String postDes = '';
  String currentHashTag = '';
  List<String> hashTags = [];
  final SessionManager _sessionManager = SessionManager();
  final shortVideoRepo = Get.find<ShortVideoRepository>();
  final desController = TextEditingController(text: '');
  var isLoadingUpload = false;

  @override
  void initState() {
    initSessionManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: ColorRes.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(context.l10n.short__upload,
                            style: AppTextStyles.s18w400.text2Color),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        )
                      ],
                    ),
                    const Divider(thickness: 1),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          child: Image(
                            height: 110,
                            width: 110,
                            fit: BoxFit.cover,
                            image: NetworkImage(widget.thumbNail ?? ''),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   LKey.describe.tr,
                              //   style: const TextStyle(
                              //     fontSize: 16,
                              //   ),
                              // ),
                              // const SizedBox(
                              //   height: 10,
                              // ),
                              AppTextField(
                                controller: desController,
                                maxLines: 3,
                                style: AppTextStyles.s16w400.text2Color,
                                hintText: context.l10n.short__description,
                                hintStyle: AppTextStyles.s14w400.copyWith(
                                  color: AppColors.subText3,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.grey8,
                                    )),
                                textInputAction: TextInputAction.done,
                                onChanged: (value) {},
                              ),
                              // Container(
                              //   decoration: BoxDecoration(
                              //     color: myLoading.isDark
                              //         ? ColorRes.colorPrimaryDark
                              //         : ColorRes.greyShade100,
                              //     borderRadius:
                              //         BorderRadius.all(Radius.circular(10)),
                              //   ),
                              //   padding: EdgeInsets.only(left: 15, right: 15),
                              //   height: 130,
                              //   child: DetectableTextField(
                              //     decoratedStyle: TextStyle(
                              //       fontFamily: FontRes.fNSfUiBold,
                              //       letterSpacing: 0.6,
                              //       fontSize: 13,
                              //       color: ColorRes.colorTextLight,
                              //     ),
                              //     basicStyle: TextStyle(
                              //       fontFamily: FontRes.fNSfUiRegular,
                              //       letterSpacing: 0.6,
                              //       fontSize: 13,
                              //       color: ColorRes.colorTextLight,
                              //     ),
                              //     textInputAction: TextInputAction.done,
                              //     inputFormatters: [
                              //       LengthLimitingTextInputFormatter(175)
                              //     ],
                              //     enableSuggestions: false,
                              //     maxLines: 8,
                              //     onChanged: (value) {
                              //       textSize.value = value.length;
                              //       postDes = value;
                              //     },
                              //     onDetectionTyped: (text) {
                              //       currentHashTag = text.split("#")[1];
                              //     },
                              //     onDetectionFinished: () {
                              //       if (currentHashTag.isNotEmpty) {
                              //         hashTags.add(currentHashTag);
                              //         currentHashTag = '';
                              //       }
                              //     },
                              //     decoration: InputDecoration(
                              //       border: InputBorder.none,
                              //       hintText: LKey.awesomeCaption.tr,
                              //       hintStyle: TextStyle(
                              //         color: ColorRes.colorTextLight,
                              //       ),
                              //     ),
                              //     detectionRegExp:
                              //         detectionRegExp(hashtag: true)!,
                              //     cursorColor: ColorRes.colorTextLight,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                      ],
                    ),
                    // Align(
                    //   alignment: AlignmentDirectional.topEnd,
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 15, vertical: 2),
                    //     child: ValueListenableBuilder(
                    //       valueListenable: textSize,
                    //       builder: (context, dynamic value, child) => Text(
                    //         '$value/${AppRes.maxLengthText}',
                    //         style: const TextStyle(
                    //           color: ColorRes.colorTextLight,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: () async {
                      // final data = await Get.find<NewsfeedRepository>()
                      //     .createFile(File(widget.postVideo ?? ''));
                      // try {
                      //   shortVideoRepo
                      //       .addPost(
                      //         widget.soundId ?? 1,
                      //         desController.text.isEmail
                      //             ? ''
                      //             : desController.text,
                      //         widget.postVideo ?? '',
                      //         widget.thumbNail ?? '',
                      //       )
                      //       .then((value) {});
                      //
                      //   Get.back();
                      //   // Get.back();
                      //   Get.back();
                      //   ViewUtil.showToast(
                      //       title: context.l10n.global__success_title,
                      //       message: context.l10n.short__upload_video_success);
                      // } catch (e) {
                      //   ViewUtil.showToast(
                      //       title: 'Error', message: e.toString());
                      // }

                      // if (currentHashTag.isNotEmpty) {
                      //   hashTags.add(currentHashTag);
                      //   currentHashTag = '';
                      // }
                      // CommonUI.showLoader(context);
                      // final Map<String, dynamic> param = {};

                      // param[UrlRes.duration] = '1';
                      // param[UrlRes.soundId] = widget.soundId;

                      // if (postDes.isNotEmpty) {
                      //   param[UrlRes.postDescription] = postDes;
                      // }
                      // if (hashTags.isNotEmpty) {
                      //   param[UrlRes.postHashTag] = hashTags.join(',');
                      // }

                      // if (widget.soundId != null) {
                      //   param[UrlRes.isOriginalSound] = '0';
                      //   ApiService()
                      //       .addPost(
                      //     postVideo: File(widget.postVideo ?? ''),
                      //     thumbnail: File(widget.thumbNail ?? ''),
                      //     duration: '1',
                      //     isOriginalSound: '0',
                      //     postDescription: postDes,
                      //     postHashTag: hashTags.join(','),
                      //     soundId: widget.soundId,
                      //   )
                      //       .then(
                      //     (value) {
                      //       if (value.status == 200) {
                      //         Navigator.pop(context);
                      //         Navigator.pop(context);
                      //         Navigator.pop(context);
                      //         CommonUI.showToast(
                      //             msg: LKey.postUploadSuccessfully.tr);
                      //       } else if (value.status == 401) {
                      //         CommonUI.showToast(msg: '${value.message}');
                      //         Navigator.pop(context);
                      //       }
                      //     },
                      //   );
                      // } else {
                      //   print('sound not available');
                      //   param[UrlRes.isOriginalSound] =
                      //       widget.soundId != null ? '0' : '1';
                      //   param[UrlRes.singer] =
                      //       _sessionManager.getUser()?.data?.fullName;
                      //   param[UrlRes.soundTitle] = 'Original Sound';

                      //   ApiService()
                      //       .addPost(
                      //     postVideo: File(widget.postVideo!),
                      //     thumbnail: File(widget.thumbNail!),
                      //     postSound: File(widget.sound!),
                      //     soundImage: File(widget.thumbNail!),
                      //     duration: '1',
                      //     isOriginalSound: widget.soundId != null ? '0' : '1',
                      //     postDescription: postDes,
                      //     postHashTag: hashTags.join(','),
                      //     singer: _sessionManager.getUser()?.data?.fullName,
                      //     soundTitle: 'Original Sound',
                      //     soundId: widget.soundId,
                      //   )
                      //       .then(
                      //     (value) {
                      //       Navigator.pop(context);
                      //       if (value.status == 200) {
                      //         Navigator.pop(context);
                      //         Navigator.pop(context);
                      //         CommonUI.showToast(
                      //             msg: LKey.postUploadSuccessfully.tr);
                      //       } else if (value.status == 401) {
                      //         CommonUI.showToast(msg: '${value.message}');
                      //       }
                      //     },
                      //   );
                      // }
                    },
                    child: FittedBox(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        decoration: const BoxDecoration(
                          color: AppColors.blue10,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: Center(
                          child: isLoadingUpload
                              ? const CircularProgressIndicator()
                              : Text(
                                  context.l10n.short__upload,
                                  style: const TextStyle(
                                      fontFamily: FontRes.fNSfUiBold,
                                      letterSpacing: 1,
                                      color: ColorRes.white),
                                ),
                        ),
                      ),
                    ).clickable(() async {
                      try {
                        setState(() {
                          isLoadingUpload = true;
                        });
                        await shortVideoRepo.addPost(
                          widget.soundId ?? 1,
                          desController.text.isEmail ? '' : desController.text,
                          widget.postVideo ?? '',
                          widget.thumbNail ?? '',
                        );

                        Get.back();
                        // Get.back();
                        Get.back();
                        ViewUtil.showToast(
                            title: context.l10n.global__success_title,
                            message: context.l10n.short__upload_video_success);
                      } catch (e) {
                        if (e is ApiException) {
                          // this exception is thrown by the API client, but api is success, so not show error message
                          if (e.kind ==
                              ApiExceptionKind
                                  .invalidSuccessResponseMapperType) {
                            Get.back();
                            Get.back();
                            ViewUtil.showToast(
                                title: context.l10n.global__success_title,
                                message:
                                    context.l10n.short__upload_video_success);
                          } else {
                            LogUtil.e('Error upload short-video: $e');
                            setState(() {
                              isLoadingUpload = false;
                            });
                            ViewUtil.showToast(
                                title: 'Error', message: e.toString());
                          }
                        } else {
                          LogUtil.e('Error upload short-video: $e');
                          setState(() {
                            isLoadingUpload = false;
                          });
                          ViewUtil.showToast(
                              title: 'Error', message: e.toString());
                        }
                      }
                    }),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                // const PrivacyPolicyView()
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> initSessionManager() async {
    await _sessionManager.initPref();
  }
}
