import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common_controller.dart/all.dart';
import '../../api/api_service.dart';
import '../../custom_view/common_ui.dart';
import '../../custom_view/data_not_found.dart';
import '../../languages/languages_keys.dart';
import '../../modal/chat/chat.dart';
import '../../modal/user/user.dart';
import '../../utils/colors.dart';
import '../../utils/key_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';
import '../chat_screen/chat_screen.dart';
import 'edit_profile_screen.dart';
import 'profile_video_screen.dart';
import 'widget/profile_card.dart';
import 'widget/tab_bar_view_custom.dart';
import 'widget/top_bar_profile.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String avatar;
  final String fullName;
  final String nickname;

  const ProfileScreen(
      {required this.userId,
      required this.avatar,
      required this.fullName,
      required this.nickname,
      super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ScrollController scrollController = ScrollController();
  PageController pageController = PageController();
  AppController appController = Get.find();

  final SessionManager _sessionManager = SessionManager();
  String? userId;
  UserData? userData;
  bool isMyProfile = true;
  bool isBlock = false;
  bool isLogin = false;
  Function? fetchScrollData;
  bool isLoading = true;

  @override
  void initState() {
    // prefData();
    // if (widget.type == 0) {
    //   userId = SessionManager.userId.toString();
    // } else {
    //   print('data : ${widget.userId}');
    //   userId = widget.userId;
    // }
    // isMyProfile = userId.toString() == SessionManager.userId.toString();

    // getUserProfile();
    // scrollController.addListener(() {
    //   if (scrollController.offset >=
    //       scrollController.position.maxScrollExtent) {
    //     Provider.of<MyLoading>(context, listen: false)
    //         .setScrollProfileVideo(true);
    //   }
    // });
    pageController = PageController();
    super.initState();
  }

  Future<void> prefData() async {
    await _sessionManager.initPref();
    userData = _sessionManager.getUser()?.data;
    isLogin = _sessionManager.getBool(KeyRes.login) ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          NestedScrollView(
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: getTotalHeight(userData),
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: ColorRes.white,
                  title: TopBarProfile(
                      isDarkMode: false,
                      isBlock: isBlock,
                      isMyProfile:
                          appController.lastLoggedUser?.id == widget.userId,
                      userData: userData,
                      onBlockApiCall: blockApiCall),
                  flexibleSpace: FlexibleSpaceBar(
                      background: SafeArea(
                    child: ProfileCard(
                        userId: widget.userId,
                        avatar: widget.avatar,
                        nickname: widget.nickname,
                        fullName: widget.fullName,
                        userData: appController.lastLoggedUser,
                        isMyProfile:
                            appController.lastLoggedUser?.id == widget.userId,
                        isBlock: isBlock,
                        isLogin: isLogin,
                        onChatIconClick: onChatIconClick,
                        onFollowUnFollowClick: onFollowUnFollowClick,
                        onEditProfileClick: onEditProfileClick),
                  )),
                ),
                SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      consumer: Consumer<MyLoading>(
                          builder: (context, myLoading, child) {
                        return TabBarViewCustom(
                          pageController: pageController,
                          myLoading: myLoading,
                        );
                      }),
                    ),
                    pinned: true),
              ];
            },
            body: Container(
              color: ColorRes.greyShade100,
              child: isBlock && !isMyProfile
                  ? const DataNotFound()
                  : Consumer<MyLoading>(builder: (context, myLoading, child) {
                      return PageView(
                        controller: pageController,
                        physics: const BouncingScrollPhysics(),
                        onPageChanged: (value) {
                          myLoading.setProfilePageIndex(value);
                        },
                        children: [
                          ProfileVideoScreen(
                            0,
                            widget.userId,
                            isMyProfile,
                          ),
                          ProfileVideoScreen(1, widget.userId, isMyProfile),
                        ],
                      );
                    }),
            ),
          ),
          // Visibility(
          //   visible: false,
          //   child: Stack(
          //     alignment: Alignment.center,
          //     children: [
          //       InkWell(
          //         onTap: () {},
          //         child: SizedBox(
          //           height: double.infinity,
          //           width: double.infinity,
          //           child: BackdropFilter(
          //             filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
          //             child: const SizedBox(),
          //           ),
          //         ),
          //       ),
          //       ClipRRect(
          //         borderRadius: BorderRadius.circular(360),
          //         child: Image.network(
          //           ConstRes.itemBaseUrl + (userData?.userProfile ?? ''),
          //           fit: BoxFit.cover,
          //           height: 250,
          //           width: 250,
          //           errorBuilder: (context, error, stackTrace) {
          //             return ImagePlaceHolder(
          //               fontSize: 70,
          //               heightWeight: 250,
          //               name: userData?.fullName?[0],
          //             );
          //           },
          //         ),
          //       )
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }

  double getTotalHeight(UserData? data) {
    double height = 350;
    if (data != null) {
      if (data.profileCategoryName == null ||
          data.profileCategoryName!.isEmpty) {
        height -= 20;
      }
      if ((data.youtubeUrl == null || data.youtubeUrl!.isEmpty) &&
          (data.fbUrl == null || data.fbUrl!.isEmpty) &&
          (data.instaUrl == null || data.instaUrl!.isEmpty)) height -= 30;
      if (data.bio == null || data.bio!.isEmpty) height -= 40;
    }
    return height;
  }

  void getUserProfile() {
    isLoading = true;
    // ApiService()
    //     .getProfile(
    //         widget.type == 0 ? SessionManager.userId.toString() : widget.userId)
    //     .then((value) {
    //   isLoading = false;
    //   if (value.status == 200) {
    //     if (widget.userId == SessionManager.userId.toString()) {
    //       Provider.of<MyLoading>(context, listen: false).setUser(value);
    //     }
    //     userData = value.data;

    //     isBlock = userData?.blockOrNot == 1;
    //     setState(() {});
    //   }
    // });
  }

  void onChatIconClick() {
    final time = DateTime.now().millisecondsSinceEpoch.toDouble();
    final ChatUser chatUser = ChatUser(
        date: time,
        image: userData?.userProfile,
        isNewMsg: false,
        isVerified: userData?.isVerify == 1 ? true : false,
        userFullName: userData?.fullName,
        userid: userData?.userId,
        userIdentity: userData?.identity,
        username: userData?.userName);
    final Conversation conversation = Conversation(
        user: chatUser,
        block: false,
        blockFromOther: false,
        conversationId:
            '${userData?.identity}${_sessionManager.getUser()?.data?.identity}',
        deletedId: '',
        isDeleted: false,
        isMute: false,
        lastMsg: '',
        newMsg: '',
        time: time);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(user: conversation),
      ),
    ).then((value) {
      getUserProfile();
    });
  }

  void onFollowUnFollowClick(bool p1) {
    final UserData? currentUserData = userData;
    if (p1) {
      userData?.addFollowerCount();
    } else {
      userData?.removeFollowerCount();
    }
    getUserProfile();
    userData = currentUserData;
  }

  void onEditProfileClick() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    ).then((value) {
      getUserProfile();
    });
  }

  void blockApiCall() {
    ApiService().blockUser('${userData?.userId ?? -1}').then((value) {
      isBlock = !isBlock;
      setState(() {});
    });
  }

  @override
  Future<void> dispose() async {
    pageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  Consumer<MyLoading> consumer;

  _SliverAppBarDelegate({required this.consumer});

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return consumer;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class SocialButton extends StatelessWidget {
  final String? url;
  final String icon;

  const SocialButton({required this.url, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return url == null || url!.isEmpty
        ? const SizedBox()
        : InkWell(
            onTap: () async {
              await canLaunchUrl(Uri.parse(url!))
                  ? await launchUrl(Uri.parse(url!))
                  : CommonUI.showToast(msg: LKey.invalidUrl.tr);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Image(
                    image: AssetImage(icon),
                    height: 20,
                    width: 20,
                    color: ColorRes.colorPrimaryDark,
                  ),
                  const SizedBox(width: 10)
                ],
              ),
            ),
          );
  }
}
