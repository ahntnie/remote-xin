import 'user_schema.dart';

String getUserByIdQuery(int id) => '''
      query MyQuery {
        backend_users(where: {id: {_eq: $id}}) {
          $userSchema
        }
      }
      ''';
