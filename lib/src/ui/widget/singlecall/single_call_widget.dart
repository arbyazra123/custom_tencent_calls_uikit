import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/extent_button.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_function_widget.dart';
import 'package:tencent_calls_uikit/src/utils/float_window.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class SingleCallWidget extends StatefulWidget {
  final Function close;

  const SingleCallWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleCallWidgetState();
}

class _SingleCallWidgetState extends State<SingleCallWidget> {
  ITUINotificationCallback? setSateCallBack;
  ITUINotificationCallback? setStateEventOnCallBeginCallback;
  bool _hadShowAcceptText = false;
  bool _isShowAcceptText = false;
  double _smallViewTop = 128;
  double _smallViewRight = 20;
  bool isFunctionExpand = true;
  bool _isOnlyShowBigVideoView = false;

  final Widget _localVideoView = TUIVideoView(
      key: CallState.instance.selfUser.key,
      onPlatformViewCreated: (viewId) {
        CallState.instance.selfUser.viewID = viewId;
        if (CallState.instance.isCameraOpen) {
          CallManager.instance.openCamera(CallState.instance.camera, viewId);
        }
      });

  final Widget _remoteVideoView = TUIVideoView(
      key: CallState.instance.remoteUserList.isEmpty
          ? GlobalKey()
          : CallState.instance.remoteUserList.values.first.key,
      onPlatformViewCreated: (viewId) {
        var firstData = CallState.instance.remoteUserList.values.first;
        firstData.viewID = viewId;
        CallManager.instance.startRemoteView(firstData.id, viewId);
      });

