String checkContactExistQuery({
  required String phoneNumber,
  required int userId,
}) {
  return '''
   query MyQuery @cached {
  pi_xfactor_contacts(where: {user_id: {_eq: "$userId"}, contact_phone_number: {_eq: "$phoneNumber"}, contact_id: {_is_null: false}}) {
    id
    contact_id
    contact_phone_number
    contact_last_name
    contact_first_name
    user {
      id
      first_name
      last_name
      phone
      avatar_path
    }
    
  }
}
  ''';
}
