import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceController extends ChangeNotifier{

  static DeviceController get instance => DeviceController();
  static DeviceController of(BuildContext context) => context.read<DeviceController>();

  String? _deviceId;
  String? get deviceId => _deviceId;
  set deviceId(String? id){
    _deviceId = id;
    notifyListeners();
  }

  String? _deviceCode;
  String? get deviceCode => _deviceCode;
  set deviceCode(String? code){
    _deviceCode = code;
    notifyListeners();
  }

  String? _deviceType;
  String? get deviceType => _deviceType;
  set deviceType(String? type){
    _deviceType = type;
    notifyListeners();
  }

  Future getDeviceInfo() async{
    final DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      const AndroidId androidId = AndroidId();
      deviceId = await androidId.getId();
      await infoPlugin.androidInfo.then((info) {
        deviceCode = 'ANDROID';
        deviceType = 'PHONE';
      });
    } else {
      await infoPlugin.iosInfo.then((info) {
        deviceId = info.identifierForVendor;
        deviceCode = 'IOS';
        deviceType = 'PHONE';
      });
    }
  }
}