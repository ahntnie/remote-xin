import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

enum ManaMissionTypeEnum {
  daily,
  achievement,
}

extension ManaMissionTypeEnumExtension on ManaMissionTypeEnum {
  String get name {
    final AppLocalizations l10n = AppLocalizations.of(Get.context!)!;
    switch (this) {
      case ManaMissionTypeEnum.daily:
        return l10n.mana_mission__daily;
      case ManaMissionTypeEnum.achievement:
        return l10n.mana_mission__achievement;
      default:
        return '';
    }
  }
}
