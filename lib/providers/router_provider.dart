import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neighborhood/utills/common.dart';

import '../pages/splash.page.dart';
import '../pages/webview.page.dart';
import '../pages/window_popup.page.dart';
import 'device_provider.dart';
import 'notification_provider.dart';
import 'permission_provider.dart';
import 'version_provider.dart';

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {

  final versionNotifier = VersionNotifier(ref);
  final permissionNotifier = PermissionNotifier(ref);
  DeviceNotifier(ref);
  NotificationNotifier(ref);

  String? redirectLogic(BuildContext _, GoRouterState state) {
    if(ref.watch(versionProvider)) return WebViewPage.path;
    return null;
  }

  return GoRouter(
      routes: [
        GoRoute(
            path: SplashPage.path,
            name: SplashPage.routeName,
            builder: (_, state) => const SplashPage(),
            redirect: redirectLogic,
            routes: [
              GoRoute(
                path: WebViewPage.path,
                name: WebViewPage.routeName,
                pageBuilder: (_, state) => const MaterialPage(child: WebViewPage(), fullscreenDialog: true),
                routes: [
                  GoRoute(
                    path: WindowPopupPage.path,
                    name: WindowPopupPage.routeName,
                    pageBuilder: (_, state) {
                      return MaterialPage(child: WindowPopupPage(state.extra as CreateWindowAction), fullscreenDialog: true);
                    },
                  )
                ],
              ),
            ]
        ),
      ],
      refreshListenable: Listenable.merge([
        versionNotifier,
        permissionNotifier
      ])
  );
});