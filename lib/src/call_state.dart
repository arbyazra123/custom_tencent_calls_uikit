import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/utils/preference_utils.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class CallState {
  static final CallState instance = CallState._internal();

  factory CallState() {
    return instance;
  }

  CallState._internal() {
    init();
  }

  User selfUser = User();
  User caller = User();
  Map<String, User> calleeList = {};
  Map<String, User> remoteUserList = {};
  List<String> calleeIdList = [];
  TUICallScene scene = TUICallScene.singleCall;
  TUICallMediaType mediaType = TUICallMediaType.none;
  int timeCount = 0;
  int startTime = 0;
  int? clientStartTime;
  late Timer _timer;
  TUIRoomId roomId = TUIRoomId.intRoomId(intRoomId: 0);
  String customRoomId = '';
  String groupId = '';
  bool isCameraOpen = false;
  TUICamera camera = TUICamera.front;
  bool isMicrophoneMute = false;
  TUIAudioPlaybackDevice audioDevice = TUIAudioPlaybackDevice.earpiece;
  bool enableMuteMode = false;
  bool enableFloatWindow = false;
  bool showVirtualBackgroundButton = false;
  bool enableBlurBackground = false;
  NetworkQualityHint networkQualityReminder = NetworkQualityHint.none;

  bool isChangedBigSmallVideo = false;
  bool isOpenFloatWindow = false;
  bool enableIncomingBanner = false;
  bool isInNativeIncomingBanner = false;
  String moveAppToFrontStatus = '';

  final TUICallObserver observer = TUICallObserver(onError:
      (int code, String message) {
    TRTCLogger.info('TUICallObserver onError(code:$code, message:$message)');
    CallManager.instance.showToast('Error: $code, $message');
  }, onCallReceived: (String callerId, List<String> calleeIdList,
      String groupId, TUICallMediaType callMediaType, String? userData) async {
    TRTCLogger.info(
        'TUICallObserver onCallReceived(callerId:$callerId, calleeIdList:$calleeIdList, groupId:$groupId, callMediaType:$callMediaType, userData:$userData), version:${Constants.pluginVersion}');
    await CallState.instance
        .handleCallReceivedData(callerId, calleeIdList, groupId, callMediaType);
    await TUICallKitPlatform.instance.updateCallStateToNative();
    await CallManager.instance.enableWakeLock(true);

    if (!await TUICallKitPlatform.instance.isAppInForeground()) {
      if (Platform.isAndroid) {
        var result = await TUICallKitPlatform.instance
            .moveAppToFront("event_handle_receive_call");
        debugPrint(
            "TUICallKitPlatform.instance.moveAppToFront.result: $result");
        switch (result) {
          case 'success_start_call':
            break;
          case 'success_launching_intent':
            break;
          case 'success_float_window':
            break;
          case 'success_showing_notification':
            break;
          case 'failed_no_permissions':
            break;
          case 'failed_caller_null':
            break;
          case 'failed_event_not_match':
            break;
          default:
        }
        CallState.instance.moveAppToFrontStatus = result;
      } else {
        CallManager.instance.launchCallingPage();
      }
    } else {
      CallManager.instance.launchCallingPage();
    }
  }, onCallCancelled: (String callerId) {
    TRTCLogger.info('TUICallObserver onCallCancelled(callerId:$callerId)');
    CallingBellFeature.stopRing();
    if (CallState.instance.mediaType == TUICallMediaType.video &&
        CallState.instance.isCameraOpen) {
      CallManager.instance.closeCamera();
    }
    CallState.instance.cleanState();
    TUICore.instance.notifyEvent(setStateEventOnCallEnd);
    TUICallKitPlatform.instance.updateCallStateToNative();
    CallManager.instance.enableWakeLock(false);
  }, onCallBegin:
      (TUIRoomId roomId, TUICallMediaType callMediaType, TUICallRole callRole) {
    TRTCLogger.info(
        'TUICallObserver onCallBegin(roomId:$roomId, callMediaType:$callMediaType, callRole:$callRole)');
    TUICallKitPlatform.instance.startForegroundService();
    CallState.instance.startTime =
        DateTime.now().millisecondsSinceEpoch ~/ 1000;
    CallingBellFeature.stopRing();
    CallState.instance.roomId = roomId;
    CallState.instance.mediaType = callMediaType;
    CallState.instance.selfUser.callRole = callRole;
    CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    if (CallState.instance.isMicrophoneMute) {
      CallManager.instance.closeMicrophone();
    } else {
      CallManager.instance.openMicrophone();
    }
    if (Platform.isIOS) {
      TUICallKit.instance.enableFloatWindow(true);
    }
    if (CallState.instance.groupId.isEmpty) {
      CallManager.instance
          .selectAudioPlaybackDevice(TUIAudioPlaybackDevice.earpiece);
    } else {
      CallManager.instance
          .selectAudioPlaybackDevice(CallState.instance.audioDevice);
    }
    CallState.instance.startTimer();
    CallState.instance.isChangedBigSmallVideo = true;
    TUICore.instance.notifyEvent(setStateEvent);
    TUICore.instance.notifyEvent(setStateEventOnCallBegin);
    TUICallKitPlatform.instance.updateCallStateToNative();
  }, onCallEnd: (TUIRoomId roomId, TUICallMediaType callMediaType,
      TUICallRole callRole, double totalTime) {
    TRTCLogger.info(
        'TUICallObserver onCallEnd(roomId:$roomId, callMediaType:$callMediaType, callRole:$callRole, totalTime:$totalTime)');
    CallState.instance.stopTimer();
    if (CallState.instance.mediaType == TUICallMediaType.video &&
        CallState.instance.isCameraOpen) {
      CallManager.instance.closeCamera();
    }
    CallState.instance.cleanState();
    TUICore.instance.notifyEvent(setStateEventOnCallEnd);
    TUICallKitPlatform.instance.updateCallStateToNative();
    CallManager.instance.enableWakeLock(false);
  }, onCallMediaTypeChanged:
      (TUICallMediaType oldCallMediaType, TUICallMediaType newCallMediaType) {
    CallState.instance.mediaType = newCallMediaType;
    TUICore.instance.notifyEvent(setStateEvent);
    TUICallKitPlatform.instance.updateCallStateToNative();
  }, onUserReject: (String userId) {
    TRTCLogger.info('TUICallObserver onUserReject(userId:$userId)');
    if (CallState.instance.remoteUserList.containsKey(userId)) {
      CallState.instance.remoteUserList.remove(userId);
      TUICore.instance.notifyEvent(setStateEvent);
    }

    if (CallState.instance.remoteUserList.isEmpty) {
      CallingBellFeature.stopRing();
      CallState.instance.cleanState();
      TUICore.instance.notifyEvent(setStateEventOnCallEnd);
    }

    TUICallKitPlatform.instance.updateCallStateToNative();
    if (TUICallScene.singleCall == CallState.instance.scene) {
      CallManager.instance.showToast(
        CallI10n.current.callRejected,
      );
    } else {
      CallManager.instance
          .showToast('$userId ${CallI10n.current.callDeclined}');
    }
  }, onUserNoResponse: (String userId) {
    TRTCLogger.info('TUICallObserver onUserNoResponse(userId:$userId)');
    if (CallState.instance.remoteUserList.containsKey(userId)) {
      CallState.instance.remoteUserList.remove(userId);
      TUICore.instance.notifyEvent(setStateEvent);
    }

    if (CallState.instance.remoteUserList.isEmpty) {
      CallingBellFeature.stopRing();
      CallState.instance.cleanState();
      TUICore.instance.notifyEvent(setStateEventOnCallEnd, {
        "arg": "userNoResponse|$userId",
      });
    }

    TUICallKitPlatform.instance.updateCallStateToNative();
    if (TUICallScene.singleCall == CallState.instance.scene) {
      CallManager.instance.showToast(
        CallI10n.current.didNotRespond,
      );
    }
  }, onUserLineBusy: (String userId) {
    TRTCLogger.info('TUICallObserver onUserLineBusy(userId:$userId)');
    if (CallState.instance.remoteUserList.containsKey(userId)) {
      CallState.instance.remoteUserList.remove(userId);
      TUICore.instance.notifyEvent(setStateEvent);
    }

    if (CallState.instance.remoteUserList.isEmpty) {
      CallingBellFeature.stopRing();
      CallState.instance.cleanState();

      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        TUICore.instance.notifyEvent(setStateEventOnCallEnd);
        timer.cancel();
      });
    }

    TUICallKitPlatform.instance.updateCallStateToNative();

    if (TUICallScene.singleCall == CallState.instance.scene) {
      CallManager.instance.showToast(
        CallI10n.current.didNotRespond,
      );
    } else {
      CallManager.instance.showToast('$userId ${CallI10n.current.noRespond}');
    }
  }, onUserJoin: (String userId) async {
    TRTCLogger.info('TUICallObserver onUserJoin(userId:$userId)');
    if (CallState.instance.remoteUserList.containsKey(userId)) {
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
      CallState.instance.remoteUserList[userId]?.callStatus =
          TUICallStatus.accept;
      TUICore.instance.notifyEvent(setStateEvent);

      TUICallKitPlatform.instance.updateCallStateToNative();
      return;
    }

    CallingBellFeature.stopRing();

    final user = User();
    user.id = userId;
    user.callStatus == TUICallStatus.accept;
    final imInfo = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .getFriendsInfo(userIDList: [userId]);
    user.nickname = StringStream.makeNull(
        imInfo.data?[0].friendInfo?.userProfile?.nickName, '');
    user.remark =
        StringStream.makeNull(imInfo.data?[0].friendInfo?.friendRemark, '');
    user.avatar = StringStream.makeNull(
        imInfo.data?[0].friendInfo?.userProfile?.faceUrl,
        Constants.defaultAvatar);
    CallState.instance.remoteUserList.addAll({user.id: user});
    TUICore.instance.notifyEvent(setStateEvent);

    TUICallKitPlatform.instance.updateCallStateToNative();
  }, onUserLeave: (String userId) {
    TRTCLogger.info('TUICallObserver onUserLeave(userId:$userId)');
    if (CallState.instance.remoteUserList.containsKey(userId)) {
      CallState.instance.remoteUserList.remove(userId);
      TUICore.instance.notifyEvent(setStateEvent);
    }

    if (CallState.instance.remoteUserList.isEmpty) {
      CallState.instance.cleanState();
      TUICore.instance.notifyEvent(setStateEventOnCallEnd);
    }

    TUICallKitPlatform.instance.updateCallStateToNative();

    if (TUICallScene.singleCall == CallState.instance.scene) {
      CallManager.instance
          .showToast(CallI10n.current.opponentHangUpAndCallIsOver);
    } else {
      CallManager.instance.showToast('$userId ${CallI10n.current.endTheCall}');
    }
  }, onUserVideoAvailable: (String userId, bool isVideoAvailable) {
    TRTCLogger.info(
        'TUICallObserver onUserVideoAvailable(userId:$userId, isVideoAvailable:$isVideoAvailable)');
    if (CallState.instance.remoteUserList.containsKey(userId)) {
      CallState.instance.remoteUserList[userId]?.videoAvailable =
          isVideoAvailable;
      TUICore.instance.notifyEvent(setStateEvent);

      TUICallKitPlatform.instance.updateCallStateToNative();
      return;
    }
  }, onUserAudioAvailable: (String userId, bool isAudioAvailable) {
    TRTCLogger.info(
        'TUICallObserver onUserAudioAvailable(userId:$userId, isVideoAvailable:$isAudioAvailable)');
    if (CallState.instance.remoteUserList.containsKey(userId)) {
      CallState.instance.remoteUserList[userId]?.audioAvailable =
          isAudioAvailable;
      TUICore.instance.notifyEvent(setStateEvent);

      TUICallKitPlatform.instance.updateCallStateToNative();
      return;
    }
  }, onUserNetworkQualityChanged:
      (List<TUINetworkQualityInfo> networkQualityList) {
    if (networkQualityList.isEmpty) {
      return;
    }
    if (TUICallScene.groupCall == CallState.instance.scene) {
      for (var networkQualityInfo in networkQualityList) {
        if (networkQualityInfo.userId == CallState.instance.selfUser.id) {
          CallState.instance.selfUser.networkQualityReminder =
              CallState.instance.isBadNetwork(networkQualityInfo.quality);
          continue;
        }
        if (CallState.instance.remoteUserList
            .containsKey(networkQualityInfo.userId)) {
          CallState.instance.remoteUserList[networkQualityInfo.userId]
                  ?.networkQualityReminder =
              CallState.instance.isBadNetwork(networkQualityInfo.quality);
        }
      }
    } else if (TUICallScene.singleCall == CallState.instance.scene) {
      TUINetworkQuality localQuality = TUINetworkQuality.unknown;
      TUINetworkQuality remoteQuality = TUINetworkQuality.unknown;

      for (var networkQualityInfo in networkQualityList) {
        if (CallState.instance.selfUser.id == networkQualityInfo.userId) {
          localQuality = networkQualityInfo.quality;
        } else {
          remoteQuality = networkQualityInfo.quality;
        }
      }

      if (CallState.instance.isBadNetwork(localQuality)) {
        CallState.instance.networkQualityReminder = NetworkQualityHint.local;
      } else if (CallState.instance.isBadNetwork(remoteQuality)) {
        CallState.instance.networkQualityReminder = NetworkQualityHint.remote;
      } else {
        CallState.instance.networkQualityReminder = NetworkQualityHint.none;
      }
    }
    TUICore.instance.notifyEvent(setStateEvent);
  }, onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {
    bool needUpdate2Native = false;
    for (var element in volumeMap.entries) {
      CallState.instance.remoteUserList[element.key]?.playOutVolume =
          element.value;
      var volume =
          (CallState.instance.remoteUserList[element.key]?.playOutVolume ?? 0);
      if (volume != 0) {
        CallState.instance.remoteUserList[element.key]?.audioAvailable = true;
        if (volume > 10) {
          needUpdate2Native = true;
        }
      }
    }

    var selfVolume = volumeMap[CallState.instance.selfUser.id] ?? 0;
    CallState.instance.selfUser.playOutVolume = selfVolume;
    if (selfVolume > 10) {
      needUpdate2Native = true;
    }

    if (needUpdate2Native) {
      TUICallKitPlatform.instance.updateCallStateToNative();
      TUICore.instance.notifyEvent(setStateEvent);
    }
  }, onKickedOffline: () {
    TRTCLogger.info('TUICallObserver onKickedOffline()');
    CallManager.instance.hangup();
    CallingBellFeature.stopRing();
    CallState.instance.cleanState();
    TUICore.instance.notifyEvent(setStateEvent);
    TUICallKitPlatform.instance.updateCallStateToNative();
  }, onUserSigExpired: () {
    TRTCLogger.info('TUICallObserver onUserSigExpired()');
    CallManager.instance.hangup();
    CallingBellFeature.stopRing();
    CallState.instance.cleanState();
    TUICore.instance.notifyEvent(setStateEvent);
    TUICallKitPlatform.instance.updateCallStateToNative();
  });

  void init() {
    PreferenceUtils.getInstance()
        .getBool(Constants.spKeyEnableMuteMode, false)
        .then((value) => {enableMuteMode = value});
  }

  Future<void> registerEngineObserver() async {
    TRTCLogger.info('CallState registerEngineObserver');
    await TUICallEngine.instance.addObserver(observer);
  }

  void unRegisterEngineObserver() {
    TUICallEngine.instance.removeObserver(observer);
  }

  Future<void> handleCallReceivedData(
      String callerId,
      List<String> calleeIdList,
      String groupId,
      TUICallMediaType callMediaType) async {
    CallState.instance.caller.id = callerId;
    CallState.instance.calleeIdList.clear();
    CallState.instance.calleeIdList.addAll(calleeIdList);
    CallState.instance.groupId = groupId;
    CallState.instance.mediaType = callMediaType;
    CallState.instance.selfUser.callStatus = TUICallStatus.waiting;

    if (callMediaType == TUICallMediaType.none || calleeIdList.isEmpty) {
      return;
    }

    if (calleeIdList.length >= Constants.groupCallMaxUserCount) {
      CallManager.instance.showToast(CallI10n.current.groupCallExceed);
      return;
    }

    CallState.instance.groupId = groupId;
    if (CallState.instance.groupId.isNotEmpty) {
      CallState.instance.scene = TUICallScene.groupCall;
    } else if (calleeIdList.length > 1) {
      CallState.instance.scene = TUICallScene.multiCall;
    } else {
      CallState.instance.scene = TUICallScene.singleCall;
    }
    CallState.instance.mediaType = callMediaType;

    CallState.instance.selfUser.callRole = TUICallRole.called;

    final allUserId = [callerId] + calleeIdList;

    for (var userId in allUserId) {
      if (CallState.instance.selfUser.id == userId) {
        if (userId == callerId) {
          CallState.instance.caller = CallState.instance.selfUser;
        } else {
          CallState.instance.calleeList.addAll(
              {CallState.instance.selfUser.id: CallState.instance.selfUser});
        }
        continue;
      }

      final user = User();
      user.id = userId;

      if (userId == callerId) {
        CallState.instance.caller = user;
      } else {
        CallState.instance.calleeList.addAll({user.id: user});
      }
    }

    final imFriendsUserInfos = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .getFriendsInfo(userIDList: allUserId);
    for (var imFriendUserInfo in imFriendsUserInfos.data!) {
      if (imFriendUserInfo.friendInfo?.userID ==
          CallState.instance.selfUser.id) {
        continue;
      }

      if (imFriendUserInfo.friendInfo?.userID == callerId) {
        CallState.instance.caller.nickname = StringStream.makeNull(
            imFriendUserInfo.friendInfo?.userProfile?.nickName, "");
        CallState.instance.caller.remark = StringStream.makeNull(
            imFriendUserInfo.friendInfo?.friendRemark, "");
        CallState.instance.caller.avatar = StringStream.makeNull(
            imFriendUserInfo.friendInfo?.userProfile?.faceUrl,
            Constants.defaultAvatar);
        CallState.instance.caller.callStatus = TUICallStatus.waiting;
        CallState.instance.caller.callRole = TUICallRole.caller;
      } else {
        var userID2 = imFriendUserInfo.friendInfo?.userID;
        if (CallState.instance.calleeList.containsKey(userID2)) {
          CallState.instance.calleeList[userID2]?.nickname =
              StringStream.makeNull(
                  imFriendUserInfo.friendInfo?.userProfile?.nickName, "");
          CallState.instance.calleeList[userID2]?.remark =
              StringStream.makeNull(
                  imFriendUserInfo.friendInfo?.friendRemark, "");
          CallState.instance.calleeList[userID2]?.avatar =
              StringStream.makeNull(
                  imFriendUserInfo.friendInfo?.userProfile?.faceUrl,
                  Constants.defaultAvatar);
          CallState.instance.calleeList[userID2]?.callStatus =
              TUICallStatus.waiting;
          CallState.instance.calleeList[userID2]?.callRole = TUICallRole.called;
        }
      }
    }

    CallState.instance.remoteUserList.clear();
    if (CallState.instance.caller.id.isNotEmpty &&
        CallState.instance.selfUser.id != CallState.instance.caller.id) {
      CallState.instance.remoteUserList
          .addAll({CallState.instance.caller.id: CallState.instance.caller});
    }
    for (var element in CallState.instance.calleeList.entries) {
      if (CallState.instance.selfUser.id == element.key) {
        continue;
      }
      CallState.instance.remoteUserList.addAll({element.key: element.value});
    }
  }

  void startTimer() {
    var clientST = CallState.instance.clientStartTime;
    if ((clientST ?? 0) > 0) {
      var time = DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(clientST!));
      CallState.instance.timeCount = time.inSeconds;
    } else {
      CallState.instance.timeCount = 0;
    }
    CallState.instance._timer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (TUICallStatus.accept != CallState.instance.selfUser.callStatus) {
        stopTimer();
        return;
      }
      CallState.instance.timeCount++;
      TUICore.instance.notifyEvent(setStateEventRefreshTiming);
    });
  }

  void stopTimer() {
    CallState.instance.timeCount = 0;
    CallState.instance.clientStartTime = 0;
    TUICore.instance.notifyEvent(setStateEventRefreshTiming);
    CallState.instance._timer.cancel();
  }

  void cleanState() {
    CallState.instance.selfUser.callRole = TUICallRole.none;
    CallState.instance.selfUser.callStatus = TUICallStatus.none;

    CallState.instance.remoteUserList.clear();
    CallState.instance.caller = User();
    CallState.instance.calleeList.clear();
    CallState.instance.calleeIdList.clear();

    CallState.instance.mediaType = TUICallMediaType.none;
    CallState.instance.timeCount = 0;
    CallState.instance.clientStartTime = 0;
    CallState.instance.startTime = 0;
    CallState.instance.roomId = TUIRoomId.intRoomId(intRoomId: 0);
    CallState.instance.groupId = '';

    CallState.instance.isMicrophoneMute = false;
    CallState.instance.camera = TUICamera.front;
    CallState.instance.isCameraOpen = false;
    CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;

    CallState.instance.isChangedBigSmallVideo = false;
    CallState.instance.enableBlurBackground = false;
  }

  bool isBadNetwork(TUINetworkQuality quality) {
    return quality == TUINetworkQuality.bad ||
        quality == TUINetworkQuality.vBad ||
        quality == TUINetworkQuality.down;
  }
}
