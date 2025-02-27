String getNotificationsDocument({
  required int userId,
  required int pageSize,
  required int offset,
  required String sortOrder,
}) =>
    '''
   query getNotification @cached {
  pi_xfactor_notifications(where: {owner: {id: {_eq: $userId}}}, limit: $pageSize, offset: $offset, order_by: {created_at: $sortOrder}) {
    data
    id
    notifiable_type
    read_at
    title
    content_html
    content_text
    created_at
    type
  }
}
''';
