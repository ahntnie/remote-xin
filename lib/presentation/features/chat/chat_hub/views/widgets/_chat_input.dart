import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rubber/rubber.dart';

import '../../../../../../core/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../common_widgets/shimmer.dart';
import '../../../../../resource/resource.dart';
import '../../../../short_video/utils/colors.dart';
import '../../controllers/chat_input_controller.dart';
import '../../controllers/record_controller.dart';
import 'reply_message_preview_widget.dart';

class ChatInput extends GetView<ChatInputController> {
  const ChatInput({super.key});

  void _onTyping(String value) {
    if (value.startsWith('/')) {
      controller.isShowMenuCommandBot.value = true;
      if (value.length > 1) {
        controller.filterCommands(value.substring(1));
      } else {
        controller.filteredCommands.value = controller.listCommandBot.value;
      }
    } else {
      controller.isShowMenuCommandBot.value = false;
    }
  }

  void _onAttachmentButtonPressed() {
    ViewUtil.hideKeyboard(Get.context!);
    Future.delayed(const Duration(seconds: 1), () async {
      controller.setIsLoadingMedia(true);
    });

    MediaHelper.pickMultipleMediaFromGallery().then((media) {
      controller.setIsLoadingMedia(false);
      if (media.isNotEmpty) {
        controller.attachImages(media);
        controller.pathLocal = media.first.file.path.substring(0, 24);
      }
    }).catchError(
      (error) {
        if (error is ValidationException) {
          // ViewUtil.showToast(
          //   title: Get.context!.l10n.error__file_is_too_large_title,
          //   message: Get.context!.l10n.error__file_is_too_large_message,
          // );
        }
        controller.setIsLoadingMedia(false);
      },
    ).whenComplete(() {
      controller.focusNode.requestFocus();
      controller.setIsLoadingMedia(false);
    });
  }

  void _onDocumentButtonPressed() {
    MediaHelper.pickDocument().then(
      (media) {
        if (media != null) {
          controller.attachImages([media]);
        }
      },
    ).catchError(
      (error) {
        if (error is ValidationException) {
          ViewUtil.showToast(
            title: Get.context!.l10n.error__file_is_too_large_title,
            message: Get.context!.l10n.error__file_is_too_large_message,
          );
        }
      },
    );
  }

