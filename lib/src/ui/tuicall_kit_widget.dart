import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/no_respond_call/callback_page.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_call_widget.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/utils/float_window.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:wakelock_for_us/wakelock_for_us.dart';

class TUICallKitWidget extends StatefulWidget {
  final Function close;

  const TUICallKitWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<TUICallKitWidget> createState() => _TUICallKitWidgetState();
}

class _TUICallKitWidgetState extends State<TUICallKitWidget> {
  EventCallback? onCallEndCallBack;

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
        if (CallState.instance.groupId.isEmpty &&
            (arg?.toString().contains("userNoResponse") ?? false)) {
          TUICallKitNavigatorObserver.isClose = true;
          TUICallKitPlatform.instance.stopForegroundService();
          CallingBellFeature.stopRing();
          TUICallKitNavigatorObserver.getInstance().navigator?.pushReplacement(
                MaterialPageRoute(
                  builder: (context) => CallbackPage(
                    userId: arg!.toString().split("|").last,
                  ),
                ),
              );
          TUICallKitNavigatorObserver.currentPage = CallPage.none;
          TUICallKitNavigatorObserver.onPageChanged?.call(CallPage.none);
        } else {
          widget.close();
        }
      }
    };
    eventBus.register(setStateEventOnCallEnd, onCallEndCallBack);
    Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
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
    eventBus.unregister(setStateEventOnCallEnd, onCallEndCallBack);
    Wakelock.disable();
  }
}
