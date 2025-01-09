import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../pages/permission_check.page.dart';
import '../pages/webview.page.dart';

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

  static const List<Permission> _permissions = [
    Permission.camera,
    Permission.microphone,
    Permission.photos,
    Permission.notification,
  ];

  Future<void> requestPermissions() async{
    /*final Map<Permission, PermissionStatus> statuses = await _permissions.request();*/
    for (Permission permission in _permissions) {
      final PermissionStatus status = await permission.request();
      if (!status.isGranted) {
        await openAppSettings();
        break;
      }
    }

    await permissionHandler();
  }

  Future<void> permissionHandler() async{
    bool value = true;
    for(Permission permission in _permissions) {
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