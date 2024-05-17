// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class CallI10n {
  CallI10n();

  static CallI10n? _current;

  static CallI10n get current {
    assert(_current != null,
        'No instance of CallI10n was loaded. Try to initialize the CallI10n delegate before accessing CallI10n.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<CallI10n> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = CallI10n();
      CallI10n._current = instance;

      return instance;
    });
  }

  static CallI10n of(BuildContext context) {
    final instance = CallI10n.maybeOf(context);
    assert(instance != null,
        'No instance of CallI10n present in the widget tree. Did you add CallI10n.delegate in localizationsDelegates?');
    return instance!;
  }

  static CallI10n? maybeOf(BuildContext context) {
    return Localizations.of<CallI10n>(context, CallI10n);
  }

  /// `id`
  String get _locale {
    return Intl.message(
      'id',
      name: '_locale',
      desc: '',
      args: [],
    );
  }

  /// `id`
  String get locale {
    return Intl.message(
      'id',
      name: 'locale',
      desc: '',
      args: [],
    );
  }

  /// `id_ID`
  String get local {
    return Intl.message(
      'id_ID',
      name: 'local',
      desc: '',
      args: [],
    );
  }

  /// `Bahasa`
  String get language {
    return Intl.message(
      'Bahasa',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get languagecode {
    return Intl.message(
      'ID',
      name: 'languagecode',
      desc: '',
      args: [],
    );
  }

  /// `Mikrofon`
  String get microphone {
    return Intl.message(
      'Mikrofon',
      name: 'microphone',
      desc: '',
      args: [],
    );
  }

  /// `Speaker`
  String get speaker {
    return Intl.message(
      'Speaker',
      name: 'speaker',
      desc: '',
      args: [],
    );
  }

  /// `Kamera`
  String get camera {
    return Intl.message(
      'Kamera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Batal`
  String get hangup {
    return Intl.message(
      'Batal',
      name: 'hangup',
      desc: '',
      args: [],
    );
  }

  /// `Angkat`
  String get accept {
    return Intl.message(
      'Angkat',
      name: 'accept',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<CallI10n> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'en'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<CallI10n> load(Locale locale) => CallI10n.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
