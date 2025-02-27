import 'package:easy_count_timer/easy_count_timer.dart';
import 'package:flutter/material.dart';

import '../../../../../core/all.dart';
import '../../../../resource/resource.dart';
import '../../enums/call_status_enum.dart';

class CallStatusWidget extends StatelessWidget {
  const CallStatusWidget({
    required this.status,
    required this.countTimerController,
    super.key,
  });

  final CallStatusEnum status;
  final CountTimerController countTimerController;

  @override
  Widget build(BuildContext context) {
    if (status == CallStatusEnum.connecting) {
      return Text(
        context.l10n.call__connecting,
        style: AppTextStyles.s14w400.copyWith(color: AppColors.text2),
      );
    }
    if (status == CallStatusEnum.ringing) {
      return Text(
        context.l10n.call__calling,
        style: AppTextStyles.s14w400.copyWith(color: AppColors.text2),
      );
    }
    if (status == CallStatusEnum.rejected) {
      return Text(
        context.l10n.call__call_rejected,
        style: AppTextStyles.s14w400.copyWith(color: AppColors.text2),
      );
    }
    if (status == CallStatusEnum.cancelled) {
      return Text(
        context.l10n.call__call_canceled,
        style: AppTextStyles.s14w400.copyWith(color: AppColors.text2),
      );
    }
    if (status == CallStatusEnum.calling || status == CallStatusEnum.ended) {
      return Column(
        children: [
          if (status == CallStatusEnum.ended)
            Text(
              context.l10n.call__call_ended,
              style: AppTextStyles.s14w400.copyWith(color: AppColors.text2),
            ),
          if (status == CallStatusEnum.ended) AppSpacing.gapH16,
          CountTimer(
            controller: countTimerController,
            enableDescriptions: false,
            format: CountTimerFormat.hoursMinutesSeconds,
            timeTextStyle:
                AppTextStyles.s14w400.copyWith(color: AppColors.text2),
            colonsTextStyle:
                AppTextStyles.s14w400.copyWith(color: AppColors.text2),
          ),
        ],
      );
    }

    return Container();
  }
}
