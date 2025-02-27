import 'package:get/get.dart';

import '../models/user.dart';
import '../presentation/common_controller.dart/user_pool.dart';
import '../repositories/all.dart';

class GetUserByIdWithUserPoolUsecase {
  final UserRepository _userRepository = Get.find();

  GetUserByIdWithUserPoolUsecase();

  Future<User> call(int userId) async {
    final userPool = Get.find<UserPool>();
    final cachedUser = userPool.getUser(userId);

    if (cachedUser != null) {
      return cachedUser;
    } else {
      final user = await _userRepository.getUserById(userId);
      await userPool.storeUser(user);

      return user;
    }
  }
}

class GetUsersByIdsWithUserPoolUsecase {
  final UserRepository _userRepository = Get.find();

  GetUsersByIdsWithUserPoolUsecase();

  Future<List<User>> call(Set<int> userIds) async {
    final userPool = Get.find<UserPool>();
    final List<User> cachedUsers = [];

    for (final userId in userIds) {
      final cachedUser = userPool.getUser(userId);

      if (cachedUser != null) {
        cachedUsers.add(cachedUser);
      }
    }

    if (cachedUsers.length == userIds.length) {
      return cachedUsers;
    }

    final missingUserIds = userIds
        .where((element) => !cachedUsers.any((e) => e.id == element))
        .toList();

    final missingUsers = await _userRepository.getUsersByIds(missingUserIds);

    for (final user in missingUsers) {
      await userPool.storeUser(user);
    }

    return [...cachedUsers, ...missingUsers];
  }
}
