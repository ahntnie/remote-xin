import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Thêm import
import 'package:get/get.dart';
import 'package:story_view/story_view.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/user_story.dart';
import '../../../../../../repositories/newsfeed/newsfeed_repo.dart';
import '../../../../../common_controller.dart/all.dart';
import '../../../../../resource/resource.dart';
import '../../../../chat/dashboard/controllers/dashboard_controller.dart';
import '../../../all.dart';
import '../../../posts/widgets/heart_animation_widget.dart';
import '../../all.dart';
import 'comment_widget.dart';
import 'emoji_animation.dart';
import 'profile_widget.dart';

class StoryWidget extends StatefulWidget {
  final UserStory user;
  final PageController controller;
  final StoryViewController storyController;

  const StoryWidget({
    required this.user,
    required this.controller,
    required this.storyController,
    super.key,
  });

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  bool isCommenting = false;
  final storyItems = <StoryItem>[];
  late StoryController controller;
  final bottomSheetController = StoryController();
  String date = '';
  String currentReaction = '';
  List<String> allRowEmoji = [
    '❤️',
    '😆',
    '😮',
    '😢',
    '😡',
    '👍',
  ];
  List<String> reaction = [
    'love',
    'haha',
    'wow',
    'sad',
    'angry',
    'like',
  ];

  bool isAnimating = false;
  int currentIndex = 0;
  bool isReaction = false;

