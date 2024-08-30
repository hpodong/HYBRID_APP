import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../utills/common.dart';
import '../../utills/enums.dart';

class GoogleConfig {

  final GoogleSignIn _signIn = GoogleSignIn();

  Future<GoogleSignInAccount?> login() async{
    try {
      final GoogleSignInAccount? account = await _signIn.signIn();
      return account;
    } on PlatformException catch (e) {
      log(e, type: LogType.error, error: e);
      return null;
    }
  }

  Future<void> logout() async{
    final GoogleSignInAccount? account = _signIn.currentUser;
    if(account != null) _signIn.signOut();
  }
}