// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a id locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'id';

  static String m0(amount) => "Undang${amount}";

  static String m1(callType) => "Mengundang Anda ke panggilan ${callType}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_locale": MessageLookupByLibrary.simpleMessage("id"),
        "accept": MessageLookupByLibrary.simpleMessage("Angkat"),
        "allowPermissionDesc": MessageLookupByLibrary.simpleMessage(
            "Anda dapat memberi izin melakukan dgn langkah-langkah:"),
        "allowPermissionStep": MessageLookupByLibrary.simpleMessage(
            "Buka Pengaturan ponsel Anda > Aplikasi > Akses aplikasi khusus > Tampilkan di aplikasi lain > Sapa Beta > Izinkan tampilan di aplikasi lain"),
        "allowPermissionTitle": MessageLookupByLibrary.simpleMessage(
            "Harap izinkan SAPA untuk berjalan di atas aplikasi lain ketika melakukan panggilan. Jika tidak, halaman panggilan tidak akan ditampilkan dengan benar."),
        "busy": MessageLookupByLibrary.simpleMessage("sibuk"),
        "callDeclined":
            MessageLookupByLibrary.simpleMessage("Panggilan ditolak"),
        "callFailedDuetoPermission": MessageLookupByLibrary.simpleMessage(
            "Panggilan baru masuk, tetapi panggilan tersebut tidak dapat dijawab karena izin tidak memadai. Harap konfirmasi bahwa izin kamera/mikrofon telah diaktifkan"),
        "callRejected": MessageLookupByLibrary.simpleMessage(
            "Lawan bicara menolak panggilan"),
        "callback": MessageLookupByLibrary.simpleMessage("Panggil\nKembail"),
        "camera": MessageLookupByLibrary.simpleMessage("Kamera"),
        "cancel": MessageLookupByLibrary.simpleMessage("Batal"),
        "chat": MessageLookupByLibrary.simpleMessage("Pesan"),
        "connected": MessageLookupByLibrary.simpleMessage("Terhubung"),
        "didNotRespond": MessageLookupByLibrary.simpleMessage(
            "Lawan bicara tidak menjawab panggilan"),
        "didnAnswer": MessageLookupByLibrary.simpleMessage("Tidak ada jawaban"),
        "endTheCall":
            MessageLookupByLibrary.simpleMessage("mengakhiri panggilan"),
        "exitallowpermission": MessageLookupByLibrary.simpleMessage(
            "Anda dapat Izinkan SAPA untuk Ditampilkan di atas aplikasi lain atau mengakhiri panggilan untuk keluar"),
        "groupCallExceed": MessageLookupByLibrary.simpleMessage(
            "Jumlah maksimal group call terlampaui"),
        "hangup": MessageLookupByLibrary.simpleMessage("Batal"),
        "inviteMembers": MessageLookupByLibrary.simpleMessage("Undang Anggota"),
        "inviteWithAmount": m0,
        "invitedYouToACall": m1,
        "invitedtoGroupCall": MessageLookupByLibrary.simpleMessage(
            "Mengundang Anda ke panggilan grup"),
        "language": MessageLookupByLibrary.simpleMessage("Bahasa"),
        "languagecode": MessageLookupByLibrary.simpleMessage("ID"),
        "later": MessageLookupByLibrary.simpleMessage("Lain kali"),
        "local": MessageLookupByLibrary.simpleMessage("id_ID"),
        "locale": MessageLookupByLibrary.simpleMessage("id"),
        "microphone": MessageLookupByLibrary.simpleMessage("Mikrofon"),
        "noRespond": MessageLookupByLibrary.simpleMessage("tidak ada respon"),
        "openAppSettings":
            MessageLookupByLibrary.simpleMessage("Buka Pengaturan"),
        "opponentHangUpAndCallIsOver": MessageLookupByLibrary.simpleMessage(
            "Lawan bicara telah menutup telepon dan panggilan selesai"),
        "otherPartyNetworkLowQuality":
            MessageLookupByLibrary.simpleMessage("Koneksi lawan bicara lambat"),
        "recepientIsBusy":
            MessageLookupByLibrary.simpleMessage("Lawan bicara sedang sibuk"),
        "selfNetworkLowQuality":
            MessageLookupByLibrary.simpleMessage("Koneksi lambat"),
        "speaker": MessageLookupByLibrary.simpleMessage("Speaker"),
        "theyThere":
            MessageLookupByLibrary.simpleMessage("Anggota yang diundang"),
        "video": MessageLookupByLibrary.simpleMessage("video"),
        "voice": MessageLookupByLibrary.simpleMessage("suara"),
        "waitTheOtherParty": MessageLookupByLibrary.simpleMessage(
            "Tunggu hingga lawan bicara menerima panggilan"),
        "you": MessageLookupByLibrary.simpleMessage("Anda")
      };
}
