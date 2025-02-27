import 'user_schema.dart';

String getUserByUsernameQuery(String userName) => '''
      query MyQuery {
        backend_users(where: {nickname: {_eq: "$userName"}}) {
          $userSchema
        }
      }
      ''';
