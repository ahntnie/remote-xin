String updateContactByIdMutation({
  required int id,
  required String firstName,
  required String lastName,
  // required String phoneNumber,
  required String avatarPath,
}) =>
    '''
    mutation MyMutation {
      update_pi_xfactor_contacts(where: {id: {_eq: $id}}, _set: {contact_avatar_path: "$avatarPath", contact_first_name: "$firstName", contact_last_name: "$lastName"}) {
        affected_rows
        returning {
          id
          contact_avatar_path
          contact_first_name
          contact_last_name
          contact_phone_number
          user_id
          contact_id
          user {
            id
            first_name
            last_name
            avatar_path
          }
        }
      }
    }
    ''';
