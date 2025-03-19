import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'customs/custom.dart';
import 'providers/router_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태바 배경색 (흰색으로 설정)
      statusBarIconBrightness: Brightness.dark, // 상태바 아이콘 색상 (dark/light)
    ));
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      theme: ThemeData(
          scaffoldBackgroundColor: CustomColors.splash,
          progressIndicatorTheme: const ProgressIndicatorThemeData(
              color: CustomColors.main
          )
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
