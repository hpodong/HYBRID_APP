import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../configs/config/config.dart';
import '../configs/http.configs/http.config.dart';
import '../repos/version.repo.dart';

final versionProvider = StateNotifierProvider<VersionStateNotifier, bool>((ref) => VersionStateNotifier());

class VersionNotifier extends ChangeNotifier {

  final Ref ref;

  VersionNotifier(this.ref) {
    ref.listen(versionProvider, (prev, next) {
      if(prev != next) notifyListeners();
    });
  }
}

class VersionStateNotifier extends StateNotifier<bool> {
  VersionStateNotifier() : super(false);

  PackageInfo? _info;

  final VersionRepo _repo = VersionRepo();

  String? get version => _info?.version;

  bool get isChecked => state;

  void change(bool state) {
    this.state = state;
  }

  Future<void> versionCheck({
    Function(Response res)? onSuccess,
    Function(int? statusCode, String storeUrl)? onFailed,
  }) async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    _info = info;

    if(VERSION_CHECK) {
      final Response res = await _repo.versionCheck(version: info.version, buildNumber: int.parse(info.buildNumber));
      if(res.statusCode == 200) {
        state = true;
        if(onSuccess != null) onSuccess(res);
      } else {
        final String storeUrl = Platform.isAndroid
            ? "https://play.google.com/store/apps/details?id=${_info?.packageName}"
            : "https://apps.apple.com/app/${_info?.appName}/$APP_STORE_ID";

        if(onFailed != null) onFailed(res.statusCode, storeUrl);
      }
    } else {
      await Future.delayed(const Duration(seconds: 1), (){
        state = !VERSION_CHECK;
      });
    }
  }
}