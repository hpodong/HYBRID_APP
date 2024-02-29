import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:soccerdiary/repos/version.repo.dart';
import 'package:url_launcher/url_launcher.dart';

import '../configs/config/config.dart';
import '../configs/http.configs/http.config.dart';
import '../customs/custom.dart';
import '../utills/common.dart';

class VersionController extends ChangeNotifier {

  static VersionController of(BuildContext context) => context.read<VersionController>();
  final VersionRepo _repo = VersionRepo();

  PackageInfo? _info;
  PackageInfo? get info => _info;
  set info(PackageInfo? info) {
    debugPrint("VERSION INFO: $info");
    _info = info;
    notifyListeners();
  }

  bool _isChecked = false;
  bool get isChecked => _isChecked;
  set isChecked(bool isChecked) {
    _isChecked = isChecked;
    notifyListeners();
  }

  Future<void> getVersion(BuildContext context) {
    return PackageInfo.fromPlatform().then((info) async{
      this.info = info;
      final Response res = await _repo.versionCheck(version: info.version, buildNumber: int.parse(info.buildNumber));
      switch(res.statusCode) {
        case 200:
          isChecked = true;
          break;
        case 401:
          CustomAlert.alert(context, "버전 업데이트", "업데이트가 필요합니다.", onTap: () {
            openURL(_storeURL(), mode: LaunchMode.externalApplication);
          });
          isChecked = false;
          break;
        case null:
          return getVersion(context);
        default:
          isChecked = false;
      }
    });
  }

  String _storeURL() {
    if(Platform.isIOS) {
      return "https://apps.apple.com/app/${info?.appName}/${Config.instance.APP_STORE_ID}";
    } else {
      return "https://play.google.com/store/apps/details?id=${_info?.packageName}";
    }
  }
}