import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/all.dart';
import '../../../../models/all.dart';
import '../../../../repositories/all.dart';
import '../../../base/all.dart';
import '../../../common_controller.dart/all.dart';
import '../../../routing/routers/app_pages.dart';
import '../../all.dart';
import '../../call/call.dart';
import 'country.dart';

class ContactController extends BaseController
    with GetSingleTickerProviderStateMixin {
  // static const _pageSize = 15;
  final ContactRepository _contactRepository = Get.find<ContactRepository>();
  final _chatRepository = Get.find<ChatRepository>();
  final _storageRepository = Get.find<StorageRepository>();
  final _userPool = Get.find<UserPool>();

  TextEditingController searchController = TextEditingController();
  RxBool isSearching = false.obs;
  RxList<UserContact> usersList = <UserContact>[].obs;
  RxList<UserContact> contactsSearching = <UserContact>[].obs;

  int pageKey = 0;
  final ScrollController scrollController = ScrollController();

  static List<UserContact> usersContact = [];

  RxString isoCode = ''.obs;
  RxBool isEditContact = false.obs;

  // Avatar
  RxString imagePath = ''.obs;
  RxString avatarUrl = ''.obs;
  final isAvatarLocal = false.obs;
  RxString phoneEdit = ''.obs;
  RxBool isDisabledBtnSync = false.obs;
  RxBool isDisabledBtnAdd = false.obs;
  RxBool isDisabledBtnEdit = false.obs;

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  late AnimationController animationController;

  final formKey = GlobalKey<FormState>();

  final _searchDebouncer = Debouncer();

  RxBool isLoadingInit = true.obs;

  var isValidFirstName = true.obs;
  var isValidForm = false.obs;

  @override
  Future<void> onInit() async {
    phoneController.addListener(() {
      checkForm();
    });

    searchController.addListener(_onSearchChanged);

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    animationController.stop();

    _userPool.myContactsRx.listen((p0) {
      usersList.clear();
      usersList.addAll(p0);
    });

    getUserContacts();

    super.onInit();
  }

  void checkForm() {
    isValidForm.value = phoneController.text.trim().isNotEmpty;

    update();
  }

  @override
  void dispose() {
    scrollController.dispose();
    animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    changeSearching = true;
    searchContact(searchController.text);
  }

  set changeSearching(bool value) {
    isSearching.value = value;
  }

  set changeIsEditContact(bool value) {
    isEditContact.value = value;
    update();
  }

  void getUserContacts({bool isLoading = true}) {
    runAction(
      handleLoading: false,
      action: () async {
        isLoadingInit.value = true;
        final contacts = await _contactRepository.getContacts(currentUser.id);
        for (var contact in contacts) {
          log(contact.userId.toString());
        }

        _userPool.updateContacts(contacts);

        usersList.clear();
        if (contacts.isNotEmpty) {
          usersList.addAll(contacts);
        } else {
          final List<UserContact> contacts =
              await getAndSyncContactLocalPhone();
          usersList.addAll(contacts);
        }
        isLoadingInit.value = false;
      },
    );
  }

  Future<void> searchContact(String query) async {
    if (searchController.text.isEmpty) {
      changeSearching = false;

      return;
    }
    contactsSearching.value.clear();
    query = query.trim();
    if (RegExp(r'^[0-9]+$').hasMatch(query) && query.startsWith('0')) {
      query = query.substring(1);
    }

    final List<UserContact> users = usersList.where((userContact) {
      if (userContact.contactPhoneNumber.contains(query) ||
          userContact.fullName.toLowerCase().contains(query.toLowerCase())) {
        return true;
      }

      if (userContact.user?.webUserId?.contains(query) ?? false) {
        return true;
      }

      return false;
    }).toList();

    contactsSearching.value = users;
    update();

    // _searchDebouncer.run(() {
    //   contactsSearching.clear();
    //   query = query.trim();
    //   if (RegExp(r'^[0-9]+$').hasMatch(query) && query.startsWith('0')) {
    //     query = query.substring(1);
    //   }

    //   final List<UserContact> users = usersList.where((userContact) {
    //     if (userContact.contactPhoneNumber.contains(query) ||
    //         userContact.fullName.toLowerCase().contains(query.toLowerCase())) {
    //       return true;
    //     }

    //     if (userContact.user?.webUserId?.contains(query) ?? false) {
    //       return true;
    //     }

    //     return false;
    //   }).toList();

    //   contactsSearching.value.addAll(users);
    //   update();
    // });
  }

  Future<List<UserContact>> getAndSyncContactLocalPhone() async {
    return [];
    final bool permissionContact = await FlutterContacts.requestPermission();
    if (!permissionContact) {
      await ViewUtil.showAppCupertinoAlertDialog(
        title: l10n.notification__title,
        message: l10n.contact__message_opened_settings,
        negativeText: l10n.setting__title,
        onNegativePressed: () async {
          await openAppSettings();
        },
        positiveText: l10n.button__cancel,
      );
    } else if (permissionContact) {
      try {
        // Get contact to local
        final List<Contact> contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withAccounts: true,
          withGroups: true,
        );

        if (contacts.isEmpty) {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.contact__no_contact,
          );

          return [];
        }

        // check region info from device
        final List<Locale> systemLocales =
            WidgetsBinding.instance.platformDispatcher.locales;
        final String isoCountryCode = systemLocales.first.countryCode ?? '';

        Map<String, String> foundedCountry = {};
        for (var country in Countries.allCountries) {
          final String dialCode = country['code'].toString();
          if (isoCountryCode.contains(dialCode)) {
            foundedCountry = country;
          }
        }

        usersContact.clear();

        for (Contact contact in contacts) {
          if (contact.phones.isEmpty) {
            continue;
          }

          String phoneNumber = contact.phones.first.number.removeAllWhitespace;

          if (phoneNumber.startsWith('+')) {
            usersContact.add(UserContact(
              contactFirstName: contact.name.first,
              contactLastName: contact.name.last,
              contactPhoneNumber: phoneNumber,
              contactAvatarPath: '',
              data: jsonEncode(contact.toJson()),
            ));
          } else {
            // get phone number from code country and phone local
            try {
              final PhoneNumber phone =
                  await PhoneNumber.getRegionInfoFromPhoneNumber(
                phoneNumber,
                foundedCountry['code'].toString(),
              );

              phoneNumber = phone.phoneNumber?.removeAllWhitespace ??
                  phoneNumber.removeAllWhitespace;

              usersContact.add(UserContact(
                contactFirstName: contact.name.first,
                contactLastName: contact.name.last,
                contactPhoneNumber: phoneNumber,
                contactAvatarPath: '',
                data: jsonEncode(contact.toJson()),
              ));
            } catch (e) {
              logError(e);
              continue;
            }
          }
        }
      } catch (e) {
        logError(e);
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.global__error_has_occurred,
        );
      }

      if (usersContact.isNotEmpty) {
        try {
          late ContactsResult contactsResult;

          await runAction(action: () async {
            contactsResult = await _contactRepository.addContact(usersContact);
          });

          if (contactsResult.created.isNotEmpty) {
            return contactsResult.created;
          }

          ViewUtil.showToast(
            title: l10n.global__success_title,
            message: l10n.contact__sync_success,
          );
        } catch (e) {
          ViewUtil.showToast(
            title: l10n.global__error_title,
            message: l10n.global__error_has_occurred,
          );
        } finally {
          unawaited(_userPool.getContacts());
        }
      }
    }

    return [];
  }

  Future<void> getRegionInfoFromPhoneNumber(String phone) async {
    if (phone.isEmpty) {
      isoCode.value = 'VN';

      return;
    }

    final PhoneNumber phoneNumberParse =
        await PhoneNumber.getRegionInfoFromPhoneNumber(phone);

    final String phoneParsableNumber =
        await PhoneNumber.getParsableNumber(phoneNumberParse);

    isoCode.value = phoneNumberParse.isoCode ?? '';
    phoneController.text = phoneParsableNumber;
    update();
  }

  Future<void> getImageFromGallery() async {
    final pickedImage = await MediaHelper.pickImageFromGallery();

    if (pickedImage == null) {
      return;
    }

    imagePath.value = pickedImage.file.path;

    isAvatarLocal.value = true;

    await runAction(
      action: () async {
        final avatar = await _storageRepository.uploadUserAvatar(
          file: pickedImage.file,
          currentUserId: currentUser.id,
        );

        avatarUrl.value = avatar;
        update();
      },
      onError: (_) => isAvatarLocal.value = false,
    );
  }

  Future<void> updateContact(UserContact user) async {
    isDisabledBtnEdit.value = true;
    update();

    try {
      user.contactAvatarPath = avatarUrl.value.trim();
      user.contactFirstName = firstNameController.text.trim();
      user.contactLastName = lastNameController.text.trim();

      List<UserContact> updatedUser = [];

      await runAction(
        action: () async {
          updatedUser = await _contactRepository.updateContactById(user);
        },
      );

      if (updatedUser.isNotEmpty) {
        final index = usersList.indexWhere((element) => element.id == user.id);
        usersList[index] = updatedUser.first;
        update();

        _userPool.updateContact(updatedUser.first);
      }
    } catch (e) {
      ViewUtil.showToast(
        title: l10n.global__error_title,
        message: l10n.global__error_has_occurred,
      );
    } finally {
      isDisabledBtnEdit.value = false;
      update();
    }
  }

  void deleteContact(int contactId) {
    runAction(
      action: () async {
        final affectedRows =
            await _contactRepository.deleteContactById(contactId);
        if (affectedRows > 0) {
          usersList.removeWhere((element) => element.id == contactId);
          update();
        }

        Get.find<PosterPersonalPageController>().checkUserContact();
      },
    );
  }

  Future<void> addContact() async {
    isDisabledBtnAdd.value = true;
    update();
    try {
      final user = UserContact(
        contactFirstName: firstNameController.text.trim(),
        contactLastName: lastNameController.text.trim(),
        contactPhoneNumber: phoneEdit.value.trim(),
        contactAvatarPath: avatarUrl.value.trim(),
      );

      late ContactsResult contactsResult;

      await runAction(action: () async {
        contactsResult = await _contactRepository.addContact([user]);
      });

      if (contactsResult.created.isNotEmpty) {
        _userPool.updateContact(user);
        usersList.add(contactsResult.created.first);
        update();

        Get.back();

        ViewUtil.showToast(
          title: l10n.global__success_title,
          message: l10n.contact__add_success,
        );
      } else if (contactsResult.notCreated.existed.isNotEmpty) {
        ViewUtil.showToast(
          title: l10n.global__error_title,
          message: l10n.contact__already_exist,
        );
      } else if (contactsResult.notCreated.notFounds.isNotEmpty) {
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
    } finally {
      Future.delayed(const Duration(milliseconds: 1000), () {
        isDisabledBtnAdd.value = false;
        update();
      });
    }
  }

  Future<void> reSyncContactLocal() async {
    try {
      isDisabledBtnSync.value = true;
      update();

      final List<UserContact> contacts = await getAndSyncContactLocalPhone();
      if (contacts.isNotEmpty) {
        usersList.addAll(contacts);
        update();
      }

      animationController.stop();
      animationController.reset();
    } catch (e) {
      ViewUtil.showToast(
        title: l10n.global__error_title,
        message: l10n.global__error_has_occurred,
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        animationController.stop();
        animationController.reset();
        isDisabledBtnSync.value = false;
        update();
      });
    }
  }

  void onCallVoice(UserContact user) {
    if (user.userId == null) {
      return;
    }

    runAction(
      action: () async {
        final conversation = await Get.find<ChatRepository>()
            .createConversation([user.contactId!]);
        unawaited(CallKitManager.instance.createCall(
          chatChannelId: conversation.id,
          receiverIds: [user.contactId!],
          isGroup: false,
          isVideo: false,
          isTranslate: false,
        ));
      },
    );
  }

  void onVideoCall(UserContact user) {
    if (user.userId == null) return;

    runAction(
      action: () async {
        final conversation = await Get.find<ChatRepository>()
            .createConversation([user.contactId!]);
        unawaited(CallKitManager.instance.createCall(
          chatChannelId: conversation.id,
          receiverIds: [user.contactId!],
          isGroup: false,
          isVideo: true,
          isTranslate: false,
        ));
      },
    );
  }

  Future<void> goToPrivateChat(UserContact contact) async {
    if (contact.contactId == null) {
      return;
    }

    final conversation =
        await _chatRepository.createConversation([contact.contactId!]);

    return Get.toNamed(
      Routes.chatHub,
      arguments: ChatHubArguments(conversation: conversation),
    );
  }

  void updateExpanded(UserContact userContact) {
    if (usersList.isNotEmpty && userContact.isExpanded) {
      for (var user in usersList) {
        user.isExpanded = false;
      }
    } else if (usersList.isNotEmpty) {
      for (var user in usersList) {
        user.isExpanded = false;
      }
      userContact.isExpanded = true;
    }

    update();
  }

  UserContact? findUserContact(User user) {
    final list = usersList.value.where((userContact) {
      return userContact.userId == user.id ||
          ((userContact.user != null) ? userContact.user?.id : -1) == user.id ||
          user.phone == userContact.contactPhoneNumber;
    });

    return (list.isEmpty) ? null : list.first;
  }
}
