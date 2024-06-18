import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/extent_button.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_user_widget_data.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/utils/float_window.dart';
import 'package:tencent_calls_uikit/src/utils/permission_request.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';
import 'group_call_user_widget.dart';

class GroupCallWidget extends StatefulWidget {
  final Function close;

  const GroupCallWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<GroupCallWidget> createState() => _GroupCallWidgetState();
}

class _GroupCallWidgetState extends State<GroupCallWidget> {
  EventCallback? setSateCallBack;
  EventCallback? groupCallUserWidgetRefreshCallback;
  bool isFunctionExpand = true;
  late final List<GroupCallUserWidget> _userViewWidgets = [];

  _initUsersViewWidget() {
    GroupCallUserWidgetData.initBlockCounter();
    GroupCallUserWidgetData.updateBlockBigger(
        CallState.instance.remoteUserList.length + 1);
    GroupCallUserWidgetData.initCanPlaceSquare(
        GroupCallUserWidgetData.blockBigger,
        CallState.instance.remoteUserList.length + 1);
    _userViewWidgets.clear();

    GroupCallUserWidgetData.blockCount++;
    _userViewWidgets.add(
      GroupCallUserWidget(
        index: GroupCallUserWidgetData.blockCount,
        user: CallState.instance.selfUser,
      ),
    );

    for (var remoteUser in CallState.instance.remoteUserList) {
      GroupCallUserWidgetData.blockCount++;
      _userViewWidgets.add(GroupCallUserWidget(
          index: GroupCallUserWidgetData.blockCount, user: remoteUser));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {
          _initUsersViewWidget();
        });
      }
    };

    groupCallUserWidgetRefreshCallback = (arg) {
      if (mounted) {
        if (GroupCallUserWidgetData.hasBiggerSquare()) {
          isFunctionExpand = false;
        } else {
          isFunctionExpand = true;
        }
        setState(() {});
      }
    };

    eventBus.register(setStateEvent, setSateCallBack);
    eventBus.register(setStateEventGroupCallUserWidgetRefresh,
        groupCallUserWidgetRefreshCallback);

    GroupCallUserWidgetData.initBlockBigger();
    _initUsersViewWidget();
    if (TUICallStatus.waiting == CallState.instance.selfUser.callStatus) {
      if (TUICallRole.caller == CallState.instance.selfUser.callRole) {
        _initialize();
      }
    }
  }

  void _initialize() async {
    Future.delayed(const Duration(milliseconds: 500)).then((value) async {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();

      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
      await CallManager.instance.selectAudioPlaybackDevice(
        CallState.instance.audioDevice,
      );
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.unregister(setStateEvent, setSateCallBack);
    eventBus.unregister(setStateEventGroupCallUserWidgetRefresh,
        groupCallUserWidgetRefreshCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFunctionWidget(),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 0),
        color: const Color.fromRGBO(45, 45, 45, 1.0),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            _buildTopWidget(),
            _buildUserVideoList(),
          ],
        ),
      ),
    );
  }

  _buildUserVideoList() {
    return (TUICallStatus.waiting == CallState.instance.selfUser.callStatus &&
            CallState.instance.selfUser.callRole == TUICallRole.called)
        ? _buildReceivedGroupCallWaitting()
        : _buildGroupCallView();
  }

  _buildReceivedGroupCallWaitting() {
    return Positioned(
        top: 0,
        left: 0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 150),
                height: 120,
                width: 120,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Image(
                  image: NetworkImage(StringStream.makeNull(
                      CallState.instance.caller.avatar, Constants.defaultAvatar)),
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stackTrace) => Image.asset(
                    'assets/images/user_icon.png',
                    package: 'tencent_calls_uikit',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  User.getUserDisplayName(CallState.instance.caller),
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              Text(
                CallI10n.current.invitedtoGroupCall,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              const SizedBox(
                height: 50,
              ),
              Text(
                CallI10n.current.theyThere,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List.generate(CallState.instance.calleeList.length,
                      ((index) {
                    return Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Image(
                        image: NetworkImage(StringStream.makeNull(
                            CallState.instance.calleeList[index].avatar,
                            Constants.defaultAvatar)),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stackTrace) => Image.asset(
                          'assets/images/user_icon.png',
                          package: 'tencent_calls_uikit',
                        ),
                      ),
                    );
                  })),
                ),
              )
            ],
          ),
        ));
  }

  _buildGroupCallView() {
    return Positioned(
      top: 50,
      left: 0,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              MediaQuery.of(context).padding.bottom),
      child: Stack(children: _userViewWidgets),
    );
  }

  _buildTopWidget() {
    final floatWindowBtnWidget = Visibility(
      visible: true,
      child: InkWell(
          onTap: () => FloatWindow.open(context),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              'assets/images/floating_button.png',
              package: 'tencent_calls_uikit',
            ),
          )),
    );

    var isAccept =
        TUICallStatus.accept == CallState.instance.selfUser.callStatus;
    final timerWidget = (isAccept)
        ? const SizedBox(width: 100, child: Center(child: TimingWidget()))
        : const SizedBox(
            width: 100,
          );

    final inviteBtnWidget = Visibility(
      visible: TUICallStatus.accept == CallState.instance.selfUser.callStatus ||
          TUICallRole.caller == CallState.instance.selfUser.callRole,
      child: InkWell(
          onTap: () =>
              TUICallKitNavigatorObserver.getInstance().enterInviteUserPage(),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              'assets/images/add_user.png',
              package: 'tencent_calls_uikit',
            ),
          )),
    );

    return Positioned(
        top: 0,
        width: MediaQuery.of(context).size.width,
        height: kToolbarHeight,
        child: Container(
          color: const Color.fromRGBO(52, 56, 66, 1.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 16,
                top: 15,
                child: floatWindowBtnWidget,
              ),
              Positioned(
                left: (MediaQuery.of(context).size.width / 2) - 50,
                top: isAccept ? 5 : 15,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      timerWidget,
                      FutureBuilder(
                        future: TencentImSDKPlugin.v2TIMManager
                            .getGroupManager()
                            .getGroupsInfo(
                                groupIDList: [CallState.instance.groupId]),
                        builder: (context,
                            AsyncSnapshot<
                                    V2TimValueCallback<
                                        List<V2TimGroupInfoResult>>>
                                snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data?.data?.isNotEmpty ?? false) {
                              var group = snapshot.data!.data!.first;
                              return Text(
                                group.groupInfo?.groupName ?? "",
                                style: TextStyle(
                                  color: Colors.grey[200]!,
                                  fontSize: isAccept ? 11 : 16,
                                ),
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 15,
                child: inviteBtnWidget,
              ),
            ],
          ),
        ));
  }

  _buildFunctionWidget() {
    Widget functionWidget;
    if (TUICallStatus.waiting == CallState.instance.selfUser.callStatus &&
        TUICallRole.called == CallState.instance.selfUser.callRole) {
      functionWidget = _buildAudioAndVideoCalleeWaitingFunctionView();
    } else {
      functionWidget = _buildVideoCallerAndCalleeAcceptedFunctionView();
    }

    return functionWidget;
  }

  _buildAudioAndVideoCalleeWaitingFunctionView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: "assets/images/hangup.png",
              tips: CallI10n.current.hangup,
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleReject(widget.close);
              },
            ),
            ExtendButton(
              imgUrl: "assets/images/dialing.png",
              tips: CallI10n.current.accept,
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleAccept();
              },
            ),
          ],
        ),
        const SizedBox(height: 80)
      ],
    );
  }

  _buildVideoCallerAndCalleeAcceptedFunctionView() {
    double bigBtnHeight = 52;
    double smallBtnHeight = 35;
    double edge = 40;
    double bottomEdge = 1;
    int duration = 300;
    int btnWidth = 100;
    Curve curve = Curves.easeInOut;
    return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: GestureDetector(
            onVerticalDragUpdate: (details) =>
                _functionWidgetVerticalDragUpdate(details),
            child: AnimatedContainer(
                curve: curve,
                height: isFunctionExpand ? 200 : 90,
                duration: Duration(milliseconds: duration),
                color: const Color.fromRGBO(52, 56, 66, 1.0),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? ((MediaQuery.of(context).size.width / 4) -
                              (btnWidth / 2))
                          : (MediaQuery.of(context).size.width * 2 / 6 -
                              btnWidth / 2),
                      bottom: isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isMicrophoneMute
                            ? "assets/images/mute_on.png"
                            : "assets/images/mute.png",
                        tips: isFunctionExpand
                            ? (CallState.instance.isMicrophoneMute
                                ? CallI10n.current.microphone
                                : CallI10n.current.microphone)
                            : '',
                        textColor: Colors.white,
                        imgHeight:
                            isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleSwitchMic();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 3 / 6 -
                              btnWidth / 2),
                      bottom: isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.audioDevice ==
                                TUIAudioPlaybackDevice.speakerphone
                            ? "assets/images/handsfree_on.png"
                            : "assets/images/handsfree.png",
                        tips: isFunctionExpand
                            ? (CallState.instance.audioDevice ==
                                    TUIAudioPlaybackDevice.speakerphone
                                ? CallI10n.current.speaker
                                : CallI10n.current.speaker)
                            : '',
                        textColor: Colors.white,
                        imgHeight:
                            isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleSwitchAudioDevice();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? (MediaQuery.of(context).size.width * 3 / 4 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 4 / 6 -
                              btnWidth / 2),
                      bottom: isFunctionExpand
                          ? bottomEdge + bigBtnHeight + edge
                          : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isCameraOpen
                            ? "assets/images/camera_on.png"
                            : "assets/images/camera_off.png",
                        tips: isFunctionExpand
                            ? (CallState.instance.isCameraOpen
                                ? CallI10n.current.camera
                                : CallI10n.current.camera)
                            : '',
                        textColor: Colors.white,
                        imgHeight:
                            isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleOpenCloseCamera();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 -
                              btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 5 / 6 -
                              btnWidth / 2),
                      bottom: bottomEdge,
                      child: ExtendButton(
                        imgUrl: "assets/images/hangup.png",
                        textColor: Colors.white,
                        imgHeight:
                            isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleHangUp(widget.close);
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                        curve: curve,
                        duration: Duration(milliseconds: duration),
                        left: (MediaQuery.of(context).size.width / 6 -
                            smallBtnHeight / 2),
                        bottom: isFunctionExpand
                            ? bottomEdge + smallBtnHeight / 4 + 22
                            : bottomEdge + 26,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isFunctionExpand = !isFunctionExpand;
                            });
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(1.0, isFunctionExpand ? 1.0 : -1.0, 1.0),
                            child: Image.asset(
                              'assets/images/arrow.png',
                              package: 'tencent_calls_uikit',
                              width: smallBtnHeight,
                            ),
                          ),
                        ))
                  ],
                ))));
  }

  _functionWidgetVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 && !isFunctionExpand) {
      isFunctionExpand = true;
    } else if (details.delta.dy > 0 && isFunctionExpand) {
      isFunctionExpand = false;
    }
    setState(() {});
  }

  _handleSwitchMic() async {
    if (CallState.instance.isMicrophoneMute) {
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    } else {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();
    }
    setState(() {});
  }

  _handleSwitchAudioDevice() async {
    if (CallState.instance.audioDevice == TUIAudioPlaybackDevice.earpiece) {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.speakerphone;
    } else {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
    }
    await CallManager.instance
        .selectAudioPlaybackDevice(CallState.instance.audioDevice);
    setState(() {});
  }

  _handleHangUp(Function close) async {
    await CallManager.instance.hangup();
    close();
  }

  _handleReject(Function close) async {
    await CallManager.instance.reject();
    close();
  }

  _handleAccept() async {
    TUIPermissionResult permissionRequestResult =
        TUIPermissionResult.requesting;
    if (Platform.isAndroid) {
      permissionRequestResult = await PermissionRequest.checkCallingPermission(
          CallState.instance.mediaType);
    }
    if (permissionRequestResult == TUIPermissionResult.granted ||
        Platform.isIOS) {
      await CallManager.instance.accept();
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    } else {
      CallManager.instance.showToast(
        CallI10n.current.callFailedDuetoPermission,
      );
    }
    setState(() {});
  }

  void _handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance.openCamera(
          CallState.instance.camera, CallState.instance.selfUser.viewID);
    } else {
      await CallManager.instance.closeCamera();
    }
    setState(() {});
  }
}
