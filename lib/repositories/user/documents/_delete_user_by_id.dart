String deleteUserByIdQuery(int id) => '''
      mutation MyMutation {
        delete_backend_users(where: {id: {_eq: "$id"}}) {
          affected_rows
          }
      }
      ''';
