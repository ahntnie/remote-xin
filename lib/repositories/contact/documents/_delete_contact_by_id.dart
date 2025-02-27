String deleteContactByIdMutation({
  required int id,
}) =>
    '''
    mutation MyMutation {
      delete_pi_xfactor_contacts(where: {id: {_eq: "$id"}}) {
        affected_rows
      }
    }
    ''';