  void _onCameraButtonPressed() {
    ViewUtil.hideKeyboard(Get.context!);
    MediaHelper.takeImageFromCamera().then((media) {
      if (media != null) {
        controller.attachImages([media]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: AppSpacing.edgeInsetsH8.copyWith(
        bottom: AppSpacing.bottomPaddingValue(context, additional: 0),
      ),
      child: GetBuilder<RecordController>(
        // init: RecordController(),
        builder: (controller) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: controller.isRecording.value
                ? _buildRecordingAudio()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // _buildToReplyMessagePreview(),
                      Row(
                        children: [
                          AppSpacing.gapW8,
                          this.controller.chatHubController.arguments.isBot ==
                                  false
                              ? _buildStickerButton()
                              : const SizedBox(),
                          this.controller.chatHubController.arguments.isBot ==
                                  true
                              ? _buildButtonMenuCommandBot(context)
                              : const SizedBox(),
                          Expanded(
                            child: _buildTextField(context),
                          ),
                          // _buildShowMoreButton(),
                          // _buildRecordButton(),

                          _buildSendOrRecordButton(context),
                          // AppSpacing.gapW4,
                          // _buildSendButton(context),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
    // return const SizedBox();
    return Container(
      color: AppColors.grey11,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _buildSearchMentionedUsers(),
          Obx(() {
            if (controller.isShowMenuCommandBot.value) {
              return const Text('context');
            }
            return const SizedBox();
          }),
          child,
        ],
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return Obx(() {
      if (!controller.isInputEmpty) {
        return AppIcon(
          icon: AppIcons.send,
          color: AppColors.white,
          isCircle: true,
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.all(5),
          onTap: controller.sendMessage,
        );
      }
      return AppIcon(
        icon: AppIcons.send,
        color: AppColors.text4,
        padding: AppSpacing.edgeInsetsAll12.copyWith(left: 8),
        onTap: controller.sendMessage,
      );
    });
  }

  Widget _buildTextField(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToSendMediasPreview(),
        _buildToSendMediaPreviewLoading(),
        AppTextField(
          fillColor: Colors.transparent,
          // border: const OutlineInputBorder(
          //   borderSide: BorderSide.none,
          //   borderRadius: BorderRadius.all(Radius.circular(39)),
          // ),
          border: InputBorder.none,
          hintStyle: AppTextStyles.s16w400.copyWith(color: AppColors.grey8),
          controller: controller.textEditingController,
          focusNode: controller.focusNode,
          borderRadius: Sizes.s32,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Sizes.s12,
            vertical: Sizes.s8,
          ),
          maxLines: 5,
          minLines: 1,
          // hintText: context.l10n.chat_hub__input_hint,
          hintText: context.l10n.text_type_message,

          onChanged: _onTyping,
          onFieldSubmitted: (_) => controller.sendMessage(),
          // suffixIcon: _buildStickerButton(),
        ),
      ],
    );
  }

  Widget _buildToSendMediaPreviewLoading() {
    return Obx(
      () => controller.isLoadingMedia.value
          ? SizedBox(
              height: 60,
              child: const Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.blue10,
                      strokeWidth: 3,
                    ),
                  ),
                  // const SizedBox(width: 12),
                  // Text('${controller.loadMediaPersent.value}%',
                  //     style: AppTextStyles.s12Base.text2Color),
                ],
              ).marginOnly(left: 8),
            )
          : const SizedBox(),
    );
  }

