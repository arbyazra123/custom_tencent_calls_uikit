import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/no_respond_call/callback_page.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_call_widget.dart';
import 'package:tencent_calls_uikit/src/utils/float_window.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class TUICallKitWidget extends StatefulWidget {
  final Function close;

  const TUICallKitWidget({Key? key, required this.close}) : super(key: key);

  @override
  State<TUICallKitWidget> createState() => _TUICallKitWidgetState();
}

class _TUICallKitWidgetState extends State<TUICallKitWidget> {
  ITUINotificationCallback? onCallEndCallBack;

  @override
  void initState() {
    super.initState();
    TRTCLogger.info('TUICallKitWidget initState');
    if (CallState.instance.selfUser.callStatus == TUICallStatus.none) {
      Future.microtask(() {
        widget.close();
      });
    }
    onCallEndCallBack = (arg) {
      if (mounted) {
        if (CallState.instance.scene == TUICallScene.singleCall &&
            (arg?.toString().contains("userNoResponse") ?? false)) {
          TUICallKitNavigatorObserver.isClose = true;
          TUICallKitPlatform.instance.stopForegroundService();
          CallingBellFeature.stopRing();
          var userID = arg['arg']?.toString().split("|").last;
          if (userID == null) {
            TUICallKitNavigatorObserver.currentPage = CallPage.none;
            TUICallKitNavigatorObserver.onPageChanged?.call(CallPage.none);
            return;
          }
          TUICallKitNavigatorObserver.getInstance().navigator?.pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                return CallbackPage(
                  userId: userID,
                );
              },
            ),
          );
          TUICallKitNavigatorObserver.currentPage = CallPage.none;
          TUICallKitNavigatorObserver.onPageChanged?.call(CallPage.none);
        } else {
          widget.close();
        }
      }
    };
    TUICore.instance.registerEvent(setStateEventOnCallEnd, onCallEndCallBack);
  }

  @override
  Widget build(BuildContext context) {
    CallKitI18nUtils.setLanguage(Localizations.localeOf(context));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return PopScope(
      canPop: false,
      onPopInvoked: (value) async {
        if (value == false) {
          FloatWindow.open(context);
        }
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: (CallState.instance.scene == TUICallScene.singleCall)
              ? SingleCallWidget(
                  close: widget.close,
                )
              : GroupCallWidget(
                  close: widget.close,
                )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    TRTCLogger.info('TUICallKitWidget dispose');
    TUICore.instance.unregisterEvent(setStateEventOnCallEnd, onCallEndCallBack);
    CallManager.instance.enableWakeLock(false);
  }
}
