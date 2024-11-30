import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/extent_button.dart';
import 'package:tencent_calls_uikit/src/utils/permission.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class SingleFunctionWidget {
  static Widget buildFunctionWidget(
      Function close, Widget? videoCallerAndCalleAcceptedView) {
    if (TUICallStatus.waiting == CallState.instance.selfUser.callStatus) {
      if (TUICallRole.caller == CallState.instance.selfUser.callRole) {
        if (TUICallMediaType.audio == CallState.instance.mediaType) {
          return _buildAudioCallerWaitingAndAcceptedView(close);
        } else {
          if (CallState.instance.showVirtualBackgroundButton) {
            return _buildVBgVideoCallerWaitingView(close);
          } else {
            return _buildVideoCallerWaitingView(close);
          }
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
        _buildMicControlButton(),
        _buildHangupButton(close),
        buildSpeakerphoneButton(),
      ],
    );
  }

  static Widget _buildVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _buildSwitchCameraButton(),
          _buildHangupButton(close),
          buildCameraControlButton(),
        ]),
      ],
    );
  }

  static Widget _buildVBgVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSwitchCameraButton(),
            _buildVirtualBackgroundButton(),
            buildCameraControlButton(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              width: 100,
            ),
            _buildHangupButton(close),
            const SizedBox(
              width: 100,
            ),
          ],
        ),
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
                handleSwitchMic();
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
              tips: CallKit_t("hangUp"),
              textColor: _getTextColor(),
              imgHeight: 60,
              onTap: () {
                handleReject(close);
              },
            ),
            ExtendButton(
              imgUrl: "assets/images/dialing.png",
              tips: CallKit_t("accept"),
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
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static handleSwitchAudioDevice() async {
    if (CallState.instance.audioDevice == TUIAudioPlaybackDevice.earpiece) {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.speakerphone;
    } else {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
    }
    await CallManager.instance
        .selectAudioPlaybackDevice(CallState.instance.audioDevice);
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static Widget buildSpeakerphoneButton() {
    return ExtendButton(
      imgUrl:
          CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
              ? "assets/images/handsfree_on.png"
              : "assets/images/handsfree.png",
      tips:
          CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
              ? CallI10n.current.speaker
              : CallI10n.current.speaker,
      imgHeight: 60,
      textColor: _getTextColor(),
      onTap: () {
        handleSwitchAudioDevice();
      },
    );
  }

  static Widget buildCameraControlButton() {
    return ExtendButton(
      imgUrl: CallState.instance.isCameraOpen
          ? "assets/images/camera_on.png"
          : "assets/images/camera_off.png",
      tips: CallState.instance.isCameraOpen
          ? CallKit_t("cameraIsOn")
          : CallKit_t("cameraIsOff"),
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        handleOpenCloseCamera();
      },
    );
  }

  static Widget _buildMicControlButton() {
    return ExtendButton(
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
    );
  }

  static Widget _buildHangupButton(Function close) {
    return ExtendButton(
      imgUrl: "assets/images/hangup.png",
      tips: CallI10n.current.hangup,
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        handleHangUp(close);
      },
    );
  }

  static Widget _buildSwitchCameraSmallButton() {
    return ExtendButton(
      imgUrl: "assets/images/switch_camera.png",
      tips: '',
      textColor: _getTextColor(),
      imgHeight: 28,
      imgOffsetX: -16,
      onTap: () {
        handleSwitchCamera();
      },
    );
  }

  static Widget _buildVirtualBackgroundSmallButton() {
    return ExtendButton(
      imgUrl: "assets/images/blur_background_accept.png",
      tips: '',
      textColor: _getTextColor(),
      imgHeight: 28,
      imgOffsetX: 16,
      onTap: () {
        handleOpenBlurBackground();
      },
    );
  }

  static Widget _buildVirtualBackgroundButton() {
    return ExtendButton(
      imgUrl: CallState.instance.enableBlurBackground
          ? "assets/images/blur_background_waiting_enable.png"
          : "assets/images/blur_background_waiting_disable.png",
      tips: CallKit_t("blurBackground"),
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        handleOpenBlurBackground();
      },
    );
  }

  static Widget _buildSwitchCameraButton() {
    return ExtendButton(
      imgUrl: "assets/images/switch_camera_group.png",
      tips: CallKit_t("switchCamera"),
      textColor: _getTextColor(),
      imgHeight: 60,
      onTap: () {
        handleSwitchCamera();
      },
    );
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
    PermissionResult permissionRequestResult = PermissionResult.requesting;
    if (Platform.isAndroid) {
      permissionRequestResult =
          await Permission.request(CallState.instance.mediaType);
    }
    if (permissionRequestResult == PermissionResult.granted || Platform.isIOS) {
      await CallManager.instance.accept();
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    } else {
      CallManager.instance
          .showToast(CallI10n.current.callFailedDuetoPermission);
    }
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static void handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance.openCamera(
          CallState.instance.camera, CallState.instance.selfUser.viewID);
    } else {
      await CallManager.instance.closeCamera();
    }
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static void handleOpenBlurBackground() async {
    CallState.instance.enableBlurBackground =
        !CallState.instance.enableBlurBackground;
    await CallManager.instance
        .setBlurBackground(CallState.instance.enableBlurBackground);
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static void handleSwitchCamera() async {
    if (TUICamera.front == CallState.instance.camera) {
      CallState.instance.camera = TUICamera.back;
    } else {
      CallState.instance.camera = TUICamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    TUICore.instance.notifyEvent(setStateEvent);
  }

  static Color _getTextColor() {
    return Colors.white;
  }
}
