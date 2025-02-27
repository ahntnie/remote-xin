// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatarPath: json['avatar_path'] as String?,
      nickname: json['nickname'] as String?,
      loginLocal: json['login_local'] as String?,
      fetchTime: json['fetch_time'] == null
          ? null
          : DateTime.parse(json['fetch_time'] as String),
      contact: json['contact'] == null
          ? null
          : UserContact.fromJson(json['contact'] as Map<String, dynamic>),
      isActivated: json['is_activated'] as bool?,
      webUserId: json['web_user_id'] as String?,
      talkLanguage: json['talk_language'] as String?,
      zoomId: json['zoom_id'] as String?,
      gender: json['gender'] as String?,
      birthday: json['birthday'] as String?,
      location: json['location'] as String?,
      isSearchGlobal: json['is_search_global'] as bool?,
      isShowEmail: json['is_show_email'] as bool?,
      isShowPhone: json['is_show_phone'] as bool?,
      isShowGender: json['is_show_gender'] as bool?,
      isShowBirthday: json['is_show_birthday'] as bool?,
      isShowLocation: json['is_show_location'] as bool?,
      isShowNft: json['is_show_nft'] as bool?,
      nftNumber: json['nft_number'] as String?,
      isPhoneVerified: json['is_phone_verified'] as bool?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'avatar_path': instance.avatarPath,
      'nickname': instance.nickname,
      'login_local': instance.loginLocal,
      'fetch_time': instance.fetchTime?.toIso8601String(),
      'contact': instance.contact?.toJson(),
      'is_activated': instance.isActivated,
      'web_user_id': instance.webUserId,
      'talk_language': instance.talkLanguage,
      'zoom_id': instance.zoomId,
      'gender': instance.gender,
      'birthday': instance.birthday,
      'location': instance.location,
      'is_search_global': instance.isSearchGlobal,
      'is_show_email': instance.isShowEmail,
      'is_show_phone': instance.isShowPhone,
      'is_show_gender': instance.isShowGender,
      'is_show_birthday': instance.isShowBirthday,
      'is_show_location': instance.isShowLocation,
      'is_show_nft': instance.isShowNft,
      'nft_number': instance.nftNumber,
      'is_phone_verified': instance.isPhoneVerified,
    };
