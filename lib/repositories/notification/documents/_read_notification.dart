String readNotificationDocument() => '''
mutation readNotification(\$notificationId: bigint!) {
  update_pi_xfactor_notifications(where: {id: {_eq: \$notificationId}}, _set: {read_at: "now()"}) {
    affected_rows
  }
}
''';
