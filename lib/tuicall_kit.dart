import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart' as intl;
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/utils/permission_request.dart';
import 'package:tencent_calls_uikit/src/utils/tuicall_localization_delegate.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class TUICallKit {
  static final TUICallKit _instance = TUICallKit();

  static TUICallKit get instance => _instance;
  static Function(
    TUIAudioPlaybackDevice output,
    String customRoomId,
  )? onAudioOutputChanged;

  static TUICallKitNavigatorObserver navigatorObserver({
    Function(CallPage?)? onPageChanged,
    Function(String userID, V2TimUserFullInfo userInfo)?
        onNavigateToChatRoomParam,
    Function(
      String userID,
      V2TimUserFullInfo userInfo,
      Function onCallSucceed,
    )? onCallbackParam,
  }) =>
      TUICallKitNavigatorObserver.getInstance(
        onPageChangedParam: onPageChanged,
        onCallbackParam: onCallbackParam,
        onNavigateToChatRoomParam: onNavigateToChatRoomParam,
      );

  static Future<bool> isAppInForeground() async {
    return await TUICallKitPlatform.instance.isAppInForeground();
  }

  static Future<void> setAudioOutputCallback(
    Function(
      TUIAudioPlaybackDevice output,
      String customRoomId,
    ) onAudioOutputChangedParam,
  ) async {
    onAudioOutputChanged = onAudioOutputChangedParam;
  }

  static Future<void> setCustomRoomId(
    String? customRoomId,
  ) async {
    CallState.instance.customRoomId = customRoomId ?? "";
  }

  static void setCallbackPageFunctions({
    Function(String userID, V2TimUserFullInfo userInfo)?
        onNavigateToChatRoomParam,
    Function(String userID, V2TimUserFullInfo userInfo, Function onCallSucceed)?
        onCallbackParam,
  }) {
    if (onNavigateToChatRoomParam != null) {
      TUICallKitNavigatorObserver.onNavigateToChatRoom =
          onNavigateToChatRoomParam;
    }
    if (onCallbackParam != null) {
      TUICallKitNavigatorObserver.onCallback = onCallbackParam;
    }
  }

  static TUICallLocalizationDelegate get getTUICallLocalization =>
      intl.CallI10n.delegate.getTUICallLocalization;
  static Future<intl.CallI10n> load(Locale locale) =>
      intl.CallI10n.load(locale);

  static syncrhonizeStartTime(int startTime) {
    CallState.instance.startTime = startTime ~/ 1000;
    CallState.instance.clientStartTime = startTime;
    TUICore.instance.notifyEvent(setStateEventRefreshTiming);
    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  void setOnInviteListener(
    Function(
      List<String> userIds,
      Map<String, String> data,
    ) onAfterInviteSuccess,
  ) {
    CallManager.instance.onAfterInviteSuccess = onAfterInviteSuccess;
  }

  CallPage get getCallCurrentPage => TUICallKitNavigatorObserver.currentPage;
  CallState get callState => CallState.instance;
  TUICallKitPlatform get tuiCallPlatform => TUICallKitPlatform.instance;

  Future<void> startRing() async => await CallingBellFeature.startRing();
  Future<void> stopRing() async => await CallingBellFeature.stopRing();
  Future<void> closeFloatingWindow() async =>
      await CallManager.instance.closeFloatWindow();

  static startTimer() {
    CallState.instance.startTimer();
  }

  static stopTimer() {
    CallState.instance.stopTimer();
  }

  Future<PermissionStatus> askPermission() async {
    var permissionResult = await PermissionRequest.checkCallingPermission(
        CallState.instance.mediaType);
    if (CallState.instance.scene != TUICallScene.singleCall) {
      permissionResult = await PermissionRequest.checkCallingPermission(
        TUICallMediaType.video,
      );
    }
    return permissionResult;
  }

  /// login TUICallKit
  ///
  /// @param sdkAppId      sdkAppId
  /// @param userId        userId
  /// @param userSig       userSig
  Future<TUIResult> login(int sdkAppId, String userId, String userSig) async {
    return await CallManager.instance.login(sdkAppId, userId, userSig);
  }

  /// logout TUICallKit
  ///
  Future<void> logout() async {
    return await CallManager.instance.logout();
  }

  /// Set user profile
  ///
  /// @param nickname User name, which can contain up to 500 bytes
  /// @param avatar   User profile photo URL, which can contain up to 500 bytes
  ///                 For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
  /// @param callback Set the result callback
  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    return await CallManager.instance.setSelfInfo(nickname, avatar);
  }

  /// Make a call
  ///
  /// @param userId        callees
  /// @param callMediaType Call type
  Future<TUIResult> call(String userId, TUICallMediaType callMediaType,
      [TUICallParams? params]) async {
    return await CallManager.instance.call(userId, callMediaType, params);
  }

  ///Make a group call
  ///
  ///@param groupId       GroupId
  ///@param userIdList    List of userId
  ///@param callMediaType Call type
  Future<TUIResult> groupCall(
      String groupId, List<String> userIdList, TUICallMediaType callMediaType,
      [TUICallParams? params]) async {
    return await CallManager.instance
        .groupCall(groupId, userIdList, callMediaType, params);
  }

  ///Join a current call
  ///
  ///@param roomId        current call room ID
  ///@param callMediaType call type
  Future<TUIResult> joinInGroupCall(
      TUIRoomId roomId, String groupId, TUICallMediaType callMediaType) async {
    return await CallManager.instance
        .joinInGroupCall(roomId, groupId, callMediaType);
  }

  /// Set the ringtone (preferably shorter than 30s)
  ///
  /// First introduce the ringtone resource into the project
  /// Then set the resource as a ringtone
  ///
  /// @param filePath Callee ringtone path
  Future<void> setCallingBell(String assetName) async {
    return await CallManager.instance.setCallingBell(assetName);
  }

  ///Enable the mute mode (the callee doesn't ring)
  Future<void> enableMuteMode(bool enable) async {
    return await CallManager.instance.enableMuteMode(enable);
  }

  ///Enable the floating window
  Future<void> enableFloatWindow(bool enable) async {
    return await CallManager.instance.enableFloatWindow(enable);
  }

  Future<void> enableVirtualBackground(bool enable) async {
    return await CallManager.instance.enableVirtualBackground(enable);
  }

  void enableIncomingBanner(bool enable) {
    CallManager.instance.enableIncomingBanner(enable);
  }
}
