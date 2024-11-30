import 'l10n.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get locale => 'en';

  @override
  String get local => 'en_US';

  @override
  String get language => 'Language';

  @override
  String get languagecode => 'EN';

  @override
  String get microphone => 'Mic';

  @override
  String get speaker => 'Speaker';

  @override
  String get camera => 'Camera';

  @override
  String get hangup => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get callDeclined => 'Call request declined';

  @override
  String get callRejected => 'The other party rejected the call';

  @override
  String get voice => 'voice';

  @override
  String get video => 'video';

  @override
  String get didNotRespond => 'The other party did not respond the call';

  @override
  String get noRespond => 'no respond';

  @override
  String get recepientIsBusy => 'The other party is busy';

  @override
  String get busy => 'busy';

  @override
  String get opponentHangUpAndCallIsOver => 'The other party has hung up and the call is over';

  @override
  String get endTheCall => 'end the call';

  @override
  String get groupCallExceed => 'Maximum number of people exceeded';

  @override
  String get callFailedDuetoPermission => 'A new call came in, but the call could not be answered due to insufficient permissions. Please confirm that camera/microphone permissions are turned on';

  @override
  String get invitedtoGroupCall => 'Invite you to a group call';

  @override
  String get theyThere => 'Invited members';

  @override
  String get inviteMembers => 'Invite Members';

  @override
  String inviteWithAmount(Object amount) {
    return 'Invite$amount';
  }

  @override
  String get you => 'You';

  @override
  String get waitTheOtherParty => 'Wait for the other party to accept the invitation';

  @override
  String invitedYouToACall(Object callType) {
    return 'Invite you to a $callType call';
  }

  @override
  String get connected => 'Connected';

  @override
  String get allowPermissionTitle => 'Please allow SAPA to Display over other apps, otherwise the call will not be displayed correctly.';

  @override
  String get allowPermissionDesc => 'You can allow the permission by following the steps:';

  @override
  String get allowPermissionStep => 'Open your phone Settings > Apps > Special app access > Display over other apps > Sapa Beta > Allow display over other apps';

  @override
  String get later => 'Later';

  @override
  String get openAppSettings => 'Open Settings';

  @override
  String get exitallowpermission => 'You can either Allow SAPA to Display over other apps or end the call to exit';

  @override
  String get cancel => 'Cancel';

  @override
  String get chat => 'Chat';

  @override
  String get callback => 'Call again';

  @override
  String get didnAnswer => 'No answer';

  @override
  String get otherPartyNetworkLowQuality => 'Other party has low network quality';
}
