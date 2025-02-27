import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/const_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../profile/item_post.dart';

class VideosByHashTagScreen extends StatefulWidget {
  final String? hashTag;

  const VideosByHashTagScreen(this.hashTag, {super.key});

  @override
  _VideosByHashTagScreenState createState() => _VideosByHashTagScreenState();
}

class _VideosByHashTagScreenState extends State<VideosByHashTagScreen> {
  var start = 0;
  int? count = 0;

  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();
  List<Data> postList = [];

  final shortVideoRepo = Get.find<ShortVideoRepository>();

  int page = 1;

  bool hasMoreData = true;
  @override
  void initState() {
    // _scrollController.addListener(
    //   () {
    //     if (_scrollController.position.maxScrollExtent ==
    //         _scrollController.position.pixels) {
    //       if (!isLoading) {
    //         callApiForGetPostsByHashTag();
    //       }
    //     }
    //   },
    // );
    callApiForGetPostsByHashTag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: CommonAppBar(
          titleWidget: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(
                icon: Assets.icons.hastag,
                color: Colors.black,
                size: 18,
              ),
              AppSpacing.gapW4,
              Text(
                widget.hashTag ?? '',
                style: AppTextStyles.s18w500.text2Color,
              )
            ],
          ),
          titleType: AppBarTitle.none,
        ),
        body: Column(
          children: [
            const Divider(
              color: AppColors.grey6,
            ),
            Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.blue10,
                        ),
                      )
                    : postList.isEmpty
                        ? const SizedBox()
                        : _buildGridView()),
          ],
        ),
      );
    });
  }

  Widget _buildGridView() {
    return GridView.builder(
      itemCount: postList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 12,
        crossAxisCount: 2,
        childAspectRatio: 1 / 2,
      ),
      itemBuilder: (context, index) {
        return _buildGridItem(index);
      },
    ).paddingSymmetric(horizontal: 12);
  }

  Widget _buildGridItem(int index) {
    final item = postList[index];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildItemPost(item),
          AppSpacing.gapH8,
          _buildDescription(item),
          _buildUserInfoRow(item),
        ],
      ),
    );
  }

  Widget _buildItemPost(Data item) {
    return SizedBox(
      height: 1.sw - 19 - 120,
      child: ItemPost(
        onComment: (index, count) {
          postList[index] = postList[index].copyWith(postCommentsCount: count);
          setState(() {});
        },
        onLike: (indexLike, liked, count) {
          if (liked) {
            postList[indexLike] = postList[indexLike]
                .copyWith(videoLikesOrNot: 1, postLikesCount: count);
          } else {
            postList[indexLike] = postList[indexLike]
                .copyWith(videoLikesOrNot: 0, postLikesCount: count);
          }
          setState(() {});
        },
        onPinned: (id, value) {
          postList[id] = postList[id].copyWith(isPinned: value);
          setState(() {});
        },
        onBookmark: (index, value) {
          postList[index] = postList[index].copyWith(isBookmark: value);
        },
        onFollowed: (index, value) {
          postList[index] = postList[index].copyWith(isFollowed: value);
        },
        data: item,
        list: postList,
        onDelete: (int videoId) {},
        onTap: () {},
        userId: item.userId,
      ),
    );
  }

  Widget _buildDescription(Data item) {
    return item.postDescription == null
        ? const SizedBox()
        : Row(
            children: [
              Flexible(
                child: Text(
                  item.postDescription ?? '',
                  style: AppTextStyles.s18w500.text2Color,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
  }

  Widget _buildUserInfoRow(Data item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Row(
            children: [
              AppCircleAvatar(size: Sizes.s24, url: item.userProfile ?? ''),
              AppSpacing.gapW4,
              Flexible(
                child: Text(
                  item.fullName ?? '',
                  style: AppTextStyles.s14Base.text4Color,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${item.postLikesCount}',
          style: AppTextStyles.s14w500.copyWith(
            color: AppColors.grey8,
          ),
        ),
        AppSpacing.gapW4,
        AppIcon(
          icon: Assets.icons.heart,
          size: Sizes.s16,
          color: AppColors.grey8,
        ),
      ],
    );
  }

  void callApiForGetPostsByHashTag() {
    if (!hasMoreData) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    shortVideoRepo
        .getSingleHashTagPostList('10', widget.hashTag ?? '', page)
        .then(
      (value) {
        final data = value as Map<String, dynamic>;
        if (data['data'] is List<dynamic>) {
          final videos = Data.fromJsonList(data['data']);
          postList.addAll(videos);
          setState(() {
            isLoading = false;
            if ((data['data'].length) < paginationLimit) {
              hasMoreData = false;
            }
          });
          page++;
        } else {
          setState(() {
            isLoading = false;

            hasMoreData = false;
          });
        }
      },
    );
  }
}
