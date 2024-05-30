// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(callType) => "The other party rejected the ${callType} call";

  static String m1(callType) =>
      "The other party did not respond the ${callType} call";

  static String m2(amount) => "Invite${amount}";

  static String m3(callType) => "Invite you to a ${callType} call";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "_locale": MessageLookupByLibrary.simpleMessage("en"),
        "accept": MessageLookupByLibrary.simpleMessage("Accept"),
        "allowPermissionDesc": MessageLookupByLibrary.simpleMessage(
            "You can allow the permission by following the steps:"),
        "allowPermissionStep": MessageLookupByLibrary.simpleMessage(
            "Open your phone Settings > Apps > Special app access > Display over other apps > Sapa Beta > Allow display over other apps"),
        "allowPermissionTitle": MessageLookupByLibrary.simpleMessage(
            "Please allow SAPA to Display over other apps, otherwise the call will not be displayed correctly."),
        "busy": MessageLookupByLibrary.simpleMessage("busy"),
        "callDeclined":
            MessageLookupByLibrary.simpleMessage("Call request declined"),
        "callFailedDuetoPermission": MessageLookupByLibrary.simpleMessage(
            "A new call came in, but the call could not be answered due to insufficient permissions. Please confirm that camera/microphone permissions are turned on"),
        "callRejected": m0,
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "connected": MessageLookupByLibrary.simpleMessage("Connected"),
        "didNotRespond": m1,
        "endTheCall": MessageLookupByLibrary.simpleMessage("end the call"),
        "groupCallExceed": MessageLookupByLibrary.simpleMessage(
            "Maximum number of people exceeded"),
        "hangup": MessageLookupByLibrary.simpleMessage("Cancel"),
        "inviteMembers": MessageLookupByLibrary.simpleMessage("Invite Members"),
        "inviteWithAmount": m2,
        "invitedYouToACall": m3,
        "invitedtoGroupCall":
            MessageLookupByLibrary.simpleMessage("Invite you to a group call"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "languagecode": MessageLookupByLibrary.simpleMessage("EN"),
        "later": MessageLookupByLibrary.simpleMessage("Later"),
        "local": MessageLookupByLibrary.simpleMessage("en_US"),
        "locale": MessageLookupByLibrary.simpleMessage("en"),
        "microphone": MessageLookupByLibrary.simpleMessage("Mic"),
        "noRespond": MessageLookupByLibrary.simpleMessage("no respond"),
        "openAppSettings":
            MessageLookupByLibrary.simpleMessage("Open Settings"),
        "opponentHangUpAndCallIsOver": MessageLookupByLibrary.simpleMessage(
            "The other party has hung up and the call is over"),
        "recepientIsBusy":
            MessageLookupByLibrary.simpleMessage("The other party is busy"),
        "speaker": MessageLookupByLibrary.simpleMessage("Speaker"),
        "theyThere":
            MessageLookupByLibrary.simpleMessage("They are also there"),
        "video": MessageLookupByLibrary.simpleMessage("video"),
        "voice": MessageLookupByLibrary.simpleMessage("suara"),
        "waitTheOtherParty": MessageLookupByLibrary.simpleMessage(
            "Wait for the other party to accept the invitation"),
        "you": MessageLookupByLibrary.simpleMessage("You")
      };
}
