import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/utils/permission.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class MethodChannelTUICallKit extends TUICallKitPlatform {
  MethodChannelTUICallKit() {
    methodChannel.setMethodCallHandler((call) async {
      _handleNativeCall(call);
    });
  }

  @visibleForTesting
  final methodChannel = const MethodChannel('tuicall_kit');

  @override
  Future<void> startForegroundService() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('startForegroundService', {});
    }
  }

  @override
  Future<void> stopForegroundService() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopForegroundService', {});
    }
  }

  @override
  Future<void> startRing(String filePath) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('startRing', {"filePath": filePath});
    }
  }

  @override
  Future<void> stopRing() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopRing', {});
    }
  }

  @override
  Future<String> moveAppToFront(String event) async {
    try {
      var result =
          await methodChannel.invokeMethod('moveAppToFront', {"event": event});
      return result.toString();
    } on PlatformException catch (e) {
      return "failed_${e.toString()}";
    } on Exception catch (e) {
      return "failed_${e.toString()}";
    }
  }

  @override
  Future<void> updateCallStateToNative() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      List remoteUserList = [];
      for (var element in CallState.instance.remoteUserList.entries) {
        remoteUserList.add(element.value.toJson());
      }

      methodChannel.invokeMethod('updateCallStateToNative', {
        'selfUser': CallState.instance.selfUser.toJson(),
        'remoteUserList': remoteUserList.isNotEmpty ? remoteUserList : [],
        'scene': CallState.instance.scene.index,
        'mediaType': CallState.instance.mediaType.index,
        'startTime': CallState.instance.startTime,
        'camera': CallState.instance.camera.index,
        'isCameraOpen': CallState.instance.isCameraOpen,
        'isMicrophoneMute': CallState.instance.isMicrophoneMute,
      });
    }
  }

  @override
  Future<void> startFloatWindow() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('startFloatWindow', {});
    }
  }

  @override
  Future<void> switchAudioState(bool isUsingSpeaker) async {
    if (!kIsWeb && (Platform.isAndroid)) {
      await methodChannel.invokeMethod('switchAudioState', {
        "isUsingSpeaker": isUsingSpeaker,
      });
    }
  }

  @override
  Future<void> stopFloatWindow() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('stopFloatWindow', {});
    }
  }

  @override
  Future<bool> hasFloatPermission() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return await methodChannel.invokeMethod('hasFloatPermission', {});
    } else {
      return false;
    }
  }

  @override
  Future<bool> isAppInForeground() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return await methodChannel.invokeMethod('isAppInForeground', {});
    } else {
      return false;
    }
  }

  @override
  Future<bool> showIncomingBanner() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod('showIncomingBanner', {});
      } else {
        return false;
      }
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  @override
  Future<bool> initResources(Map resources) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel
            .invokeMethod('initResources', {"resources": resources});
      } else {
        return false;
      }
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  @override
  Future<void> openMicrophone() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('openMicrophone', {});
    }
  }

  @override
  Future<void> closeMicrophone() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('closeMicrophone', {});
    }
  }

  @override
  Future<void> apiLog(TRTCLoggerLevel level, String logString) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod(
          'apiLog', {'level': level.index, 'logString': logString});
    }
  }

  @override
  Future<bool> hasPermissions(
      {required List<PermissionType> permissions}) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      List<int> permissionsList = [];
      for (var element in permissions) {
        permissionsList.add(element.index);
      }
      return await methodChannel
          .invokeMethod('hasPermissions', {'permission': permissionsList});
    } else {
      return false;
    }
  }

  @override
  Future<PermissionResult> requestPermissions(
      {required List<PermissionType> permissions,
      String title = "",
      String description = "",
      String settingsTip = ""}) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        List<int> permissionsList = [];
        for (var element in permissions) {
          permissionsList.add(element.index);
        }
        int result = await methodChannel.invokeMethod('requestPermissions', {
          'permission': permissionsList,
          'title': title,
          'description': description,
          'settingsTip': settingsTip
        });
        if (result == PermissionResult.granted.index) {
          return PermissionResult.granted;
        } else if (result == PermissionResult.denied.index) {
          return PermissionResult.denied;
        } else {
          return PermissionResult.requesting;
        }
      } else {
        return PermissionResult.denied;
      }
    } on PlatformException catch (_) {
      return PermissionResult.denied;
    } on Exception catch (_) {
      return PermissionResult.denied;
    }
  }

  @override
  Future<void> pullBackgroundApp() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('pullBackgroundApp', {});
    }
  }

  @override
  Future<void> openLockScreenApp() async {
    if (!kIsWeb && Platform.isAndroid) {
      await methodChannel.invokeMethod('openLockScreenApp', {});
    }
  }

  @override
  Future<void> enableWakeLock(bool enable) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('enableWakeLock', {'enable': enable});
    }
  }

  @override
  Future<bool> isScreenLocked() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      return await methodChannel.invokeMethod('isScreenLocked', {});
    }
    return false;
  }

  @override
  Future<void> imSDKInitSuccessEvent() async {
    if (!kIsWeb && Platform.isAndroid) {
      TRTCLogger.info('imSDKInitSuccessEvent USBCameraService');
      await methodChannel.invokeMethod('imSDKInitSuccessEvent', {});
    }
  }

  @override
  Future<void> loginSuccessEvent() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('loginSuccessEvent', {});
    }
  }

  @override
  Future<void> logoutSuccessEvent() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod('logoutSuccessEvent', {});
    }
  }

  @override
  Future<bool> checkUsbCameraService() async {
    if (!kIsWeb && Platform.isAndroid) {
      return await methodChannel.invokeMethod('checkUsbCameraService', {});
    }
    return false;
  }

  @override
  Future<void> openUsbCamera(int viewId) async {
    if (!kIsWeb && Platform.isAndroid) {
      await methodChannel.invokeMethod('openUsbCamera', {'viewId': viewId});
    }
  }

  @override
  Future<void> closeUsbCamera() async {
    if (!kIsWeb && Platform.isAndroid) {
      await methodChannel.invokeMethod('closeUsbCamera', {});
    }
  }

  @override
  Future<bool> isSamsungDevice() async {
    if (!kIsWeb && Platform.isAndroid) {
      return await methodChannel.invokeMethod('isSamsungDevice', {});
    }
    return false;
  }

  void _handleNativeCall(MethodCall call) {
    debugPrint(
        "CallHandler method:${call.method}, arguments:${call.arguments}");
    switch (call.method) {
      case "backCallingPageFromFloatWindow":
        _backCallingPageFromFloatWindow();
        break;
      case "launchCallingPageFromIncomingBanner":
        _launchCallingPageFromIncomingBanner();
        break;
      case "appEnterForeground":
        _appEnterForeground();
        break;
      case "voipChangeMute":
        _handleVoipChangeMute(call);
        break;
      case "voipChangeAudioPlaybackDevice":
        _handleVoipChangeAudioPlaybackDevice(call);
        break;
      case "voipChangeHangup":
        _handleVoipHangup();
        break;
      case "voipChangeAccept":
        _handleVoipAccept();
        break;
      default:
        debugPrint("flutter: MethodNotImplemented ${call.method}");
        break;
    }
  }

  void _backCallingPageFromFloatWindow() {
    CallManager.instance.backCallingPageFormFloatWindow();
  }

  void _launchCallingPageFromIncomingBanner() {
    CallState.instance.isInNativeIncomingBanner = false;
    if (CallState.instance.selfUser.callStatus != TUICallStatus.none) {
      CallManager.instance.launchCallingPage();
    }
  }

  void _appEnterForeground() {
    CallManager.instance.handleAppEnterForeground();
  }

  void _handleVoipChangeMute(MethodCall call) {
    if (CallState.instance.selfUser.callStatus != TUICallStatus.none) {
      bool mute = call.arguments['mute'];
      CallState.instance.isMicrophoneMute = mute;
      mute
          ? CallManager.instance.closeMicrophone()
          : CallManager.instance.openMicrophone();
      TUICore.instance.notifyEvent(setStateEvent);
    }
  }

  void _handleVoipChangeAudioPlaybackDevice(MethodCall call) {
    if (CallState.instance.selfUser.callStatus != TUICallStatus.none) {
      CallState.instance.audioDevice = call.arguments['audioPlaybackDevice'];
      CallManager.instance
          .selectAudioPlaybackDevice(CallState.instance.audioDevice);
      TUICore.instance.notifyEvent(setStateEvent);
    }
  }

  void _handleVoipHangup() {
    if (CallState.instance.selfUser.callStatus == TUICallStatus.waiting) {
      CallManager.instance.reject();
    } else if (CallState.instance.selfUser.callStatus == TUICallStatus.accept) {
      CallManager.instance.hangup();
    }
  }

  void _handleVoipAccept() {
    if (CallState.instance.selfUser.callStatus == TUICallStatus.waiting) {
      CallManager.instance.accept();
    }
  }
}
