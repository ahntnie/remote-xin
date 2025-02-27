part of '../conversation_resources_view.dart';

class _VoiceTabView extends StatelessWidget {
  const _VoiceTabView({
    required this.controller,
  });

  final ConversationResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.audios.isEmpty) {
        return Center(
          child: Text(
            context.l10n.conversation_resources__no_voice,
            style: AppTextStyles.s16w500,
          ),
        );
      }

      return ListView.separated(
        padding: AppSpacing.edgeInsetsH20,
        itemCount: controller.audios.length,
        separatorBuilder: (context, index) => AppSpacing.gapH16,
        itemBuilder: (context, index) {
          final audioUrl = controller.audios[index];

          return Align(
            alignment: Alignment.centerLeft,
            child: VoiceMessageView(
              // backgroundColor: AppColors.label1Color,

              activeSliderColor: AppColors.pacificBlue,
              circlesColor: AppColors.pacificBlue,

              counterTextStyle:
                  AppTextStyles.s12w400.copyWith(color: AppColors.pacificBlue),
              // notActiveSliderColor: Colors.transparent,
              controller: VoiceController(
                audioSrc: audioUrl,
                isFile: false,
                maxDuration: const Duration(seconds: 10),
                onComplete: () {},
                onPause: () {},
                onPlaying: () {},
                onError: (err) {},
              ),
            ),
          );
        },
      );
    });
  }
}
