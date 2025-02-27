import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../core/all.dart';
import '../../../../../models/user_like_video.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../common_controller.dart/app_controller.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../../resource/styles/app_colors.dart';
import '../../custom_view/common_ui.dart';
import '../../languages/languages_keys.dart';
import '../../modal/comment/comment.dart';
import '../../modal/user_video/user_video.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/key_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';
import 'widget/item_comment.dart';

class CommentScreen extends StatefulWidget {
  final Data? videoData;
  final Function(int) onComment;

  const CommentScreen(this.videoData, this.onComment, {super.key});

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  FocusNode commentFocusNode = FocusNode();
  SessionManager sessionManager = SessionManager();
  bool hasNoMore = false;
  List<CommentData> commentList = [];
  bool isLogin = false;
  bool isLoading = true;
  final shortVideoRepo = Get.find<ShortVideoRepository>();
  final appController = Get.find<AppController>();
  late bool isMyVideo;
  int indexSelect = 0;
  final List<UserLike> listUserLikeVideo = [];
  bool isLoadingGetUserLike = false;

  @override
  void initState() {
    prefData();
    _scrollController.addListener(
      () {
        if (_scrollController.position.maxScrollExtent ==
            _scrollController.position.pixels) {
          if (!isLoading) {
            callApiForComments();
          }
        }
      },
    );
    callApiForComments();
    getUserLikeVideo();
    isMyVideo = appController.lastLoggedUser!.id == widget.videoData!.userId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) {
        return Container(
          margin: EdgeInsets.only(top: AppBar().preferredSize.height),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            color: ColorRes.white,
          ),
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            children: [
              const SizedBox(height: 5),
              Stack(
                alignment: Alignment.center,
                children: [
                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: TabBar(tabs: [
                  //     Tab(
                  //       child: Row(
                  //         children: <Widget>[
                  //           AppIcon(icon: AppIcons.chat),
                  //           Text('0')
                  //         ],
                  //       ),
                  //     ),
                  //     Tab(
                  //       child: Row(
                  //         children: <Widget>[
                  //           AppIcon(icon: AppIcons.chat),
                  //           Text('0')
                  //         ],
                  //       ),
                  //     ),
                  //   ]),
                  // ),
                  // Text('${commentList.length} ${context.l10n.comments__title}',
                  //     style:
                  //         const TextStyle(fontSize: 16, color: Colors.black)),
                  Row(
                    children: [
                      AppSpacing.gapW16,
                      buildItemAppBar(
                          context: context,
                          icon: AppIcon(
                            icon: indexSelect == 0
                                ? Icons.mode_comment
                                : Icons.mode_comment_outlined,
                            color: Colors.black,
                          ),
                          text: '${commentList.length}',
                          isSelect: indexSelect == 0,
                          onTap: () {
                            indexSelect = 0;
                            setState(() {});
                          }),
                      AppSpacing.gapW16,
                      buildItemAppBar(
                          context: context,
                          icon: AppIcon(
                            icon: indexSelect == 1
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            color: Colors.black,
                          ),
                          text: '${commentList.length}',
                          isSelect: indexSelect == 1,
                          onTap: () {
                            indexSelect = 1;
                            setState(() {});
                          }),
                    ],
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
              const Divider(
                color: ColorRes.colorTextLight,
                thickness: 0.2,
                height: 0.2,
              ),
              const SizedBox(height: 5),
              Expanded(
                child: PageView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    if (indexSelect == 0) {
                      return isLoading
                          ? const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.blue10,
                                ),
                              ),
                            )
                          : commentList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        context
                                            .l10n.comments__no_comments_message,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontFamily: FontRes.fNSfUiBold,
                                            color: ColorRes.colorTextLight),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 25),
                                  controller: _scrollController,
                                  itemCount: commentList.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final CommentData commentData =
                                        commentList[index];

                                    return ItemComment(
                                      videoData: widget.videoData,
                                      commentData: commentData,
                                      onRemoveClick: (id) {
                                        shortVideoRepo.deleteComment(
                                          commentList[index].commentsId ?? 0,
                                        );
                                        commentList.removeAt(index);
                                        widget.onComment(1);
                                        setState(() {});
                                      },
                                    );
                                  },
                                );
                    } else {
                      return ListView.builder(itemBuilder: (context, index) {
                        return Text('Like');
                      });
                    }
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  height: 50,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    color: ColorRes.greyShade100,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                            style: const TextStyle(color: Colors.black),
                            controller: _commentController,
                            focusNode: commentFocusNode,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: context.l10n.comments__input_hint,
                                hintStyle: const TextStyle(
                                    color: ColorRes.colorTextLight),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 15)),
                            cursorColor: Colors.black),
                      ),
                      InkWell(
                        onTap: _addComment,
                        child: Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                              // gradient: LinearGradient(colors: [
                              //   ColorRes.colorTheme,
                              //   ColorRes.colorPink
                              // ]),
                              color: AppColors.blue10,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.send_rounded,
                              color: ColorRes.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void callApiForComments() {
    if (hasNoMore) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    shortVideoRepo
        .getCommentByPostId('${commentList.length}', '$paginationLimit',
            '${widget.videoData?.postId}')
        .then((value) {
      if ((value.length) < paginationLimit) {
        hasNoMore = true;
      }

      if (commentList.isEmpty) {
        commentList.addAll(value);
      } else {
        for (int i = 0; i < (value.length); i++) {
          commentList.add(value[i]);
        }
      }
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> getUserLikeVideo() async {
    setState(() {
      isLoadingGetUserLike = true;
    });
    final listData =
        await shortVideoRepo.getUserLikeVideo(widget.videoData!.postId ?? 0);
    listUserLikeVideo.addAll(listData.data.map((e) => e.user!));
    setState(() {
      isLoadingGetUserLike = false;
    });
  }

  Future _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      CommonUI.showToast(msg: LKey.enterCommentFirst.tr);
    } else {
      // if (SessionManager.userId == -1 || !isLogin) {
      //   showModalBottomSheet(
      //     backgroundColor: Colors.transparent,
      //     shape: const RoundedRectangleBorder(
      //         borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      //     isScrollControlled: true,
      //     context: context,
      //     builder: (context) {
      //       return LoginSheet();
      //     },
      //   );
      //   return;
      // }
      final commentText = _commentController.text.trim();
      final newComment = CommentData(
        comment: _commentController.text.trim(),
        userId: appController.lastLoggedUser!.id,
        fullName: appController.lastLoggedUser!.fullName,
        userName: appController.lastLoggedUser!.nickname,
        userProfile: appController.lastLoggedUser!.avatarPath,
      );
      commentList.add(newComment);
      _commentController.clear();
      commentFocusNode.unfocus();
      widget.onComment(0);
      setState(() {});
      await shortVideoRepo
          .addComment(commentText, widget.videoData!.postId ?? 0)
          .then((value) {
        final index = commentList.indexOf(newComment);
        if (index != -1) {
          commentList[index] =
              newComment.copyWith(commentsId: value.commentsId);
        }
      });
    }
  }

  Future<void> prefData() async {
    await sessionManager.initPref();
    isLogin = sessionManager.getBool(KeyRes.login) ?? false;
    setState(() {});
  }

  Widget buildItemAppBar(
      {required BuildContext context,
      required AppIcon icon,
      required String text,
      required bool isSelect,
      required VoidCallback onTap}) {
    return Row(
      children: [
        icon,
        Text(
          text,
          style: isSelect
              ? AppTextStyles.s16w700.text2Color
              : AppTextStyles.s16Base.text2Color,
        ),
      ],
    ).clickable(() => onTap.call());
  }
}
