class Constants {
  static const String pluginVersion = '2.6.1';
  static const int groupCallMaxUserCount = 9;
  static const int roomIdMaxValue = 2147483647; // 2^31 - 1
  static const String spKeyEnableMuteMode = "enableMuteMode";
  static const String defaultAvatar =
      "https://networkapp.telkomsel.co.id/sapawebapi/auth/images/avatar/Image.jpg";

  static const int blurLevelHigh = 3;
  static const int blurLevelClose = 0;
}

enum NetworkQualityHint {
  none,
  local,
  remote,
}

const setStateEvent = 'SET_STATE_EVENT';
const setStateEventOnCallReceived = 'SET_STATE_EVENT_ONCALLRECEIVED';
const setStateEventOnCallEnd = 'SET_STATE_EVENT_ONCALLEND';
const setStateEventRefreshTiming = 'SET_STATE_EVENT_REFRESH_TIMING';
const setStateEventOnCallBegin = 'SET_STATE_EVENT_CALLBEGIN';
const setStateEventGroupCallUserWidgetRefresh = 'SET_STATE_EVENT_GROUP_CALL_USER_WIDGET_REFRESH';
