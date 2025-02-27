// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserContact _$UserContactFromJson(Map<String, dynamic> json) => UserContact(
      contactFirstName: json['contact_first_name'] as String,
      contactLastName: json['contact_last_name'] as String,
      contactPhoneNumber: json['contact_phone_number'] as String,
      user: json['user'] == null
          ? null
          : User.fromJson(json['user'] as Map<String, dynamic>),
      id: json['id'] as int?,
      contactAvatarPath: json['contact_avatar_path'] as String?,
      isExpanded: json['is_expanded'] as bool? ?? false,
      userId: json['user_id'] as int?,
      contactId: json['contact_id'] as int?,
      data: json['data'] as String?,
    );

Map<String, dynamic> _$UserContactToJson(UserContact instance) =>
    <String, dynamic>{
      'id': instance.id,
      'contact_first_name': instance.contactFirstName,
      'contact_last_name': instance.contactLastName,
      'contact_phone_number': instance.contactPhoneNumber,
      'contact_avatar_path': instance.contactAvatarPath,
      'is_expanded': instance.isExpanded,
      'user_id': instance.userId,
      'contact_id': instance.contactId,
      'user': instance.user?.toJson(),
      'data': instance.data,
    };

ContactsResult _$ContactsResultFromJson(Map<String, dynamic> json) =>
    ContactsResult(
      notCreated: NotCreatedContacts.fromJson(
          json['not_created'] as Map<String, dynamic>),
      created: (json['created'] as List<dynamic>?)
              ?.map((e) => UserContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ContactsResultToJson(ContactsResult instance) =>
    <String, dynamic>{
      'created': instance.created.map((e) => e.toJson()).toList(),
      'not_created': instance.notCreated.toJson(),
    };

NotCreatedContacts _$NotCreatedContactsFromJson(Map<String, dynamic> json) =>
    NotCreatedContacts(
      existed: (json['existed'] as List<dynamic>?)
              ?.map((e) => UserContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notFounds: (json['not_founds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NotCreatedContactsToJson(NotCreatedContacts instance) =>
    <String, dynamic>{
      'existed': instance.existed.map((e) => e.toJson()).toList(),
      'not_founds': instance.notFounds,
    };
