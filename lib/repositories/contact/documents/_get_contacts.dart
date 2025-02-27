String getContactsQuery(int userId) => '''
      query MyQuery {
          pi_xfactor_contacts(where: {user_id: {_eq: $userId}, contact_id: {_is_null: false}}) {
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
              web_user_id
            }
          }
      }
''';

// String getContactsQuery(int userId) => '''
//       query MyQuery {
//           pi_xfactor_contacts(where: {user_id: {_eq: $userId}}) {
//             id
//             contact_last_name
//             contact_avatar_path
//             contact_first_name
//             contact_phone_number
//             user_id
//             contact_id
//             user {
//               id
//               first_name
//               last_name
//               avatar_path
//               nickname
//               web_user_id
//             }
//           }
//       }
// ''';
