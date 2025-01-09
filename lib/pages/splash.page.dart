import 'package:flutter/material.dart';

import '../configs/config/config.dart';

class SplashPage extends StatelessWidget {
  static const String path = "/";
  static const String routeName = "/splash";

  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image(
        image: AssetImage(SPLASH_IMAGE),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
