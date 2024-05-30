import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_call_widget.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:wakelock_for_us/wakelock_for_us.dart';

class TUICallKitWidget extends StatefulWidget {
  final Function close;

  const TUICallKitWidget({Key? key, required this.close}) : super(key: key);

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
        widget.close();
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

    return WillPopScope(
      onWillPop: () async {
        return false;
        // if (Platform.isAndroid) {
        //   var checkFloatingPermission =
        //       await SystemAlertWindow.checkPermissions(
        //     prefMode: SystemWindowPrefMode.OVERLAY,
        //   );
        //   if (checkFloatingPermission == false) {
        //     // ignore: unused_local_variable
        //     var result = await showModalBottomSheet<bool?>(
        //       context: context,
        //       builder: (context) {
        //         return Container(
        //           child: Text(
        //             "Please allow SAPA to Display over other apps, otherwise the call will not be displayed correctly.",
        //           ),
        //         );
        //       },
        //     );
        //     SystemAlertWindow.requestPermissions(
        //         prefMode: SystemWindowPrefMode.OVERLAY);
        //   } else {
        //     TUICallKit.instance.enableFloatWindow(true);
        //     CallManager.instance.openFloatWindow();
        //     return true;
        //   }
        //   debugPrint("checkFloatingPermission: $checkFloatingPermission");
        //   return true;
        // } else {
        //   return true;
        // }
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
