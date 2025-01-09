import 'package:HYBRID_APP/pages/permission_check.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pages/splash.page.dart';
import '../pages/webview.page.dart';
import '../pages/window_popup.page.dart';
import '../utills/common.dart';
import 'device_provider.dart';
import 'notification_provider.dart';
import 'permission_provider.dart';
import 'version_provider.dart';

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {

  final versionNotifier = VersionNotifier(ref);
  final permissionNotifier = PermissionNotifier(ref);
  DeviceNotifier(ref);
  NotificationNotifier(ref);

  return GoRouter(
      routes: [
        GoRoute(
          path: SplashPage.path,
          name: SplashPage.routeName,
          builder: (_, state) => const SplashPage(),
          routes: [
            GoRoute(
                path: WebViewPage.path,
                name: WebViewPage.routeName,
                pageBuilder: (_, state) => const MaterialPage(child: WebViewPage(), fullscreenDialog: true),
                routes: [
                  GoRoute(
                    path: WindowPopupPage.path,
                    name: WindowPopupPage.routeName,
                    pageBuilder: (_, state) => MaterialPage(child: WindowPopupPage(state.extra as CreateWindowAction), fullscreenDialog: true),
                  )
                ],
            ),
            GoRoute(
                path: PermissionCheckPage.path,
                name: PermissionCheckPage.routeName,
                pageBuilder: (_, state) => const MaterialPage(child: PermissionCheckPage(), fullscreenDialog: true),
            ),
          ]
        ),
      ],
      redirect: versionNotifier.redirectLogic,
      refreshListenable: Listenable.merge([
        versionNotifier,
        permissionNotifier
      ])
  );
});