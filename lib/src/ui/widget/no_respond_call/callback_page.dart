import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tencent_calls_uikit/src/I10n/l10n.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class CallbackPage extends StatefulWidget {
  const CallbackPage({Key? key, required this.userId}) : super(key: key);
  final String userId;
  @override
  State<CallbackPage> createState() => _CallbackPageState();
}

class _CallbackPageState extends State<CallbackPage> {
  V2TimUserFullInfo? userInfo;
  @override
  void initState() {
    super.initState();
    _init();
  }

  bool _isLoading = true;
  bool _isCallingLoading = false;

  void _init() async {
    var resultGetUser = await TencentImSDKPlugin.v2TIMManager
        .getUsersInfo(userIDList: [widget.userId]);
    if (resultGetUser.code == 0) {
      _isLoading = false;
      userInfo = resultGetUser.data?.firstOrNull;
    } else {
      _isLoading = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          _buildUserInfoWidget(),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Positioned(
      bottom: kToolbarHeight,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                TUICallKitNavigatorObserver.getInstance().navigator?.pop();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/ic_cancel.svg",
                    package: 'tencent_calls_uikit',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    CallI10n.current.cancel,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                if (userInfo == null) {
                  return;
                }
                TUICallKitNavigatorObserver.getInstance().navigator?.pop();
                TUICallKitNavigatorObserver.onNavigateToChatRoom?.call(
                  widget.userId,
                  userInfo!,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/images/ic_send_message.svg",
                    package: 'tencent_calls_uikit',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    CallI10n.current.chat,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () async {
                if (_isCallingLoading) return;
                if (userInfo == null) {
                  return;
                }
                setState(() {
                  _isCallingLoading = true;
                });
                await TUICallKitNavigatorObserver.onCallback?.call(
                  widget.userId,
                  userInfo!,
                  () {
                    setState(() {
                      _isCallingLoading = false;
                    });
                    TUICallKitNavigatorObserver.getInstance().navigator?.pop();
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.only(
                    top: CallI10n.current.locale == "id" ? 22 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: !_isCallingLoading,
                      replacement: Container(
                        height: 60,
                        width: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2BA471),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.2,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      child: SvgPicture.asset(
                        "assets/images/ic_callback.svg",
                        package: 'tencent_calls_uikit',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      CallI10n.current.callback,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBackground() {
    var avatar = '';
    if (userInfo != null) {
      avatar =
          StringStream.makeNull(userInfo?.faceUrl, Constants.defaultAvatar);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          // borderRadius: BorderRadius.circular(8),
          child: Image(
            height: double.infinity,
            width: double.maxFinite,
            image: NetworkImage(avatar),
            fit: BoxFit.cover,
            errorBuilder: (ctx, err, stackTrace) => Image.asset(
              'assets/images/user_icon.png',
              package: 'tencent_calls_uikit',
            ),
          ),
        ),
        Opacity(
          opacity: 1,
          child: Container(
            color: const Color.fromRGBO(45, 45, 45, 0.9),
          ),
        )
      ],
    );
  }

  _buildUserInfoWidget() {
    var showName = '';
    var avatar = '';
    if (userInfo != null) {
      showName = userInfo?.nickName ?? "";
      avatar = StringStream.makeNull(
        userInfo?.faceUrl,
        Constants.defaultAvatar,
      );
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
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              CallI10n.current.didnAnswer,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ));

    return userInfoWidget;
  }
}
