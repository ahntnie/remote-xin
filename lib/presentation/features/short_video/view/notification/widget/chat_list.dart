import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../custom_view/common_ui.dart';
import '../../../custom_view/image_place_holder.dart';
import '../../../languages/languages_keys.dart';
import '../../../modal/chat/chat.dart';
import '../../../modal/user/user.dart';
import '../../../utils/colors.dart';
import '../../../utils/const_res.dart';
import '../../../utils/firebase_res.dart';
import '../../../utils/my_loading/my_loading.dart';
import '../../../utils/session_manager.dart';
import '../../chat_screen/chat_screen.dart';
import '../../dialog/confirmation_dialog.dart';

class ChatList extends StatefulWidget {
  final MyLoading myLoading;
  const ChatList({required this.myLoading, Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  SessionManager sessionManager = SessionManager();
  User? user;
  Stream<QuerySnapshot<Conversation>>? dataStream;

  @override
  void initState() {
    getChatUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Conversation>>(
      stream: dataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(LKey.somethingWentWrong.tr));
        }
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.none) {
          return const LoaderDialog();
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text(LKey.dataNotFound.tr));
        }
        return ListView.builder(
          itemCount: snapshot.data?.docs.length,
          itemBuilder: (context, index) {
            final Conversation? conversation =
                snapshot.data?.docs[index].data();
            return InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                onUserTap(conversation);
              },
              onLongPress: () {
                onLongPress(conversation);
              },
              child: AspectRatio(
                aspectRatio: 1 / 0.22,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.myLoading.isDark
                        ? ColorRes.colorPrimary
                        : ColorRes.colorLight,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: ColorRes.colorTextLight,
                            ),
                            borderRadius: BorderRadius.circular(30)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            '${ConstRes.itemBaseUrl}${conversation?.user?.image}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return ImagePlaceHolder(
                                name: conversation?.user?.userFullName,
                                heightWeight: 50,
                                fontSize: 30,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${conversation?.user?.userFullName}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Visibility(
                                        visible:
                                            conversation?.user?.isVerified ??
                                                false,
                                        child: const Icon(
                                          Icons.verified_sharp,
                                          color: Colors.blueAccent,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  readTimestamp(conversation?.time ?? 0.0),
                                  style: const TextStyle(
                                      color: ColorRes.colorTextLight),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    conversation?.lastMsg ?? '',
                                    style: const TextStyle(
                                        color: ColorRes.colorTextLight,
                                        overflow: TextOverflow.ellipsis),
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Visibility(
                                  visible:
                                      conversation?.user?.isNewMsg ?? false,
                                  child: Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                      color: ColorRes.colorIcon,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void onUserTap(Conversation? conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(user: conversation),
      ),
    );
  }

  getChatUsers() async {
    await sessionManager.initPref();
    user = sessionManager.getUser();
    dataStream = db
        .collection(FirebaseRes.userChatList)
        .doc(user?.data?.identity)
        .collection(FirebaseRes.userList)
        .where(FirebaseRes.isDeleted, isEqualTo: false)
        .orderBy(FirebaseRes.time, descending: true)
        .withConverter(
          fromFirestore: (snapshot, options) =>
              Conversation.fromJson(snapshot.data()!),
          toFirestore: (Conversation value, options) {
            return value.toJson();
          },
        )
        .snapshots();
    if (mounted) {
      setState(() {});
    }
  }

  static String readTimestamp(double timestamp) {
    final now = DateTime.now();
    final date = DateTime.fromMicrosecondsSinceEpoch(timestamp.toInt() * 1000);
    var time = '';
    if (now.day == date.day) {
      time = DateFormat(
        'hh:mm a',
      ).format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));
      return time;
    }
    if (now.weekday > date.weekday) {
      time = DateFormat(
        'EEEE',
      ).format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));
      return time;
    }
    if (now.month == date.month) {
      time = DateFormat(
        'dd/MM/yyyy',
      ).format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));
      return time;
    }
    return time;
  }

  String timeAgo(DateTime d) {
    final Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    }
    if (diff.inDays > 0) {
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    }
    return 'just now';
  }

  @override
  void dispose() {
    dataStream?.listen((event) {}).cancel();
    super.dispose();
  }

  void onLongPress(Conversation? conversation) {
    HapticFeedback.vibrate();
    print(user?.data?.identity);
    print(conversation?.user?.userIdentity);
    showDialog(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
            aspectRatio: 1.7,
            title1: LKey.deleteThisChat.tr,
            title2: LKey.messageWillOnlyBeRemovedFromThisDeviceNAreYouSure.tr,
            positiveText: LKey.deleteChat.tr,
            onPositiveTap: () {
              db
                  .collection(FirebaseRes.userChatList)
                  .doc(user?.data?.identity)
                  .collection(FirebaseRes.userList)
                  .doc(conversation?.user?.userIdentity)
                  .update({
                FirebaseRes.isDeleted: true,
                FirebaseRes.deletedId:
                    '${DateTime.now().millisecondsSinceEpoch}',
                FirebaseRes.block: false,
                FirebaseRes.blockFromOther: false,
              }).then((value) {
                Navigator.pop(context);
              });
            });
      },
    );
    setState(() {});
  }
}
