import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_id.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// No description provided for @locale.
  ///
  /// In id, this message translates to:
  /// **'id'**
  String get locale;

  /// No description provided for @local.
  ///
  /// In id, this message translates to:
  /// **'id_ID'**
  String get local;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @languagecode.
  ///
  /// In id, this message translates to:
  /// **'ID'**
  String get languagecode;

  /// No description provided for @microphone.
  ///
  /// In id, this message translates to:
  /// **'Mikrofon'**
  String get microphone;

  /// No description provided for @speaker.
  ///
  /// In id, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @camera.
  ///
  /// In id, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @hangup.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get hangup;

  /// No description provided for @accept.
  ///
  /// In id, this message translates to:
  /// **'Angkat'**
  String get accept;

  /// No description provided for @callDeclined.
  ///
  /// In id, this message translates to:
  /// **'Panggilan ditolak'**
  String get callDeclined;

  /// No description provided for @callRejected.
  ///
  /// In id, this message translates to:
  /// **'Lawan bicara menolak panggilan'**
  String get callRejected;

  /// No description provided for @voice.
  ///
  /// In id, this message translates to:
  /// **'suara'**
  String get voice;

  /// No description provided for @video.
  ///
  /// In id, this message translates to:
  /// **'video'**
  String get video;

  /// No description provided for @didNotRespond.
  ///
  /// In id, this message translates to:
  /// **'Lawan bicara tidak menjawab panggilan'**
  String get didNotRespond;

  /// No description provided for @noRespond.
  ///
  /// In id, this message translates to:
  /// **'tidak ada respon'**
  String get noRespond;

  /// No description provided for @recepientIsBusy.
  ///
  /// In id, this message translates to:
  /// **'Lawan bicara sedang sibuk'**
  String get recepientIsBusy;

  /// No description provided for @busy.
  ///
  /// In id, this message translates to:
  /// **'sibuk'**
  String get busy;

  /// No description provided for @opponentHangUpAndCallIsOver.
  ///
  /// In id, this message translates to:
  /// **'Lawan bicara telah menutup telepon dan panggilan selesai'**
  String get opponentHangUpAndCallIsOver;

  /// No description provided for @endTheCall.
  ///
  /// In id, this message translates to:
  /// **'mengakhiri panggilan'**
  String get endTheCall;

  /// No description provided for @groupCallExceed.
  ///
  /// In id, this message translates to:
  /// **'Jumlah maksimal group call terlampaui'**
  String get groupCallExceed;

  /// No description provided for @callFailedDuetoPermission.
  ///
  /// In id, this message translates to:
  /// **'Panggilan baru masuk, tetapi panggilan tersebut tidak dapat dijawab karena izin tidak memadai. Harap konfirmasi bahwa izin kamera/mikrofon telah diaktifkan'**
  String get callFailedDuetoPermission;

  /// No description provided for @invitedtoGroupCall.
  ///
  /// In id, this message translates to:
  /// **'Mengundang Anda ke panggilan grup'**
  String get invitedtoGroupCall;

  /// No description provided for @theyThere.
  ///
  /// In id, this message translates to:
  /// **'Anggota yang diundang'**
  String get theyThere;

  /// No description provided for @inviteMembers.
  ///
  /// In id, this message translates to:
  /// **'Undang Anggota'**
  String get inviteMembers;

  /// No description provided for @inviteWithAmount.
  ///
  /// In id, this message translates to:
  /// **'Undang{amount}'**
  String inviteWithAmount(Object amount);

  /// No description provided for @you.
  ///
  /// In id, this message translates to:
  /// **'Anda'**
  String get you;

  /// No description provided for @waitTheOtherParty.
  ///
  /// In id, this message translates to:
  /// **'Tunggu hingga lawan bicara menerima panggilan'**
  String get waitTheOtherParty;

  /// No description provided for @invitedYouToACall.
  ///
  /// In id, this message translates to:
  /// **'Mengundang Anda ke panggilan {callType}'**
  String invitedYouToACall(Object callType);

  /// No description provided for @connected.
  ///
  /// In id, this message translates to:
  /// **'Terhubung'**
  String get connected;

  /// No description provided for @allowPermissionTitle.
  ///
  /// In id, this message translates to:
  /// **'Harap izinkan SAPA untuk berjalan di atas aplikasi lain ketika melakukan panggilan. Jika tidak, halaman panggilan tidak akan ditampilkan dengan benar.'**
  String get allowPermissionTitle;

  /// No description provided for @allowPermissionDesc.
  ///
  /// In id, this message translates to:
  /// **'Anda dapat memberi izin melakukan dgn langkah-langkah:'**
  String get allowPermissionDesc;

  /// No description provided for @allowPermissionStep.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan ponsel Anda > Aplikasi > Akses aplikasi khusus > Tampilkan di aplikasi lain > Sapa Beta > Izinkan tampilan di aplikasi lain'**
  String get allowPermissionStep;

  /// No description provided for @later.
  ///
  /// In id, this message translates to:
  /// **'Lain kali'**
  String get later;

  /// No description provided for @openAppSettings.
  ///
  /// In id, this message translates to:
  /// **'Buka Pengaturan'**
  String get openAppSettings;

  /// No description provided for @exitallowpermission.
  ///
  /// In id, this message translates to:
  /// **'Anda dapat Izinkan SAPA untuk Ditampilkan di atas aplikasi lain atau mengakhiri panggilan untuk keluar'**
  String get exitallowpermission;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @chat.
  ///
  /// In id, this message translates to:
  /// **'Pesan'**
  String get chat;

  /// No description provided for @callback.
  ///
  /// In id, this message translates to:
  /// **'Panggil\nKembail'**
  String get callback;

  /// No description provided for @didnAnswer.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada jawaban'**
  String get didnAnswer;

  /// No description provided for @otherPartyNetworkLowQuality.
  ///
  /// In id, this message translates to:
  /// **'Koneksi lawan bicara bermasalah'**
  String get otherPartyNetworkLowQuality;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'id': return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
