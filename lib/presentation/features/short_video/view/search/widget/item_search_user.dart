import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../custom_view/image_place_holder.dart';
import '../../../languages/languages_keys.dart';
import '../../../modal/search/search_user.dart';
import '../../../utils/app_res.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/font_res.dart';

class ItemSearchUser extends StatelessWidget {
  final SearchUserData? searchUser;

  const ItemSearchUser(this.searchUser, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ProfileScreen(
      //         type: 1, userId: searchUser?.userId.toString() ?? '-1'),
      //   ),
      // ),
      child: Container(
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
                    ConstRes.itemBaseUrl +
                        (searchUser?.userProfile == null ||
                                searchUser!.userProfile!.isEmpty
                            ? ''
                            : searchUser?.userProfile ?? ''),
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return ImagePlaceHolder(
                        name: searchUser?.fullName,
                        fontSize: 25,
                        heightWeight: 60,
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        searchUser?.fullName ?? '',
                        style: const TextStyle(
                          fontFamily: FontRes.fNSfUiMedium,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        '${AppRes.atSign}${searchUser?.userName}',
                        style: const TextStyle(
                            color: ColorRes.colorTextLight,
                            fontFamily: FontRes.fNSfUiMedium,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis),
                        maxLines: 1,
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        '${searchUser?.followersCount} ${LKey.fans.tr} ${searchUser?.myPostCount} ${LKey.videos.tr}',
                        style: const TextStyle(
                          color: ColorRes.colorTheme,
                          fontFamily: FontRes.fNSfUiLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
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
      ),
    );
  }
}
