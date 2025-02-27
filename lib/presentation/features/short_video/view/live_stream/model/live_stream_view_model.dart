import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked/stacked.dart';

import '../../../../../common_controller.dart/all.dart';
import '../../../modal/live_stream/live_stream.dart';
import '../../../modal/setting/setting.dart';
import '../../../modal/user/user.dart';
import '../../../utils/firebase_res.dart';
import '../../../utils/session_manager.dart';
import '../../../view/live_stream/screen/audience_screen.dart';
import '../../../view/live_stream/screen/broad_cast_screen.dart';

class LiveStreamScreenViewModel extends BaseViewModel {
  SessionManager pref = SessionManager();
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<LiveStreamUser> liveUsers = [];
  StreamSubscription<QuerySnapshot<LiveStreamUser>>? userStream;
  List<String> joinedUser = [];
  User? registrationUser;
  final appController = Get.find<AppController>();

  int liveStreamId = 0;

  SettingData? settingData;

  void init() {
    prefData();
  }

  Future<void> prefData() async {
    await pref.initPref();
    registrationUser = pref.getUser();
    settingData = pref.getSetting()?.data;
    getLiveStreamUser();
  }

  Future<void> goLiveTap(BuildContext context) async {
    // CommonUI.showLoader(context);
    // await ApiService()
    //     .generateAgoraToken(registrationUser?.data?.identity)
    //     .then((value) async {
    //   Navigator.pop(context);
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (c) => BroadCastScreen(
    //           registrationUser: registrationUser,
    //           agoraToken: value.token,
    //           channelName: registrationUser?.data?.identity),
    //     ),
    //   );
    // });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => BroadCastScreen(
          registrationUser: registrationUser,
          agoraToken: '',
          channelName: appController.lastLoggedUser?.id.toString(),
        ),
      ),
    );

    // try {
    //   final baseUrl = Get.find<EnvConfig>().apiUrl;
    //   final accessToken = await Get.find<AppPreferences>().getAccessToken();
    //   final response = await Dio().post(
    //     '$baseUrl/livestream/generate-token',
    //     data: {
    //       'channelName': appController.lastLoggedUser?.id.toString(),
    //     },
    //     options: Options(
    //       headers: {
    //         'Authorization': 'Bearer $accessToken',
    //         'Content-Type': 'application/json',
    //       },
    //     ),
    //   );
    //   if (response.statusCode == 200) {
    //     log('message');
    //     final token = response.data['token'];
    //     // liveStreamId = response.data[''];
    //     await Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (c) => BroadCastScreen(
    //           registrationUser: registrationUser,
    //           agoraToken: token,
    //           channelName: appController.lastLoggedUser?.id.toString(),
    //         ),
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   log(e.toString());
    // }
  }

  void getLiveStreamUser() {
    userStream = db
        .collection(FirebaseRes.liveStreamUser)
        .withConverter(
          fromFirestore: LiveStreamUser.fromFireStore,
          toFirestore: (LiveStreamUser value, options) {
            return value.toFireStore();
          },
        )
        .snapshots()
        .listen((event) {
      liveUsers = [];
      for (int i = 0; i < event.docs.length; i++) {
        liveUsers.add(event.docs[i].data());
      }
      notifyListeners();
    });
  }

  Future<void> onImageTap(BuildContext context, LiveStreamUser user) async {
    // const String authString =
    //     '${ConstRes.customerId}:${ConstRes.customerSecret}';
    // final String authToken = base64.encode(authString.codeUnits);
    // CommonUI.showLoader(context);

    joinedUser.add(appController.lastLoggedUser?.id.toString() ?? '');
    db.collection(FirebaseRes.liveStreamUser).doc(user.hostIdentity).update({
      FirebaseRes.watchingCount: user.watchingCount! + 1,
      FirebaseRes.joinedUser: FieldValue.arrayUnion(joinedUser),
    }).then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudienceScreen(
            channelName: user.hostIdentity,
            agoraToken: user.agoraToken,
            user: user,
          ),
        ),
      );
    });

    // ApiService()
    //     .agoraListStreamingCheck(
    //         user.hostIdentity ?? '', authToken, '${settingData?.agoraAppId}')
    //     .then((value) {
    //   Navigator.pop(context);
    //   if (value.message != null) {
    //     return CommonUI.showToast(msg: value.message ?? '');
    //   }
    //   if (value.data?.channelExist == true ||
    //       value.data!.broadcasters!.isNotEmpty) {
    //     joinedUser.add(registrationUser?.data?.identity ?? '');
    //     db
    //         .collection(FirebaseRes.liveStreamUser)
    //         .doc(user.hostIdentity)
    //         .update({
    //       FirebaseRes.watchingCount: user.watchingCount! + 1,
    //       FirebaseRes.joinedUser: FieldValue.arrayUnion(joinedUser),
    //     }).then((value) {
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => AudienceScreen(
    //             channelName: user.hostIdentity,
    //             agoraToken: user.agoraToken,
    //             user: user,
    //           ),
    //         ),
    //       );
    //     });

    //   } else {
    //     showModalBottomSheet(
    //       context: context,
    //       backgroundColor: Colors.transparent,
    //       builder: (c) {
    //         return LiveStreamEndSheet(
    //           name: user.fullName ?? '',
    //           onExitBtn: () async {
    //             Navigator.pop(context);
    //             db
    //                 .collection(FirebaseRes.liveStreamUser)
    //                 .doc(user.hostIdentity)
    //                 .delete();
    //             final batch = db.batch();
    //             final collection = db
    //                 .collection(FirebaseRes.liveStreamUser)
    //                 .doc(user.hostIdentity)
    //                 .collection(FirebaseRes.comment);
    //             final snapshots = await collection.get();
    //             for (var doc in snapshots.docs) {
    //               batch.delete(doc.reference);
    //             }
    //             await batch.commit();
    //           },
    //         );
    //       },
    //     );
    //   }
    // });
  }

  @override
  void dispose() {
    userStream?.cancel();
    super.dispose();
  }
}
