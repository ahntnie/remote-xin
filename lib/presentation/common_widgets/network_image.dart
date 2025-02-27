import 'package:cached_network_image/cached_network_image.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../core/all.dart';
import '../resource/resource.dart';
import 'all.dart';

const int _kDefaultImageCacheWidth = 200;
const int _kDefaultImageCacheHeight = 250;

class AppNetworkImage extends StatefulWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.imageBuilder,
    this.width,
    this.height,
    this.fadeOutDuration,
    this.fadeOutCurve = Curves.easeOut,
    this.useOldImageOnUrlChange = false,
    this.loadingBackgroundColor,
    this.radius,
    this.clickToSeeFullImage = false,
    this.colorLoading,
    this.sizeLoading,
    this.onFullImageLongPress,
    this.images,
    this.multiImage = false,
    this.initIndex,
  });

  final String? url;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Widget Function(
    BuildContext context,
    ImageProvider imageProvider,
  )? imageBuilder;
  final double? width;
  final double? height;
  final Duration? fadeOutDuration;
  final Curve fadeOutCurve;
  final bool useOldImageOnUrlChange;
  final Color? loadingBackgroundColor;
  final double? radius;
  final bool clickToSeeFullImage;
  final Color? colorLoading;
  final double? sizeLoading;
  final VoidCallback? onFullImageLongPress;
  final List<String>? images;
  final bool multiImage;
  final int? initIndex;

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  late PageController pageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController(
      initialPage: widget.multiImage ? widget.initIndex ?? 0 : 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null || widget.url!.isEmpty) {
      return _buildErrorWidget();
    }

    // final cacheWidth = (width ?? _kDefaultImageCacheWidth).cacheSize(context);
    // final cacheHeight =
    //     (height ?? _kDefaultImageCacheHeight).cacheSize(context);

    Widget image = CachedNetworkImage(
      imageUrl: widget.url!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (_, __) =>
          widget.placeholder ?? _buildDefaultLoadingWidget(),
      errorWidget: (_, __, dynamic error) => _buildErrorWidget(),
      imageBuilder: widget.imageBuilder,
      fadeOutDuration: widget.fadeOutDuration,
      fadeInDuration: Duration.zero,
      fadeOutCurve: widget.fadeOutCurve,
      useOldImageOnUrlChange: widget.useOldImageOnUrlChange,
      memCacheWidth: widget.width != null
          ? widget.width!.cacheSize(context)
          : _kDefaultImageCacheWidth,
      memCacheHeight: widget.height != null
          ? widget.height!.cacheSize(context)
          : _kDefaultImageCacheHeight,
    );

    if (widget.radius != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius!),
        child: image,
      );
    }
    if (widget.clickToSeeFullImage && widget.url != null) {
      return image.clickable(() {
        // ViewUtil.showImageDialog(
        //   imageUrl: url!,
        //   onLongPress: onFullImageLongPress,
        // );
        Get.generalDialog(
          barrierColor: Colors.black87,
          pageBuilder: (context, animation, secondaryAnimation) {
            return DismissiblePage(
              onDismissed: () => Navigator.of(context).pop(),
              // Start of the optional properties
              isFullScreen: false,
              minRadius: 10,
              maxRadius: 10,
              dragSensitivity: 1.0,
              maxTransformValue: .8,
              direction: DismissiblePageDismissDirection.multi,
              // onDragStart: () {
              //   print('onDragStart');
              // },
              // onDragUpdate: (details) {
              //   print(details);
              // },
              dismissThresholds: const {
                DismissiblePageDismissDirection.vertical: .2,
              },
              minScale: .8,
              reverseDuration: const Duration(milliseconds: 250),
              // End of the optional properties
              child: PhotoViewGallery.builder(
                pageController: pageController,
                builder: (BuildContext context, int index) =>
                    PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.multiImage
                      ? widget.images![index]
                      : widget.url ?? ''),
                  maxScale: 4.0,
                  minScale: PhotoViewComputedScale.contained,
                ),
                itemCount: widget.multiImage ? widget.images!.length : 1,
                // loadingBuilder: (context, event) =>
                //     _imageGalleryLoadingBuilder(event),

                scrollPhysics: const ClampingScrollPhysics(),
              ),
            );
          },
        );
      });
    }

    return image;
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? AppSpacing.emptyBox;
  }

  Widget _buildDefaultLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        color: widget.loadingBackgroundColor ??
            AppColors.label1Color.withOpacity(0.58),
        borderRadius: BorderRadius.circular(widget.radius ?? 0),
      ),
      width: widget.width,
      height: widget.height,
      child: AppDefaultLoading(
        color: widget.colorLoading,
      ),
    );
  }
}

class AppCachedNetworkImageProvider extends CachedNetworkImageProvider {
  const AppCachedNetworkImageProvider(super.url);
}

extension ImageExtension on num {
  int cacheSize(BuildContext context) {
    return (this * MediaQuery.of(context).devicePixelRatio).round();
  }
}
