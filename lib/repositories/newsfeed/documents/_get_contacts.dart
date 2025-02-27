String getContactsQuery(int userId, String querySearch) => '''
      query MyQuery(\$querySearch: String = "%$querySearch%") {
  pi_xfactor_contacts(
  where: {
    _and: {
      user_id: {_eq: $userId}, 
      user: {
        _or: [
            {first_name: {_ilike: \$querySearch}},
            {last_name: {_ilike: \$querySearch}},
            {nickname: {_ilike: \$querySearch}}
          ]
      }
    }
  }) {
    id
    contact_last_name
    contact_avatar_path
    contact_first_name
    contact_phone_number
    user_id
    contact_id
    user {
        id
        first_name
        last_name
        avatar_path
        nickname
    }
  }
}
''';
