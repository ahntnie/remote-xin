import 'user_schema.dart';

String getUsersByIdsQuery(List<int> ids) => '''
      query MyQuery {
         backend_users(where: {id: {_in: $ids}}) {
          $userSchema
        }
      }
      ''';
