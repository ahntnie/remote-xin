import 'user_schema.dart';

String getUsersWithAvatarQuery() => '''
  query MyQuery {
    backend_users(where: {avatar_path: {_neq: ""}}, limit: 40) {
      $userSchema
    }
  }
''';
