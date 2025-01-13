import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../configs/config/config.dart';
import '../configs/http.configs/http.config.dart';
import '../pages/permission_check.page.dart';
import '../pages/splash.page.dart';
import '../pages/webview.page.dart';
import '../repos/version.repo.dart';
import '../utills/common.dart';
import 'permission_provider.dart';

final versionProvider = StateNotifierProvider<VersionStateNotifier, bool>((ref) => VersionStateNotifier());

class VersionNotifier extends ChangeNotifier {

  final Ref ref;

  VersionNotifier(this.ref) {
    ref.listen(versionProvider, (prev, next) {
      if(prev != next) notifyListeners();
    });
    ref.read(versionProvider.notifier).versionCheck();
  }
}

class VersionStateNotifier extends StateNotifier<bool> {
  VersionStateNotifier() : super(false);

  PackageInfo? _info;

  final VersionRepo _repo = VersionRepo();

  String? get version => _info?.version;

  bool get isChecked => state;

  Future<void> versionCheck({
    Function(Response res)? onSuccess
  }) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    _info = info;

    if(VERSION_CHECK) {
      final Response res = await _repo.versionCheck(version: info.version, buildNumber: int.parse(info.buildNumber));
      if(onSuccess != null) onSuccess(res);
    } else {
      await Future.delayed(const Duration(seconds: 1), (){
        state = !VERSION_CHECK;
      });
    }
  }

  String? _storeURL() {
    return _info?.installerStore;
    /*if(Platform.isIOS) {
      return "https://apps.apple.com/app/${_info?.appName}/$APP_STORE_ID";
    } else {
      return "https://play.google.com/store/apps/details?id=${_info?.packageName}";
    }*/
  }
}