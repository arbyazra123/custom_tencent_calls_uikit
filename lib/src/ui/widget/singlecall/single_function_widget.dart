import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/extent_button.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/utils/permission_request.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class SingleFunctionWidget {
  static Widget buildFunctionWidget(
      Function close, Widget? videoCallerAndCalleAcceptedView) {
    if (TUICallStatus.waiting == CallState.instance.selfUser.callStatus) {
      if (TUICallRole.caller == CallState.instance.selfUser.callRole) {
        if (TUICallMediaType.audio == CallState.instance.mediaType) {
          return _buildAudioCallerWaitingAndAcceptedView(close);
        } else {
          return _buildVideoCallerWaitingView(close);
        }
      } else {
        return _buildAudioAndVideoCalleeWaitingView(close);
      }
    } else if (TUICallStatus.accept == CallState.instance.selfUser.callStatus) {
      if (TUICallMediaType.audio == CallState.instance.mediaType) {
        return _buildAudioCallerWaitingAndAcceptedView(close);
      } else {
        if (videoCallerAndCalleAcceptedView != null) {
          return videoCallerAndCalleAcceptedView;
        }
        return _buildVideoCallerAndCalleeAcceptedView(close);
      }
    } else {
      return Container();
    }
  }

  static Widget _buildAudioCallerWaitingAndAcceptedView(Function close) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ExtendButton(
          imgUrl: CallState.instance.isMicrophoneMute
              ? "assets/images/mute_on.png"
              : "assets/images/mute.png",
          tips:
              CallState.instance.isMicrophoneMute ? CallI10n.current.microphone : CallI10n.current.microphone,
          textColor: _getTextColor(),
          imgHeight: 60,
          onTap: () {
            handleSwitchMic();
          },
        ),
        ExtendButton(
          imgUrl: "assets/images/hangup.png",
          tips: CallI10n.current.hangup,
          textColor: _getTextColor(),
          imgHeight: 60,
          onTap: () {
            handleHangUp(close);
          },
        ),
        ExtendButton(
          imgUrl: CallState.instance.audioDevice ==
                  TUIAudioPlaybackDevice.speakerphone
              ? "assets/images/handsfree_on.png"
              : "assets/images/handsfree.png",
          tips: CallState.instance.audioDevice ==
                  TUIAudioPlaybackDevice.speakerphone
              ? CallI10n.current.speaker
              : CallI10n.current.speaker,
          imgHeight: 60,
          textColor: _getTextColor(),
          onTap: () {
            handleSwitchAudioDevice();
          },
        ),
      ],
    );
  }

  static Widget _buildVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const SizedBox(
            width: 100,
          ),
          ExtendButton(
            imgUrl: "assets/images/hangup.png",
            tips: CallI10n.current.hangup,
            textColor: _getTextColor(),
            imgHeight: 60,
            onTap: () {
              handleHangUp(close);
            },
          ),
          ExtendButton(
            imgUrl: "assets/images/switch_camera.png",
            tips: CallKit_t(" "),
            textColor: _getTextColor(),
            imgHeight: 28,
            onTap: () {
              handleSwitchCamera();
            },
          ),
        ]),
      ],
    );
  }

  static Widget _buildVideoCallerAndCalleeAcceptedView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: CallState.instance.isMicrophoneMute
                  ? "assets/images/mute_on.png"
                  : "assets/images/mute.png",
              tips: CallState.instance.isMicrophoneMute
                  ? CallI10n.current.microphone
                  : CallI10n.current.microphone,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                handleSwitchMic();
              },
            ),
            ExtendButton(
              imgUrl: CallState.instance.audioDevice ==
                      TUIAudioPlaybackDevice.speakerphone
                  ? "assets/images/handsfree_on.png"
                  : "assets/images/handsfree.png",
              tips: CallState.instance.audioDevice ==
                      TUIAudioPlaybackDevice.speakerphone
                  ? CallI10n.current.speaker
                  : CallI10n.current.speaker,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                handleSwitchAudioDevice();
              },
            ),
            ExtendButton(
              imgUrl: CallState.instance.isCameraOpen
                  ? "assets/images/camera_on.png"
                  : "assets/images/camera_off.png",
              tips: CallState.instance.isCameraOpen
                  ? CallI10n.current.camera
                  : CallI10n.current.camera,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                handleOpenCloseCamera();
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const SizedBox(
            width: 100,
          ),
          ExtendButton(
            imgUrl: "assets/images/hangup.png",
            tips: '',
            textColor: _getTextColor(),
            imgHeight: 60,
            onTap: () {
              handleHangUp(close);
            },
          ),
          ExtendButton(
            imgUrl: "assets/images/switch_camera.png",
            tips: CallKit_t(" "),
            textColor: _getTextColor(),
            imgHeight: 28,
            onTap: () {
              handleSwitchCamera();
            },
          ),
        ]),
      ],
    );
  }

  static Widget _buildAudioAndVideoCalleeWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: "assets/images/hangup.png",
              tips: CallI10n.current.hangup,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                handleReject(close);
              },
            ),
            ExtendButton(
              imgUrl: "assets/images/dialing.png",
              tips: CallI10n.current.accept,
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                handleAccept();
              },
            ),
          ],
        )
      ],
    );
  }

  static handleSwitchMic() async {
    if (CallState.instance.isMicrophoneMute) {
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    } else {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();
    }
    eventBus.notify(setStateEvent);
  }

  static handleSwitchAudioDevice() async {
    if (CallState.instance.audioDevice == TUIAudioPlaybackDevice.earpiece) {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.speakerphone;
    } else {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
    }
    await CallManager.instance
        .selectAudioPlaybackDevice(CallState.instance.audioDevice);
    eventBus.notify(setStateEvent);
  }

  static handleHangUp(Function close) async {
    await CallManager.instance.hangup();
    close();
  }

  static handleReject(Function close) async {
    await CallManager.instance.reject();
    close();
  }

  static handleAccept() async {
    PermissionStatus permissionRequestResult =
        PermissionStatus.denied;
    if (Platform.isAndroid) {
      permissionRequestResult = await PermissionRequest.checkCallingPermission(
          CallState.instance.mediaType);
    }
    if (permissionRequestResult == PermissionStatus.granted ||
        Platform.isIOS) {
      await CallManager.instance.accept();
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    } else {
      CallManager.instance
          .showToast(CallI10n.current.callFailedDuetoPermission);
    }
    eventBus.notify(setStateEvent);
  }

  static handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance.openCamera(
          CallState.instance.camera, CallState.instance.selfUser.viewID);
    } else {
      await CallManager.instance.closeCamera();
    }
    eventBus.notify(setStateEvent);
  }

  static handleSwitchCamera() async {
    if (TUICamera.front == CallState.instance.camera) {
      CallState.instance.camera = TUICamera.back;
    } else {
      CallState.instance.camera = TUICamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    eventBus.notify(setStateEvent);
  }

  static Color _getTextColor() {
    return Colors.white;
  }
}
