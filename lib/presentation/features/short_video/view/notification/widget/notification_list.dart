import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/enums/item_video_from_page_enums.dart';
import '../../../api/api_service.dart';
import '../../../custom_view/common_ui.dart';
import '../../../custom_view/data_not_found.dart';
import '../../../custom_view/image_place_holder.dart';
import '../../../languages/languages_keys.dart';
import '../../../modal/notification/notification.dart';
import '../../../modal/user_video/user_video.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../video/video_list_screen.dart';

class NotificationList extends StatefulWidget {
  const NotificationList({super.key});

  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final ScrollController _scrollController = ScrollController();
  List<NotificationData> notificationList = [];
  bool isLoading = true;
  bool hasMoreData = true;

  @override
  void initState() {
    callApiForNotificationList();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) {
        if (!isLoading) {
          callApiForNotificationList();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? const LoaderDialog()
        : notificationList.isEmpty
            ? const DataNotFound()
            : ListView.builder(
                controller: _scrollController,
                itemCount: notificationList.length,
                itemBuilder: (context, index) {
                  final NotificationData notificationData =
                      notificationList[index];
                  return InkWell(
                    onTap: () {
                      if (notificationData.notificationType! >= 4) {
                        return;
                      }
                      if (notificationData.notificationType == 1 ||
                          notificationData.notificationType == 2) {
                        ///Video Screen
                        CommonUI.showLoader(context);
                        ApiService()
                            .getPostByPostId(notificationData.itemId.toString())
                            .then((value) {
                          Navigator.pop(context);
                          if (value.status == 401) {
                            CommonUI.showToast(msg: value.message!);
                          } else {
                            final List<Data> list = [value.data!];
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return VideoListScreen(
                                list: list,
                                index: 0,
                                type: 6,
                                onComment: (index, count) {},
                                onLike: (index, isLiked, count) {},
                                onDelete: (p0) {},
                                onPinned: (id, value) {},
                                onBookmark: (index, value) {},
                                onFollowed: (index, value) {},
                                fromPage: ItemVideoFromPageEnum.notification,
                              );
                            }));
                          }
                        });
                      } else {
                        ///User Screen
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => ProfileScreen(
                        //       type: 1,
                        //       userId: '${notificationData.itemId ?? -1}',
                        //     ),
                        //   ),
                        // );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 55,
                                width: 55,
                                padding: const EdgeInsets.all(1),
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  color: Colors.transparent,
                                  child: ClipOval(
                                    child: Image.network(
                                      "${ConstRes.itemBaseUrl}${notificationData.senderUser?.userProfile}",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return ImagePlaceHolder(
                                          name: notificationData
                                              .senderUser?.fullName,
                                          heightWeight: 40,
                                          fontSize: 35,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (notificationData.notificationType! >= 4
                                          ? LKey.admin.tr
                                          : notificationData
                                                  .senderUser?.fullName ??
                                              'Unknown'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontFamily: FontRes.fNSfUiSemiBold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      (notificationData.message != null
                                          ? notificationData.message!
                                          : ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: ColorRes.colorTextLight,
                                        fontFamily: FontRes.fNSfUiLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Consumer(
                                builder:
                                    (context, MyLoading myLoading, child) =>
                                        Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image(
                                      image: AssetImage(getIcon(
                                          notificationData.notificationType,
                                          myLoading.isDark)),
                                      height: 28,
                                      color: ColorRes.colorTextLight),
                                ),
                              ),
                            ],
                          ),
                          Container(
                              margin: const EdgeInsets.only(top: 10),
                              height: 0.2,
                              color: ColorRes.colorTextLight),
                        ],
                      ),
                    ),
                  );
                },
              );
  }

  String getIcon(int? notificationType, bool isDark) {
    if (notificationType == 1) {
      return icNotiLike;
    }
    if (notificationType == 2) {
      return icNotiComment;
    }
    if (notificationType == 3) {
      return icNotiFollowing;
    }
    if (notificationType == 4) {
      return isDark ? icLogo : icLogoLight;
    }
    return isDark ? icLogo : icLogoLight;
  }

  void callApiForNotificationList() {
    if (!hasMoreData) {
      return;
    }
    if (notificationList.isEmpty) {
      isLoading = true;
      setState(() {});
    }
    ApiService()
        .getNotificationList(
            notificationList.length.toString(), paginationLimit.toString())
        .then(
      (value) {
        isLoading = false;
        notificationList.addAll(value.data ?? []);
        if ((value.data?.length ?? 0) < paginationLimit) {
          hasMoreData = false;
        }
        setState(() {});
      },
    );
  }
}
