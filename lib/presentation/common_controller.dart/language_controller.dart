import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/all.dart' as prefix;
import '../../repositories/user/user_repo.dart';
import '../base/all.dart';
import 'app_controller.dart';

class LanguageController extends BaseController {
  final List<Map<String, String>> languages = [
    {
      'title': 'Tiếng Việt',
      'code': 'VI',
      'flagCode': 'vn',
      'talkCode': 'vi-VN',
      'langCode': 'vi',
    },
    {
      'title': 'English',
      'code': 'EN',
      'flagCode': 'gb',
      'talkCode': 'en-US',
      'langCode': 'en',
    },
    {
      'title': '日本語',
      'code': 'JA',
      'flagCode': 'jp',
      'talkCode': 'ja-JP',
      'langCode': 'ja',
    },
    {
      'title': '한국어',
      'code': 'KO',
      'flagCode': 'kr',
      'talkCode': 'ko-KR',
      'langCode': 'ko',
    },
    {
      'title': 'العربية',
      'code': 'AR',
      'flagCode': 'ae',
      'talkCode': 'ar-AE',
      'langCode': 'ar',
    },
    {
      'title': '中文',
      'code': 'ZH',
      'flagCode': 'cn',
      'talkCode': 'zh-CN',
      'langCode': 'zh',
    },
  ];
  RxInt currentIndex = 0.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadLanguage();
  }

  void _storeLanguage(
    String languageCode,
  ) {
    write(
      'languageCode',
      languageCode,
    );
  }

  Future<void> _loadLanguage() async {
    final language = await read<String>('languageCode');
    if (language == null) {
      final int index = languages.indexWhere(
          (item) => item['langCode'] == Get.deviceLocale!.languageCode);
      if (index != -1) {
        changeLanguage(Get.deviceLocale!.languageCode);
        _storeLanguage(Get.deviceLocale!.languageCode);
        currentIndex.value = index;
      } else {
        changeLanguage(prefix.LocaleConfig.defaultLocale.languageCode);
        _storeLanguage(prefix.LocaleConfig.defaultLocale.languageCode);
        currentIndex.value = 1;
      }
    } else {
      final int index =
          languages.indexWhere((item) => item['langCode'] == language);
      if (index != -1) {
        changeLanguage(language);
        currentIndex.value = index;
      } else {
        changeLanguage(prefix.LocaleConfig.defaultLocale.languageCode);
        currentIndex.value = 1;
      }
    }
  }

  void changeLanguage(String languageCode) {
    final locale = Locale(languageCode);
    Get.updateLocale(locale);
    _storeLanguage(languageCode);
  }

  Future<void> updateTalkLanguage(
      int id, String talkLanguage, String email) async {
    final UserRepository userRepo = Get.find();
    await userRepo.updateUserTalkLanguage(
      id: id,
      email: email,
      talkLanguage: talkLanguage,
    );
    final userUpdated = await userRepo.getUserById(id);

    Get.find<AppController>().setLoggedUser(userUpdated);
  }

  Future<void> updateTalkLanguageProfile(int index) async {
    runAction(action: () async {
      try {
        final UserRepository userRepo = Get.find();
        await userRepo.updateProfile(
          id: currentUser.id,
          firstName: currentUser.firstName,
          lastName: currentUser.lastName,
          phone: currentUser.phone ?? '',
          avatarPath: currentUser.avatarPath ?? '',
          nickname: currentUser.nickname ?? '',
          email: currentUser.email ?? '',
          gender: currentUser.gender ?? '',
          birthday: currentUser.birthday ?? '',
          location: currentUser.location ?? '',
          isSearchGlobal: currentUser.isSearchGlobal ?? true,
          isShowEmail: currentUser.isShowEmail ?? true,
          isShowPhone: currentUser.isShowPhone ?? true,
          isShowGender: currentUser.isShowGender ?? true,
          isShowNft: currentUser.isShowNft ?? true,
          isShowBirthday: currentUser.isShowBirthday ?? true,
          isShowLocation: currentUser.isShowLocation ?? true,
          talkLanguage: prefix.languages[index]['talkCode'] ?? '',
          nftNumber: currentUser.nftNumber ?? '',
        );
        final userUpdated = await userRepo.getUserById(currentUser.id);

        Get.find<AppController>().setLoggedUser(userUpdated);
      } catch (e) {
        log(e.toString());
      } finally {}
    });
  }
}
