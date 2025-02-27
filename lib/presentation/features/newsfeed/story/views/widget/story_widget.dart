import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            title: story.content ?? '',
            backgroundColor: Color(int.parse('0xff${story.colorCode}')),
            duration: Duration(
              milliseconds: (5 * 1000).toInt(),
            ),
          ),
        );
      } else {
        storyItems.add(StoryItem.pageImage(
          url: story.urlMedia ?? '',
          controller: controller,
          caption: Text(
            story.content ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.s16w400,
          ),
          duration: Duration(
            milliseconds: (5 * 1000).toInt(),
          ),
        ));
      }

      // switch (story.mediaType) {
      //   case MediaType.image:
      //     storyItems.add(StoryItem.pageImage(
      //       url: story.url == null
      //           ? 'https://media.giphy.com/media/5GoVLqeAOo6PK/giphy.gif'
      //           : story.url.toString(),
      //       controller: controller,
      //       caption: Text(story.caption),
      //       duration: Duration(
      //         milliseconds: (story.duration * 1000).toInt(),
      //       ),
      //     ));
      //     break;
      //   case MediaType.text:
      //     storyItems.add(
      //       StoryItem.text(
      //         title: story.caption,
      //         backgroundColor: story.color,
      //         duration: Duration(
      //           milliseconds: (story.duration * 1000).toInt(),
      //         ),
      //       ),
      //     );
      //     break;
      // }
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
    // Lấy danh sách reaction của câu chuyện hiện tại
    final reactions = widget.user.stories[index].reactions;

    // Đếm số lượng reaction cho mỗi loại reaction
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
                style: AppTextStyles.s22Base
                    .copyWith(fontSize: 18, color: AppColors.text2),
              ),
              Text(
                '${allRowEmoji[index]} ',
                style: AppTextStyles.s22Base.copyWith(fontSize: 22),
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
                padding: const EdgeInsets.all(16.0),
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    Text(
                      'Các tin của bạn',
                      style: AppTextStyles.s20Base
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.user.stories.length + 1,
                        itemBuilder: (context, index) {
                          if (index < widget.user.stories.length) {
                            final bool isSelected = selectedIndex == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: isSelected ? 110 : 90,
                              height: isSelected ? 110 : 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(children: [
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
                                        setState(() {
                                          selectedIndex = index;
                                          print(
                                              'selectedIndex: $selectedIndex');
                                        });
                                        print('Tapped $isSelected');
                                      },
                                    ),
                                  )
                                ]),
                              ),
                            );
                          } else {
                            // Slot thêm tin
                            return GestureDetector(
                              onTap: () {
                                debugPrint(
                                    'Nhấn để thêm tin ${storyItems.length}');
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                width: 70,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 32,
                                  color: Colors.black54,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      'Số lượt xem ${widget.user.stories[currentIndex].reactions.length}',
                      style: AppTextStyles.s20Base.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.text2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            widget.user.stories[currentIndex].reactions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const CircleAvatar(
                              backgroundImage:
                                  NetworkImage('https://picsum.photos/200/300'),
                            ),
                            title: Text('Người dùng $index'),
                            subtitle:
                                const Text('Phản ứng hoặc mô tả gì đó...'),
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

    // Khi bottomSheet *đóng* -> resume story chính
    controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyBoardUp = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
              ),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: StoryView(
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
                      print('Current Index: $currentIndex');
                      print(
                          'Total Stories: ${widget.user.stories[currentIndex].reactions.length}');
                    }
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.centerLeft,
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
                      style: AppTextStyles.s24Base.copyWith(fontSize: 60),
                    )),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.1,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        widget.user.userId !=
                                Get.find<AppController>().currentUser.id
                            ? CommentWidget(
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
                            : const SizedBox(),
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
                                            bool isReactionEmoji = false;
                                            isReactionEmoji = isReaction
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
                                                            height: 5,
                                                            width: 5,
                                                            decoration: const BoxDecoration(
                                                                color: Colors
                                                                    .transparent,
                                                                shape: BoxShape
                                                                    .circle),
                                                          )
                                                        : AppSpacing.emptyBox
                                                    : checkReaction() != -1
                                                        ? allRowEmoji[
                                                                    checkReaction()] ==
                                                                emoji
                                                            ? Container(
                                                                height: 5,
                                                                width: 5,
                                                                decoration: const BoxDecoration(
                                                                    color: Colors
                                                                        .transparent,
                                                                    shape: BoxShape
                                                                        .circle),
                                                              )
                                                            : AppSpacing
                                                                .emptyBox
                                                        : AppSpacing.emptyBox,
                                                EmojiAnimation(
                                                  isReaction: isReactionEmoji,
                                                  emoji: emoji,
                                                  onTap: () {
                                                    controller.pause();
                                                    HapticFeedback
                                                        .heavyImpact();
                                                    if (currentReaction !=
                                                        emoji) {
                                                      setState(() {
                                                        isAnimating = true;
                                                        currentReaction = emoji;
                                                        isReaction = true;
                                                      });
                                                      Get.find<
                                                              NewsfeedRepository>()
                                                          .reactionStory(
                                                        type: reaction[
                                                            allRowEmoji.indexOf(
                                                                emoji)],
                                                        id: widget
                                                            .user
                                                            .stories[
                                                                currentIndex]
                                                            .storyId,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                      ] // Chuyển kết quả của map thành danh sách
                                    )
                                : widget.user.stories[currentIndex].reactions
                                        .isEmpty
                                    ? SizedBox(
                                        height: 70,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Align(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showViewersBottomSheet();
                                                  },
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons
                                                          .keyboard_arrow_up_outlined),
                                                      Text(
                                                        'Chưa có người xem', // Số người xem
                                                        style: AppTextStyles
                                                            .s20Base
                                                            .copyWith(
                                                          color:
                                                              AppColors.text1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              AppSpacing.gapW64,
                                              AppSpacing.gapW64,
                                              Align(
                                                child: IconButton(
                                                  icon: const Icon(Icons
                                                      .add_to_photos_rounded),
                                                  onPressed: () {
                                                    // Thực hiện hành động thêm tin
                                                    print('Thêm tin');
                                                  },
                                                ),
                                              ),
                                            ]),
                                      )
                                    : SizedBox(
                                        height: 70,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Align(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showViewersBottomSheet();
                                                  },
                                                  child: Row(
                                                    children: [
                                                      const Icon(Icons
                                                          .keyboard_arrow_up_outlined),
                                                      Text(
                                                        '${widget.user.stories[currentIndex].reactions.length} người xem',
                                                        style: AppTextStyles
                                                            .s20Base
                                                            .copyWith(
                                                          color:
                                                              AppColors.text1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              AppSpacing.gapW64,
                                              AppSpacing.gapW64,
                                              AppSpacing.gapW64,
                                              Align(
                                                child: IconButton(
                                                  icon: const Icon(Icons
                                                      .add_to_photos_rounded),
                                                  onPressed: () {
                                                    print('Thêm tin');
                                                  },
                                                ),
                                              ),
                                            ]),
                                      )),
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
