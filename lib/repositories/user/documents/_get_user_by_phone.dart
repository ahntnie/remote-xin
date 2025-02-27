import 'user_schema.dart';

String getUserByPhoneQuery(String phone) => '''
      query MyQuery {
        backend_users(where: {phone: {_eq: "$phone"}}) {
          $userSchema
        }
      }
      ''';
