import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../resource/resource.dart';
import '../../../routing/routers/app_pages.dart';
import '../../all.dart';
import '../call.dart';
import '../enums/built_in_buttons_enum.dart';
import 'widgets/call_action_button.dart';
import 'widgets/call_action_buttons_widget.dart';
import 'widgets/call_status_widget.dart';
import 'widgets/call_video_layout.dart';
import 'widgets/flag_your_language.dart';
import 'widgets/info_user_widget.dart';

class CallView extends StatefulWidget {
  const CallView({Key? key}) : super(key: key);

  @override
  State<CallView> createState() => _CallViewState();
}

class _CallViewState extends State<CallView> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CallController>(
      autoRemove: false,
      global: false,
      init: () {
        if (Get.isRegistered<CallController>(
          tag: CallKitManager.instance.callControllerId,
        )) {
          return Get.find<CallController>(
            tag: CallKitManager.instance.callControllerId,
          );
        }

        return CallKitManager.instance.isOnPipView
            ? Get.find<CallController>(
                tag: CallKitManager.instance.callControllerId,
              )
            : Get.put<CallController>(
                CallController(),
                tag: CallKitManager.instance.callControllerId,
                permanent: true,
              );
      }(),
      builder: (controller) => WillPopScope(
        onWillPop: () async {
          await controller.pipClick(context);

          return Future.value(true);
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage(Assets.images.chatBackground.path),
                //   fit: BoxFit.fill,
                // ),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.background7)),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Obx(
                  () => controller.callStatus == CallStatusEnum.calling
                      ? CallVideoLayoutViewer(
                          key: UniqueKey(),
                          client: controller.agoraVoiceClient,
                          floatingLayoutSubViewPadding:
                              const EdgeInsets.only(top: 100, right: 40),
                          userLocalView: Obx(
                            () => Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (controller.callArgument.isGroup)
                                  Text(context.l10n.call_calling_group)
                                else
                                  InfoUserWidget(
                                    user: controller.getPartnerUser(),
                                    isTranslate:
                                        controller.callArgument.isTranslate,
                                  ),
                                if (!controller.callArgument.isGroup)
                                  AppSpacing.gapH20,
                                if (!controller.callArgument.isGroup)
                                  CallStatusWidget(
                                    key: UniqueKey(),
                                    status: controller.callStatus,
                                    countTimerController:
                                        controller.countTimerController,
                                  ),
                              ],
                            ),
                          ),
                          users: controller.users,
                          countTimerController: controller.countTimerController,
                          callStatusWidget: () => Column(
                            children: [
                              AppSpacing.gapH20,
                              Obx(
                                () => CallStatusWidget(
                                  status: controller.callStatus,
                                  countTimerController:
                                      controller.countTimerController,
                                ),
                              ),
                            ],
                          ),
                          isTranslate: controller.callArgument.isTranslate,
                        )
                      : Positioned(
                          top: 0.3.sh,
                          left: 0,
                          right: 0,
                          child: Column(
                            children: [
                              Obx(
                                () => InfoUserWidget(
                                  user: controller.getPartnerUser(),
                                  isTranslate:
                                      controller.callArgument.isTranslate,
                                ),
                              ),
                              AppSpacing.gapH20,
                              Obx(
                                () => CallStatusWidget(
                                  status: controller.callStatus,
                                  countTimerController:
                                      controller.countTimerController,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  width: Get.width,
                  child: Obx(
                    () => controller.callStatus == CallStatusEnum.ended ||
                            controller.callStatus == CallStatusEnum.rejected ||
                            controller.callStatus == CallStatusEnum.connecting
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: Sizes.s40),
                            child: CallActionButton(
                              turnOn: true,
                              onPressed: controller.onCloseClick,
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: Sizes.s24,
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                                border: Border.all(
                                  width: 0.1,
                                ),
                                // color: Colors.black.withOpacity(0.5),
                                color: const Color(0xfff6f6f6)),
                            padding: const EdgeInsets.only(
                              left: Sizes.s16,
                              right: Sizes.s16,
                              top: Sizes.s16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (controller.callStatus ==
                                        CallStatusEnum.calling ||
                                    controller.callStatus ==
                                        CallStatusEnum.ringing)
                                  CallActionButtonsWidget(
                                    client: controller.agoraVoiceClient,
                                    enabledButtons: const [
                                      BuiltInButtons.callEnd,
                                      BuiltInButtons.toggleMic,
                                      BuiltInButtons.toggleCamera,
                                      BuiltInButtons.toggleSpeaker,
                                    ],
                                    extraButtons: [
                                      CallActionButton(
                                        onPressed: () =>
                                            onChatClick(context, controller),
                                        child: Assets.icons.chat.svg(
                                            width: 24, color: Colors.black),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top,
                  left: Sizes.s16,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.arrow_back_outlined,
                          color: AppColors.text2,
                        ),
                        onPressed: () => controller.pipClick(context),
                      ),
                      Text(
                        context.l10n.text_back,
                        style: AppTextStyles.s16w700
                            .copyWith(color: AppColors.text2),
                      ),
                    ],
                  ),
                ),
                if (controller.callArgument.isTranslate)
                  Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      right: 16,
                      child: FlagYourLanguage(
                          talkCode: controller.currentUser.talkLanguage ?? '')),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => controller.callStatus == CallStatusEnum.calling &&
                                controller.callArgument.isTranslate
                            ? Text(
                                controller.statusTranslate.value,
                                style: AppTextStyles.s16Base.text2Color,
                                textAlign: TextAlign.center,
                              )
                            : AppSpacing.emptyBox,
                      ),
                      AppSpacing.gapH20,
                      Obx(
                        () => controller.callStatus == CallStatusEnum.calling &&
                                controller.callArgument.isTranslate
                            ? GestureDetector(
                                onPanDown: (_) => startRecording(controller),
                                onPanCancel: () => stopRecording(controller),
                                onPanEnd: (details) =>
                                    stopRecording(controller),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 0.15.sh),
                                  padding: AppSpacing.edgeInsetsAll16,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.pacificBlue,
                                  ),
                                  child: Obx(
                                    () => controller.isRecord.value
                                        ? const CircularProgressIndicator()
                                        : Assets.icons.translation.svg(
                                            width: 40,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              )
                            : AppSpacing.emptyBox,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          resizeToAvoidBottomInset: false,
        ),
      ),
      dispose: (state) {
        if (CallKitManager.instance.canCloseCallController) {
          GetInstance().delete<CallController>(
            tag: CallKitManager.instance.callControllerId,
            force: true,
          );
        }
      },
    );
  }

  void startRecording(CallController controller) {
    controller.isRecord.value = true;
    controller.startRecording();
  }

  void stopRecording(CallController controller) {
    controller.isRecord.value = false;
    controller.stopRecording();
  }

  Future onChatClick(BuildContext context, CallController controller) async {
    Get.back(closeOverlays: true);
    unawaited(Get.toNamed(
      Routes.chatHub,
      arguments: ChatHubArguments(conversation: controller.conversation!),
    ));
    unawaited(controller.pipClick(context));
  }
}
