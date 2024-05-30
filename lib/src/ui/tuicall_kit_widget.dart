import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:system_alert_window/system_alert_window.dart' as sys;
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
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
        // return false;
        if (Platform.isAndroid) {
          var checkFloatingPermission =
              await sys.SystemAlertWindow.checkPermissions(
            prefMode: sys.SystemWindowPrefMode.OVERLAY,
          );
          if (checkFloatingPermission == false) {
            // ignore: unused_local_variable, use_build_context_synchronously
            var result = await showModalBottomSheet<bool?>(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          CallI10n.current.allowPermissionTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181C21),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Image.asset(
                          "assets/floating_window_permission_tutorial.gif",
                          package: 'tencent_calls_uikit',
                          height: 300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CallI10n.current.allowPermissionDesc,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181C21),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CallI10n.current.allowPermissionStep,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(123, 139, 157, 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: const Color(0xFFFFFFFF),
                                backgroundColor: const Color(0xFFFFE5E9),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                ),
                                elevation: 0,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  // height: 24.0 / titleMedium,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  CallI10n.current.later,
                                  style: const TextStyle(
                                    color: Color(0xFFFF0025),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFFFFF),
                                  backgroundColor: const Color(0xFFFF0025),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                  ),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    // height: 24.0 / titleMedium,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    CallI10n.current.openAppSettings,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
            if (result ?? false) {
              await sys.SystemAlertWindow.requestPermissions(
                  prefMode: sys.SystemWindowPrefMode.OVERLAY);
              var checkFloatingPermission =
                  await sys.SystemAlertWindow.checkPermissions(
                prefMode: sys.SystemWindowPrefMode.OVERLAY,
              );
              if (checkFloatingPermission ?? false) {
                TUICallKit.instance.enableFloatWindow(true);
                CallManager.instance.openFloatWindow();
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              }
            }
          } else {
            TUICallKit.instance.enableFloatWindow(true);
            CallManager.instance.openFloatWindow();
            return true;
          }
          return false;
        } else {
          return true;
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
