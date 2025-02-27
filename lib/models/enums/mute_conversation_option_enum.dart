import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum MuteConversationOption {
  oneHour(typeU),
  fourHours(typeU),
  eightHours(typeU),
  oneDay(typeU),
  forever(typeP);

  final String type;

  static const String typeU = 'U';
  static const String typeP = 'P';

  const MuteConversationOption(this.type);
}

extension MuteConversationOptionExtension on MuteConversationOption {
  String labelName(AppLocalizations l10n) {
    switch (this) {
      case MuteConversationOption.oneHour:
        return l10n.conversation__mute_for_hour(1);
      case MuteConversationOption.fourHours:
        return l10n.conversation__mute_for_hours(4);
      case MuteConversationOption.eightHours:
        return l10n.conversation__mute_for_hours(8);
      case MuteConversationOption.oneDay:
        return l10n.conversation__mute_for_day(1);
      case MuteConversationOption.forever:
        return l10n.conversation__mute_for_forever;
    }
  }
  Duration get duration {
    switch (this) {
      case MuteConversationOption.oneHour:
        return const Duration(hours: 1);
      case MuteConversationOption.fourHours:
        return const Duration(hours: 4);
      case MuteConversationOption.eightHours:
        return const Duration(hours: 8);
      case MuteConversationOption.oneDay:
        return const Duration(days: 1);
      case MuteConversationOption.forever:
        return const Duration(days: 365 * 100);
    }
  }
}
