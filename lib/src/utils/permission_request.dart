import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';

class PermissionRequest {
  static String getPermissionRequestTitle(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return CallKit_t("申请麦克风权限");
    } else {
      return CallKit_t("申请麦克风、摄像头权限");
    }
  }

  static String getPermissionRequestDescription(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return CallKit_t("需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。");
    } else {
      return CallKit_t("需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。");
    }
  }

  static String getPermissionRequestSettingsTip(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return "${CallKit_t("申请麦克风权限")}\n${CallKit_t("需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。")}";
    } else {
      return "${CallKit_t("申请麦克风、摄像头权限")}\n${CallKit_t("需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。")}";
    }
  }

  static Future<PermissionStatus> checkCallingPermission(
      TUICallMediaType type) async {
    if (TUICallMediaType.video == type) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();
      var anyProb = statuses.values.firstWhereOrNull((element) {
        if (!element.isGranted) {
          return true;
        }
        return false;
      });
      if (anyProb != null) {
        return PermissionStatus.denied;
      }
      return PermissionStatus.granted;
    } else {
      var anyProb = await Permission.microphone.request();
      if (!anyProb.isGranted) {
        return PermissionStatus.denied;
      }
      return PermissionStatus.granted;
    }
  }
}
