import 'package:flutter/material.dart';

import '../../custom_view/image_place_holder.dart';
import '../../modal/followers/follower_following_data.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';

class ItemFollowers extends StatelessWidget {
  final FollowerUserData user;

  const ItemFollowers(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              ClipOval(
                child: Image.network(
                  ConstRes.itemBaseUrl + user.userProfile!,
                  fit: BoxFit.cover,
                  height: 45,
                  width: 45,
                  errorBuilder: (context, error, stackTrace) {
                    return ImagePlaceHolder(
                      name: user.fullName,
                      heightWeight: 45,
                      fontSize: 25,
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName!,
                    style: const TextStyle(
                      fontFamily: FontRes.fNSfUiMedium,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    '@${user.userName}',
                    style: const TextStyle(
                      color: ColorRes.colorTextLight,
                      fontFamily: FontRes.fNSfUiRegular,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            color: ColorRes.colorTextLight,
            height: 0.2,
          ),
        ],
      ),
    );
  }
}
