import 'package:freezed_annotation/freezed_annotation.dart';

part 'mana.g.dart';

@JsonSerializable()
class Mana {
  Mana({
    this.mana,
    this.email,
    this.id,
    this.maxMana,
  });

  int? mana;
  String? email;
  String? id;
  @JsonKey(name: 'max_mana')
  int? maxMana;

  factory Mana.fromJson(Map<String, dynamic> json) {
    return _$ManaFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ManaToJson(this);

// static List<Mana> fromJsonList(List<dynamic> jsonList) {
//   return jsonList
//       .map((e) => Mana.fromJson(e as Map<String, dynamic>))
//       .toList();
// }
}
