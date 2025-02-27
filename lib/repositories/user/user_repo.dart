import 'dart:io';

import 'package:get/get.dart';

import '../../data/api/api.dart';
import '../../data/mappers/response_mapper/base/base_success_response_mapper.dart';
import '../../models/all.dart';
import '../../presentation/common_controller.dart/all.dart';
import '../base/base_repo.dart';
import 'documents/_get_users_by_ids.dart';
import 'documents/_update_user_talk_language_by_id.dart';
import 'documents/all.dart';

class UserRepository extends BaseRepository {
  final _graphQLApiClient = Get.find<AuthenticatedGraphQLApiClient>();
  final _authenticatedRestApiClient = Get.find<AuthenticatedRestApiClient>();

  Future<User> getUserById(int id) async {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: getUserByIdQuery(id),
          decoder: (data) {
            final users = (data as Map<String, dynamic>)['backend_users'];

            if (users.isEmpty) {
              return User.deactivated(id);
            }

            return User.fromJson(users.first);
          },
        );
      },
    );
  }

  Future<List<User>> getUsersByIds(List<int> ids) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: getUsersByIdsQuery(ids),
          decoder: (data) => User.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<List<User>> getRandomUsers() async {
    final users = await executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: getUsersWithAvatarQuery(),
          decoder: (data) => User.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );

    // Lấy ngẫu nhiên 20 người dùng từ kết quả
    users.shuffle(); // Xáo trộn danh sách
    final cropUser = users.take(15).toList();

    return cropUser
        .where((user) => user.id != Get.find<AppController>().currentUser.id)
        .toList();
  }

  Future<List<User>> searchUser(String query) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: searchUserByQuery(query),
          decoder: (data) => User.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<int> updateProfile({
    required int id,
    required String firstName,
    required String lastName,
    required String phone,
    required String avatarPath,
    required String nickname,
    required String email,
    required String gender,
    required String birthday,
    required String location,
    required bool isSearchGlobal,
    required bool isShowEmail,
    required bool isShowPhone,
    required bool isShowGender,
    required bool isShowBirthday,
    required bool isShowLocation,
    required bool isShowNft,
    required String nftNumber,
    required String talkLanguage,
    int? idAttachment,
    String? attachmentType,
  }) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.mutate(
          document: updateUserByIdMutation(
            id: id,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phone,
            avatarPath: avatarPath,
            nickname: nickname,
            email: email,
            attachmentType: attachmentType,
            idAttachment: idAttachment,
            gender: gender,
            birthday: birthday,
            location: location,
            isSearchGlobal: isSearchGlobal,
            isShowEmail: isShowEmail,
            isShowPhone: isShowPhone,
            isShowGender: isShowGender,
            isShowBirthday: isShowBirthday,
            isShowLocation: isShowLocation,
            nftNumber: nftNumber,
            talkLanguage: talkLanguage,
            isShowNft: isShowNft,
          ),
          decoder: (data) =>
              (data as Map<String, dynamic>)['update_backend_users']
                  ['affected_rows'] as int,
        );
      },
    );
  }

  Future<List<User>> getUserByPhone(String phone) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: getUserByPhoneQuery(phone),
          decoder: (data) => User.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<List<User>> getUsersByUsername(String username) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: getUserByUsernameQuery(username),
          decoder: (data) => User.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<List<User>> getUsersByEmail(String email) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: getUserByEmailQuery(email),
          decoder: (data) => User.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<List<User>> searchUserWithPaging(
    String query,
    int pageSize,
    int offset,
  ) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: searchUserByNameWithPaging(query, pageSize, offset),
          decoder: (data) => User.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<List<UserContact>> searchUserContactWithPaging(
    String query,
    int pageSize,
    int offset,
  ) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.query(
          document: searchUserByNameWithPaging(query, pageSize, offset),
          decoder: (data) => UserContact.fromJsonList(
            (data as Map<String, dynamic>)['backend_users'] as List<dynamic>,
          ),
        );
      },
    );
  }

  Future<Attachment> uploadAvatarToServer(File file) async {
    return await executeApiRequest(
      () async {
        return _authenticatedRestApiClient.postMultiForm(
          '/files',
          body: {
            'file_data': file,
          },
          decoder: (data) =>
              Attachment.fromJson((data as Map<String, dynamic>)['data']),
        );
      },
    );
  }

  Future<void> deleteUserById(int id) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.mutate(
          document: deleteUserByIdQuery(id),
          decoder: (data) =>
              (data as Map<String, dynamic>)['delete_backend_users']
                  ['affected_rows'] as int,
        );
      },
    );
  }

  Future<void> blockUserById(int id) {
    return executeApiRequest(
      () async {
        await _authenticatedRestApiClient.post(
          '/users/$id/block',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<void> unblockUserById(int id) {
    return executeApiRequest(
      () async {
        await _authenticatedRestApiClient.delete(
          '/users/$id/block',
          successResponseMapperType: SuccessResponseMapperType.plain,
        );
      },
    );
  }

  Future<int> updateUserTalkLanguage({
    required int id,
    String? talkLanguage,
    String? email,
  }) {
    return executeApiRequest(
      () async {
        return _graphQLApiClient.mutate(
          document: updateUserTalkLanguageByIdMutation(
              id: id, talkLanguage: talkLanguage, email: email),
          decoder: (data) =>
              (data as Map<String, dynamic>)['update_backend_users']
                  ['affected_rows'] as int,
        );
      },
    );
  }
}
