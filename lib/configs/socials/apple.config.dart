import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleConfig {

  Future<AuthorizationCredentialAppleID?> login() {
    return SignInWithApple.isAvailable().then((isAvailable) {
      if(!isAvailable) return null;
      return SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: 'net.oursoccer',
          redirectUri: Uri.parse('https://oursoccer.net/callback/apple.php'),
        ),
      );
    });
  }
}