import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/all.dart';
import '../../../../../../models/user.dart';
import '../../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../../common_widgets/all.dart';
import '../../../../../resource/styles/styles.dart';
import '../../../utils/app_res.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';

class ProfileCard extends StatefulWidget {
  final User? userData;
  final int userId;
  final String avatar;
  final String fullName;
  final String nickname;
  final bool isMyProfile;
  final bool isLogin;
  final bool isBlock;
  final VoidCallback onChatIconClick;
  final Function(bool) onFollowUnFollowClick;
  final VoidCallback onEditProfileClick;

  const ProfileCard(
      {required this.userData,
      required this.isMyProfile,
      required this.isLogin,
      required this.isBlock,
      required this.onChatIconClick,
      required this.onFollowUnFollowClick,
      required this.onEditProfileClick,
      required this.userId,
      required this.avatar,
      required this.fullName,
      required this.nickname,
      Key? key})
      : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  UserStatistics userStatistics =
      const UserStatistics(totalLikes: 0, totalComments: 0, totalShares: 0);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserinfo();
  }

  Future getUserinfo() async {
    userStatistics =
        await Get.find<ShortVideoRepository>().getUserStatistics(widget.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        // InkWell(
        //   onTap: () {},
        //   child: Container(
        //     height: 110,
        //     width: 110,
        //     decoration: BoxDecoration(
        //         border: Border.all(color: ColorRes.colorTextLight, width: 0.5),
        //         shape: BoxShape.circle),
        //     child: ClipOval(
        //       child: Image.network(
        //         widget.userData?.avatarPath ?? '',
        //         fit: BoxFit.cover,
        //         errorBuilder: (context, error, stackTrace) {
        //           return ImagePlaceHolder(
        //               heightWeight: 110,
        //               name: widget.userData?.fullName,
        //               fontSize: 110 / 3);
        //         },
        //       ),
        //     ),
        //   ),
        // ),
        AppCircleAvatar(
          url: widget.avatar,
          size: 110,
        ),
        const SizedBox(height: 5),
        Text(widget.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.s20w700.text2Color),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${AppRes.atSign}${widget.nickname}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ColorRes.colorTextLight,
                fontFamily: FontRes.fNSfUiMedium,
                fontSize: 17,
              ),
            ),
            const SizedBox(width: 5),
            // userData?.isVerify == 1
            //     ? Image.asset(
            //         icVerify,
            //         height: 15,
            //         width: 15,
            //       )
            //     : const SizedBox()
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(
        //       horizontal: MediaQuery.of(context).size.width / 10),
        //   child: const Text('userData?.bio ?? ' '',
        //       maxLines: 3,
        //       textAlign: TextAlign.center,
        //       overflow: TextOverflow.ellipsis,
        //       style: TextStyle(color: ColorRes.colorTextLight, fontSize: 15)),
        // ),
        AppSpacing.gapH16,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Text(
                  userStatistics.totalLikes.toString(),
                  style: AppTextStyles.s20w700.text2Color,
                ),
                Text(
                  context.l10n.newsfeed__like,
                  style: AppTextStyles.s14w500.subText2Color,
                )
              ],
            ),
            Column(
              children: [
                Text(
                  userStatistics.totalComments.toString(),
                  style: AppTextStyles.s20w700.text2Color,
                ),
                Text(
                  context.l10n.newsfeed__comment,
                  style: AppTextStyles.s14w500.subText2Color,
                )
              ],
            ),
            Column(
              children: [
                Text(
                  userStatistics.totalShares.toString(),
                  style: AppTextStyles.s20w700.text2Color,
                ),
                Text(
                  context.l10n.newsfeed__share,
                  style: AppTextStyles.s14w500.subText2Color,
                )
              ],
            )
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class VerticalTilesCustom extends StatelessWidget {
  final VoidCallback onTap;
  final int? count;
  final String title;

  const VerticalTilesCustom(
      {required this.onTap, required this.count, required this.title, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            NumberFormat.compact().format(count ?? 0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ColorRes.colorTextLight,
              fontSize: 17,
              fontFamily: FontRes.fNSfUiBold,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ColorRes.colorTextLight,
              fontFamily: FontRes.fNSfUiMedium,
            ),
          ),
        ],
      ),
    );
  }
}
