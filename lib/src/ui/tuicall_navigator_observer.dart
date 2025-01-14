import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/boot.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_kit_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/inviteuser/invite_user_widget.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

class TUICallKitNavigatorObserver extends NavigatorObserver {
  static final TUICallKitNavigatorObserver _instance =
      TUICallKitNavigatorObserver();
  static bool isClose = true;
  static CallPage currentPage = CallPage.none;
  // CUSTOM
  static Function(CallPage?)? onPageChanged;
  static Function(String userID)?
      onNavigateToChatRoom;
  static Function(
    String userID,
    Function(int code, String status) onMakeCallProgress,
  )? onCallback;
  // CUSTOM

  static TUICallKitNavigatorObserver getInstance({
    Function(CallPage?)? onPageChangedParam,
    Function(String userID)?
        onNavigateToChatRoomParam,
    Function(
      String userID,
      Function(int code, String status) onMakeCallProgress,
    )? onCallbackParam,
    Function(TUIAudioPlaybackDevice output)? onAudioOutputChangedParam,
  }) {
    if (onPageChangedParam != null) {
      onPageChanged = onPageChangedParam;
    }
    if (onNavigateToChatRoomParam != null) {
      onNavigateToChatRoom = onNavigateToChatRoomParam;
    }
    if (onCallbackParam != null) {
      onCallback = onCallbackParam;
    }

    return _instance;
  }

  TUICallKitNavigatorObserver() {
    TRTCLogger.info('TUICallKitNavigatorObserver Init');
    Boot.instance;
  }

  void enterCallingPage() async {
    TRTCLogger.info(
        'TUICallKitNavigatorObserver enterCallingPage：[isClose：$isClose]');
    if (!isClose) {
      return;
    }
    currentPage = CallPage.callingPage;
    onPageChanged?.call(currentPage);
    TUICallKitNavigatorObserver.getInstance()
        .navigator
        ?.push(MaterialPageRoute(builder: (widget) {
      return TUICallKitWidget(close: () async {
        if (!isClose) {
          isClose = true;
          TUICallKitNavigatorObserver.getInstance().exitCallingPage();
          TUICallKitPlatform.instance.stopForegroundService();
          CallingBellFeature.stopRing();
        }
      });
    }));
    isClose = false;
  }

  void exitCallingPage() async {
    TRTCLogger.info(
        'TUICallKitNavigatorObserver exitCallingPage：[currentPage：$currentPage]');
    if (currentPage == CallPage.inviteUserPage) {
      TUICallKitNavigatorObserver.getInstance().navigator?.pop();
      TUICallKitNavigatorObserver.getInstance().navigator?.pop();
    } else if (currentPage == CallPage.callingPage) {
      TUICallKitNavigatorObserver.getInstance().navigator?.pop();
    }
    currentPage = CallPage.none;
    onPageChanged?.call(currentPage);
  }

  void enterInviteUserPage() {
    if (currentPage == CallPage.callingPage) {
      currentPage = CallPage.inviteUserPage;
      onPageChanged?.call(currentPage);
      TUICallKitNavigatorObserver.getInstance()
          .navigator
          ?.push(MaterialPageRoute(builder: (widget) {
        return const InviteUserWidget();
      }));
    }
  }

  void exitInviteUserPage() {
    currentPage = CallPage.callingPage;
    onPageChanged?.call(currentPage);
    TUICallKitNavigatorObserver.getInstance().navigator?.pop();
  }
}

enum CallPage { none, callingPage, inviteUserPage }
