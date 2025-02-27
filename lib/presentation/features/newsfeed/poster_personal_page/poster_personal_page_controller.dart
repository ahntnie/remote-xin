import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../base/all.dart';
import '../../../common_controller.dart/all.dart';
import '../../../resource/gen/assets.gen.dart';
import '../../../routing/routing.dart';
import '../../all.dart';
import '../../call/call.dart';
import '../../call_gateway/contact/contact_controller.dart';

class PosterPersonalPageController extends BaseController {
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  // final postController = Get.find<PostsController>();
  // final sharePostController = Get.find<SharePostController>();
  final _chatRepository = Get.find<ChatRepository>();
  final ContactRepository _contactRepository = Get.find();
  final UserRepository userRepository = Get.find();
  RxList<Post> posts = <Post>[].obs;

  static const _pageSize = 20;
  int pageKey = 1;
  ScrollController scrollController = ScrollController();
  RxBool isLoadingLoadMore = false.obs;
  RxBool hasMorePage = false.obs;

  User user = Get.arguments['user'];
  bool isChat = Get.arguments['isChat'] as bool;
  RxBool isContactSaved = false.obs;

  RxBool isLoadingInit = true.obs;

  var userPhoneText = '**********'.obs;
  var userEmailText = '**********'.obs;
  var userNftText = '**********'.obs;
  var userGenderIcon = Assets.icons.venusMars.obs;
  var userAgeValueText = '--'.obs;
  var userLocationText = '---'.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    // checkUserContact();

    // user = await userRepository.getUserById(user.id);
    posts.clear();
    pageKey = 1;

    await Future.wait([
      // getPostPersonalPage(),
    ]);

