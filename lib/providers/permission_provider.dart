import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utills/common.dart';

final permissionProvider = StateNotifierProvider<PermissionStateNotifier, bool>((ref) => PermissionStateNotifier());

class PermissionNotifier extends ChangeNotifier {
  final Ref ref;

  PermissionNotifier(this.ref) {
    ref.listen<bool>(permissionProvider, (prev, next) {
      if(prev != next) notifyListeners();
    });
    ref.read(permissionProvider.notifier).permissionHandler();
  }
}

class PermissionStateNotifier extends StateNotifier<bool> {
  PermissionStateNotifier() : super(false);

  static const List<Permission> _androidRequestPermissions = [
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse,
    Permission.camera,
    Permission.microphone,
    Permission.mediaLibrary,
    Permission.notification,
  ];

  static const List<Permission> _iosRequestPermissions = [
    Permission.location,
    Permission.locationAlways,
    Permission.locationWhenInUse,
    Permission.camera,
    Permission.microphone,
    Permission.photos,
    Permission.notification,
  ];

  static const List<Permission> _androidCheckingPermissions = [
    Permission.camera, Permission.microphone, Permission.photos
  ];

  static const List<Permission> _iosCheckingPermissions = [
    Permission.camera, Permission.microphone
  ];

  static List<Permission> get _requestPermissions => Platform.isAndroid ? _androidRequestPermissions : _iosRequestPermissions;
  static List<Permission> get _checkingPermissions => Platform.isAndroid ? _androidCheckingPermissions : _iosCheckingPermissions;

  Future<void> requestPermissions() async{
    for(Permission permission in _requestPermissions) {
      PermissionStatus status = await permission.status;
      if(!status.isGranted) status = await permission.request();
    }
    await permissionHandler();
  }

  Future<void> permissionHandler() async{
    bool value = true;
    for(Permission permission in _checkingPermissions) {
      final PermissionStatus status = await permission.status;
      final bool isGranted = status.isGranted;
      if(!isGranted) {
        value = false;
        break;
      }
    }
    state = value;
    if(!state) openAppSettings();
  }
}