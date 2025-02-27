import 'package:get/get.dart';

import '../../../../core/helpers/debouncer.dart';
import '../../../../models/all.dart';
import '../../../../repositories/user/user_repo.dart';
import '../../../base/base_controller.dart';

class SearchUserController extends BaseController {
  final _userRepo = Get.find<UserRepository>();

  final _users = <User>[].obs;
  List<User> get users => _users.toList();

  final _usersRandom = <User>[].obs;
  List<User> get usersRandom => _usersRandom.toList();

  final _searchDebouncer = Debouncer();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getRamdomUsers();
  }

  List<User> convertUserContactsToUsers(List<UserContact> userContacts) {
    return userContacts.map((contact) {
      return User(
        id: contact.user!.id,
        firstName: contact.contactFirstName,
        lastName: contact.contactLastName,
        phone: contact.contactPhoneNumber,
        avatarPath: contact.contactAvatarPath,
      );
    }).toList();
  }

  RxBool getIsSearch() => _users.isEmpty ? false.obs : true.obs;

  Future getRamdomUsers() async {
    // _users.value = convertUserContactsToUsers(
    //     Get.find<ContactController>().usersList.toList());
    final usersQuery = await _userRepo.getRandomUsers();
    _usersRandom.addAll(usersQuery);
    _users.addAll(usersQuery);
  }

  void searchUser(String query) {
    query = query.trim();

    _searchDebouncer.run(() {
      runAction(
        action: () async {
          if (query.trim().isEmpty) {
            _users.value = usersRandom;

            return;
          }

          // if query is phone number and start with 0, remove the 0
          if (RegExp(r'^[0-9]+$').hasMatch(query) && query.startsWith('0')) {
            query = query.substring(1);
          }

          final users = await _userRepo.searchUser(query);

          _users.value =
              users.where((user) => user.id != currentUser.id).toList();
        },
      );
    });
  }
}
