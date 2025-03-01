import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../api/api_service.dart';
import '../../custom_view/common_ui.dart';
import '../../custom_view/privacy_policy_view.dart';
import '../../languages/languages_keys.dart';
import '../../utils/assert_image.dart';
import '../../utils/colors.dart';
import '../../utils/const_res.dart';
import '../../utils/font_res.dart';
import '../../utils/key_res.dart';
import '../../utils/my_loading/my_loading.dart';
import '../../utils/session_manager.dart';
import '../../utils/url_res.dart';
import '../email/sign_in_screen.dart';

class LoginSheet extends StatelessWidget {
  final SessionManager sessionManager = SessionManager();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LoginSheet({super.key});

  @override
  Widget build(BuildContext context) {
    initData();
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return Container(
        height: MediaQuery.of(context).size.height -
            AppBar().preferredSize.height * 1.5,
        decoration: BoxDecoration(
            color:
                myLoading.isDark ? ColorRes.colorPrimaryDark : ColorRes.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Image.asset(
                            myLoading.isDark ? icLogo : icLogoLight,
                            height: 90)),
                    Text('${LKey.signUpFor.tr} $appName',
                        style: const TextStyle(
                            fontSize: 22, fontFamily: FontRes.fNSfUiSemiBold)),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                          LKey.createAProfileFollowOtherCreatorsNBuildYourFanFollowingBy
                              .tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, fontFamily: FontRes.fNSfUiLight)),
                    ),
                    const SizedBox(height: 15),
                    Visibility(
                      visible: Platform.isIOS,
                      child: SocialButton(
                          onTap: () {
                            CommonUI.showLoader(context);
                            _signInWithApple().then(
                              (value) {
                                Navigator.pop(context);
                                if (value != null) {
                                  _callApiForLogin(
                                      value, KeyRes.apple, context, myLoading);
                                } else {
                                  CommonUI.showToast(
                                      msg: LKey.somethingWentWrong.tr);
                                }
                              },
                            );
                          },
                          image: icApple,
                          isDarkMode: myLoading.isDark,
                          name: LKey.singInWithApple.tr),
                    ),
                    SocialButton(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              )).then((value) {});
                        },
                        isDarkMode: myLoading.isDark,
                        image: icEmail,
                        name: LKey.singInWithEmail.tr),
                    SocialButton(
                        onTap: () {
                          CommonUI.showLoader(context);
                          _signInWithGoogle().then((value) {
                            Navigator.pop(context);

                            if (value != null) {
                              print('null');
                              _callApiForLogin(
                                  value, KeyRes.google, context, myLoading);
                            } else {
                              print('null');
                            }
                          });
                        },
                        isGoogleIcon: true,
                        isDarkMode: myLoading.isDark,
                        image: icGoogle,
                        name: LKey.singInWithGoogle.tr),
                    const SizedBox(height: 15),
                    const PrivacyPolicyView(),
                    SizedBox(height: AppBar().preferredSize.height / 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<User?> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
      return null;
    }
    final googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential? authResult;
    try {
      authResult = await _auth.signInWithCredential(googleCredential);
    } on FirebaseAuthException catch (e) {
      print('LOG ============ ${e.message}');
    }
    return authResult?.user;
  }

  Future<User?> _signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ]);
      final oauthCredential = OAuthProvider('apple.com')
          .credential(idToken: appleCredential.identityToken);
      final String displayName =
          '${appleCredential.givenName} ${appleCredential.familyName}';
      final String userEmail = '${appleCredential.email}';
      final authResult = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = authResult.user;

      if (displayName.isNotEmpty && firebaseUser?.displayName == null) {
        await firebaseUser?.updateDisplayName(displayName);
      }
      if (userEmail.isNotEmpty && firebaseUser?.email == null) {
        await firebaseUser?.updateEmail(userEmail);
      }
      return firebaseUser;
    } catch (e) {
      log(e.toString());
    }
    return null;
  }

  void _callApiForLogin(
      User value, String loginType, BuildContext context, MyLoading myLoading) {
    final HashMap<String, String?> params = HashMap();
    params[UrlRes.deviceToken] = sessionManager.getString(KeyRes.deviceToken);
    params[UrlRes.userEmail] = value.email ??
        '${value.displayName!.split('@')[value.displayName!.split('@').length - 1]}@fb.com';
    params[UrlRes.fullName] = value.displayName;
    params[UrlRes.loginType] = loginType;
    params[UrlRes.userName] =
        value.email != null ? value.email!.split('@')[0] : value.uid;
    params[UrlRes.identity] = value.email ?? value.uid;
    params[UrlRes.platform] = Platform.isAndroid ? '1' : '2';
    CommonUI.showLoader(context);
    ApiService().registerUser(params).then(
      (value) {
        Navigator.pop(context);
        if (value.status == 200) {
          sessionManager.saveBoolean(KeyRes.login, true);
          myLoading.setSelectedItem(0);
          myLoading.setUser(value);
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> initData() async {
    await sessionManager.initPref();
  }
}

class SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String image;
  final String name;
  final bool isDarkMode;
  final bool isGoogleIcon;

  const SocialButton(
      {required this.onTap,
      required this.image,
      required this.name,
      required this.isDarkMode,
      super.key,
      this.isGoogleIcon = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 210,
        margin: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: isDarkMode ? ColorRes.colorPrimary : ColorRes.greyShade100,
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Image.asset(image,
                  height: 23,
                  color: isGoogleIcon
                      ? null
                      : isDarkMode
                          ? ColorRes.white
                          : Colors.black),
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: FontRes.fNSfUiMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}
