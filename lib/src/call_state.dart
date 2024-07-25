import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/utils/preference_utils.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

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
  List<String> calleeIdList = [];
  Map<String, User> remoteUserList = {};
  TUICallScene scene = TUICallScene.singleCall;
  TUICallMediaType mediaType = TUICallMediaType.none;
  int timeCount = 0;
  int startTime = 0;
  int? clientStartTime;
  late Timer _timer;
  TUIRoomId roomId = TUIRoomId.intRoomId(intRoomId: 0);
  String groupId = '';
  bool isCameraOpen = false;
  TUICamera camera = TUICamera.front;
  bool isMicrophoneMute = false;
  TUIAudioPlaybackDevice audioDevice = TUIAudioPlaybackDevice.earpiece;
  bool enableMuteMode = false;
  bool enableFloatWindow = false;
  bool isChangedBigSmallVideo = false;
  bool isOpenFloatWindow = false;

  String moveAppToFrontStatus = '';

  TUICallObserver observer = TUICallObserver(
    onError: (int code, String message) {
      TRTCLogger.info('TUICallObserver onError(code:$code, message:$message)');
      CallManager.instance.showToast('Error: $code, $message');
    },
    onCallReceived: (
      String callerId,
      List<String> calleeIdList,
      String groupId,
      TUICallMediaType callMediaType,
      String? userData,
    ) async {
      TRTCLogger.info(
          'TUICallObserver onCallReceived(callerId:$callerId, calleeIdList:$calleeIdList, groupId:$groupId, callMediaType:$callMediaType), version:${Constants.pluginVersion}');
      await CallState.instance.handleCallReceivedData(
        callerId,
        calleeIdList,
        groupId,
        callMediaType,
      );
      await TUICallKitPlatform.instance.updateCallStateToNative();
      CallingBellFeature.startRing();
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
        }
      } else {
        CallManager.instance.launchCallingPage();
      }
    },
    onCallCancelled: (String callerId) {
      TRTCLogger.info('TUICallObserver onCallCancelled(callerId:$callerId)');
      CallingBellFeature.stopRing();
      CallState.instance.cleanState();
      eventBus.notify(setStateEventOnCallEnd);
      TUICallKitPlatform.instance.updateCallStateToNative();
      // CallManager.instance.enableWakeLock(false);
    },
    onCallBegin: (TUIRoomId roomId, TUICallMediaType callMediaType,
        TUICallRole callRole) {
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
      CallManager.instance
          .selectAudioPlaybackDevice(CallState.instance.audioDevice);
      CallState.instance.startTimer();
      CallState.instance.isChangedBigSmallVideo = true;
      eventBus.notify(setStateEvent);
      eventBus.notify(setStateEventOnCallBegin);
      TUICallKitPlatform.instance.updateCallStateToNative();
    },
    onCallEnd: (TUIRoomId roomId, TUICallMediaType callMediaType,
        TUICallRole callRole, double totalTime) {
      TRTCLogger.info(
          'TUICallObserver onCallEnd(roomId:$roomId, callMediaType:$callMediaType, callRole:$callRole, totalTime:$totalTime)');
      CallState.instance.stopTimer();
      CallState.instance.cleanState();
      eventBus.notify(setStateEventOnCallEnd);
      TUICallKitPlatform.instance.updateCallStateToNative();
      // CallManager.instance.enableWakeLock(false);
    },
    onCallMediaTypeChanged:
        (TUICallMediaType oldCallMediaType, TUICallMediaType newCallMediaType) {
      CallState.instance.mediaType = newCallMediaType;
      eventBus.notify(setStateEvent);
      TUICallKitPlatform.instance.updateCallStateToNative();
    },
    onUserReject: (String userId) {
      TRTCLogger.info('TUICallObserver onUserReject(userId:$userId)');

      if (CallState.instance.remoteUserList.containsKey(userId)) {
        CallState.instance.remoteUserList.remove(userId);
        eventBus.notify(setStateEvent);
      }

      if (CallState.instance.remoteUserList.isEmpty) {
        CallingBellFeature.stopRing();
        CallState.instance.cleanState();
        eventBus.notify(setStateEventOnCallEnd);
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
    },
    onUserNoResponse: (String userId) {
      TRTCLogger.info('TUICallObserver onUserNoResponse(userId:$userId)');

      if (CallState.instance.remoteUserList.containsKey(userId)) {
        CallState.instance.remoteUserList.remove(userId);
        eventBus.notify(setStateEvent);
      }

      if (CallState.instance.remoteUserList.isEmpty) {
        CallingBellFeature.stopRing();
        CallState.instance.cleanState();
        eventBus.notify(
          setStateEventOnCallEnd,
          "userNoResponse|$userId",
        );
      }

      TUICallKitPlatform.instance.updateCallStateToNative();
      if (TUICallScene.singleCall == CallState.instance.scene) {
        CallManager.instance.showToast(
          CallI10n.current.didNotRespond,
        );
      } else {
        CallManager.instance.showToast('$userId ${CallI10n.current.noRespond}');
      }
    },
    onUserLineBusy: (String userId) {
      TRTCLogger.info('TUICallObserver onUserLineBusy(userId:$userId)');

      if (CallState.instance.remoteUserList.containsKey(userId)) {
        CallState.instance.remoteUserList.remove(userId);
        eventBus.notify(setStateEvent);
      }

      if (CallState.instance.remoteUserList.isEmpty) {
        CallingBellFeature.stopRing();
        CallState.instance.cleanState();

        Timer.periodic(const Duration(milliseconds: 100), (timer) {
          eventBus.notify(setStateEventOnCallEnd);
          timer.cancel();
        });
      }

      TUICallKitPlatform.instance.updateCallStateToNative();

      if (TUICallScene.singleCall == CallState.instance.scene) {
        CallManager.instance.showToast(CallI10n.current.recepientIsBusy);
      } else {
        CallManager.instance.showToast('$userId ${CallI10n.current.busy}');
      }
    },
    onUserJoin: (String userId) async {
      TRTCLogger.info('TUICallObserver onUserJoin(userId:$userId)');

      if (CallState.instance.remoteUserList.containsKey(userId)) {
        CallState.instance.selfUser.callStatus = TUICallStatus.accept;
        CallState.instance.remoteUserList[userId]?.callStatus =
            TUICallStatus.accept;
        eventBus.notify(setStateEvent);

        TUICallKitPlatform.instance.updateCallStateToNative();
        return;
      }

      CallingBellFeature.stopRing();

      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
      eventBus.notify(setStateEvent);

      final user = User();
      user.id = userId;
      user.callStatus = TUICallStatus.accept;
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
      eventBus.notify(setStateEvent);

      TUICallKitPlatform.instance.updateCallStateToNative();
    },
    onUserLeave: (String userId) {
      TRTCLogger.info('TUICallObserver onUserLeave(userId:$userId)');

      if (CallState.instance.remoteUserList.containsKey(userId)) {
        CallState.instance.remoteUserList.remove(userId);
        eventBus.notify(setStateEvent);
      }

      if (CallState.instance.remoteUserList.isEmpty) {
        CallState.instance.cleanState();
        eventBus.notify(setStateEventOnCallEnd);
      }

      TUICallKitPlatform.instance.updateCallStateToNative();

      if (TUICallScene.singleCall == CallState.instance.scene) {
        CallManager.instance
            .showToast(CallI10n.current.opponentHangUpAndCallIsOver);
      } else {
        CallManager.instance
            .showToast('$userId ${CallI10n.current.endTheCall}');
      }
    },
    onUserVideoAvailable: (String userId, bool isVideoAvailable) {
      TRTCLogger.info(
          'TUICallObserver onUserVideoAvailable(userId:$userId, isVideoAvailable:$isVideoAvailable)');

      if (CallState.instance.remoteUserList.containsKey(userId)) {
        CallState.instance.remoteUserList[userId]?.videoAvailable =
            isVideoAvailable;
        eventBus.notify(setStateEvent);

        TUICallKitPlatform.instance.updateCallStateToNative();
        return;
      }
    },
    onUserAudioAvailable: (String userId, bool isAudioAvailable) {
      TRTCLogger.info(
          'TUICallObserver onUserAudioAvailable(userId:$userId, isVideoAvailable:$isAudioAvailable)');
      if (CallState.instance.remoteUserList.containsKey(userId)) {
        CallState.instance.remoteUserList[userId]?.audioAvailable =
            isAudioAvailable;
        eventBus.notify(setStateEvent);

        TUICallKitPlatform.instance.updateCallStateToNative();
        return;
      }
    },
    onUserNetworkQualityChanged:
        (List<TUINetworkQualityInfo> networkQualityList) {},
    onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {
      for (var element in volumeMap.entries) {
        CallState.instance.remoteUserList[element.key]?.playOutVolume =
            element.value;
        if ((CallState.instance.remoteUserList[element.key]?.playOutVolume ??
                0) !=
            0) {
          CallState.instance.remoteUserList[element.key]?.audioAvailable = true;
        }
      }
      CallState.instance.selfUser.playOutVolume =
          volumeMap[CallState.instance.selfUser.id] ?? 0;
      TUICallKitPlatform.instance.updateCallStateToNative();
      eventBus.notify(setStateEvent);
    },
    onKickedOffline: () {
      TRTCLogger.info('TUICallObserver onKickedOffline()');
      CallManager.instance.hangup();
      CallingBellFeature.stopRing();
      CallState.instance.cleanState();
      eventBus.notify(setStateEvent);
      TUICallKitPlatform.instance.updateCallStateToNative();
    },
    onUserSigExpired: () {
      TRTCLogger.info('TUICallObserver onUserSigExpired()');
      CallManager.instance.hangup();
      CallingBellFeature.stopRing();
      CallState.instance.cleanState();
      eventBus.notify(setStateEvent);
      TUICallKitPlatform.instance.updateCallStateToNative();
    },
  );

  void init() {
    PreferenceUtils.getInstance()
        .getBool(Constants.spKeyEnableMuteMode, false)
        .then((value) => {enableMuteMode = value});
  }

  Future<void> registerEngineObserver() async {
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
      CallState.instance.remoteUserList
          .addAll({element.key: element.value});
    }
  }

  void startTimer() {
    var clientST = CallState.instance.clientStartTime;
    if (clientST != null) {
      var time = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
          CallState.instance.clientStartTime!));
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
      eventBus.notify(setStateEventRefreshTiming);
    });
  }

  void stopTimer() {
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
    CallState.instance.roomId = TUIRoomId.intRoomId(intRoomId: 0);
    CallState.instance.groupId = '';

    CallState.instance.isMicrophoneMute = false;
    CallState.instance.camera = TUICamera.front;
    CallState.instance.isCameraOpen = false;
    CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;

    CallState.instance.isChangedBigSmallVideo = false;
  }
}
