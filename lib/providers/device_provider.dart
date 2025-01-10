import 'dart:io';
import '../models/device.dart';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceProvider = StateNotifierProvider((ref) => DeviceStateNotifier());

class DeviceNotifier extends ChangeNotifier{

  final Ref ref;

  DeviceNotifier(this.ref) {
    ref.listen(deviceProvider, (prev, next) {
      if(prev != next) notifyListeners();
    });
  }
}

class DeviceStateNotifier extends StateNotifier<Device?>{
  DeviceStateNotifier(): super(null);

  String? get deviceId => state?.deviceId;

  Future setDeviceInfo() async{
    final DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    if(Platform.isAndroid) {
      const AndroidId androidId = AndroidId();
      final String? id = await androidId.getId();
      if(id != null) state = Device(id, "ANDROID", "PHONE");
    } else {
      final IosDeviceInfo info = await infoPlugin.iosInfo;
      final String? id = info.identifierForVendor;
      if(id != null) state = Device(id, "IOS", "PHONE");
    }
  }
}