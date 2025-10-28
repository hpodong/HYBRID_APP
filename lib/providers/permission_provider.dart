import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/legacy.dart';


final permissionProvider = StateNotifierProvider<PermissionStateNotifier, bool>((ref) => PermissionStateNotifier());

class PermissionNotifier extends ChangeNotifier {
  final Ref ref;

  PermissionNotifier(this.ref) {
    ref.listen<bool>(permissionProvider, (prev, next) {
      if(prev != next) notifyListeners();
    });
    ref.read(permissionProvider.notifier).permissionHandler(false);
  }
}

class PermissionStateNotifier extends StateNotifier<bool> {
  PermissionStateNotifier() : super(true);

  static const List<Permission> _androidRequestPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
    Permission.notification,
  ];

  static const List<Permission> _iosRequestPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.photos,
    Permission.notification,
  ];

  static const List<Permission> _androidCheckingPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ];

  static const List<Permission> _iosCheckingPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.photos,
  ];

  static List<Permission> get _requestPermissions => Platform.isAndroid ? _androidRequestPermissions : _iosRequestPermissions;
  static List<Permission> get _checkingPermissions => Platform.isAndroid ? _androidCheckingPermissions : _iosCheckingPermissions;

  Future<void> requestPermissions() async{
    for(Permission permission in _requestPermissions) {
      if(permission == Permission.storage && Platform.isAndroid && await _isHigh30SDK()) {
        permission = Permission.manageExternalStorage;
      }
      PermissionStatus status = await permission.status;
      if(!status.isGranted) status = await permission.request();
    }
    await permissionHandler(true);
  }

  Future<void> permissionHandler(bool openSettings) async{
    bool value = true;
    for(Permission permission in _checkingPermissions) {
      if(permission == Permission.storage && Platform.isAndroid && await _isHigh30SDK()) {
        permission = Permission.manageExternalStorage;
      }
      final PermissionStatus status = await permission.status;
      final bool isGranted = status.isGranted;
      if(!isGranted) {
        value = false;
        break;
      }
    }
    if(!value && openSettings) await openAppSettings();
    state = value;
  }

  Future<bool> _isHigh30SDK() async{
    final DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo info = await infoPlugin.androidInfo;
    return info.version.sdkInt >= 32;
  }
}