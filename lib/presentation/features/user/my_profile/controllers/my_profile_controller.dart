import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/all.dart';
import '../../../../../models/all.dart';
import '../../../../../repositories/all.dart';
import '../../../../../repositories/short-video/short_video_repo.dart';
import '../../../../base/all.dart';
import '../../../../common_controller.dart/all.dart';
import '../../../../common_widgets/all.dart';
import '../../../../resource/resource.dart';
import '../../../all.dart';
import '../views/widgets/build_user_info.dart';

class MyProfileController extends BaseController with ScrollMixin {
  // final contactController = Get.find<ContactController>();
  // final postController = Get.find<PostsController>();
  final _newsFeedRepository = Get.find<NewsfeedRepository>();
  final UserRepository _userRepo = Get.find();
  final _storageRepository = Get.find<StorageRepository>();
  final ContactRepository _contactRepository = Get.find();
  final appController = Get.find<AppController>();
  List<UserContact> usersContact = [];
  RxList<Post> posts = <Post>[].obs;
  int pageKey = 1;
  RxBool isLoadingLoadMore = false.obs;
  RxBool hasMorePage = false.obs;
  static const _pageSize = 20;

  final isAvatarLocal = false.obs;

  Rx<int> selectedButtonSegmentIndex = 1.obs;

  /// scroll controller for short video
  ScrollController shortScrollController = ScrollController();

  /// controller of page
  PageController pageController = PageController();

  /// variable for user statistics, include all statistics for short video
  Rx<UserStatistics> userStatistics =
      Rx(const UserStatistics(totalLikes: 0, totalComments: 0, totalShares: 0));

  RxString imagePath = ''.obs;

  RxString avatarUrl = ''.obs;

  final Rx<PickedMedia?> _toSendMedia = Rx(null);
  PickedMedia? get toSendMedia => _toSendMedia.value;

  final bool isMine = Get.arguments['isMine'] as bool;
  final User user = Get.arguments['user'] as User;
  final bool isAddContactAgr = Get.arguments['isAddContact'] as bool;

