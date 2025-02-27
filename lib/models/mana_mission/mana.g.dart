// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mana.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mana _$ManaFromJson(Map<String, dynamic> json) => Mana(
      mana: json['mana'] as int?,
      email: json['email'] as String?,
      id: json['id'] as String?,
      maxMana: json['max_mana'] as int?,
    );

Map<String, dynamic> _$ManaToJson(Mana instance) => <String, dynamic>{
      'mana': instance.mana,
      'email': instance.email,
      'id': instance.id,
      'max_mana': instance.maxMana,
    };
