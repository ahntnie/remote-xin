import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../models/enums/mission_mana_type_enum.dart';
import '../../../../models/mana_mission/mana.dart';
import '../../../../models/mana_mission/mana_mission.dart';
import '../../../../repositories/all.dart';
import '../../../../repositories/missions/mana_mission_repo.dart';
import '../../../base/all.dart';

class PersonalPageController extends BaseController with ScrollMixin {
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  final _manaMissionRepository = Get.find<ManaMissionRepository>();
  final _authRepository = Get.find<AuthRepository>();
  // final postController = Get.find<PostsController>();
  // final sharePostController = Get.find<SharePostController>();
  final Rx<ManaMissionTypeEnum> _manaMissionType =
      ManaMissionTypeEnum.daily.obs;
  RxString phoneNumber = ''.obs;
  final Rxn<Mana> _mana = Rxn();
  RxList<Post> posts = <Post>[].obs;
  final RxList<ManaMission> _manaMissions = <ManaMission>[].obs;

  static const _pageSize = 20;
  int pageKey = 1;
  RxBool isLoadingLoadMore = false.obs;
  RxBool hasMorePage = false.obs;
  RxBool isLoadingInit = true.obs;

  String shareLink = '';

  @override
  Future<void> onInit() async {
    super.onInit();

    // ever(currentUserRx, (user) async {
    //   phoneNumber.value = await PhoneNumberUtil.formatPhoneNumber(
    //     user?.phone ?? '',
    //   );
    //   update();
    // });
    // // ever(_manaMissionType, (callback) {
    // //   getManaMissionDay();
    // // });
    // posts.clear();
    // pageKey = 1;

    // await Future.wait([
    //   getManaMissionDay(),
    //   getPhoneNumber(),
    //   getPostPersonalPage(),
    // ]);
    // await getManaMissionDay();
    // shareLink = await getSharedLink();
  }

  Future init() async {
    await getManaMissionDay();
    shareLink = await getSharedLink();
  }

  Future<void> getPhoneNumber() async {
    phoneNumber.value = await PhoneNumberUtil.formatPhoneNumber(
      currentUserRx.value?.phone ?? '',
    );
    update();
  }

  Future<void> getPostPersonalPageRepository({
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    final listPost = await _newsFeedRepository.getPostPersonalPage(
      type: ['post'],
      boardType: r'\Backend\Models\User',
      boardId: currentUser.id,
      page: pageKey,
      pageSize: _pageSize,
    );

    hasMorePage.value = listPost.pagination.hasMorePage;

    if (listPost.data.isEmpty) {
      pageKey--;

      if (isRefresh) {
        posts.clear();
      }

      return;
    }

    if (isRefresh) {
      posts.clear();
    }

    if (isLoadMore) {
      posts.addAll([...posts, ...listPost.data]);
    } else {
      posts.addAll(listPost.data as List<Post>);
    }
  }

  Future<void> getPostPersonalPage() async {
    await runAction(
      action: () async {
        pageKey = 1;
        posts.clear();
        await getPostPersonalPageRepository();
      },
    );
  }

  Future<void> getManaMissionDay() async {
    await runAction(
      action: () async {
        isLoadingInit.value = true;
        final user = currentUser.email ?? currentUser.phone ?? '';
        manaMissions = await _manaMissionRepository.getManaMissionsDay(
          user,
          manaMissionType,
        );
        mana = await _manaMissionRepository.getMana(user);
      },
      handleLoading: false,
    );
    isLoadingInit.value = false;
  }

  Future<void> onRefreshPostPersonalPage() async {
    await runAction(
      handleLoading: false,
      action: () async {
        pageKey = 1;
        getManaMissionDay();
        // await getPostPersonalPageRepository(isRefresh: true);
      },
    );
  }

  Future<void> loadMorePostPersonalPage() async {
    await runAction(
      handleLoading: false,
      action: () async {
        if (!hasMorePage.value) return;

        isLoadingLoadMore.value = true;

        pageKey++;
        await getPostPersonalPageRepository(isLoadMore: true);

        isLoadingLoadMore.value = false;
      },
      onError: (exception) {
        isLoadingLoadMore.value = false;
      },
    );
  }

  List<ManaMission> get manaMissions => _manaMissions.toList();

  set manaMissions(List<ManaMission> value) {
    _manaMissions.assignAll(value);
  }

  ManaMissionTypeEnum get manaMissionType => _manaMissionType.value;

  set manaMissionType(ManaMissionTypeEnum value) {
    _manaMissionType.value = value;
  }

  Rx<ManaMissionTypeEnum> get rxMissionManaType => _manaMissionType;

  Mana? get mana => _mana.value;

  set mana(Mana? value) {
    _mana.value = value;
  }

  void onRefreshManaMission() {
    getManaMissionDay();
  }

  @override
  Future<void> onEndScroll() async {
    await loadMorePostPersonalPage();
  }

  @override
  Future<void> onTopScroll() async {
    try {
      if (scroll.hasClients) {
        await scroll.animateTo(
          0,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      LogUtil.e(e);
    }
  }

  Future<String> getSharedLink() async {
    late String sharedLink;

    await runAction(
      handleLoading: false,
      action: () async {
        sharedLink = await Get.find<SharedLinkRepository>().getSharedLink(
          type: SharedLinkType.user,
          id: currentUser.id,
        );
      },
    );

    return sharedLink;
  }
}
