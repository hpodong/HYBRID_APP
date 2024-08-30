import 'dart:async';
import 'package:HYBRID_APP/configs/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/device.controller.dart';
import '../controllers/inapp-web.controller.dart';
import '../controllers/notification.controller.dart';
import '../controllers/overlay.controller.dart';
import '../controllers/version.controller.dart';
import '../customs/custom.dart';
import '../utills/common.dart';
import 'webview.page.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  Timer? _closeTimer;

  bool _canClose = false;

  Future<bool> _onWillPop() async{
    final InAppWebViewController webViewCtr = InAppWebController.of(context).webViewCtr;

    if(await webViewCtr.canGoBack()) {
      await webViewCtr.goBack();
      return false;
    } else {
      _closeTimer?.cancel();
      if(_canClose) return true;
      setState(() => _canClose = true);
      showToast("뒤로가기 버튼을 한번 더 누르면 앱이 종료됩니다.");
      _closeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _canClose = false;
        setState((){});
      });
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
      OverlayController.of(context).showOverlayWidget(context, (context) => _buildSplash(context));
      await NotificationController.of(context).setFcmToken();
      if(mounted) await DeviceController.of(context).getDeviceInfo();
      if(mounted) await VersionController.of(context).getVersion(context);
      permissionCheck([
        Permission.mediaLibrary,
        Permission.photos,
        Permission.camera,
        Permission.microphone,
        Permission.videos,
        Permission.storage,
        Permission.manageExternalStorage,
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer<VersionController>(
          builder: (context, controller, child) {
            if(!controller.isChecked) {
            // if(false) {
              return _buildSplash(context);
            } else {
              return const WebViewPage();
            }
          }
      ),
    );
  }

  Widget _buildSplash(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.splash,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            color: CustomColors.splash,
            image: DecorationImage(
                image: AssetImage(SPLASH_IMAGE),
                fit: BoxFit.cover
            )
        ),
      ),
    );
  }
}