  Widget _buildToSendMediasPreview() {
    return Obx(
      () => Column(
        children: [
          if (controller.toSendImages.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: controller.toSendImages.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = controller.toSendImages[index];

                  return AppMediaPreview(
                    media: item,
                    onRemove: () {
                      controller.removeItemInMedias(item);
                    },
                  ).marginOnly(left: 8);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToReplyMessagePreview() {
    return Obx(
      () => controller.chatHubController.replyFromMessage != null
          ? Padding(
              padding: AppSpacing.edgeInsetsV8,
              child: ReplyMessagePreviewWidget(
                message: controller.chatHubController.replyFromMessage!,
                onCloseMessage: controller.chatHubController.removeReplyMessage,
                isMine: controller.chatHubController.replyFromMessage?.isMine(
                      myId: controller.chatHubController.currentUser.id,
                    ) ??
                    true,
                members: controller.chatHubController.conversation.members,
                onMentionPressed: controller.chatHubController.onMentionPressed,
              ),
            )
          : AppSpacing.emptyBox,
    );
  }

  Widget _buildSendOrRecordButton(BuildContext context) {
    return Obx(() {
      if (controller.isInputEmpty && controller.toSendImages.isEmpty) {
        return controller.chatHubController.arguments.isBot == false
            ? Row(
                children: [
                  _buildShowMoreButton(),
                  _buildRecordButton(),
                  _buildGallery(context)
                ],
              )
            : const SizedBox();
      }

      return AppIcon(
        icon: Assets.icons.send,
        color: AppColors.blue10,
        padding: AppSpacing.edgeInsetsAll12.copyWith(left: 8),
        onTap: controller.sendMessage,
      );
    });
  }

  // Widget _buildAttachButtons() {
  //   return Obx(
  //     () => controller.isInputEmpty
  //         ? AppSpacing.emptyBox
  //         : Row(
  //             children: [
  //               _buildCameraButton(),
  //               _buildGalleryButton(),
  //               _buildSendDocumentButton(),
  //               _buildRecordButton(),
  //             ],
  //           ),
  //   );
  // }

  Widget _buildStickerButton() {
    return AppIcon(
      icon: AppIcons.sticker,
      color: AppColors.text2,
      // padding: AppSpacing.edgeInsetsAll8,
      onTap: controller.stipop.show,
    );
  }

  Widget _buildRecordButton() {
    return GetBuilder<RecordController>(
      init: RecordController(), // INIT IT ONLY THE FIRST TIME
      builder: (controller) {
        return AppIcon(
          icon: AppIcons.microphone,
          padding: AppSpacing.edgeInsetsAll8,
          color: AppColors.text2,
        ).clickable(() {
          controller.startRecording();
        });
      },
    );
  }

  Widget _buildGallery(BuildContext context) => AppIcon(
        icon: Assets.icons.gallery,
        padding: AppSpacing.edgeInsetsAll8.copyWith(left: 6),
        color: AppColors.text2,
      ).clickable(() {
        ViewUtil.hideKeyboard(context);
        _onAttachmentButtonPressed();
      });

  Widget _buildRecordingAudio() {
    return GetBuilder<RecordController>(
      init: RecordController(),
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppSpacing.gapW8,
            _buildDeleteAudioButton(controller),
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.blue7.withOpacity(0.58),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                children: [
                  controller.isRecordingCompleted.value
                      ? Row(
                          children: [
                            _buildPlayAudio(controller),
                            AudioFileWaveforms(
                              size: Size(0.8.sw, 30),
                              playerController: controller.playController,
                              padding: EdgeInsets.only(left: 6.w, right: 6.w),
                              decoration: const BoxDecoration(),
                              playerWaveStyle: const PlayerWaveStyle(
                                fixedWaveColor: AppColors.deepSkyBlue,
                                liveWaveColor: AppColors.deepSkyBlue,
                                seekLineColor: AppColors.deepSkyBlue,
                              ),
                            ),
                            // controller.isPlaying.value
                            //     ?
                            StreamBuilder<Duration>(
                              stream:
                                  controller.onPlayingCurrentDurationChanged,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    '${snapshot.data!.inMinutes.toString().padLeft(2, '0')}:${(snapshot.data!.inSeconds % 60).toString().padLeft(2, '0')}',
                                    style: AppTextStyles.s12w400
                                        .copyWith(color: AppColors.zambezi),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),
                            // : Text(
                            //     controller.maxDuration.value,
                            //     style: AppTextStyles.s12w400,
                            //   ),
                          ],
                        )
                      : Row(
                          children: [
                            _buildPauseRecording(controller),
                            AudioWaveforms(
                              enableGesture: true,
                              size: Size(200.w, 30),
                              recorderController: controller.recorderController,
                              waveStyle: const WaveStyle(
                                waveColor: AppColors.deepSkyBlue,
                                extendWaveform: true,
                                showMiddleLine: false,
                                spacing: 5,
                              ),
                              padding: EdgeInsets.only(
                                left: 8.w,
                                right: 8.w,
                              ),
                            ),
                            StreamBuilder<Duration>(
                              stream: controller
                                  .recorderController.onCurrentDuration,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    controller.formatDuration(snapshot.data!),
                                    style: AppTextStyles.s12w400
                                        .copyWith(color: AppColors.zambezi),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                ],
              ),
            ),
            _buildSendAudioButton(controller),
          ],
        );
      },
    );
  }

  Widget _buildSendAudioButton(RecordController controller) {
    return AppIcon(
      icon: Assets.icons.send,
      color: AppColors.blue10,
      padding: AppSpacing.edgeInsetsAll12,
      onTap: () {
        controller.onSendAudio();
      },
    );
  }

  Widget _buildDeleteAudioButton(RecordController controller) {
    return AppIcon(
      icon: AppIcons.deleteAudio,
      color: AppColors.zambezi,
      onTap: () {
        controller.deleteRecord();
      },
    );
  }

  Widget _buildPauseRecording(RecordController controller) {
    return Container(
      width: Sizes.s28,
      height: Sizes.s28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pacificBlue,
        // gradient: LinearGradient(
        //   colors: AppColors.button2,
        // ),
      ),
      child: GetBuilder<RecordController>(
        init: RecordController(),
        builder: (controller) {
          return AppIcon(
            icon: AppIcons.pauseAudio,
            padding: const EdgeInsets.all(4),
            onTap: () {
              controller.stopRecording();
            },
          );
        },
      ),
    );
  }

  Widget _buildPlayAudio(RecordController controller) {
    return Container(
      width: Sizes.s28,
      height: Sizes.s28,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.pacificBlue,
        // gradient: LinearGradient(
        //   colors: AppColors.button2,
        // ),
      ),
      child: GetBuilder<RecordController>(
        init: RecordController(),
        builder: (controller) {
          return AppIcon(
            icon: AppIcons.playAudio,
            color: AppColors.text1,
            padding: const EdgeInsets.all(4),
            onTap: () {
              controller.playAudio();
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchMentionedUsers() {
    return Obx(
      () {
        if (controller.mentionedUsersInSearch.isEmpty) {
          return AppSpacing.emptyBox;
        }

        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 220,
          ),
          child: Container(
            child: Padding(
              padding: EdgeInsets.only(bottom: 72.h),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: controller.mentionedUsersInSearch.length,
                itemBuilder: (context, index) {
                  final user = controller.mentionedUsersInSearch[index];

                  return ListTile(
                    leading: AppCircleAvatar(
                      url: user.avatarPath ?? '',
                      size: Sizes.s40,
                    ),
                    title: Text(
                      user.fullName,
                      style: AppTextStyles.s16w500.text2Color,
                    ),
                    onTap: () => controller.onMentionedUserSelected(user),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShowMoreButton() {
    return AppIcon(
      icon: Assets.icons.postOption,
      size: 6,
      color: AppColors.text2,
      padding: AppSpacing.edgeInsetsAll12.copyWith(right: 6, left: 0),
      onTap: () {
        ViewUtil.showBottomSheet(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: GridView(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: Sizes.s16,
              ),
              children: [
                _buildCameraButton(),
                _buildGalleryButton(),
                _buildSendDocumentButton(),
                _buildScheduleReminder(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleReminder() {
    return _buildOptionItem(
        context: Get.context!,
        icon: AppIcon(
          icon: AppIcons.bell,
          isCircle: true,
          backgroundColor: AppColors.blue10,
          padding: AppSpacing.edgeInsetsAll8,
        ),
        title: Get.context!.l10n.schedule_reminder,
        onTap: () {});
  }

  Widget _buildCameraButton() {
    return _buildOptionItem(
      context: Get.context!,
      icon: AppIcon(
        icon: AppIcons.camera,
        isCircle: true,
        backgroundColor: AppColors.blue10,
        padding: AppSpacing.edgeInsetsAll8,
      ),
      title: Get.context!.l10n.chat_hub__camera_label,
      onTap: _onCameraButtonPressed,
    );
  }

  Widget _buildGalleryButton() {
    return _buildOptionItem(
      context: Get.context!,
      icon: AppIcon(
        icon: AppIcons.gallery,
        isCircle: true,
        backgroundColor: AppColors.blue10,
        padding: AppSpacing.edgeInsetsAll8,
      ),
      title: Get.context!.l10n.chat_hub__gallery_label,
      onTap: _onAttachmentButtonPressed,
    );
  }

  Widget _buildSendDocumentButton() {
    return _buildOptionItem(
      context: Get.context!,
      icon: AppIcon(
        icon: AppIcons.document,
        isCircle: true,
        backgroundColor: AppColors.blue10,
        padding: AppSpacing.edgeInsetsAll8,
      ),
      title: Get.context!.l10n.chat_hub__document_label,
      onTap: _onDocumentButtonPressed,
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        icon,
        AppSpacing.gapH4,
        Text(
          title,
          style: AppTextStyles.s12w600.copyWith(
            color: AppColors.zambezi,
          ),
        ),
      ],
    ).clickable(() {
      Get.back();
      onTap();
    });
  }

  Widget _buildButtonMenuCommandBot(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Row(
          children: [
            Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns:
                        Tween<double>(begin: 0.0, end: 0.5).animate(animation),
                    child: child,
                  );
                },
                child: AppIcon(
                  key: ValueKey<bool>(controller.isShowMenuCommandBot.value),
                  icon: controller.isShowMenuCommandBot.value
                      ? Icons.close
                      : Icons.menu,
                  color: AppColors.white,
                ),
              );
            }),
            AppSpacing.gapW4,
            const Text(
              'Menu',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ).clickable(() {
      controller.isShowMenuCommandBot.value =
          !controller.isShowMenuCommandBot.value;
      _showMenuCommandBot(context);
    });
  }

  // Widget _buildMenuCommandBot(BuildContext context) {
  //   return Obx(() {
  //     return false //controller.isFetchingCommand.value
  //         ? SizedBox(
  //             height: 300,
  //             child: ListView.builder(
  //               itemCount: 5,
  //               itemBuilder: (context, index) {
  //                 return _buildItemMenuShimmer(context);
  //               },
  //             ),
  //           )
  //         : ConstrainedBox(
  //           constraints: BoxConstraints(
  //             maxHeight: MediaQuery.of(context).size.height / 2,
  //             minHeight: 60,
  //           ),
  //           child: Container(
  //             height:
  //                 controller.filteredCommands.value.slashCommands!.length *
  //                     60.0,
  //             margin: EdgeInsets.only(bottom: 0.059.sh),
  //             decoration: BoxDecoration(
  //               color: AppColors.white,
  //               borderRadius: BorderRadius.circular(16),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.withOpacity(0.4),
  //                   spreadRadius: 2,
  //                   blurRadius: 10,
  //                   offset: const Offset(0, 3),
  //                 ),
  //               ],
  //             ),
  //             child: Obx(() {
  //               final commands = controller.filteredCommands;
  //               return ListView.builder(
  //                 itemCount: commands.value.slashCommands!.length,
  //                 itemBuilder: (context, index) {
  //                   return _buildItemMenuCommandBot(
  //                     context,
  //                     commands.value.slashCommands![index].name!,
  //                     commands.value.slashCommands![index].description!,
  //                     () {
  //                       controller.textEditingController.text =
  //                           '/${commands.value.slashCommands![index].name!}';
  //                       controller.sendMessage();
  //                       controller.textEditingController.clear();
  //                       controller.isShowMenuCommandBot.value = false;
  //                     },
  //                   );
  //                 },
  //               );
  //             }),
  //           ),
  //         );
  //   });
  // }

  // void _showMenuCommandBot(BuildContext context) {
  //   Future.delayed(const Duration(milliseconds: 100), () {
  //     Scaffold.of(context)
  //         .showBottomSheet(
  //           backgroundColor: Colors.transparent,
  //           (BuildContext context) {
  //             return Container(
  //               // margin: EdgeInsets.only(
  //               //     bottom: MediaQuery.of(context).size.height * 0.05),
  //               decoration: const BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.vertical(top: Radius.circular(1)),
  //               ),
  //               child: DraggableScrollableSheet(
  //                 minChildSize: 0.2,
  //                 expand: false,
  //                 builder: (context, scrollController) {
  //                   return Obx(() {
  //                     final commands = controller.filteredCommands;
  //                     return controller.isFetchingCommand.value
  //                         ? ListView.builder(
  //                             controller: scrollController,
  //                             itemCount: 5,
  //                             itemBuilder: (context, index) {
  //                               return _buildItemMenuShimmer(context);
  //                             },
  //                           )
  //                         : ListView.builder(
  //                             controller: scrollController,
  //                             itemCount: commands.value.slashCommands!.length,
  //                             itemBuilder: (context, index) {
  //                               return _buildItemMenuCommandBot(
  //                                 context,
  //                                 commands.value.slashCommands![index].name!,
  //                                 commands
  //                                     .value.slashCommands![index].description!,
  //                                 () {
  //                                   controller.textEditingController.text =
  //                                       '/${commands.value.slashCommands![index].name!}';
  //                                   controller.sendMessage();
  //                                   controller.textEditingController.clear();
  //                                   controller.isShowMenuCommandBot.value =
  //                                       false;
  //                                   Navigator.pop(context);
  //                                 },
  //                               );
  //                             },
  //                           );
  //                   });
  //                 },
  //               ),
  //             );
  //           },
  //         )
  //         .closed
  //         .then((_) {
  //           controller.isShowMenuCommandBot.value = false;
  //           print('Bottom sheet đã đóng!');
  //         });
  //   });
  // }

  void _showMenuCommandBot(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.of(context)
          .push(PageRouteBuilder(
        opaque: false, // Cho phép hiển thị nền mờ phía sau
        pageBuilder: (context, animation, secondaryAnimation) {
          return _RubberBottomSheetContent(
            controller: controller,
          );
        },
      ))
          .then((_) {
        controller.isShowMenuCommandBot.value = false;
        print('Bottom sheet đã đóng!');
      });
    });
  }

  Widget _buildItemMenuCommandBot(BuildContext context, String name,
      String description, VoidCallback onTap) {
    return Wrap(children: [
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Container(
              //   width: 32,
              //   height: 32,
              //   decoration: const BoxDecoration(
              //     color: AppColors.primary,
              //     shape: BoxShape.circle,
              //   ),
              //   child: Center(
              //       child: Text('XIN', style: AppTextStyles.s14w700.text1Color)),
              // ),

              Text(
                description,
                style: const TextStyle(color: AppColors.text2),
              ),
              Text(
                '/$name',
                style: const TextStyle(color: AppColors.subText3),
              ),
            ],
          ).paddingOnly(left: 8, right: 12, top: 10, bottom: 8),
          const Divider(
            thickness: 0.3,
            color: Colors.grey,
          ).paddingOnly(left: 20),
        ],
      ),
    ]).clickable(onTap);
  }

  Widget _buildItemMenuShimmer(BuildContext context) {
    return Row(
      children: [
        // Container(
        //   width: 32,
        //   height: 32,
        //   decoration: const BoxDecoration(
        //     color: AppColors.primary,
        //     shape: BoxShape.circle,
        //   ),
        //   child: Center(
        //       child: Text('XIN', style: AppTextStyles.s14w700.text1Color)),
        // ),
        AppSpacing.gapW8,
        Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.2),
          highlightColor: ColorRes.colorLight.withOpacity(0.2),
          child: Container(
            width: 100,
            height: 20,
            color: Colors.grey,
          ),
        ),
        AppSpacing.gapW8,
        Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.2),
          highlightColor: ColorRes.colorLight.withOpacity(0.2),
          child: Container(
            width: 100,
            height: 20,
            color: Colors.grey,
          ),
        ),
      ],
    ).paddingOnly(left: 8, right: 12, top: 8, bottom: 8);
  }
}

/// Widget này chứa toàn bộ logic hiển thị RubberBottomSheet
class _RubberBottomSheetContent extends StatefulWidget {
  const _RubberBottomSheetContent({required this.controller, Key? key})
      : super(key: key);
  final ChatInputController controller;
  @override
  _RubberBottomSheetContentState createState() =>
      _RubberBottomSheetContentState();
}

class _RubberBottomSheetContentState extends State<_RubberBottomSheetContent>
    with SingleTickerProviderStateMixin {
  late RubberAnimationController _rubberController;

  @override
  void initState() {
    super.initState();
    _rubberController = RubberAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      // Khi bottom sheet ở trạng thái đóng, chỉ hiện 10px từ cạnh dưới
      // lowerBoundValue: AnimationControllerValue(pixel: 10),
      // // Chiều cao tối đa của bottom sheet (ví dụ chiếm 70% chiều cao màn hình)
      upperBoundValue: AnimationControllerValue(percentage: 0.5),
      // // Giá trị khởi tạo ban đầu là 10px
      initialValue: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền mờ phía sau khi hiển thị bottom sheet
      backgroundColor: Colors.blue.withOpacity(0.1),
      body: RubberBottomSheet(
        animationController: _rubberController,
        // lowerLayer dùng để hiển thị nền phía sau bottom sheet; chạm vào đây sẽ đóng sheet
        lowerLayer: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.transparent),
        ),
        // upperLayer chứa nội dung của bottom sheet
        upperLayer: Obx(() {
          final commands = widget.controller.filteredCommands;
          print(commands.value.slashCommands!.length);
          return widget.controller.isFetchingCommand.value
              ? ListView.builder(
                  //  controller: scrollController,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return _buildItemMenuShimmer(context);
                  },
                )
              : ListView.builder(
                  // controller: scrollController,
                  itemCount: commands.value.slashCommands!.length,
                  itemBuilder: (context, index) {
                    return _buildItemMenuCommandBot(
                      context,
                      commands.value.slashCommands![index].name!,
                      commands.value.slashCommands![index].description!,
                      () {
                        widget.controller.textEditingController.text =
                            '/${commands.value.slashCommands![index].name!}';
                        widget.controller.sendMessage();
                        widget.controller.textEditingController.clear();
                        widget.controller.isShowMenuCommandBot.value = false;
                        Navigator.pop(context);
                      },
                    );
                  },
                );
        }),
      ),
    );
  }

  Widget _buildItemMenuCommandBot(BuildContext context, String name,
      String description, VoidCallback onTap) {
    return Wrap(children: [
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Container(
              //   width: 32,
              //   height: 32,
              //   decoration: const BoxDecoration(
              //     color: AppColors.primary,
              //     shape: BoxShape.circle,
              //   ),
              //   child: Center(
              //       child: Text('XIN', style: AppTextStyles.s14w700.text1Color)),
              // ),

              Text(
                description,
                style: const TextStyle(color: AppColors.text2),
              ),
              Text(
                '/$name',
                style: const TextStyle(color: AppColors.subText3),
              ),
            ],
          ).paddingOnly(left: 8, right: 12, top: 10, bottom: 8),
          const Divider(
            thickness: 0.3,
            color: Colors.grey,
          ).paddingOnly(left: 20),
        ],
      ),
    ]).clickable(onTap);
  }

  Widget _buildItemMenuShimmer(BuildContext context) {
    return Row(
      children: [
        // Container(
        //   width: 32,
        //   height: 32,
        //   decoration: const BoxDecoration(
        //     color: AppColors.primary,
        //     shape: BoxShape.circle,
        //   ),
        //   child: Center(
        //       child: Text('XIN', style: AppTextStyles.s14w700.text1Color)),
        // ),
        AppSpacing.gapW8,
        Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.2),
          highlightColor: ColorRes.colorLight.withOpacity(0.2),
          child: Container(
            width: 100,
            height: 20,
            color: Colors.grey,
          ),
        ),
        AppSpacing.gapW8,
        Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.2),
          highlightColor: ColorRes.colorLight.withOpacity(0.2),
          child: Container(
            width: 100,
            height: 20,
            color: Colors.grey,
          ),
        ),
      ],
    ).paddingOnly(left: 8, right: 12, top: 8, bottom: 8);
  }
}
