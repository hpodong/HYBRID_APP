import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../configs/config/config.dart';
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

  Future<void> getVersion(BuildContext context) async {
    isChecked = true;
    return PackageInfo.fromPlatform().then((info) async{
      this.info = info;
      /*final Response res = await _repo.versionCheck(version: info.version, buildNumber: int.parse(info.buildNumber));
      switch(res.statusCode) {
        case 200:
          switch (res.data?["AV_status"]) {
            case "pass":
              isChecked = true;
              break;
            case "update":
              CustomAlert.alert(context, "버전 업데이트", "업데이트가 필요합니다.", onTap: () {
                openURL(_storeURL(), mode: LaunchMode.externalApplication);
              });
              break;
            case "inspection":
              CustomAlert.alert(context, "버전 업데이트", "서버 점검중입니다.", onTap: () {
                openURL(_storeURL(), mode: LaunchMode.externalApplication);
              });
              break;
            case "warning":
              CustomAlert.confirm(context, "버전 업데이트", "업데이트를 해주세요.", () {
                openURL(_storeURL(), mode: LaunchMode.externalApplication);
              });
              break;
          }
          break;
        case 401:
          CustomAlert.alert(context, "버전 업데이트", "API KEY 값이 없습니다.", onTap: () {
            openURL(_storeURL(), mode: LaunchMode.externalApplication);
          });
          isChecked = false;
          break;
        default:
          isChecked = false;
      }*/
    });
  }

  String _storeURL() {
    if(Platform.isIOS) {
      return "https://apps.apple.com/app/${info?.appName}/$APP_STORE_ID";
    } else {
      return "https://play.google.com/store/apps/details?id=${_info?.packageName}";
    }
  }
}