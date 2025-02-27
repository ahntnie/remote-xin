import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../../core/all.dart';
import '../../../../../core/enums/item_video_from_page_enums.dart';
import '../../../../resource/resource.dart';
import '../../modal/user_video/user_video.dart';
import '../video/video_list_screen.dart';

class ItemPost extends StatefulWidget {
  final Data? data;
  final List<Data> list;
  final VoidCallback? onTap;
  final int? type;
  final int? userId;
  final String? soundId;
  final Function(int index, bool isLiked, int count) onLike;
  final Function(int index, int count) onComment;
  final Function(int postId)? onDelete;
  final Function(int index, bool value) onPinned;
  final Function(int index, bool value) onBookmark;
  final Function(int index, bool value) onFollowed;

  const ItemPost(
      {required this.data,
      required this.list,
      required this.onDelete,
      required this.onPinned,
      required this.onLike,
      required this.onComment,
      required this.onBookmark,
      required this.onFollowed,
      super.key,
      this.onTap,
      this.type,
      this.userId,
      this.soundId});

  @override
  State<ItemPost> createState() => _ItemPostState();
}

class _ItemPostState extends State<ItemPost> {
  bool isPinned = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isPinned = widget.data?.isPinned ?? false;
  }

  @override
  void didUpdateWidget(covariant ItemPost oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the data has changed
    if (oldWidget.data != widget.data) {
      log(oldWidget.data!.isPinned.toString());
      log(widget.data!.isPinned.toString());
      setState(() {
        isPinned = widget.data?.isPinned ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onTap?.call();
        log(widget.list.length.toString());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoListScreen(
              list: widget.list,
              index: widget.list
                  .indexWhere((item) => item.postId == widget.data!.postId),
              type: widget.type,
              userId: widget.userId,
              soundId: widget.soundId,
              fromPage: ItemVideoFromPageEnum.profile,
              onLike: (index, isLiked, count) {
                widget.onLike(index, isLiked, count);
              },
              onComment: (index, count) {
                widget.onComment(index, count);
              },
              onDelete: (postId) {
                if (widget.onDelete != null) {
                  widget.onDelete!(postId);
                }
              },
              onPinned: (index, value) {
                widget.onPinned(index, value);
              },
              onBookmark: (index, value) {
                widget.onBookmark(index, value);
              },
              onFollowed: (index, value) {
                widget.onFollowed(index, value);
              },
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Stack(
              children: [
                CachedNetworkImage(
                    imageUrl: widget.data!.postImage ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorWidget: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey,
                      );
                    }),
                isPinned && widget.type == 0
                    ? Positioned(
                        left: 5,
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1, horizontal: 2.5),
                          decoration: BoxDecoration(
                              color: const Color(0xffe45256),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            context.l10n.pinned,
                            style: AppTextStyles.s12Base,
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(vertical: 10.0),
          //   child: Row(
          //     children: [
          //       const SizedBox(width: 5),
          //       const Icon(Icons.play_arrow_rounded,
          //           color: ColorRes.white, size: 20),
          //       Text(
          //         NumberFormat.compact().format(data?.postViewCount ?? 0),
          //         style: const TextStyle(
          //             fontSize: 12,
          //             color: ColorRes.white,
          //             fontFamily: FontRes.fNSfUiSemiBold),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
