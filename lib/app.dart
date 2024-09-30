import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'controllers/device.controller.dart';
import 'controllers/inapp-web.controller.dart';
import 'controllers/notification.controller.dart';
import 'controllers/overlay.controller.dart';
import 'controllers/version.controller.dart';
import 'customs/custom.dart';
import 'pages/splash.page.dart';
import 'pages/webview.page.dart';

class App extends StatelessWidget {
  App({super.key});

  final Map<String, WidgetBuilder> _routes = <String, WidgetBuilder>{
    WebViewPage.routeName: (context) => const WebViewPage(),
  };

  final List<SingleChildWidget> _providers = <SingleChildWidget>[
    ChangeNotifierProvider(create: (_) => VersionController()),
    ChangeNotifierProvider(create: (_) => NotificationController()),
    ChangeNotifierProvider(create: (_) => DeviceController()),
    ChangeNotifierProvider(create: (_) => OverlayController()),
    ChangeNotifierProvider(create: (_) => InAppWebController()),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MultiProvider(
        providers: _providers,
        child: MaterialApp(
          theme: ThemeData(
              scaffoldBackgroundColor: CustomColors.splash
          ),
          debugShowCheckedModeBanner: false,
          routes: _routes,
          home: const WebViewPage(),
        )
    );
  }
}
