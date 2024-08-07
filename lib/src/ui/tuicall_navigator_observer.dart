import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/ui/widget/inviteuser/invite_user_widget.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_kit_widget.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';

class TUICallKitNavigatorObserver extends NavigatorObserver {
  static final TUICallKitNavigatorObserver _instance =
      TUICallKitNavigatorObserver();
  static bool isClose = true;
  static CallPage currentPage = CallPage.none;
  static Function(CallPage?)? onPageChanged;
  static Function(String userID, V2TimUserFullInfo userInfo)?
      onNavigateToChatRoom;
  static Function(
    String userID,
    V2TimUserFullInfo userInfo,
    Function onCallSucceed,
  )? onCallback;

  static TUICallKitNavigatorObserver getInstance({
    Function(CallPage?)? onPageChangedParam,
    Function(String userID, V2TimUserFullInfo userInfo)?
        onNavigateToChatRoomParam,
    Function(
      String userID,
      V2TimUserFullInfo userInfo,
      Function onCallSucceed,
    )? onCallbackParam,
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
    _bootInit();
  }

  void enterCallingPage() async {
    if (!isClose) {
      return;
    }
    currentPage = CallPage.callingPage;
    onPageChanged?.call(currentPage);
    TUICallKitNavigatorObserver.getInstance()
        .navigator
        ?.push(MaterialPageRoute(builder: (widget) {
      return TUICallKitWidget(
        close: () {
          if (!isClose) {
            isClose = true;
            TUICallKitPlatform.instance.stopForegroundService();
            CallingBellFeature.stopRing();
            TUICallKitNavigatorObserver.getInstance().exitCallingPage();
          }
        },
      );
    }));
    isClose = false;
  }

  void exitCallingPage() async {
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

  static void _bootInit() {
    TUICallKitPlatform.instance;
  }
}

enum CallPage { none, callingPage, inviteUserPage }