  @override
  void initState() {
    super.initState();
    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {});
      }
    };
    setStateEventOnCallBeginCallback = (arg) {
      _initialize();
      if (mounted) {
        setState(() {});
      }
    };
    TUICore.instance.registerEvent(setStateEvent, setSateCallBack);
    TUICore.instance.registerEvent(
        setStateEventOnCallBegin, setStateEventOnCallBeginCallback);
  }

  void _initialize() async {
    debugPrint("setStateEventOnCallBegin._initialize called");
    Future.delayed(const Duration(milliseconds: 500)).then((value) async {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
      await CallManager.instance
          .selectAudioPlaybackDevice(TUIAudioPlaybackDevice.earpiece);
    });
  }

  @override
  dispose() {
    super.dispose();
    TUICore.instance.unregisterEvent(setStateEvent, setSateCallBack);
    TUICore.instance.unregisterEvent(
        setStateEventOnCallBegin, setStateEventOnCallBeginCallback);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "CallState.instance.audioDevice.name ${CallState.instance.audioDevice}");
    return Scaffold(
      // backgroundColor: _getBackgroundColor(),
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color.fromRGBO(52, 56, 66, 1),
      body: Builder(builder: (context) {
        return Stack(
          alignment: Alignment.topLeft,
          fit: StackFit.expand,
          children: [
            if (CallState.instance.mediaType == TUICallMediaType.video)
              _buildBackground(),
            _buildBigVideoWidget(),
            _isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildSmallVideoWidget(),
            _isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildFloatingWindowBtnWidget(),
            if (CallState.instance.mediaType == TUICallMediaType.video)
              _buildTimerWidget(),
            _isOnlyShowBigVideoView ? const SizedBox() : _buildUserInfoWidget(),
            _isOnlyShowBigVideoView ? const SizedBox() : _buildHintTextWidget(),
            _isOnlyShowBigVideoView
                ? const SizedBox()
                : _buildFunctionButtonWidget(),
          ],
        );
      }),
    );
  }

  _buildBackground() {
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList.values.first.avatar,
          Constants.defaultAvatar);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(
        bottom: _isOnlyShowBigVideoView
            ? 0
            : isFunctionExpand
                ? 180
                : 70,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image(
              height: double.infinity,
              image: NetworkImage(avatar),
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stackTrace) => Image.asset(
                'assets/images/user_icon.png',
                package: 'tencent_calls_uikit',
              ),
            ),
          ),
          Opacity(
            opacity: 0.9,
            child: Container(
              color: Colors.grey[900],
            ),
          )
        ],
      ),
    );
  }

  _buildFloatingWindowBtnWidget() {
    return CallState.instance.enableFloatWindow
        ? SafeArea(
            child: SizedBox(
              width: 24,
              height: 24,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  top: kToolbarHeight / 2,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        child: Image.asset(
                          'assets/images/floating_button.png',
                          package: 'tencent_calls_uikit',
                          width: 24,
                          height: 24,
                        ),
                        onTap: () {
                          FloatWindow.open(context);
                        },
                      )
                    ]),
              ),
            ),
          )
        : const SizedBox();
  }

  _buildTimerWidget() {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight / 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CallState.instance.selfUser.callStatus == TUICallStatus.accept
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: const TimingWidget(),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  _buildUserInfoWidget() {
    var showName = '';
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      showName = User.getUserDisplayName(
          CallState.instance.remoteUserList.values.first);
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList.values.first.avatar,
          Constants.defaultAvatar);
    }

    final userInfoWidget = Positioned(
        top: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 110,
              width: 110,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Image(
                image: NetworkImage(avatar),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stackTrace) => Image.asset(
                  'assets/images/user_icon.png',
                  package: 'tencent_calls_uikit',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              showName,
              style: TextStyle(
                fontSize: 24,
                color: _getTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            CallState.instance.selfUser.callStatus == TUICallStatus.accept
                ? Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: const TimingWidget(),
                  )
                : const SizedBox(),
          ],
        ));

    if (CallState.instance.mediaType == TUICallMediaType.video &&
        CallState.instance.selfUser.callStatus == TUICallStatus.accept) {
      return const SizedBox();
    }
    return userInfoWidget;
  }

  _buildHintTextWidget() {
    if (CallState.instance.selfUser.callRole == TUICallRole.caller &&
        CallState.instance.selfUser.callStatus == TUICallStatus.accept &&
        CallState.instance.timeCount < 1) {
      if (!_hadShowAcceptText) {
        _isShowAcceptText = true;
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _isShowAcceptText = false;
            _hadShowAcceptText = true;
          });
        });
      }
    }

    String hintText = "";
    TextStyle textStyle;

    bool isWaiting =
        CallState.instance.selfUser.callStatus == TUICallStatus.waiting
            ? true
            : false;

    if (_isShowAcceptText) {
      hintText = CallI10n.current.connected;
      textStyle = TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _getTextColor(),
      );
    } else {
      if (isWaiting &&
          CallState.instance.selfUser.callRole == TUICallRole.called) {
        hintText = CallI10n.current.invitedYouToACall(
            CallState.instance.mediaType == TUICallMediaType.audio
                ? CallI10n.current.voice
                : CallI10n.current.video);
      } else if (NetworkQualityHint.local ==
          CallState.instance.networkQualityReminder) {
        hintText = CallI10n.current.selfNetworkLowQuality;
      } else if (NetworkQualityHint.remote ==
          CallState.instance.networkQualityReminder) {
        hintText = CallI10n.current.otherPartyNetworkLowQuality;
      } else if (isWaiting) {
        hintText = CallI10n.current.waitTheOtherParty;
      }
      textStyle = TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: _getTextColor());
    }

    return Positioned(
      top: MediaQuery.of(context).size.height * 2 / 3.2,
      width: MediaQuery.of(context).size.width,
      child: Center(
        child: hintText.isNotEmpty
            ? Text(
                hintText,
                textScaleFactor: 1.0,
                style: textStyle,
              )
            : const SizedBox(),
      ),
    );
  }

  _buildFunctionButtonWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom +
                (TUICallStatus.waiting == CallState.instance.selfUser.callStatus
                    ? 40
                    : CallState.instance.mediaType == TUICallMediaType.audio
                        ? 40
                        : 0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SingleFunctionWidget.buildFunctionWidget(
                widget.close,
                _buildVideoCallerAndCalleeAcceptedFunctionView(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildVideoCallerAndCalleeAcceptedFunctionView() {
    double bigBtnHeight = 52;
    double smallBtnHeight = 35;
    double edge = 45;
    double bottomEdge = 0;
    int duration = 300;
    int btnWidth = 100;
    Curve curve = Curves.easeInOut;
    return GestureDetector(
      onVerticalDragUpdate: (details) =>
          _functionWidgetVerticalDragUpdate(details),
      child: AnimatedContainer(
        curve: curve,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          color: Color.fromRGBO(52, 56, 66, 1),
        ),
        height: isFunctionExpand ? 200 : 90,
        duration: Duration(milliseconds: duration),
        child: Stack(
          children: [
            if (CallState.instance.mediaType == TUICallMediaType.video)
              AnimatedPositioned(
                curve: curve,
                duration: Duration(milliseconds: duration),
                left: isFunctionExpand
                    ? ((MediaQuery.of(context).size.width / 5) - (btnWidth / 2))
                    : (MediaQuery.of(context).size.width / 4 - btnWidth / 2),
                bottom: isFunctionExpand
                    ? bottomEdge + bigBtnHeight + edge
                    : bottomEdge,
                child: ExtendButton(
                  onlyIcon: true,
                  userAnimation: true,
                  duration: Duration(milliseconds: duration),
                  imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                  imgUrl: "assets/images/switch_camera.png",
                  containerColor: CallState.instance.camera == TUICamera.front
                      ? Colors.grey[900]!
                      : Colors.white,
                  tips: isFunctionExpand ? CallKit_t("switchCamera") : '',
                  textColor: _getTextColor(),
                  imgColor: CallState.instance.camera == TUICamera.back
                      ? Colors.grey[900]!
                      : Colors.white,
                  onTap: () {
                    SingleFunctionWidget.handleSwitchCamera();
                  },
                ),
              ),
            AnimatedPositioned(
              curve: curve,
              duration: Duration(milliseconds: duration),
              left: isFunctionExpand
                  ? ((MediaQuery.of(context).size.width / 2.4) - (btnWidth / 2))
                  : (MediaQuery.of(context).size.width / 2.4) - btnWidth / 2,
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
                imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                onTap: () {
                  // _handleSwitchMic();
                  SingleFunctionWidget.handleSwitchMic();
                },
                userAnimation: true,
                duration: Duration(milliseconds: duration),
              ),
            ),
            AnimatedPositioned(
              curve: curve,
              duration: Duration(milliseconds: duration),
              left: isFunctionExpand
                  ? (MediaQuery.of(context).size.width / 1.6 - btnWidth / 2)
                  : (MediaQuery.of(context).size.width / 1.72) - btnWidth / 2,
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
                imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                onTap: () {
                  // _handleSwitchAudioDevice();
                  SingleFunctionWidget.handleSwitchAudioDevice();
                },
                userAnimation: true,
                duration: Duration(milliseconds: duration),
              ),
            ),
            AnimatedPositioned(
              curve: curve,
              duration: Duration(milliseconds: duration),
              left: isFunctionExpand
                  ? (MediaQuery.of(context).size.width / 1.2 - btnWidth / 2)
                  : (MediaQuery.of(context).size.width / 1.34) - btnWidth / 2,
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
                imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                onTap: () {
                  // _handleOpenCloseCamera();
                  SingleFunctionWidget.handleOpenCloseCamera();
                },
                userAnimation: true,
                duration: Duration(milliseconds: duration),
              ),
            ),
            AnimatedPositioned(
              curve: curve,
              duration: Duration(milliseconds: duration),
              left: isFunctionExpand
                  ? (MediaQuery.of(context).size.width / 2 - btnWidth / 2)
                  : (MediaQuery.of(context).size.width / 1.1) - btnWidth / 2,
              bottom: bottomEdge,
              child: ExtendButton(
                imgUrl: "assets/images/hangup.png",
                textColor: Colors.white,
                imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                onTap: () {
                  SingleFunctionWidget.handleHangUp(widget.close);
                },
                userAnimation: true,
                duration: Duration(milliseconds: duration),
              ),
            ),
            AnimatedPositioned(
              curve: curve,
              duration: Duration(milliseconds: duration),
              left: 16,
              bottom: 30,
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
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBigVideoWidget() {
    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList.values.first.avatar,
          Constants.defaultAvatar);
      remoteVideoAvailable =
          CallState.instance.remoteUserList.values.first.videoAvailable;
    }
    var selfAvatar = StringStream.makeNull(
        CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    if (CallState.instance.mediaType == TUICallMediaType.audio) {
      return const SizedBox();
    }

    bool isLocalViewBig = true;
    if (CallState.instance.selfUser.callStatus == TUICallStatus.waiting) {
      isLocalViewBig = true;
    } else {
      if (CallState.instance.isChangedBigSmallVideo) {
        isLocalViewBig = false;
      } else {
        isLocalViewBig = true;
      }
    }

    return CallState.instance.mediaType == TUICallMediaType.video
        ? InkWell(
            onTap: () {
              setState(() {
                _isOnlyShowBigVideoView = !_isOnlyShowBigVideoView;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(
                bottom: _isOnlyShowBigVideoView
                    ? 0
                    : isFunctionExpand
                        ? 180
                        : 70,
              ),
              color: Colors.black54,
              child: Stack(
                children: [
                  CallState.instance.selfUser.callStatus == TUICallStatus.accept
                      ? Visibility(
                          visible: (isLocalViewBig
                              ? !isCameraOpen
                              : !remoteVideoAvailable),
                          child: Center(
                              child: Container(
                            height: 80,
                            width: 80,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Image(
                              image: NetworkImage(
                                  isLocalViewBig ? selfAvatar : remoteAvatar),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stackTrace) =>
                                  Image.asset(
                                'assets/images/user_icon.png',
                                package: 'tencent_calls_uikit',
                              ),
                            ),
                          )),
                        )
                      : Container(),
                  Opacity(
                      opacity: isLocalViewBig
                          ? _getOpacityByVis(isCameraOpen)
                          : _getOpacityByVis(remoteVideoAvailable),
                      child:
                          isLocalViewBig ? _localVideoView : _remoteVideoView)
                ],
              ),
            ))
        : Container();
  }

  Widget _buildSmallVideoWidget() {
    if (CallState.instance.mediaType == TUICallMediaType.audio) {
      return const SizedBox();
    }
    bool isRemoteViewSmall = true;

    if (CallState.instance.selfUser.callStatus == TUICallStatus.accept) {
      if (CallState.instance.isChangedBigSmallVideo) {
        isRemoteViewSmall = false;
      } else {
        isRemoteViewSmall = true;
      }
    }

    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    var remoteAudioAvailable = false;

    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList.values.first.avatar,
          Constants.defaultAvatar);
      remoteVideoAvailable =
          CallState.instance.remoteUserList.values.first.videoAvailable;
      remoteAudioAvailable =
          CallState.instance.remoteUserList.values.first.audioAvailable;
    }
    var selfAvatar = StringStream.makeNull(
        CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    var smallVideoWidget =
        CallState.instance.selfUser.callStatus == TUICallStatus.accept
            ? Container(
                height: 216,
                width: 110,
                color: Colors.black54,
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    Visibility(
                      visible: (isRemoteViewSmall
                          ? !remoteVideoAvailable
                          : !isCameraOpen),
                      child: Center(
                        child: Container(
                          height: 80,
                          width: 80,
                          clipBehavior: Clip.hardEdge,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Image(
                            image: NetworkImage(
                                isRemoteViewSmall ? remoteAvatar : selfAvatar),
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, err, stackTrace) => Image.asset(
                              'assets/images/user_icon.png',
                              package: 'tencent_calls_uikit',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                        opacity: isRemoteViewSmall
                            ? _getOpacityByVis(remoteVideoAvailable)
                            : _getOpacityByVis(isCameraOpen),
                        child: isRemoteViewSmall
                            ? _remoteVideoView
                            : _localVideoView),
                    Positioned(
                      left: 5,
                      bottom: 5,
                      width: 20,
                      height: 20,
                      child: (isRemoteViewSmall && !remoteAudioAvailable)
                          ? Image.asset(
                              'assets/images/audio_unavailable_grey.png',
                              package: 'tencent_calls_uikit',
                            )
                          : const SizedBox(),
                    )
                  ],
                ))
            : Container();

    return Positioned(
        top: _smallViewTop - 40,
        right: _smallViewRight,
        child: GestureDetector(
          onTap: () {
            _changeVideoView();
          },
          onPanUpdate: (DragUpdateDetails e) {
            if (CallState.instance.mediaType == TUICallMediaType.video) {
              _smallViewRight -= e.delta.dx;
              _smallViewTop += e.delta.dy;
              if (_smallViewTop < 100) {
                _smallViewTop = 100;
              }
              if (_smallViewTop > MediaQuery.of(context).size.height - 216) {
                _smallViewTop = MediaQuery.of(context).size.height - 216;
              }
              if (_smallViewRight < 0) {
                _smallViewRight = 0;
              }
              if (_smallViewRight > MediaQuery.of(context).size.width - 110) {
                _smallViewRight = MediaQuery.of(context).size.width - 110;
              }
              setState(() {});
            }
          },
          child: SizedBox(
            width: 110,
            child: smallVideoWidget,
          ),
        ));
  }

  _changeVideoView() {
    if (CallState.instance.mediaType == TUICallMediaType.audio ||
        CallState.instance.selfUser.callStatus == TUICallStatus.waiting) {
      return;
    }

    setState(() {
      CallState.instance.isChangedBigSmallVideo =
          !CallState.instance.isChangedBigSmallVideo;
    });
  }

  double _getOpacityByVis(bool vis) {
    return vis ? 1.0 : 0;
  }

  _openFloatWindow() async {
    if (Platform.isAndroid) {
      bool result = await TUICallKitPlatform.instance.hasFloatPermission();
      if (!result) {
        return;
      }
    }
    TUICallKitNavigatorObserver.getInstance().exitCallingPage();
    CallManager.instance.openFloatWindow();
  }

  _getBackgroundColor() {
    return CallState.instance.mediaType == TUICallMediaType.audio
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF444444);
  }

  _getTextColor() {
    return Colors.white;
  }

  _functionWidgetVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 && !isFunctionExpand) {
      isFunctionExpand = true;
    } else if (details.delta.dy > 0 && isFunctionExpand) {
      isFunctionExpand = false;
    }
    setState(() {});
  }
}
