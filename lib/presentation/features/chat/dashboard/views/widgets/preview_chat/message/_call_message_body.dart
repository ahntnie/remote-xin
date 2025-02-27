import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../../../../../../../../core/configs/env_config.dart';
import '../../../../../../../../models/call.dart';
import '../../../../../../../../models/call_history.dart';
import '../../../../../../../../models/conversation.dart';
import '../../../../../../../../models/message.dart';
import '../../../../../../../common_widgets/app_blurry_container.dart';
import '../../../../../../../common_widgets/app_icon.dart';
import '../../../../../../../resource/resource.dart';

class PreviewCallMessageBody extends StatelessWidget {
  final Message message;
  final bool isMine;
  final int currentUserId;
  final Conversation conversation;

  const PreviewCallMessageBody({
    required this.message,
    required this.isMine,
    required this.currentUserId,
    required this.conversation,
    super.key,
  });

  CallHistory? getCallHistory(List<CallHistory> callHistories, int senderId) {
    final index = callHistories.indexWhere(
      (element) => element.userId == senderId,
    );
    if (index != -1) {
      return callHistories[index];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final Call? call = Call.callFromStringJson(message.content);

    if (message.isCallJitsi) {
      String? groupName;
      String? joinUrl;
      joinUrl = '${Get.find<EnvConfig>().jitsiUrl}/${conversation.id}';

      return AppBlurryContainer(
        blur: isMine ? 5 : 0,
        borderRadius: Sizes.s12,
        color: AppColors.grey7,
        padding: const EdgeInsets.only(
          top: Sizes.s8,
          bottom: Sizes.s8,
          left: Sizes.s24,
          right: Sizes.s8,
        ),
        child: buildItemCallGroup(
          Icons.video_call,
          l10n.call__call_meeting(groupName ?? ''),
          AppColors.text2,
          joinUrl,
          AppColors.text1,
        ),
      );
    }
    if (call == null) {
      return Container();
    }
    final callHistory = getCallHistory(call.callHistories ?? [], currentUserId);
    if (callHistory == null) {
      return Container();
    }

    return AppBlurryContainer(
      blur: isMine ? 5 : 0,
      borderRadius: Sizes.s12,
      color: AppColors.grey7,
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.s24,
        vertical: Sizes.s8,
      ),
      child: _buildStatusCall(
        callHistory.status,
        Duration(seconds: callHistory.duration).toHHMMSS(),
        call.isVideo ?? false,
      ),
    );
  }

  Widget _buildStatusCall(String status, String time, bool isVideoCall) {
    final l10n = AppLocalizations.of(Get.context!)!;
    Widget result = const SizedBox();
    switch (status) {
      case 'outgoing':
        result = buildItemStatusCall(
          AppIcons.phoneOut,
          isVideoCall
              ? l10n.call_history__video_outgoing
              : l10n.call_history__outgoing,
          AppColors.text2,
          time,
        );
        break;
      case 'incoming':
        result = buildItemStatusCall(
          AppIcons.phoneIn,
          isVideoCall
              ? l10n.call_history__video_incoming
              : l10n.call_history__incoming,
          AppColors.text2,
          time,
        );
        break;
      case 'missed':
        result = buildItemStatusCall(
          AppIcons.phoneMissed,
          isVideoCall
              ? l10n.call_history__video_missed
              : l10n.call_history__missed,
          AppColors.text2,
          time,
        );
        break;
      case 'canceled':
        result = buildItemStatusCall(
          AppIcons.phoneOut,
          isVideoCall
              ? l10n.call_history__video_canceled
              : l10n.call_history__canceled,
          AppColors.text2,
          time,
        );
      case 'declined':
        result = buildItemStatusCall(
          AppIcons.phoneMissed,
          isVideoCall
              ? l10n.call_history__video_declined
              : l10n.call_history__declined,
          AppColors.negative,
          time,
        );
        break;
    }

    return result;
  }

  Widget buildItemStatusCall(
    SvgGenImage icon,
    String title,
    Color color,
    String time,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          icon: icon,
          size: Sizes.s28,
          color: AppColors.white,
          isCircle: true,
          backgroundColor: AppColors.grey9,
        ),
        AppSpacing.gapW12,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.s16w700.copyWith(
                  color: AppColors.text2, decoration: TextDecoration.none),
            ),
            Text(
              time,
              style: AppTextStyles.s14w500.copyWith(
                  color: AppColors.grey8, decoration: TextDecoration.none),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildItemCallGroup(
    Object icon,
    String title,
    Color color,
    String time,
    Color? iconColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(
          icon: icon,
          size: Sizes.s28,
          color: iconColor ?? color,
          isCircle: true,
          backgroundColor: AppColors.grey9,
        ),
        AppSpacing.gapW12,
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.s14w700
                    .copyWith(color: color, decoration: TextDecoration.none),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(
                width: Sizes.s4,
              ),
              Text(
                time,
                style: AppTextStyles.s14w400.copyWith(
                  color: AppColors.text2,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.pacificBlue,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
