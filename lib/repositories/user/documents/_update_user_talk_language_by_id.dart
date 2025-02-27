String updateUserTalkLanguageByIdMutation({
  required int id,
  String? talkLanguage,
  String? email,
}) {
  return '''
    mutation MyMutation {
     update_backend_users(where: {id: {_eq: $id}}, _set: {email: "$email", talk_language: "$talkLanguage"}) {
        affected_rows
      }
    }''';
}
