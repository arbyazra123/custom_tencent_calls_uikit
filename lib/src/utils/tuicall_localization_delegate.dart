
import 'package:flutter/material.dart';
import 'package:multiple_localization/multiple_localization.dart';
import 'package:tencent_calls_uikit/src/I10n/intl/messages_all.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';

class TUICallLocalizationDelegate extends LocalizationsDelegate<CallI10n> {
  const TUICallLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<CallI10n> load(Locale locale) {
    return MultipleLocalizations.load(
      initializeMessages,
      locale,
      (locale) => CallI10n.load(Locale(locale)),
      setDefaultLocale: true,
    );
  }

  @override
  bool shouldReload(TUICallLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}


extension AppLocalizationDelegateExt on AppLocalizationDelegate {
  TUICallLocalizationDelegate get getTUICallLocalization =>
      const TUICallLocalizationDelegate();
}

