import 'user_schema.dart';

String searchUserByQuery(String query) => '''
      query MyQuery(\$query: String = "%$query%") {
        backend_users(
            where: {
              _and: [
                {is_search_global: {_eq: true}},
                {
                  _or: [
                    {first_name: {_ilike: \$query}},
                    {last_name: {_ilike: \$query}},
                    {nickname: {_ilike: \$query}},
                    {email: {_ilike: \$query}},
                    {phone: {_ilike: \$query}},
                    {web_user_id: {_ilike: \$query}}
                    {nft_number: {_ilike: \$query}},
                  ]
                }
              ]
            },
            limit: 8
      ) {
          $userSchema
        }
      }
      ''';

String searchUserByNameWithPaging(
  String query,
  int pageSize,
  int offset,
) =>
    '''
      query MyQuery(\$query: String = "%$query%") {
        backend_users(
            where: {
              _or: [
                    {first_name: {_ilike: \$query}}
                    {last_name: {_ilike: \$query}}
                    {nickname: {_ilike: \$query}}
                    {email: {_ilike: \$query}}
                    {phone: {_ilike: \$query}}
              ]
            },limit: $pageSize, offset: $offset
      ) {
          $userSchema
        }
      }
      ''';
