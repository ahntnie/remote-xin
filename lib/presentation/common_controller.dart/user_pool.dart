import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/user.dart';
import '../../models/user_contact.dart';
import '../../repositories/contact/contact_repo.dart';
import '../base/all.dart';
import 'app_controller.dart';

const _boxName = 'user_pool';
const _contactsKey = 'contacts';

const _kUserPoolCapacity = 500;
const _kTTLDays = 5;

class UserPool extends BaseController with WidgetsBindingObserver {
  @override
  String get boxName => _boxName;

  final _contactRepository = Get.find<ContactRepository>();

  @override
  Future<void> onInit() async {
    await ensureInitStorage();
    await _restoreContacts();

    unawaited(getContacts());
    await _purgeExpiredUsers();

    WidgetsBinding.instance.addObserver(this);
    super.onInit();
  }

  final RxList<UserContact> myContactsRx = RxList([]);
  List<UserContact> get myContacts => myContactsRx.toList();

  Future<void> _storeContacts(List<UserContact> contacts) async {
    await write(_contactsKey, contacts.map((e) => e.toJson()).toList());
  }

  Future<void> _restoreContacts() async {
    try {
      final json = await read(_contactsKey);

      if (json == null) {
        return;
      }

      final contacts = (json as List)
          .map((e) => UserContact.fromJson(e as Map<String, dynamic>))
          .toList();

      myContactsRx.clear();
      myContactsRx.addAll(contacts);
    } catch (e) {
      await delete(_contactsKey);
    }
  }

  Future<void> getContacts() async {
    final currentUser = Get.find<AppController>().lastLoggedUser;

    if (currentUser == null) {
      return;
    }

    final contacts = await _contactRepository.getContacts(currentUser.id);

    updateContacts(contacts);
  }

  void updateContact(UserContact contact) {
    final index =
        myContacts.indexWhere((e) => e.contactId == contact.contactId);

    if (index != -1) {
      myContactsRx[index] = contact;
    } else {
      myContactsRx.add(contact);
    }

    update();

    _storeContacts(myContacts);
  }

  void updateContacts(List<UserContact> contacts) {
    myContactsRx.clear();
    myContactsRx.addAll(contacts);

    _storeContacts(contacts);
  }

  Future<void> _purgeExpiredUsers() async {
    var keys = box!.getKeys();

    // Remove users that are older than 5 days
    for (final key in keys) {
      final user = getUser(int.parse(key));

      if (user != null &&
          (user.fetchTime == null ||
              user.fetchTime!.isBefore(DateTime.now().subtract(
                const Duration(days: _kTTLDays),
              )))) {
        await delete(key);
      }

      if (user != null) {
        final contact = myContacts
            .firstWhereOrNull((contact) => contact.contactId == user.id);
        if (contact != null) {
          await storeUser(user.copyWith(contact: contact), checkContact: false);
        }
      }
    }

    // If the user pool is still over capacity after removing over 5 days old users
    // then remove the oldest users until the pool is under capacity
    keys = box!.getKeys();
    if (keys.length > _kUserPoolCapacity) {
      for (var i = keys.length - 1; i >= _kUserPoolCapacity; i--) {
        await delete(keys[i]);
      }
    }
  }

  Future<void> storeUser(User user, {bool checkContact = true}) async {
    if (checkContact) {
      final contact = myContacts
          .firstWhereOrNull((contact) => contact.contactId == user.id);
      if (contact != null) {
        user = user.copyWith(contact: contact);
      }
    }

    await write(
      user.id.toString(),
      user.copyWith(fetchTime: DateTime.now()).toJson(),
    );
  }

  User? getUser(int id) {
    try {
      final json = readSync(id.toString());

      if (json == null) {
        return null;
      }

      return User.fromJson(json);
    } catch (e) {
      delete(id.toString());

      return null;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _purgeExpiredUsers();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
    }
  }
}
