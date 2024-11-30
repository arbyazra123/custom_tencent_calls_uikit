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

  /// `Panggilan ditolak`
  String get callDeclined {
    return Intl.message(
      'Panggilan ditolak',
      name: 'callDeclined',
      desc: '',
      args: [],
    );
  }

  /// `Lawan bicara menolak panggilan`
  String get callRejected {
    return Intl.message(
      'Lawan bicara menolak panggilan',
      name: 'callRejected',
      desc: '',
      args: [],
    );
  }

  /// `suara`
  String get voice {
    return Intl.message(
      'suara',
      name: 'voice',
      desc: '',
      args: [],
    );
  }

  /// `video`
  String get video {
    return Intl.message(
      'video',
      name: 'video',
      desc: '',
      args: [],
    );
  }

  /// `Lawan bicara tidak menjawab panggilan`
  String get didNotRespond {
    return Intl.message(
      'Lawan bicara tidak menjawab panggilan',
      name: 'didNotRespond',
      desc: '',
      args: [],
    );
  }

  /// `tidak ada respon`
  String get noRespond {
    return Intl.message(
      'tidak ada respon',
      name: 'noRespond',
      desc: '',
      args: [],
    );
  }

  /// `Lawan bicara sedang sibuk`
  String get recepientIsBusy {
    return Intl.message(
      'Lawan bicara sedang sibuk',
      name: 'recepientIsBusy',
      desc: '',
      args: [],
    );
  }

  /// `sibuk`
  String get busy {
    return Intl.message(
      'sibuk',
      name: 'busy',
      desc: '',
      args: [],
    );
  }

  /// `Lawan bicara telah menutup telepon dan panggilan selesai`
  String get opponentHangUpAndCallIsOver {
    return Intl.message(
      'Lawan bicara telah menutup telepon dan panggilan selesai',
      name: 'opponentHangUpAndCallIsOver',
      desc: '',
      args: [],
    );
  }

  /// `mengakhiri panggilan`
  String get endTheCall {
    return Intl.message(
      'mengakhiri panggilan',
      name: 'endTheCall',
      desc: '',
      args: [],
    );
  }

  /// `Jumlah maksimal group call terlampaui`
  String get groupCallExceed {
    return Intl.message(
      'Jumlah maksimal group call terlampaui',
      name: 'groupCallExceed',
      desc: '',
      args: [],
    );
  }

  /// `Panggilan baru masuk, tetapi panggilan tersebut tidak dapat dijawab karena izin tidak memadai. Harap konfirmasi bahwa izin kamera/mikrofon telah diaktifkan`
  String get callFailedDuetoPermission {
    return Intl.message(
      'Panggilan baru masuk, tetapi panggilan tersebut tidak dapat dijawab karena izin tidak memadai. Harap konfirmasi bahwa izin kamera/mikrofon telah diaktifkan',
      name: 'callFailedDuetoPermission',
      desc: '',
      args: [],
    );
  }

  /// `Mengundang Anda ke panggilan grup`
  String get invitedtoGroupCall {
    return Intl.message(
      'Mengundang Anda ke panggilan grup',
      name: 'invitedtoGroupCall',
      desc: '',
      args: [],
    );
  }

  /// `Anggota yang diundang`
  String get theyThere {
    return Intl.message(
      'Anggota yang diundang',
      name: 'theyThere',
      desc: '',
      args: [],
    );
  }

  /// `Undang Anggota`
  String get inviteMembers {
    return Intl.message(
      'Undang Anggota',
      name: 'inviteMembers',
      desc: '',
      args: [],
    );
  }

  /// `Undang{amount}`
  String inviteWithAmount(Object amount) {
    return Intl.message(
      'Undang$amount',
      name: 'inviteWithAmount',
      desc: '',
      args: [amount],
    );
  }

  /// `Anda`
  String get you {
    return Intl.message(
      'Anda',
      name: 'you',
      desc: '',
      args: [],
    );
  }

  /// `Tunggu hingga lawan bicara menerima panggilan`
  String get waitTheOtherParty {
    return Intl.message(
      'Tunggu hingga lawan bicara menerima panggilan',
      name: 'waitTheOtherParty',
      desc: '',
      args: [],
    );
  }

  /// `Mengundang Anda ke panggilan {callType}`
  String invitedYouToACall(Object callType) {
    return Intl.message(
      'Mengundang Anda ke panggilan $callType',
      name: 'invitedYouToACall',
      desc: '',
      args: [callType],
    );
  }

  /// `Terhubung`
  String get connected {
    return Intl.message(
      'Terhubung',
      name: 'connected',
      desc: '',
      args: [],
    );
  }

  /// `Harap izinkan SAPA untuk berjalan di atas aplikasi lain ketika melakukan panggilan. Jika tidak, halaman panggilan tidak akan ditampilkan dengan benar.`
  String get allowPermissionTitle {
    return Intl.message(
      'Harap izinkan SAPA untuk berjalan di atas aplikasi lain ketika melakukan panggilan. Jika tidak, halaman panggilan tidak akan ditampilkan dengan benar.',
      name: 'allowPermissionTitle',
      desc: '',
      args: [],
    );
  }

  /// `Anda dapat memberi izin melakukan dgn langkah-langkah:`
  String get allowPermissionDesc {
    return Intl.message(
      'Anda dapat memberi izin melakukan dgn langkah-langkah:',
      name: 'allowPermissionDesc',
      desc: '',
      args: [],
    );
  }

  /// `Buka Pengaturan ponsel Anda > Aplikasi > Akses aplikasi khusus > Tampilkan di aplikasi lain > Sapa Beta > Izinkan tampilan di aplikasi lain`
  String get allowPermissionStep {
    return Intl.message(
      'Buka Pengaturan ponsel Anda > Aplikasi > Akses aplikasi khusus > Tampilkan di aplikasi lain > Sapa Beta > Izinkan tampilan di aplikasi lain',
      name: 'allowPermissionStep',
      desc: '',
      args: [],
    );
  }

  /// `Lain kali`
  String get later {
    return Intl.message(
      'Lain kali',
      name: 'later',
      desc: '',
      args: [],
    );
  }

  /// `Buka Pengaturan`
  String get openAppSettings {
    return Intl.message(
      'Buka Pengaturan',
      name: 'openAppSettings',
      desc: '',
      args: [],
    );
  }

  /// `Anda dapat Izinkan SAPA untuk Ditampilkan di atas aplikasi lain atau mengakhiri panggilan untuk keluar`
  String get exitallowpermission {
    return Intl.message(
      'Anda dapat Izinkan SAPA untuk Ditampilkan di atas aplikasi lain atau mengakhiri panggilan untuk keluar',
      name: 'exitallowpermission',
      desc: '',
      args: [],
    );
  }

  /// `Batal`
  String get cancel {
    return Intl.message(
      'Batal',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Pesan`
  String get chat {
    return Intl.message(
      'Pesan',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Panggil\nKembail`
  String get callback {
    return Intl.message(
      'Panggil\nKembail',
      name: 'callback',
      desc: '',
      args: [],
    );
  }

  /// `Tidak ada jawaban`
  String get didnAnswer {
    return Intl.message(
      'Tidak ada jawaban',
      name: 'didnAnswer',
      desc: '',
      args: [],
    );
  }

  /// `Koneksi lawan bicara lambat`
  String get otherPartyNetworkLowQuality {
    return Intl.message(
      'Koneksi lawan bicara lambat',
      name: 'otherPartyNetworkLowQuality',
      desc: '',
      args: [],
    );
  }

  /// `Koneksi lambat`
  String get selfNetworkLowQuality {
    return Intl.message(
      'Koneksi lambat',
      name: 'selfNetworkLowQuality',
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
