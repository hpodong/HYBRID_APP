import 'dart:convert';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/config.dart';

class AppleConfig {

  static String? getEmail(String? token) {
    if(token == null) return null;
    final List<String> jwt = token.split('.');
    String payload = jwt[1];
    payload = base64.normalize(payload);

    final List<int> jsonData = base64.decode(payload);
    final Map<String, dynamic> userInfo = jsonDecode(utf8.decode(jsonData));
    return userInfo["email"];
  }

  Future<AuthorizationCredentialAppleID?> login() {
    return SignInWithApple.isAvailable().then((isAvailable) {
      if(!isAvailable) return null;
      return SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: APPLE_CLIENT_ID,
          redirectUri: Uri.parse(APPLE_LOGIN_CALLBACK),
        ),
      );
    });
  }
}