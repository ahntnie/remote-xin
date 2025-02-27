import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/all.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../common_controller.dart/app_controller.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/my_loading/my_loading.dart';
import 'item_post.dart';

class ProfileVideoScreen extends StatefulWidget {
  final int type;
  final int userId;
  final bool isMyProfile;

  const ProfileVideoScreen(this.type, this.userId, this.isMyProfile,
      {super.key});

  @override
  _ProfileVideoScreenState createState() => _ProfileVideoScreenState();
}

class _ProfileVideoScreenState extends State<ProfileVideoScreen> {
  List<Data> _profileData = [];
  bool isLoading = true;
  bool hasMoreData = true;
  bool isLoadFirstTime = true;
  final shortVideoRepo = Get.find<ShortVideoRepository>();
  final appController = Get.find<AppController>();
  int page = 1;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _profileData = [];
    callApi();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProfileVideoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset data and call API again when type changes
    if (oldWidget.type != widget.type) {
      setState(() {
        _profileData = [];
        isLoading = true;
        hasMoreData = true;
        isLoadFirstTime = true;
        page = 1;
      });
      callApi();
    }
  }

  void _scrollListener() {
    // Kiểm tra khi cuộn gần đến cuối danh sách
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Nếu không đang load và còn dữ liệu
      if (!isLoading && hasMoreData) {
        callApi();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<MyLoading>(
          builder: (context, value, child) {
            if (value.isScrollProfileVideo &&
                value.getProfilePageIndex == widget.type) {
              if (!isLoading) {
                callApi();
              }
            }
            return Container(height: 0);
          },
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(5),
            child: isLoadFirstTime
                ? _buildShimmerLoading()
                : _profileData.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.l10n.short__nothing_video,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontFamily: FontRes.fNSfUiBold,
                                  color: ColorRes.colorTextLight),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(top: 10),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1 / 1.3,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5),
                        itemCount: _profileData.length + (hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Hiển thị loading indicator khi cuộn đến cuối
                          if (index == _profileData.length) {
                            return _buildLoadingIndicator();
                          }

                          return InkWell(
                            child: ItemPost(
                              data: _profileData[index],
                              list: _profileData,
                              type: widget.type,
                              userId: widget.userId,
                              onComment: (indexComment, count) {
                                _profileData[indexComment] =
                                    _profileData[indexComment]
                                        .copyWith(postCommentsCount: count);
                              },
                              onLike: (indexLike, liked, count) {
                                log(indexLike.toString());
                                if (liked) {
                                  _profileData[indexLike] =
                                      _profileData[indexLike].copyWith(
                                          videoLikesOrNot: 1,
                                          postLikesCount: count);
                                } else {
                                  _profileData[indexLike] =
                                      _profileData[indexLike].copyWith(
                                          videoLikesOrNot: 0,
                                          postLikesCount: count);
                                }
                              },
                              onDelete: (p0) async {
                                log(p0.toString());
                                _profileData.removeAt(p0);
                                await Future.delayed(
                                    const Duration(seconds: 1));

                                ViewUtil.showToast(
                                    title: context.l10n.global__success_title,
                                    message:
                                        context.l10n.delete_video_successfully);
                                setState(() {});
                              },
                              onPinned: (id, value) {
                                log('message$value');
                                _profileData[id] =
                                    _profileData[id].copyWith(isPinned: value);
                                _profileData.sort((a, b) {
                                  // Safely check isPinned, handling potential null values
                                  final bool isPinnedA = a.isPinned ?? false;
                                  final bool isPinnedB = b.isPinned ?? false;

                                  // Pinned items first, then maintain original order
                                  if (isPinnedA && !isPinnedB) return -1;
                                  if (!isPinnedA && isPinnedB) return 1;
                                  return 0;
                                });
                                setState(() {});
                              },
                              onBookmark: (indexBookmark, value) {
                                _profileData[indexBookmark] =
                                    _profileData[indexBookmark]
                                        .copyWith(isBookmark: value);
                              },
                              onFollowed: (indexFollow, value) {
                                _profileData[indexFollow] =
                                    _profileData[indexFollow]
                                        .copyWith(isFollowed: value);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  // Phương thức build shimmer loading
  Widget _buildShimmerLoading() {
    return GridView(
      primary: false,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 1 / 1.3),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      children: List.generate(6, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.withOpacity(0.2),
          highlightColor: ColorRes.colorLight.withOpacity(0.2),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: ColorRes.colorPrimaryDark,
            ),
            margin: const EdgeInsets.only(top: 10, right: 10),
          ),
        );
      }),
    );
  }

  // Phương thức build loading indicator
  Widget _buildLoadingIndicator() {
    return hasMoreData
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: AppColors.blue10,
              ),
            ),
          )
        : Container();
  }

  void callApi() {
    if (!hasMoreData) {
      return;
    }
    if (isLoadFirstTime) {
      isLoadFirstTime = true;
    }
    isLoading = true;
    try {
      if (widget.type == 2) {
        shortVideoRepo.getBookmark(page).then((value) {
          isLoadFirstTime = false;
          _profileData.addAll(value);
          setState(() {
            isLoading = false;
            if ((value.length) < paginationLimit) {
              hasMoreData = false;
            }
          });

          page++;
          // final data = value as Map<String, dynamic>;
          // if (data['data'] is List<dynamic>) {
          //   final videos = Data.fromJsonList(data['data']);
          //   isLoadFirstTime = false;
          //   _profileData.addAll(videos);

          //   setState(() {
          //     isLoading = false;
          //     if ((data['data'].length) < paginationLimit) {
          //       hasMoreData = false;
          //     }
          //   });

          //   page++;
          // } else {
          //   setState(() {
          //     isLoading = false;
          //     isLoadFirstTime = false;
          //     hasMoreData = false;
          //   });
          // }
        });
      } else {
        shortVideoRepo
            .getUserVideos(
          '${_profileData.length}',
          widget.type,
          widget.userId,
          page,
        )
            .then((value) {
          final data = value as Map<String, dynamic>;
          if (data['data'] is List<dynamic>) {
            final videos = Data.fromJsonList(data['data']);
            isLoadFirstTime = false;
            _profileData.addAll(videos);

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
              isLoadFirstTime = false;
              hasMoreData = false;
            });
          }
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadFirstTime = false;
        hasMoreData = false;
      });
    }
  }
}
