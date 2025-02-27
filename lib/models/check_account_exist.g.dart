// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_account_exist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CheckAccountExist _$CheckAccountExistFromJson(Map<String, dynamic> json) =>
    CheckAccountExist(
      code: json['code'] as String,
      accountExist: json['account_exist'] as bool,
    );

Map<String, dynamic> _$CheckAccountExistToJson(CheckAccountExist instance) =>
    <String, dynamic>{
      'code': instance.code,
      'account_exist': instance.accountExist,
    };