  Rx<bool> isAddContact = false.obs;
  var userNameText = ''.obs;
  var userPhoneText = '**********'.obs;
  var userEmailText = '**********'.obs;
  var userNftText = '**********'.obs;
  var userGender = '--'.obs;
  var userAgeValueText = '--'.obs;
  var userLocationText = '---'.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    isAddContact.value = isAddContactAgr;
    // usersContact = contactController.usersList.reversed.toList();
    // getPostPersonalPage();
    loadUserInfo();
    getUserinfo();
    checkContactExist();
  }

  Future getUserinfo() async {
    userStatistics.value =
        await Get.find<ShortVideoRepository>().getUserStatistics(user.id);
  }

  void loadUserInfo() {
    userNameText.value = user.contactName;
    userPhoneText.value = user.phone ?? '**********';

    userNftText.value = user.nftNumber ?? '**********';

    userEmailText.value = user.email ?? '**********';

    userGender.value =
        user.gender != '' && user.gender != null && user.gender != 'null'
            ? user.gender ?? '--'
            : '--';

    userAgeValueText.value =
        user.birthday != '' && user.birthday != null && user.birthday != 'null'
            ? '${calculateAge(user.birthday ?? '')}'
            : '--';
    userLocationText.value =
        user.location != '' && user.location != null && user.location != 'null'
            ? user.location ?? '---'
            : '---';
    if (!isMine) {
      if (!(user.isShowPhone ?? true)) {
        userPhoneText.value = '**********';
      }
      if (!(user.isShowEmail ?? true)) {
        userEmailText.value = '**********';
      }
      if (!(user.isShowGender ?? true)) {
        userGender.value = '--';
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
    }

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

  void attachMedia(PickedMedia media) {
    _toSendMedia.value = media;
  }

  Future<void> onCameraButtonPressed(BuildContext context) async {
    await MediaHelper.takeImageFromCamera().then((media) {
      if (media != null) {
        if (isAvatarLocal.value == false) {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => customBackground());
        }
        attachMedia(media);
        imagePath.value = media.file.path;
        isAvatarLocal.value = true;
      }
    });
  }

  Future<void> getImageFromGallery(BuildContext context) async {
    // final pickedImage = await MediaHelper.pickImageFromGallery();

    // if (pickedImage == null) {
    //   return;
    // }

    // imagePath.value = pickedImage.file.path;
    // isAvatarLocal.value = true;
    // setDisableLoginBtn = false;

    await MediaHelper.pickImageFromGallery().then((media) {
      if (media != null) {
        if (isAvatarLocal.value == false) {
          showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (context) => customBackground());
        }
        attachMedia(media);
        imagePath.value = media.file.path;
        isAvatarLocal.value = true;
      }
    }).catchError(
      (error) {
        if (error is ValidationException) {
          ViewUtil.showToast(
            title: Get.context!.l10n.error__file_is_too_large_title,
            message: Get.context!.l10n.error__file_is_too_large_message,
          );
        }
      },
    );
  }

  Widget customBackground() => PopScope(
        canPop: false,
        child: Container(
          // color: AppColors.background7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.gapH40,
              Padding(
                padding: AppSpacing.edgeInsetsH20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                          isAvatarLocal.value = false;
                        },
                        icon: AppIcon(
                          icon: AppIcons.arrowLeft,
                        )),
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.deepSkyBlue,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          Get.context!.l10n.setting__save,
                          style: AppTextStyles.s16w500,
                        )).clickable(() {
                      updateProfile();
                      isAvatarLocal.value = false;
                      Get.back();
                    })
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  SizedBox(
                    height: 0.3.sh + 60,
                  ),
                  Obx(
                    () => Container(
                      width: double.infinity,
                      height: 0.3.sh,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(
                            File(imagePath.value),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 76,
                    right: 16,
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xff4e5b73),
                        shape: BoxShape.circle,
                        // border: Border.all(
                        //   color: Colors.white,
                        //   width: 0.5,
                        // ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AppIcon(icon: AppIcons.camera),
                      ),
                    ).clickable(() {
                      openImageOption();
                    }),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: Container(
                        height: 140,
                        width: 140,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(width: 4, color: AppColors.white)),
                        child: Obx(() => AppCircleAvatar(
                            size: 140, url: currentUser.avatarPath ?? ''))),
                  ),
                ],
              ),
              AppSpacing.gapH16,
              Padding(
                padding: AppSpacing.edgeInsetsOnlyLeft20,
                child: Text(
                  currentUser.fullName,
                  style: AppTextStyles.s24w700,
                ),
              ),
            ],
          ),
        ),
      );

  Future<void> updateAvatar({
    required File file,
  }) async {
    await runAction(
      action: () async {
        final url = await _storageRepository.uploadUserAvatar(
            file: file, currentUserId: currentUser.id);

        avatarUrl = url.obs;

        if (file.existsSync()) {
          await file.delete();
        }
      },
    );
  }

  Future<void> updateProfile() async {
    if (_toSendMedia.value != null) {
      await updateAvatar(file: _toSendMedia.value!.file);
    }

    await runAction(
      action: () async {
        await _userRepo.updateProfile(
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
          isShowNft: currentUser.isShowNft ?? true,
          isShowGender: currentUser.isShowGender ?? true,
          isShowBirthday: currentUser.isShowBirthday ?? true,
          isShowLocation: currentUser.isShowLocation ?? true,
          nftNumber: currentUser.nftNumber ?? '',
          // talkLanguage: currentUser.talkLanguage,
          // pinNumber: currentUser.pinNumber,
          // linkedAddress: currentUser.linkedAddress,
          // backgroundPath: avatarUrl.value,
          talkLanguage: currentUser.talkLanguage ?? '',
        );

        isAvatarLocal.value = false;

        ViewUtil.showToast(
          title: l10n.global__success_title,
          message: l10n.profile__updated_success,
        );

        final userUpdated = await _userRepo.getUserById(currentUser.id);

        Get.find<AppController>().setLoggedUser(userUpdated);

        // if (isUpdateProfileFirstLogin) {
        //   unawaited(Get.offNamed(AppPages.afterAuthRoute));
        // }
      },
      onError: (exception) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.profile__updated_error,
        );
      },
    );
  }

  Widget buildOptionItem({
    required BuildContext context,
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        icon,
        AppSpacing.gapH4,
        Text(
          title,
          style: AppTextStyles.s12w400.copyWith(
            color: AppColors.white,
          ),
        ),
      ],
    ).clickable(() {
      Get.back();
      onTap();
    });
  }

  Widget buildCameraButton() {
    return buildOptionItem(
      context: Get.context!,
      icon: AppIcon(
        icon: AppIcons.camera,
        isCircle: true,
        backgroundColor: AppColors.deepSkyBlue,
        padding: AppSpacing.edgeInsetsAll8,
      ),
      title: Get.context!.l10n.chat_hub__camera_label,
      onTap: () {
        onCameraButtonPressed(Get.context!);
      },
    );
  }

  Widget buildGalleryButton() {
    return buildOptionItem(
      context: Get.context!,
      icon: AppIcon(
        icon: AppIcons.gallery,
        isCircle: true,
        backgroundColor: AppColors.deepSkyBlue,
        padding: AppSpacing.edgeInsetsAll8,
      ),
      title: Get.context!.l10n.chat_hub__gallery_label,
      onTap: () {
        getImageFromGallery(Get.context!);
      },
    );
  }

  void openImageOption() {
    ViewUtil.showBottomSheet(
      child: Padding(
        padding: AppSpacing.edgeInsetsAll20.copyWith(bottom: 0),
        child: GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: Sizes.s16,
            mainAxisSpacing: Sizes.s32,
          ),
          children: [
            buildCameraButton(),
            buildGalleryButton(),
          ],
        ),
      ),
    );
  }

  @override
  Future<void> onEndScroll() async {
    // await loadMorePostPersonalPage();
  }

  @override
  Future<void> onTopScroll() async {
    // if (scroll.hasClients) {
    //   await scroll.animateTo(
    //     0,
    //     duration: const Duration(seconds: 1),
    //     curve: Curves.easeInOut,
    //   );
    // }
  }

  Future<void> updateContact(UserContact user) async {
    try {
      List<UserContact> updatedUser = [];

      await runAction(
        action: () async {
          updatedUser = await _contactRepository.updateContactById(user);
          if (updatedUser.isNotEmpty) {
            Get.back();
            ViewUtil.showToast(
              title: l10n.global__success_title,
              message: l10n.text_edit_contact,
            );
            userNameText.value = user.fullName;
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

  void onAddContactClick({required UserContact userContact}) {
    runAction(
      action: () async {
        final resultsContact =
            await _contactRepository.addContact([userContact]);
        Get.find<UserPool>().updateContact(userContact);
        if (resultsContact.created.isNotEmpty) {
          // userContactList.add(resultsContact.created.first);

          try {
            Get.find<ConversationDetailsController>().checkContactExist();
          } catch (e) {
            LogUtil.e(e);
          }
          Get.back();
          isAddContact.value = false;
          // userNameText.value = userContact.fullName;
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