  final ScrollController _scrollController = ScrollController();
  final _isScrolling = false;

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      if (!_isScrolling) {
        setState(() {
          controller.pause();
        });
      }
    } else if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent) {
      if (!_isScrolling) {
        setState(() {
          controller.play();
        });
      }
    }
  }

  void addStoryItems() {
    for (final story in widget.user.stories) {
      if (story.storyType == 'text') {
        storyItems.add(
          StoryItem.text(
            title: '', // Không hiển thị văn bản mặc định
            backgroundColor: Color(int.parse('0xff${story.colorCode}')),
            duration: const Duration(milliseconds: 5000),
          ),
        );
      } else {
        storyItems.add(
          StoryItem.pageImage(
            url: story.urlMedia ?? '',
            controller: controller,
            duration: const Duration(milliseconds: 5000),
          ),
        );
      }
    }
  }

  int checkReaction() {
    for (var reactionStory in widget.user.stories[currentIndex].reactions) {
      if (reactionStory.userId == Get.find<AppController>().currentUser.id) {
        currentReaction = allRowEmoji[reaction.indexOf(reactionStory.type)];
        return reaction.indexOf(reactionStory.type);
      }
    }
    return -1;
  }

  int countReaction(int index) {
    int total = 0;
    final reactions = widget.user.stories[index].reactions;
    for (var reactionStory in reactions) {
      if (reactionStory.type == reaction[index]) {
        total++;
      }
    }
    return total;
  }

  Widget reactionTotal(int index) {
    final total = countReaction(index);
    return total == 0
        ? AppSpacing.emptyBox
        : Row(
            children: [
              Text(
                '$total ',
                style: AppTextStyles.s22Base.copyWith(
                  fontSize: 18.sp,
                  color: AppColors.text2,
                ),
              ),
              Text(
                '${allRowEmoji[index]} ',
                style: AppTextStyles.s22Base.copyWith(fontSize: 22.sp),
              ),
            ],
          );
  }

  @override
  void initState() {
    super.initState();
    controller = StoryController();
    addStoryItems();
    date = widget.user.stories[0].timeEnd;
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void handleCompleted() {
    widget.controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    final currentIndex = widget.storyController.userStorys.indexOf(widget.user);
    final isLastPage =
        widget.storyController.userStorys.length - 1 == currentIndex;
    if (isLastPage) {
      Navigator.of(context).pop();
      Get.find<PostsController>().getListUserStory();
    }
  }

  Future<void> _showViewersBottomSheet() async {
    controller.pause();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int selectedIndex = -1;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(16.w),
                height: 0.9.sh, // 90% chiều cao màn hình
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Các tin của bạn',
                      style: AppTextStyles.s20Base.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 110.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.user.stories.length + 1,
                        itemBuilder: (context, index) {
                          if (index < widget.user.stories.length) {
                            final bool isSelected = selectedIndex == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              width: isSelected ? 110.w : 90.w,
                              height: isSelected ? 110.h : 90.h,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: Stack(
                                  children: [
                                    StoryView(
                                      storyItems: List<StoryItem>.filled(
                                          1, storyItems[index],
                                          growable: true),
                                      controller: bottomSheetController,
                                      onComplete: () {
                                        bottomSheetController.play();
                                      },
                                      indicatorColor: Colors.transparent,
                                      indicatorForegroundColor:
                                          Colors.transparent,
                                    ),
                                    Positioned.fill(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: () {
                                          setModalState(() {
                                            selectedIndex = index;
                                            print(
                                                'selectedIndex: $selectedIndex');
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                debugPrint(
                                    'Nhấn để thêm tin ${storyItems.length}');
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.w),
                                width: 70.w,
                                height: 70.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 32.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Số lượt xem ${widget.user.stories[currentIndex].reactions.length}',
                      style: AppTextStyles.s20Base.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            widget.user.stories[currentIndex].reactions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 20.r,
                              backgroundImage: const NetworkImage(
                                  'https://picsum.photos/200/300'),
                            ),
                            title: Text(
                              'Người dùng $index',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            subtitle: Text(
                              'Phản ứng hoặc mô tả gì đó...',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyBoardUp = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              // height: 0.9.sh, // Bỏ giá trị cố định
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  70.h,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.black.withOpacity(0.8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: StoryView(
                  indicatorOuterPadding:
                      EdgeInsets.symmetric(vertical: 14.r, horizontal: 10.r),
                  storyItems: storyItems,
                  controller: controller,
                  onComplete: handleCompleted,
                  onVerticalSwipeComplete: (direction) {
                    if (direction == Direction.down) {
                      Navigator.pop(context);
                      Get.find<PostsController>().getListUserStory();
                    }
                  },
                  onStoryShow: (storyItem, index) {
                    if (index != currentIndex) {
                      setState(() {
                        date = widget.user.stories[index].timeEnd;
                        currentIndex = index;
                      });
                      // print('Current Index: $currentIndex');
                      // print(
                      //     'Text Position: (${widget.user.stories[currentIndex].textPositionX}, ${widget.user.stories[currentIndex].textPositionY})');
                    }
                  },
                ),
              ),
            ),
            // if (widget.user.stories[currentIndex].content != null &&
            //     widget.user.stories[currentIndex].content!.isNotEmpty)
            Positioned(
              //bỏ cái conteent phía trên và thay bằng cái này, các giá trị thêm data vào là được
              //   left: (widget.user.stories[currentIndex].textPositionX ?? 0.0) * screenWidth,
              // top: (widget.user.stories[currentIndex].textPositionY ?? 0.0) * screenHeight,
              left: 0.7031789380450563 * screenWidth,
              top: 0.8595436568538493 * screenHeight,
              child: Text(
                widget.user.stories[currentIndex].content ?? '',
                style: AppTextStyles.s16w400.copyWith(
                  fontSize: 16.sp, //data font size
                  color: Colors.white, // data color
                  shadows: const [Shadow(blurRadius: 4)],
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(top: 2.h, left: 10.w),
              child: ProfileWidget(
                user: widget.user,
                date: date,
                onTapMenu: () {
                  controller.pause();
                },
                onTapItem: () {
                  ViewUtil.showAppCupertinoAlertDialog(
                    title: context.l10n.delete_story_title_confirm,
                    message: context.l10n.delete_story_message_confirm,
                    negativeText: context.l10n.button__cancel,
                    positiveText: context.l10n.button__delete,
                    onPositivePressed: () {
                      Get.back();
                      ViewUtil.showAppSnackBarNewFeeds(
                        title: context.l10n.delete_story_success,
                      );
                      final storyIdToDelete =
                          widget.user.stories[currentIndex].storyId;
                      Get.find<NewsfeedRepository>()
                          .deleteStory(storyId: storyIdToDelete);
                      final listStoryOfCurrentUser =
                          Get.find<ChatDashboardController>()
                              .userStorys
                              .firstWhere((element) =>
                                  element.userId == widget.user.userId)
                              .stories;
                      listStoryOfCurrentUser.removeWhere(
                          (element) => element.storyId == storyIdToDelete);
                      if (listStoryOfCurrentUser.isEmpty) {
                        Get.find<ChatDashboardController>()
                            .userStorys
                            .removeWhere((element) =>
                                element.userId == widget.user.userId);
                      }
                    },
                  );
                },
              ),
            ),
            Align(
              child: Opacity(
                opacity: isAnimating ? 1 : 0,
                child: HeartAnimationWiget(
                  isAnimating: isAnimating,
                  onEnd: () {
                    setState(() {
                      isAnimating = false;
                    });
                  },
                  child: Text(
                    currentReaction,
                    style: AppTextStyles.s24Base.copyWith(fontSize: 60.sp),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 0.1.sh, // 10% chiều cao màn hình
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.user.userId !=
                            Get.find<AppController>().currentUser.id)
                          CommentWidget(
                            onTap: () {
                              controller.pause();
                              setState(() {
                                isCommenting = true;
                              });
                            },
                            story: widget.user.stories[currentIndex],
                            userStory: widget.user,
                            onKeyboardHidden: () {
                              controller.play();
                              setState(() {
                                isCommenting = false;
                              });
                            },
                            isExpanded: isCommenting,
                          )
                        else
                          const SizedBox(),
                        AnimatedOpacity(
                          opacity: isCommenting ? 0.3 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: widget.user.userId !=
                                  Get.find<AppController>().currentUser.id
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isKeyBoardUp)
                                      ...allRowEmoji.map((emoji) {
                                        final bool isReactionEmoji = isReaction
                                            ? currentReaction == emoji
                                            : checkReaction() != -1
                                                ? allRowEmoji[
                                                        checkReaction()] ==
                                                    emoji
                                                : false;
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            isReaction
                                                ? currentReaction == emoji
                                                    ? Container(
                                                        height: 5.h,
                                                        width: 5.w,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                      )
                                                    : AppSpacing.emptyBox
                                                : checkReaction() != -1
                                                    ? allRowEmoji[
                                                                checkReaction()] ==
                                                            emoji
                                                        ? Container(
                                                            height: 5.h,
                                                            width: 5.w,
                                                            decoration:
                                                                const BoxDecoration(
                                                              color: Colors
                                                                  .transparent,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          )
                                                        : AppSpacing.emptyBox
                                                    : AppSpacing.emptyBox,
                                            EmojiAnimation(
                                              isReaction: isReactionEmoji,
                                              emoji: emoji,
                                              onTap: () {
                                                controller.pause();
                                                HapticFeedback.heavyImpact();
                                                if (currentReaction != emoji) {
                                                  setState(() {
                                                    isAnimating = true;
                                                    currentReaction = emoji;
                                                    isReaction = true;
                                                  });
                                                  Get.find<NewsfeedRepository>()
                                                      .reactionStory(
                                                    type: reaction[allRowEmoji
                                                        .indexOf(emoji)],
                                                    id: widget
                                                        .user
                                                        .stories[currentIndex]
                                                        .storyId,
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                  ],
                                )
                              : widget.user.stories[currentIndex].reactions
                                      .isEmpty
                                  ? SizedBox(
                                      height: 70.h,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Align(
                                            child: GestureDetector(
                                              onTap: _showViewersBottomSheet,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .keyboard_arrow_up_outlined,
                                                    size: 24.sp,
                                                  ),
                                                  Text(
                                                    'Chưa có người xem',
                                                    style: AppTextStyles.s20Base
                                                        .copyWith(
                                                      fontSize: 20.sp,
                                                      color: AppColors.text1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 64.w),
                                          SizedBox(width: 64.w),
                                          Align(
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add_to_photos_rounded,
                                                size: 24.sp,
                                              ),
                                              onPressed: () {
                                                print('Thêm tin');
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : SizedBox(
                                      height: 70.h,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Align(
                                            child: GestureDetector(
                                              onTap: _showViewersBottomSheet,
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .keyboard_arrow_up_outlined,
                                                    size: 24.sp,
                                                  ),
                                                  Text(
                                                    '${widget.user.stories[currentIndex].reactions.length} người xem',
                                                    style: AppTextStyles.s20Base
                                                        .copyWith(
                                                      fontSize: 20.sp,
                                                      color: AppColors.text1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 64.w),
                                          SizedBox(width: 64.w),
                                          SizedBox(width: 64.w),
                                          Align(
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.add_to_photos_rounded,
                                                size: 24.sp,
                                              ),
                                              onPressed: () {
                                                print('Thêm tin');
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
