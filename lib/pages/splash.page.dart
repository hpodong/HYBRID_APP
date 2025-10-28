import 'dart:io';

import 'package:HYBRID_APP/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../extensions/string_extension.dart';
import '../providers/version_provider.dart';
import '../utills/common.dart';

import '../configs/config/config.dart';
import '../customs/custom.dart';

class SplashPage extends ConsumerStatefulWidget {
  static const String path = "/";
  static const String routeName = "/splash";

  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {

  @override
  void initState() {
    super.initState();
    _versionCheck();
  }

  void _versionCheck() async {
    await ref.read(notificationProvider.notifier).initialFcmToken();
    await ref.read(versionProvider.notifier).versionCheck(
        onFailed: (statusCode, storeUrl) {
          switch(statusCode) {
            case 400: {
              CustomAlert.confirm(context, "새로운 버전", "원활한 서비스를 위해 업데이트를 권장합니다.".insertZwj(), (result) async{
                if(result) {
                  await openURL(storeUrl);
                  exit(0);
                } else {
                  ref.read(versionProvider.notifier).change(true);
                }
              });
            }
            case 401: {
              CustomAlert.alert(context, "업데이트 필요", "서비스를 이용하기 위해 업데이트가 필요합니다.".insertZwj(), () async{
                await openURL(storeUrl);
                exit(0);
              });
            }
            case 500: {
              CustomAlert.alert(context, "서버 점검중", "더 나은 서비스를 위해 현재 서버 점검중입니다".insertZwj(), () => exit(0));
            }
          }
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image(
        image: AssetImage(SPLASH_IMAGE),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
