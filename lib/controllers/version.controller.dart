import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../configs/config/config.dart';
import '../configs/http.configs/http.config.dart';
import '../repos/version.repo.dart';

class VersionController extends ChangeNotifier {

  static VersionController of(BuildContext context) => context.read<VersionController>();
  final VersionRepo _repo = VersionRepo();

  PackageInfo? _info;
  PackageInfo? get info => _info;
  set info(PackageInfo? info) {
    _info = info;
    notifyListeners();
  }

  bool _isChecked = false;
  bool get isChecked => _isChecked;
  set isChecked(bool isChecked) {
    _isChecked = isChecked;
    notifyListeners();
  }

  Future<void> getVersion(BuildContext context, {
    Function(Response res)? onSuccess
  }) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    this.info = info;

    if(VERSION_CHECK) {
      final Response res = await _repo.versionCheck(version: info.version, buildNumber: int.parse(info.buildNumber));
      if(onSuccess != null) onSuccess(res);
    } else {
      await Future.delayed(const Duration(seconds: 2), (){
        isChecked = !VERSION_CHECK;
      });
    }
  }

  String? _storeURL() {
    return info?.installerStore;
    if(Platform.isIOS) {
      return "https://apps.apple.com/app/${info?.appName}/$APP_STORE_ID";
    } else {
      return "https://play.google.com/store/apps/details?id=${_info?.packageName}";
    }
  }
}