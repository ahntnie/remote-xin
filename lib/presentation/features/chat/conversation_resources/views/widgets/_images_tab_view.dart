part of '../conversation_resources_view.dart';

class _ImageTabView extends StatelessWidget {
  const _ImageTabView({
    required this.controller,
  });

  final ConversationResourcesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.images.isEmpty) {
        return Center(
          child: Text(
            context.l10n.conversation_resources__no_image,
            style: AppTextStyles.s16w500,
          ),
        );
      }

      return GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: controller.images.length,
        itemBuilder: (context, index) {
          final imageUrl = controller.images[index];

          return AppNetworkImage(
            imageUrl,
            fit: BoxFit.fitWidth,
          ).clickable(() => _onImageTap(context, index, controller.images));
        },
      );
    });
  }

  void _onImageTap(BuildContext context, int index, List<String> images) {
    Get.generalDialog(
      barrierColor: Colors.black87,
      barrierDismissible: true,
      barrierLabel: 'conversation_resources__images_carousel',
      pageBuilder: (context, animation, secondaryAnimation) {
        return _ImagesCarouselDialog(
          images: images,
          initialIndex: index,
        );
      },
    );
  }
}

class _ImagesCarouselDialog extends StatelessWidget {
  const _ImagesCarouselDialog({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return DisabledDialogWrapper(
      dismissibleKey: Key(images[initialIndex]),
      child: CarouselSlider.builder(
        itemCount: images.length,
        disableGesture: true,
        options: CarouselOptions(
          height: 1.sh,
          initialPage: initialIndex,
          enableInfiniteScroll: false,
          viewportFraction: 1.0,
          onPageChanged: (index, _) {},
        ),
        itemBuilder: (context, index, _) {
          final imageUrl = images[index];

          return AppNetworkImage(
            imageUrl,
            fit: BoxFit.contain,
            imageBuilder: (context, imageProvider) {
              return Image(
                image: ResizeImage(
                  imageProvider,
                  width: 1.sw.toInt().cacheSize(context),
                ),
                fit: BoxFit.contain,
              );
            },
          );
        },
      ),
    );
  }
}
