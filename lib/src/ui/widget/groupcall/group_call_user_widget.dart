import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/loading_animation.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_user_widget_data.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';

import 'package:tencent_calls_uikit/src/utils/tuple.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class GroupCallUserWidget extends StatefulWidget {
  final int index;
  final User user;

  const GroupCallUserWidget({Key? key, required this.index, required this.user})
      : super(key: key);

  @override
  State<GroupCallUserWidget> createState() => _GroupCallUserWidgetState();
}

class _GroupCallUserWidgetState extends State<GroupCallUserWidget> {
  EventCallback? refreshCallback;
  final _duration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    refreshCallback = (arg) {
      if (mounted) {
        setState(() {});
      }
    };
    eventBus.register(setStateEventGroupCallUserWidgetRefresh, refreshCallback);
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.unregister(
        setStateEventGroupCallUserWidgetRefresh, refreshCallback);
  }

  @override
  Widget build(BuildContext context) {
    final wh = _getWH(GroupCallUserWidgetData.blockBigger, widget.index,
        GroupCallUserWidgetData.blockCount);
    final Tuple<double, double> tl = _getTopLeft(
        GroupCallUserWidgetData.blockBigger,
        widget.index,
        GroupCallUserWidgetData.blockCount);

    bool isAvatarImage = (widget.user.id == CallState.instance.selfUser.id &&
            !CallState.instance.isCameraOpen) ||
        (widget.user.id != CallState.instance.selfUser.id &&
            !widget.user.videoAvailable);
    bool isShowLoadingImage =
        (widget.user.callStatus == TUICallStatus.waiting) &&
            (widget.user.id != CallState.instance.selfUser.id);
    bool isShowSpeaking = widget.user.playOutVolume != 0 &&
        widget.user.callStatus == TUICallStatus.accept;
    bool isShowRemoteMute = (widget.user.callStatus == TUICallStatus.accept) &&
        (widget.user.id != CallState.instance.selfUser.id) &&
        !widget.user.audioAvailable;
    bool amIMuted = (widget.user.id == CallState.instance.selfUser.id) &&
        CallState.instance.isMicrophoneMute;
    bool isShowSwitchCameraAndVB =
        GroupCallUserWidgetData.blockBigger[widget.index]! &&
            (widget.user.id == CallState.instance.selfUser.id) &&
            (CallState.instance.isCameraOpen == true);

    return AnimatedPositioned(
        width: wh,
        height: wh,
        top: tl.item1,
        left: tl.item2,
        duration: _duration,
        child: InkWell(
            onTap: () {
              GroupCallUserWidgetData.blockBigger.forEach((key, value) {
                GroupCallUserWidgetData.blockBigger[key] = (key == widget.index)
                    ? !GroupCallUserWidgetData.blockBigger[key]!
                    : false;
              });

              GroupCallUserWidgetData.initCanPlaceSquare(
                  GroupCallUserWidgetData.blockBigger,
                  CallState.instance.remoteUserList.length + 1);
              eventBus.notify(setStateEventGroupCallUserWidgetRefresh);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                TUIVideoView(
                  key: widget.user.key,
                  onPlatformViewCreated: (viewId) {
                    _onPlatformViewCreated(widget.user, viewId);
                  },
                ),

                Visibility(
                  visible: isAvatarImage,
                  child: Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: NetworkImage(widget.user.avatar),
                        fit: BoxFit.cover,
                        width: double.maxFinite,
                        height: double.maxFinite,
                        errorBuilder: (ctx, err, stackTrace) => Image.asset(
                          'assets/images/user_icon.png',
                          package: 'tencent_calls_uikit',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                Visibility(
                  visible: isShowLoadingImage,
                  child: Center(
                    child: LoadingAnimation(),
                  ),
                ),
                Visibility(
                  visible: isShowSpeaking,
                  child: Positioned(
                      left: 5,
                      bottom: 5,
                      width: 24,
                      height: 24,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            "assets/images/speaking.png",
                            package: 'tencent_calls_uikit',
                          ))),
                ),
                Visibility(
                  visible: isShowRemoteMute || amIMuted,
                  child: Positioned(
                    left: 5,
                    bottom: 5,
                    width: 24,
                    height: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        "assets/images/audio_unavailable.png",
                        package: 'tencent_calls_uikit',
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isShowSwitchCameraAndVB,
                  child: Positioned(
                      right: 10,
                      bottom: 5,
                      width: 24,
                      height: 24,
                      child: InkWell(
                          onTap: () {
                            _handleSwitchCamera();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Positioned(
                                      width: 14,
                                      height: 14,
                                      child: Image.asset(
                                          "assets/images/switch_camera.png",
                                          package: 'tencent_calls_uikit',
                                          fit: BoxFit.contain))
                                ],
                              )))),
                ),
                // Text("${widget.user.id} ${widget.user.id.isEmpty}")
                // TODO: 虚拟背景开关
                // Visibility(
                //   visible: isShowSwitchCameraAndVB,
                //   child: Positioned(
                //       right: 50,
                //       bottom: 5,
                //       width: 24,
                //       height: 24,
                //       child: InkWell(
                //           onTap: () {
                //             _handleVirtualBackgroubd();
                //           },
                //           child: Container(
                //               decoration: BoxDecoration(
                //                 color: Colors.black54,
                //                 shape: BoxShape.rectangle,
                //                 borderRadius: BorderRadius.circular(12),
                //               ),
                //               child: Stack(
                //                 alignment: AlignmentDirectional.center,
                //                 children: [
                //                   Positioned(
                //                       width: 14,
                //                       height: 14,
                //                       child: Image.asset("assets/images/virtual_background.png",
                //                           package: 'tencent_calls_uikit', fit: BoxFit.contain))
                //                 ],
                //               )))),
                // ),
              ],
            )));
  }

  _getWH(Map<int, bool> blockBigger, int index, int count) {
    if (_hasBigger(blockBigger)) {
      if (blockBigger[index]!) {
        if (count <= 4) {
          return MediaQuery.of(context).size.width;
        }
        return MediaQuery.of(context).size.width * 2 / 3;
      }

      return MediaQuery.of(context).size.width * 1 / 3;
    } else {
      if (count <= 4) {
        return MediaQuery.of(context).size.width / 2;
      }
      return MediaQuery.of(context).size.width * 1 / 3;
    }
  }

  Tuple<double, double> _getTopLeft(
      Map<int, bool> blockBigger, int index, int count) {
    // Step 1 判断自己是否最大的 、有最大的
    bool has = _hasBigger(blockBigger);
    bool selfIsBigger = blockBigger[index]!;

    // Step 2 有最大的
    if (has) {
      // Step 2.1 自己是最大的
      if (selfIsBigger) {
        // Step 2.1.1 小于等于4个
        if (count <= 4) {
          return Tuple(0, 0);
        }

        // Step 2.1.2 5~9
        // 计算将大widget放置的起始行、列
        int i = (index - 1) ~/ 3;
        int j = (index - 1) % 3;
        // 如果被放大的widget在被方大之前在第2列，那么放大的起始列变为第一列。 （若为第0列，则保持不变）
        j = (j > 1) ? 1 : j;
        return Tuple(MediaQuery.of(context).size.width * i / 3,
            MediaQuery.of(context).size.width * j / 3);
      }

      //Step 2.2 自己不是最大的
      for (int i = 0; i < GroupCallUserWidgetData.canPlaceSquare.length; i++) {
        for (int j = 0;
            j < GroupCallUserWidgetData.canPlaceSquare[i].length;
            j++) {
          if (GroupCallUserWidgetData.canPlaceSquare[i][j] == true) {
            GroupCallUserWidgetData.canPlaceSquare[i][j] = false;
            return Tuple(MediaQuery.of(context).size.width * i / 3,
                MediaQuery.of(context).size.width * j / 3);
          }
        }
      }
    }

    // Step 3 没有最大的
    // Step 3.1 只有2个人
    if (count == 2) {
      if (index == 1) {
        return Tuple(MediaQuery.of(context).size.width / 3, 0);
      }
      return Tuple(MediaQuery.of(context).size.width / 3,
          MediaQuery.of(context).size.width / 2);
    }
    // Step 3.2 有3个人
    if (count == 3) {
      if (index == 1) {
        return Tuple(0, 0);
      } else if (index == 2) {
        return Tuple(0, MediaQuery.of(context).size.width / 2);
      }
      return Tuple(MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.width / 4);
    }
    // Step 3.3 4个人
    if (count == 4) {
      if (index == 1) {
        return Tuple(0, 0);
      } else if (index == 2) {
        return Tuple(0, MediaQuery.of(context).size.width / 2);
      } else if (index == 3) {
        return Tuple(MediaQuery.of(context).size.width / 2, 0);
      }
      return Tuple(MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.width / 2);
    }

    // Step 3.4 大于4个人
    for (int i = 0; i < GroupCallUserWidgetData.canPlaceSquare.length; i++) {
      for (int j = 0;
          j < GroupCallUserWidgetData.canPlaceSquare[i].length;
          j++) {
        if (GroupCallUserWidgetData.canPlaceSquare[i][j] == true) {
          GroupCallUserWidgetData.canPlaceSquare[i][j] = false;
          return Tuple(MediaQuery.of(context).size.width * i / 3,
              MediaQuery.of(context).size.width * j / 3);
        }
      }
    }
    return Tuple(0, 0);
  }

  _hasBigger(Map<int, bool> blockBigger) {
    bool has = false;
    blockBigger.forEach((key, value) {
      if (value == true) {
        has = true;
      }
    });
    return has;
  }

  _onPlatformViewCreated(User user, int viewId) {
    debugPrint(
        "_onPlatformViewCreated: user.id = ${user.id}, viewId = $viewId");
    if (user.id == CallState.instance.selfUser.id) {
      CallState.instance.selfUser.viewID = viewId;
      if (CallState.instance.isCameraOpen) {
        CallManager.instance.openCamera(CallState.instance.camera, viewId);
      }
    } else {
      CallManager.instance.startRemoteView(user.id, viewId);
    }
    user.viewID = viewId;
  }

  _handleSwitchCamera() async {
    if (TUICamera.front == CallState.instance.camera) {
      CallState.instance.camera = TUICamera.back;
    } else {
      CallState.instance.camera = TUICamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    eventBus.notify(setStateEvent);
  }

  _handleVirtualBackgroubd() async {}
}
