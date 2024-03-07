import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toyou/utills/common.dart';

class GoogleConfig {

  final GoogleSignIn _signIn = GoogleSignIn();

  Future<GoogleSignInAccount?> login() async{
    try {
      final GoogleSignInAccount? account = await _signIn.signIn();
      return account;
    } on PlatformException catch (e) {
      log(e);
    }
  }

  Future<void> logout() async{
    final GoogleSignInAccount? account = _signIn.currentUser;
    if(account != null) _signIn.signOut();
  }
}