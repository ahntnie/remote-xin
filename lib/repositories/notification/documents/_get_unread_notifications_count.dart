String getUnreadNotificationsCountDocument({
  required int userId,
}) =>
    '''
query getUnreadNotificationsCount @cached {
  pi_xfactor_notifications_aggregate(where: {owner: {id: {_eq: $userId}}, read_at: {_is_null: true}}) {
    aggregate {
      count
    }
  }
}
''';