    // scrollController.addListener(() {
    //   if (scrollController.position.pixels ==
    //       scrollController.position.maxScrollExtent) {
    //     pageKey++;
    //     loadMorePostPersonalPage();
    //   }
    // });
    loadUserInfo();
    // checkContactExist();
  }

  void loadUserInfo() {
    log(user.toString());
    userPhoneText.value = user.phone ?? '**********';

    userNftText.value = user.nftNumber ?? '**********';

    userEmailText.value = user.email ?? '**********';

    userGenderIcon.value = user.gender == l10n.text_gender_male
        ? Assets.icons.male
        : user.gender == l10n.text_gender_female
            ? Assets.icons.female
            : Assets.icons.venusMars;
    userAgeValueText.value =
        user.birthday != '' && user.birthday != null && user.birthday != 'null'
            ? '${calculateAge(user.birthday ?? '')}'
            : '--';
    userLocationText.value =
        user.location != '' && user.location != null && user.location != 'null'
            ? user.location ?? '---'
            : '---';
    if (!(user.isShowPhone ?? true)) {
      userPhoneText.value = '**********';
    }
    if (!(user.isShowEmail ?? true)) {
      userEmailText.value = '**********';
    }
    if (!(user.isShowGender ?? true)) {
      userGenderIcon.value = Assets.icons.venusMars;
    }
    if (!(user.isShowBirthday ?? true)) {
      userAgeValueText.value = '--';
    }
    if (!(user.isShowLocation ?? true)) {
      userLocationText.value = '---';
    }
    if (!(user.isShowNft ?? true)) {
      userNftText.value = '**********';
    }
    update();
  }

  int calculateAge(String birth) {
    // Chuyển đổi chuỗi ngày sinh thành DateTime
    final DateTime birthDate = DateFormat('MM/dd/yyyy').parse(birth);
    final DateTime currentDate = DateTime.now();

    int age = currentDate.year - birthDate.year;

    // Kiểm tra nếu ngày sinh chưa đến trong năm hiện tại thì trừ 1 tuổi
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    if (age == -1) {
      return 0;
    }
    return age;
  }

  void checkUserContact() {
    isContactSaved.value = false;
    update();
    if (Get.find<ContactController>().findUserContact(user) != null) {
      isContactSaved.value = true;
      update();
    }
  }

  Future<void> getPostPersonalPageRepository({
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    final listPost = await _newsFeedRepository.getPostPersonalPage(
      type: ['post'],
      boardType: r'\Backend\Models\User',
      boardId: user.id,
      page: pageKey,
      pageSize: _pageSize,
    );

    hasMorePage.value = listPost.pagination.hasMorePage;

    if (listPost.data.isEmpty) {
      pageKey--;

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
        handleLoading: false,
        action: () async {
          isLoadingInit.value = true;
          pageKey = 1;
          posts.clear();
          await getPostPersonalPageRepository();
          isLoadingInit.value = false;
        });
  }

  Future<void> onRefreshPostPersonalPage() async {
    await runAction(
      handleLoading: false,
      action: () async {
        pageKey = 1;

        await getPostPersonalPageRepository(isRefresh: true);
      },
    );
  }

  Future<void> loadMorePostPersonalPage() async {
    await runAction(
      handleLoading: false,
      action: () async {
        if (!hasMorePage.value) return;

        isLoadingLoadMore.value = true;

        await getPostPersonalPageRepository(isLoadMore: true);

        isLoadingLoadMore.value = false;
      },
      onError: (exception) {
        isLoadingLoadMore.value = false;
      },
    );
  }

  Future<void> goToPrivateChat(int contactId) async {
    final conversation = await _chatRepository.createConversation([contactId]);

    return Get.toNamed(
      Routes.chatHub,
      arguments: ChatHubArguments(conversation: conversation),
    );
  }

  String getInfoPartner() {
    final String phone = user.phone ?? '';
    final String nickname = user.nickname ?? '';

    if (phone.isNotEmpty && nickname.isNotEmpty) {
      return '$phone • @$nickname';
    } else if (phone.isNotEmpty) {
      return phone;
    } else if (nickname.isNotEmpty) {
      return '@$nickname';
    } else {
      return '';
    }
  }

  void onAddContactClick({required UserContact userContact}) {
    runAction(
      action: () async {
        final resultsContact =
            await _contactRepository.addContact([userContact]);

        Get.find<UserPool>().updateContact(userContact);

        if (resultsContact.created.isNotEmpty) {
          // userContactList.add(resultsContact.created.first);

          try {
            checkUserContact();
            Get.find<ConversationDetailsController>().checkContactExist();
          } catch (e) {
            LogUtil.e(e);
          }
          Get.back();

          ViewUtil.showToast(
            title: l10n.global__success_title,
            message: l10n.contact__add_success,
          );
        } else if (resultsContact.notCreated.existed.isNotEmpty) {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.contact__already_exist,
          );
        } else if (resultsContact.notCreated.notFounds.isNotEmpty) {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.contact__no_exist,
          );
        } else {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.global__error_has_occurred,
          );
        }
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.global__error_has_occurred,
        );
      },
    );
  }

  void onCallVoice(User user) {
    runAction(
      action: () async {
        final conversation =
            await Get.find<ChatRepository>().createConversation([user.id]);
        unawaited(CallKitManager.instance.createCall(
          chatChannelId: conversation.id,
          receiverIds: [user.id],
          isGroup: false,
          isVideo: false,
          isTranslate: false,
        ));
      },
    );
  }

  void onVideoCall(User user) {
    runAction(
      action: () async {
        final conversation =
            await Get.find<ChatRepository>().createConversation([user.id]);
        unawaited(CallKitManager.instance.createCall(
          chatChannelId: conversation.id,
          receiverIds: [user.id],
          isGroup: false,
          isVideo: true,
          isTranslate: false,
        ));
      },
    );
  }

  Future<void> updateContact(UserContact user) async {
    try {
      List<UserContact> updatedUser = [];

      await runAction(
        action: () async {
          updatedUser = await _contactRepository.updateContactById(user);
          if (updatedUser.isNotEmpty) {
            ViewUtil.showToast(
              title: l10n.global__success_title,
              message: l10n.text_edit_contact,
            );

            Get.find<UserPool>().updateContact(updatedUser.first);
            currentUserContact = updatedUser.first;

            try {
              await checkContactExist();
              Get.find<ConversationDetailsController>().checkContactExist();
            } catch (e) {
              LogUtil.e(e);
            }

            update();
          }
        },
      );
    } catch (e) {
      ViewUtil.showToast(
        title: l10n.global__error_title,
        message: l10n.global__error_has_occurred,
      );
    } finally {
      update();
    }
  }

  UserContact? currentUserContact;

  Future<void> checkContactExist() async {
    await runAction(
      action: () async {
        final resultContactList = await _contactRepository.checkContactExist(
          phoneNumber: user.phone ?? '',
          userId: currentUser.id,
        );
        if (resultContactList.isNotEmpty) {
          currentUserContact = resultContactList.first;
        }
      },
    );
  }
}
