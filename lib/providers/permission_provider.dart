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

  static const List<Permission> _androidRequiredPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.mediaLibrary,
  ];

  static const List<Permission> _iosRequiredPermissions = [
    Permission.camera,
    Permission.microphone,
    Permission.photos,
  ];

  static const List<Permission> _androidSelectPermissions = [
    Permission.notification,
  ];

  static const List<Permission> _iosSelectPermissions = [
    Permission.notification,
  ];

  static List<Permission> get _requiredPermissions => Platform.isAndroid ? _androidRequiredPermissions : _iosRequiredPermissions;
  static List<Permission> get _selectPermissions => Platform.isAndroid ? _androidSelectPermissions : _iosSelectPermissions;

  Future<void> requestPermissions() async{
    /*final Map<Permission, PermissionStatus> statuses = await _permissions.request();*/
    for (Permission permission in [..._requiredPermissions, ..._selectPermissions]) {
      final PermissionStatus status = await permission.request();
      if (!status.isGranted) {
        log(permission, title: "DISABLED");
        if(_requiredPermissions.contains(permission)) await openAppSettings();
        break;
      }
    }

    await permissionHandler();
  }

  Future<void> permissionHandler() async{
    bool value = true;
    for(Permission permission in _requiredPermissions) {
      final PermissionStatus status = await permission.status;
      final bool isGranted = status.isGranted;
      if(!isGranted) {
        value = false;
        break;
      }
    }
    state = value;
  }
}