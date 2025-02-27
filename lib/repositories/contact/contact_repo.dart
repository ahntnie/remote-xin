import 'package:get/get.dart';

import '../../data/api/clients/all.dart';
import '../../models/all.dart';
import '../base/base_repo.dart';
import 'documents/all.dart';

class ContactRepository extends BaseRepository {
  final _graphQLApiClient = Get.find<AuthenticatedGraphQLApiClient>();
  final _authenticatedRestApiClient = Get.find<AuthenticatedRestApiClient>();

  Future<List<UserContact>> getContacts(int userId) async {
    return await executeApiRequest(() async {
      return _graphQLApiClient.query(
        document: getContactsQuery(userId),
        decoder: (data) => UserContact.fromJsonList(
          (data as Map<String, dynamic>)['pi_xfactor_contacts']
              as List<dynamic>,
        ),
      );
    });
  }

  Future<ContactsResult> addContact(List<UserContact> users) async {
    return executeApiRequest(() async {
      return _authenticatedRestApiClient.post(
        '/contacts',
        body: {
          'contacts': users.map((user) => user.toDtoJson()).toList(),
        },
        decoder: (data) => ContactsResult.fromJson(
          (data as Map<String, dynamic>)['data'],
        ),
      );
    });
  }

  Future<List<UserContact>> updateContactById(UserContact user) async {
    return await executeApiRequest(() async {
      return _graphQLApiClient.mutate(
        document: updateContactByIdMutation(
          id: user.id!,
          firstName: user.contactFirstName,
          lastName: user.contactLastName,
          // phoneNumber: user.contactPhoneNumber,
          avatarPath: user.contactAvatarPath ?? '',
        ),
        decoder: (data) => UserContact.fromJsonList(
          (data as Map<String, dynamic>)['update_pi_xfactor_contacts']
              ['returning'] as List<dynamic>,
        ),
      );
    });
  }

  Future<int> deleteContactById(int contactId) async {
    return await executeApiRequest(() async {
      return _graphQLApiClient.mutate(
        document: deleteContactByIdMutation(id: contactId),
        decoder: (data) =>
            (data as Map<String, dynamic>)['delete_pi_xfactor_contacts']
                ['affected_rows'],
      );
    });
  }

  Future<List<UserContact>> checkContactExist({
    required String phoneNumber,
    required int userId,
  }) async {
    return await executeApiRequest(() async {
      return _graphQLApiClient.query(
        document:
            checkContactExistQuery(userId: userId, phoneNumber: phoneNumber),
        decoder: (data) => UserContact.fromJsonList(
          (data as Map<String, dynamic>)['pi_xfactor_contacts']
              as List<dynamic>,
        ),
      );
    });
  }
}
