String updateUserByIdMutation({
  required int id,
  required String firstName,
  required String lastName,
  required String phoneNumber,
  required String avatarPath,
  required String nickname,
  required String email,
  required String gender,
  required String birthday,
  required String location,
  required bool isSearchGlobal,
  required bool isShowEmail,
  required bool isShowPhone,
  required bool isShowGender,
  required bool isShowBirthday,
  required bool isShowLocation,
  required bool isShowNft,
  required String nftNumber,
  required String talkLanguage,
  int? idAttachment,
  String? attachmentType,
}) {
  final String updateSystemFiles = (idAttachment != null &&
          attachmentType != null)
      ? '''update_system_files(where: {id: {_eq: $idAttachment}}, _set: {attachment_id: $id, attachment_type: "$attachmentType", field: "avatar"}) {affected_rows}'''
      : '';

  return '''
    mutation MyMutation {
      $updateSystemFiles
      update_backend_users(where: {id: {_eq: $id}}, _set: {avatar_path: "$avatarPath", first_name: "$firstName", last_name: "$lastName", phone: "$phoneNumber", nickname: "$nickname", email: "$email", gender: "$gender", birthday: "$birthday", location: "$location", is_search_global: $isSearchGlobal, is_show_email: $isShowEmail, is_show_phone: $isShowPhone, is_show_gender: $isShowGender, is_show_birthday: $isShowBirthday, is_show_nft: $isShowNft, is_show_location: $isShowLocation, talk_language: "$talkLanguage", nft_number: "$nftNumber"}) {
        affected_rows
      }
    }''';
}
