import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../config/config.dart';

class AppleConfig {

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