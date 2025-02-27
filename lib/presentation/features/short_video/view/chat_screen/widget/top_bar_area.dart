import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../api/api_service.dart';
import '../../../custom_view/image_place_holder.dart';
import '../../../languages/languages_keys.dart';
import '../../../modal/chat/chat.dart';
import '../../../utils/assert_image.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/firebase_res.dart';
import '../../../utils/font_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../../utils/session_manager.dart';
import '../../report/report_screen.dart';

class TopBarArea extends StatefulWidget {
  final Conversation? user;
  final Conversation? conversation;

  const TopBarArea({required this.user, Key? key, this.conversation})
      : super(key: key);

  @override
  State<TopBarArea> createState() => _TopBarAreaState();
}

class _TopBarAreaState extends State<TopBarArea> {
  bool isBlock = false;
  var db = FirebaseFirestore.instance;
  SessionManager sessionManager = SessionManager();

  @override
  void initState() {
    initSession();
    getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, MyLoading myLoading, child) {
        return SafeArea(
          bottom: false,
          child: Visibility(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 33),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => ProfileScreen(
                          //         type: 1,
                          //         userId: '${widget.user?.user?.userid ?? -1}'),
                          //   ),
                          // );
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                '${ConstRes.itemBaseUrl}${widget.user?.user?.image}',
                                height: 37,
                                width: 37,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return ImagePlaceHolder(
                                    name: widget.user?.user?.userFullName,
                                    heightWeight: 37,
                                    fontSize: 25,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        flex: 5,
                                        child: Text(
                                          widget.user?.user?.userFullName ?? '',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontFamily: FontRes.fNSfUiBold,
                                              overflow: TextOverflow.ellipsis),
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Flexible(
                                        child: Visibility(
                                          visible:
                                              widget.user?.user?.isVerified ??
                                                  false,
                                          child: const Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(widget.user?.user?.username ?? '',
                                      style: const TextStyle(
                                          color: ColorRes.colorTextLight,
                                          fontSize: 12,
                                          fontFamily: FontRes.fNSfUiBold,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 1),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton(
                      onSelected: (value) {
                        if (value == 0) {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return ReportScreen(
                                    2, '${widget.user?.user?.userid}');
                              },
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent);
                          return;
                        }
                        if (value == 1) {
                          ApiService()
                              .blockUser('${widget.user?.user?.userid}')
                              .then((value) {
                            isBlock = !isBlock;
                            myLoading.setIsUserBlockOrNot(isBlock);
                            blockUnblockStatus(isBlock: isBlock);
                            setState(() {});
                          });
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return List.generate(
                          2,
                          (index) {
                            return PopupMenuItem(
                                value: index,
                                child: Text(
                                    index == 0
                                        ? LKey.reportUser.tr
                                        : (myLoading.getIsUserBlockOrNot
                                            ? LKey.unblockUser.tr
                                            : LKey.blockUser.tr),
                                    style: const TextStyle(
                                      color: ColorRes.colorTextLight,
                                      fontFamily: FontRes.fNSfUiMedium,
                                    )));
                          },
                        );
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: myLoading.isDark
                          ? ColorRes.colorPrimary
                          : ColorRes.greyShade100,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Image.asset(
                          icMenu,
                          width: 18,
                          color: myLoading.isDark
                              ? ColorRes.white
                              : ColorRes.colorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 0.5,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.only(bottom: 5.5),
                  color: ColorRes.colorTextLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  initSession() async {
    await sessionManager.initPref();
  }

  getProfile() async {
    print(widget.user?.user?.userid);
    await ApiService()
        .getProfile(widget.user?.user?.userid.toString())
        .then((value) {
      isBlock = value.data?.blockOrNot == 1 ? true : false;
      Provider.of<MyLoading>(context, listen: false)
          .setIsUserBlockOrNot(isBlock);
      blockUnblockStatus(isBlock: isBlock);
      setState(() {});
    });
  }

  blockUnblockStatus({required bool isBlock}) {
    db
        .collection(FirebaseRes.userChatList)
        .doc(widget.conversation?.user?.userIdentity)
        .collection(FirebaseRes.userList)
        .doc(sessionManager.getUser()?.data?.identity)
        .withConverter(
          fromFirestore: (snapshot, options) =>
              Conversation.fromJson(snapshot.data()!),
          toFirestore: (Conversation value, options) => value.toJson(),
        )
        .update({FirebaseRes.blockFromOther: isBlock});

    db
        .collection(FirebaseRes.userChatList)
        .doc(sessionManager.getUser()?.data?.identity)
        .collection(FirebaseRes.userList)
        .doc(widget.conversation?.user?.userIdentity)
        .withConverter(
          fromFirestore: (snapshot, options) =>
              Conversation.fromJson(snapshot.data()!),
          toFirestore: (Conversation value, options) => value.toJson(),
        )
        .update({FirebaseRes.block: isBlock});
  }
}
