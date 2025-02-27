String getMissedCallByUserIdQuery({
  required int userId,
  required int pageSize,
  required int offset,
}) =>
    '''
query CallHistories {
  call_histories: pi_xfactor_call_histories(order_by: {call: {created_at: desc}}, where: {status: {_in: ["missed", "declined"]}, user_id: {_eq: $userId}, role: {_eq: "subscriber"}}, limit: $pageSize, offset: $offset) {
    call {
      created_at
      is_group
      is_video
      callers: histories(where: {role: {_eq: "publisher"}}) {
        user {
          id
          last_name
          first_name
          avatar_path
          email
        }
      }
      receivers: histories(where: {role: {_eq: "subscriber"}}) {
        user {
          id
          last_name
          first_name
          avatar_path
          email
        }
      }
      chat_channel_id
      id
    }
    user_id
    status
    duration
  }
}
''';
