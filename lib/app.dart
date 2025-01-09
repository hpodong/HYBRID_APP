import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'customs/custom.dart';
import 'providers/router_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      theme: ThemeData(
          scaffoldBackgroundColor: CustomColors.splash
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
