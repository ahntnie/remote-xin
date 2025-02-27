import 'user_schema.dart';

String getUserByEmailQuery(String email) => '''
      query MyQuery {
        backend_users(where: {email: {_eq: "$email"}}) {
          $userSchema
        }
      }
      ''';
