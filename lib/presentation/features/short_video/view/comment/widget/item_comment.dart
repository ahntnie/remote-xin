import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../core/all.dart';
import '../../../../../../repositories/all.dart';
import '../../../../../common_controller.dart/app_controller.dart';
import '../../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../../common_controller.dart/all.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/resource.dart';
import '../../../../../routing/routers/app_pages.dart';
import '../../../modal/comment/comment.dart';
import '../../../modal/user_video/user_video.dart';

class ItemComment extends StatefulWidget {
  final Data? videoData;
  final CommentData commentData;
  final Function(int) onRemoveClick;

  const ItemComment(
      {super.key,
      this.videoData,
      required this.commentData,
      required this.onRemoveClick});

  @override
  State<ItemComment> createState() => _ItemCommentState();
}

class _ItemCommentState extends State<ItemComment> {
  final AppController appController = Get.find();
  Rx<int> _likedAccountsCount = Rx<int>(0);
  Rx<bool> _isLiked = Rx<bool>(false);

  @override
  void initState() {
    _likedAccountsCount.value = widget.commentData.likedUsersCount ?? 0;
    _isLiked.value = widget.commentData.isLiked ?? false;
    super.initState();
  }

  final UserRepository userRepository = Get.find();
  final ContactRepository contactRepository = Get.find();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7.5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppCircleAvatar(
                url: widget.commentData.userProfile ?? '',
                size: 40,
              ).clickable(() async {
                final userPartner = await userRepository
                    .getUserById(widget.commentData.userId ?? 0);
                final resultContactList =
                    await contactRepository.checkContactExist(
                  phoneNumber: userPartner.phone ?? '',
                  userId: appController.lastLoggedUser!.id,
                );
                await Get.toNamed(Routes.myProfile, arguments: {
                  'isMine': false,
                  'user': userPartner,
                  'isAddContact': resultContactList.isEmpty,
                });
              }),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: GestureDetector(
                  onLongPress: () {
                    ///Nếu video không phải của mình thì không xóa được comment.
                    ///Kiểm tra xem nếu user id của comment khác user id của mình thì không xóa được
                    if (widget.commentData.userId !=
                        appController.lastLoggedUser!.id) {
                      return;
                    }

                    ///Nếu thỏa mãn tiêu chí: video của bản thân thì được quyền xóa comment
                    ViewUtil.showActionSheet(items: [
                      ActionSheetItem(
                        title: context.l10n.button__delete,
                        onPressed: () {
                          widget.onRemoveClick(
                              widget.commentData.commentsId ?? 0);
                        },
                      )
                    ]);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: AppColors.grey7,
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.commentData.fullName ?? '',
                          style: AppTextStyles.s14w700.text2Color,
                        ).clickable(() async {
                          final userPartner = await userRepository
                              .getUserById(widget.commentData.userId ?? 0);
                          final resultContactList =
                              await contactRepository.checkContactExist(
                            phoneNumber: userPartner.phone ?? '',
                            userId: appController.lastLoggedUser!.id,
                          );
                          await Get.toNamed(Routes.myProfile, arguments: {
                            'isMine': false,
                            'user': userPartner,
                            'isAddContact': resultContactList.isEmpty,
                          });
                        }),
                        Text(
                          widget.commentData.comment ?? '',
                          style: AppTextStyles.s16w400.text2Color,
                        ),
                        _buildInteractRowOnComment()
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractRowOnComment() {
    return Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppIcon(
              size: 18,
              icon: _isLiked.value! ? Icons.favorite : Icons.favorite_border,
              color: _isLiked.value! ? AppColors.negative : AppColors.zambezi,
              onTap: () async {
                //Kiểm tra trạng thái để tăng hoặc giảm lượt thích
                if (_isLiked.value) {
                  _likedAccountsCount.value--;
                } else {
                  _likedAccountsCount.value++;
                }

                //Đổi trạng thái cho _isLiked
                _isLiked.value = !_isLiked.value;

                await Get.find<ShortVideoRepository>().likeAndUnlikeComment(
                    commentId: widget.commentData.commentsId!);
              },
            ),
            AppSpacing.gapW8,
            Text(
              '${_likedAccountsCount.value}',
              style: TextStyle(color: AppColors.text2),
            )
          ],
        ));
  }
}
