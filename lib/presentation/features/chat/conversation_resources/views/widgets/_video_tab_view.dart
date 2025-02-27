part of '../conversation_resources_view.dart';

class _VideoTabView extends StatelessWidget {
  const _VideoTabView({
    required this.controller,
  });

  final ConversationResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.videos.isEmpty) {
        return Center(
          child: Text(
            context.l10n.conversation_resources__no_video,
            style: AppTextStyles.s16w500,
          ),
        );
      }

      return GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: controller.videos.length,
        itemBuilder: (context, index) {
          final videoUrl = controller.videos[index];

          return IgnorePointer(
            child: AppVideoPlayer(
              videoUrl,
              fit: BoxFit.fitWidth,
              isThumbnailMode: true,
            ),
          ).clickable(() => _onVideoTap(context, index, controller.videos));
        },
      );
    });
  }

  void _onVideoTap(BuildContext context, int index, List<String> videos) {
    Get.generalDialog(
      barrierColor: Colors.black87,
      barrierDismissible: true,
      barrierLabel: 'conversation_resources__videos_carousel',
      pageBuilder: (context, animation, secondaryAnimation) {
        return _VideosCarouselDialog(
          videos: videos,
          initialIndex: index,
        );
      },
    );
  }
}

class _VideosCarouselDialog extends StatelessWidget {
  const _VideosCarouselDialog({
    required this.videos,
    required this.initialIndex,
  });

  final List<String> videos;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return DisabledDialogWrapper(
      child: CarouselSlider.builder(
        itemCount: videos.length,
        disableGesture: true,
        options: CarouselOptions(
          height: 1.sh,
          initialPage: initialIndex,
          enableInfiniteScroll: false,
          viewportFraction: 1,
        ),
        itemBuilder: (context, index, _) {
          final videoUrl = videos[index];

          return AppVideoPlayer(
            videoUrl,
            fit: BoxFit.fitWidth,
          );
        },
      ),
    );
  }
}
