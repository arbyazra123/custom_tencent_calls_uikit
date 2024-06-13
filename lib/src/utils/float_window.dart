import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:system_alert_window/system_alert_window.dart' as sys;
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

class FloatWindow {
  static void open(BuildContext context) async {
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
            // ignore: use_build_context_synchronously
            TUICallKit.instance.enableFloatWindow(true);
            TUICallKitNavigatorObserver.getInstance().exitCallingPage();
            CallManager.instance.openFloatWindow();
          }
        } else {
          CallManager.instance.showToast(
            CallI10n.current.exitallowpermission,
          );
          TUICallKitNavigatorObserver.getInstance().exitCallingPage();
          TUICallKitNavigatorObserver.isClose = true;
        }
      } else {
        TUICallKit.instance.enableFloatWindow(true);
        TUICallKitNavigatorObserver.getInstance().exitCallingPage();
        CallManager.instance.openFloatWindow();
      }
    } else {
      TUICallKit.instance.enableFloatWindow(true);
      TUICallKitNavigatorObserver.getInstance().exitCallingPage();
      CallManager.instance.openFloatWindow();
    }
  }
}
