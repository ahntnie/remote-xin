import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_controller.dart/all.dart';
import '../../../../../common_widgets/circle_avatar.dart';
import '../../../../../resource/styles/styles.dart';
import '../../../languages/languages_keys.dart';
import '../../../utils/colors.dart';
import '../../../utils/font_res.dart';
import '../../../utils/key_res.dart';
import '../../../utils/session_manager.dart';

class LivestreamEndScreen extends StatefulWidget {
  const LivestreamEndScreen({Key? key}) : super(key: key);

  @override
  State<LivestreamEndScreen> createState() => _LivestreamEndScreenState();
}

class _LivestreamEndScreenState extends State<LivestreamEndScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );
  late final Animation<double> _animation =
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
  SessionManager pref = SessionManager();

  String time = '';
  String watching = '';
  String diamond = '';
  String image = '';

  @override
  void initState() {
    prefData();
    super.initState();
  }

  Future<void> prefData() async {
    await pref.initPref();
    time = pref.getString(KeyRes.liveStreamingTiming) ?? '';
    watching = pref.getString(KeyRes.liveStreamWatchingUser) ?? '';
    diamond = pref.getString(KeyRes.liveStreamCollected) ?? '';
    image = pref.getString(KeyRes.liveStreamProfile) ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();
    _controller.forward();
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppCircleAvatar(
                  url: appController.lastLoggedUser?.avatarPath ?? '',
                  size: 1.sw / 2,
                ),
                ScaleTransition(
                  scale: _animation,
                  child: Text(
                    LKey.yourLiveStreamHasEtc.tr,
                    style: const TextStyle(
                        fontFamily: FontRes.fNSfUiBold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        SizeTransition(
                          sizeFactor: _animation,
                          axis: Axis.horizontal,
                          axisAlignment: -1,
                          child: Text(time,
                              style: const TextStyle(
                                  fontFamily: FontRes.fNSfUiSemiBold,
                                  fontSize: 15)),
                        ),
                        Text(
                          LKey.streamFor.tr,
                          style: const TextStyle(
                              fontFamily: FontRes.fNSfUiSemiBold,
                              fontSize: 15,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizeTransition(
                          sizeFactor: _animation,
                          axis: Axis.horizontal,
                          axisAlignment: -1,
                          child: Text(watching,
                              style: const TextStyle(
                                  fontFamily: FontRes.fNSfUiSemiBold,
                                  fontSize: 15,
                                  color: Colors.black)),
                        ),
                        Text(
                          LKey.users.tr,
                          style: const TextStyle(
                              fontFamily: FontRes.fNSfUiSemiBold, fontSize: 15),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizeTransition(
                          sizeFactor: _animation,
                          axis: Axis.horizontal,
                          axisAlignment: -1,
                          child: Text(diamond,
                              style: const TextStyle(
                                  fontFamily: FontRes.fNSfUiSemiBold,
                                  fontSize: 15)),
                        ),
                        Text(
                          '💎 ${LKey.collected.tr}',
                          style: const TextStyle(
                              fontFamily: FontRes.fNSfUiSemiBold, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.blue10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          LKey.ok.tr,
                          style: const TextStyle(
                              color: ColorRes.white,
                              fontFamily: FontRes.fNSfUiHeavy,
                              letterSpacing: 0.8,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
