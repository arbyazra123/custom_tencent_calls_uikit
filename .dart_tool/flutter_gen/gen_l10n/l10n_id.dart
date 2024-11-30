import 'l10n.dart';

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get locale => 'id';

  @override
  String get local => 'id_ID';

  @override
  String get language => 'Bahasa';

  @override
  String get languagecode => 'ID';

  @override
  String get microphone => 'Mikrofon';

  @override
  String get speaker => 'Speaker';

  @override
  String get camera => 'Kamera';

  @override
  String get hangup => 'Batal';

  @override
  String get accept => 'Angkat';

  @override
  String get callDeclined => 'Panggilan ditolak';

  @override
  String get callRejected => 'Lawan bicara menolak panggilan';

  @override
  String get voice => 'suara';

  @override
  String get video => 'video';

  @override
  String get didNotRespond => 'Lawan bicara tidak menjawab panggilan';

  @override
  String get noRespond => 'tidak ada respon';

  @override
  String get recepientIsBusy => 'Lawan bicara sedang sibuk';

  @override
  String get busy => 'sibuk';

  @override
  String get opponentHangUpAndCallIsOver => 'Lawan bicara telah menutup telepon dan panggilan selesai';

  @override
  String get endTheCall => 'mengakhiri panggilan';

  @override
  String get groupCallExceed => 'Jumlah maksimal group call terlampaui';

  @override
  String get callFailedDuetoPermission => 'Panggilan baru masuk, tetapi panggilan tersebut tidak dapat dijawab karena izin tidak memadai. Harap konfirmasi bahwa izin kamera/mikrofon telah diaktifkan';

  @override
  String get invitedtoGroupCall => 'Mengundang Anda ke panggilan grup';

  @override
  String get theyThere => 'Anggota yang diundang';

  @override
  String get inviteMembers => 'Undang Anggota';

  @override
  String inviteWithAmount(Object amount) {
    return 'Undang$amount';
  }

  @override
  String get you => 'Anda';

  @override
  String get waitTheOtherParty => 'Tunggu hingga lawan bicara menerima panggilan';

  @override
  String invitedYouToACall(Object callType) {
    return 'Mengundang Anda ke panggilan $callType';
  }

  @override
  String get connected => 'Terhubung';

  @override
  String get allowPermissionTitle => 'Harap izinkan SAPA untuk berjalan di atas aplikasi lain ketika melakukan panggilan. Jika tidak, halaman panggilan tidak akan ditampilkan dengan benar.';

  @override
  String get allowPermissionDesc => 'Anda dapat memberi izin melakukan dgn langkah-langkah:';

  @override
  String get allowPermissionStep => 'Buka Pengaturan ponsel Anda > Aplikasi > Akses aplikasi khusus > Tampilkan di aplikasi lain > Sapa Beta > Izinkan tampilan di aplikasi lain';

  @override
  String get later => 'Lain kali';

  @override
  String get openAppSettings => 'Buka Pengaturan';

  @override
  String get exitallowpermission => 'Anda dapat Izinkan SAPA untuk Ditampilkan di atas aplikasi lain atau mengakhiri panggilan untuk keluar';

  @override
  String get cancel => 'Batal';

  @override
  String get chat => 'Pesan';

  @override
  String get callback => 'Panggil\nKembail';

  @override
  String get didnAnswer => 'Tidak ada jawaban';

  @override
  String get otherPartyNetworkLowQuality => 'Koneksi lawan bicara bermasalah';
}
